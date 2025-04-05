pipeline {
    agent any

    stages {
        stage('Install Node.js') {
            steps {
                sh '''
                    # Install Node.js 20.x if not present
                    if ! command -v node &> /dev/null; then
                        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
                        sudo apt-get install -y nodejs
                    fi
                    sudo npm install -g @angular/cli
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

        stage('s3 upload'){
            steps{
                withAWS(region: 'us-east-2', credentials: 'aws-key'){
                    sh 'ls -la'
                    sh 'aws s3 cp dist/temp-app/browser/. s3://cn-jenkins-angular/ --recursive'
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
