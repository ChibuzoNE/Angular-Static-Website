pipeline {
    agent any

    environment {
        S3_BUCKET = 'cn-jenkins-angular'
        AWS_REGION = 'us-east-2' // e.g., us-east-1
        VERSION = "v${env.BUILD_NUMBER}"
    }

    stages{
        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build Angular App') {
            steps {
                sh 'ng build --configuration=production'
            }
        }

        stage('Create Artifact') {
            steps {
                script {
                    def ARTIFACT_NAME = "angular_app-${VERSION}.tar.gz"  // Use VERSION here for consistency
                    sh "tar -czf ${ARTIFACT_NAME} -C dist/angular_app ."
                }
            }
        }

        stage('Upload to S3') {
            steps {
                withAWS(credentials: 'aws-jenkins-credentials', region: "${AWS_REGION}") {
                    s3Upload(
                        file: "angular_app-${VERSION}.tar.gz",  // Use the same name as created earlier
                        bucket: "${S3_BUCKET}", 
                        path: "artifacts/")
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                sh '''
                ansible-playbook -i hosts.ini angular-app.yml --extra-vars "artifact_version=$VERSION"
                '''
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
