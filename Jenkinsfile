pipeline {
    agent any

    tools {
        nodejs 'NodeJS-20'
    }

    environment {
        S3_BUCKET = 'cn-jenkins-angular'
        AWS_REGION = 'us-east-2'
        VERSION = "v${env.BUILD_NUMBER}"
    }

    stages {
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
                    // Filter only directories inside dist/
                    def distDir = sh(
                        script: "find dist -mindepth 1 -maxdepth 1 -type d | head -n 1",
                        returnStdout: true
                    ).trim()

                    if (!distDir || distDir == "") {
                        error "ERROR: Could not find a valid build directory inside dist/"
                    }

                    def artifactName = "angular_app-${VERSION}.tar.gz"
                    env.ARTIFACT_NAME = artifactName
                    env.DIST_DIR = distDir

                    echo "Using dist directory: ${distDir}"

                    // Create the artifact from that folder
                    sh "tar -czf ${artifactName} -C ${distDir} ."
                }
            }
        }

        stage('Upload to S3') {
            steps {
                withAWS(credentials: 'aws-key', region: "${AWS_REGION}") {
                    s3Upload(
                        file: "${ARTIFACT_NAME}",
                        bucket: "${S3_BUCKET}", 
                        path: "artifacts/"
                    )
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                sh '''
                ansible-playbook -i hosts.ini angular-app.yml --extra-vars "artifact_version=${VERSION}"
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