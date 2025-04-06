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
                    // Detect correct dist folder dynamically
                    def distDir = sh(script: "ls dist", returnStdout: true).trim()
                    def artifactName = "angular_app-${VERSION}.tar.gz"
                    env.ARTIFACT_NAME = artifactName
                    env.DIST_DIR = distDir

                    // Log detected folder
                    echo "Using dist directory: dist/${distDir}"

                    // Check that it exists
                    sh """
                        if [ ! -d "dist/${distDir}" ]; then
                          echo "ERROR: dist/${distDir} not found"
                          exit 1
                        fi
                    """

                    // Create the artifact
                    sh "tar -czf ${artifactName} -C dist/${distDir} ."
                }
            }
        }

        stage('Upload to S3') {
            steps {
                withAWS(credentials: 'aws-jenkins-credentials', region: "${AWS_REGION}") {
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
