pipeline { 
    agent any

    tools {
        nodejs 'NodeJS-20'
    }

    environment {
        AWS_REGION = 'us-east-2'
        AWS_CLI_HOME = "${WORKSPACE}/aws-cli"
        PATH = "${AWS_CLI_HOME}/bin:${env.PATH}"
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
                        aws configure set region "$AWS_REGION"
                        aws s3 cp dist/temp-app/browser/ s3://cn-jenkins-angular/ --recursive
                        echo "Deployment complete!"
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
