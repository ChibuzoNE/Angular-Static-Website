pipeline{
    agent any
    stages{
        stage('build'){
            steps{
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
