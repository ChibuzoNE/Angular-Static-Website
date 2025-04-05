pipeline {
    agent any

    tools {
        nodejs 'NodeJS-20'
    }

    environment {
        AWS_REGION = 'us-east-2'
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

        stage('Install AWS CLI') {
            steps {
                sh '''
                    # Install AWS CLI using bundled installer (no unzip required)
                    if ! command -v aws &> /dev/null; then
                        echo "Installing AWS CLI..."
                        # Download the AWS CLI install script
                        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                        
                        # Use Python to extract (no unzip needed)
                        python3 -m zipfile -e awscliv2.zip .
                        
                        # Install AWS CLI
                        sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli
                        
                        # Clean up
                        rm -rf awscliv2.zip aws/
                        
                        # Verify installation
                        aws --version
                    fi
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