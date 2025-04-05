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
                    # Install AWS CLI locally in workspace
                    if ! command -v aws &> /dev/null; then
                        echo "Installing AWS CLI..."
                        mkdir -p "${AWS_CLI_HOME}"
                        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "${AWS_CLI_HOME}/awscliv2.zip"
                        
                        # Extract using Python with proper permissions (single line command)
                        python3 -c "import zipfile, os; with zipfile.ZipFile('${AWS_CLI_HOME}/awscliv2.zip', 'r') as zip_ref: [zip_ref.extract(member, '${AWS_CLI_HOME}') for member in zip_ref.infolist()]"
                        
                        # Set execute permissions and install
                        if [ -f "${AWS_CLI_HOME}/aws/install" ]; then
                            chmod +x "${AWS_CLI_HOME}/aws/install"
                            "${AWS_CLI_HOME}/aws/install" \
                                --bin-dir "${AWS_CLI_HOME}/bin" \
                                --install-dir "${AWS_CLI_HOME}/aws-cli" \
                                --update
                        else
                            echo "Error: AWS CLI installer not found after extraction!"
                            exit 1
                        fi
                        
                        # Clean up
                        rm -f "${AWS_CLI_HOME}/awscliv2.zip"
                        
                        # Verify installation
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
                        # Configure AWS credentials
                        aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
                        aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
                        aws configure set region "$AWS_REGION"

                        # Upload to S3
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