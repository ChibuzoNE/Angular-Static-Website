pipeline{
    agent any
    

    tools {
        nodejs 'NodeJS-20'
    }

    stages{

        stage('Setup') {
            steps {
                sh 'npm install -g @angular/cli'
            }
        }

        stage('build'){
            steps{
                sh 'install nodejs'
                sh 'npm install'
                sh 'ng build'
                sh 'ls'
                sh 'cd dist && ls'
                sh 'cd dist/angular/browser && ls'
            }
        }
        stage('s3 upload'){
            steps{
                withAWS(region: 'us-east-2', credentials: 'aws-key'){
                    sh 'ls -la'
                    sh 'aws s3 cp dist/angular/browser/. s3://cn-jenkins-angular/ --recursive'
                }
            }
        }
    }
}
