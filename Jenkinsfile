pipeline {
    agent any

    environment {
        // Use direct Node.js installation (fallback if plugin not available)
        PATH = "/usr/local/bin:${env.PATH}"
    }

    stages {
        stage('Install Node.js') {
            steps {
                script {
                    // Install Node.js 20.x if not already present
                    sh '''
                        if ! command -v node &> /dev/null; then
                            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
                            sudo apt-get install -y nodejs
                        fi
                        sudo npm install -g @angular/cli
                    '''
                }
            }
        }

        stage('Build Angular App') {
            steps {
                sh '''
                    echo "Node version: $(node --version)"
                    echo "npm version: $(npm --version)"
                    npm install
                    ng build --configuration=production
                    ls -la dist/
                '''
            }
        }

        stage('S3 Upload') {
            steps {
                withAWS(region: 'us-east-2', credentials: 'aws-key') {
                    sh '''
                        echo "Uploading files to S3..."
                        aws s3 cp dist/angular/browser/ s3://cn-jenkins-angular/ --recursive
                        echo "Upload complete!"
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Build and deployment successful!'
        }
        failure {
            echo 'Build or deployment failed!'
        }
    }
}
