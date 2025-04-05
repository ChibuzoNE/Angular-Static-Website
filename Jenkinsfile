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
                            "${AWS_CLI_HOME}/aws/install" \
                                --bin-dir "${AWS_CLI_HOME}/bin" \
                                --install-dir "${AWS_CLI_HOME}/aws-cli" \
                                --update
                        else
                            echo 'Error: AWS CLI installer not found after extraction!'
                            exit 1
                        fi

                        rm -f "${AWS_CLI_HOME}/awscliv2.zip"
                        aws --version || exit 1
                    fi
                '''
            }
        }

        stage('S3 Upload') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
                        aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
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
