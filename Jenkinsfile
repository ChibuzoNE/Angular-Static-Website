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

    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Deployment failed!"
        }
    }

}
