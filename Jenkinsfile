pipeline {
    agent any

    tools {
        nodejs 'NodeJS-20'
    }

    environment {
        AWS_REGION = 'us-east-2'
        AWS_CLI_HOME = "${WORKSPACE}/aws-cli"
        PATH = "${AWS_CLI_HOME}/bin:${env.PATH}"
        VERSION = "v${env.BUILD_NUMBER}"
        ANSIBLE_VAULT_PASSWORD = credentials('ansible-vault-secret')
    }

    stages {
        stage('Verify Node.js') {
            steps {
                sh '''
                    node --version
                    npm --version
                '''
            }
        }

        stage('Build') {
            steps {
                sh '''
                    npm install
                    ng build --configuration=production
                    ls -la dist/
                '''
            }
        }

        stage('Install AWS CLI') {
            steps {
                sh '''
                    if ! command -v aws &> /dev/null; then
                        echo "Installing AWS CLI using Python (no unzip required)..."
                        mkdir -p "${AWS_CLI_HOME}"
                        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "${AWS_CLI_HOME}/awscliv2.zip"

                        # Use Python to unzip (avoids need for unzip binary)
                        python3 -c "import zipfile; zipfile.ZipFile('${AWS_CLI_HOME}/awscliv2.zip').extractall('${AWS_CLI_HOME}')"

                        if [ -f "${AWS_CLI_HOME}/aws/install" ]; then
                            chmod +x "${AWS_CLI_HOME}/aws/install"
                            # Set execute permissions for the AWS CLI binary
                            chmod +x "${AWS_CLI_HOME}/bin/aws"
                            "${AWS_CLI_HOME}/aws/install" \
                                --bin-dir "${AWS_CLI_HOME}/bin" \
                                --install-dir "${AWS_CLI_HOME}/aws-cli" \
                                --update
                        else
                            echo 'Error: AWS CLI installer not found after extraction!'
                            exit 1
                        fi

                        rm -f "${AWS_CLI_HOME}/awscliv2.zip"
                        # Ensure correct permissions and check if AWS CLI works
                        chmod +x "${AWS_CLI_HOME}/bin/aws"  # Reapply just in case
                        aws --version || exit 1
                    fi
                '''
            }
        }

        stage('S3 Upload') {
            steps {
                withAWS(credentials: 'aws-key') {
                    sh '''
                        sudo yum install -y zip
                        aws configure set region "$AWS_REGION"
                        aws s3 cp dist/temp-app/browser/ s3://cn-jenkins-angular/ --recursive
                        # Set dynamic version (e.g., using Jenkins BUILD_NUMBER or timestamp)
                        VERSION="v1.0.${BUILD_NUMBER}"  # or use `VERSION=$(date +%Y%m%d%H%M%S)` for timestamp

                        # Define ZIP and S3 path
                        ZIP_FILE="angular-app-${VERSION}.zip"
                        ZIP_PATH="dist/$ZIP_FILE"
                        S3_DEST="s3://cn-jenkins-angular/artifacts/$ZIP_FILE"

                        # Zip the Angular build
                        cd dist/temp-app/browser && zip -r "../../$ZIP_FILE" . && cd -

                        # Upload the ZIP to S3
                        aws s3 cp "$ZIP_PATH" "$S3_DEST"

                        echo "Deployment complete!"
                    '''
                }
            }
        }

        stage('Deploy with Ansible') {
        steps {
            sshagent(credentials: ['ansible_ssh_key']) {
                sh """
                    ssh -o StrictHostKeyChecking=no ec2-user@172.31.20.58 \\
                    'echo "${ANSIBLE_VAULT_PASSWORD}" > .vault_pass && \\
                    chmod 600 .vault_pass && \\
                    ansible-playbook -i /home/ec2-user/Angular-Static-Website/hosts.ini \\
                                    /home/ec2-user/Angular-Static-Website/angular-app.yml \\
                                    --extra-vars artifact_version=${ARTIFACT_VERSION} \\
                                    --vault-password-file .vault_pass && \\
                    rm -f .vault_pass'
                """
            }
    }

        }
    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Deployment failed.!"
        }
    }
}
