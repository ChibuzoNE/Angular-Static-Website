pipeline {
    agent any

    tools {
        nodejs 'NodeJS-20'  // Must match the name in Jenkins Global Tools
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
