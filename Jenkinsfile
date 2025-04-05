pipeline{
    agent any
    

    environment {
    NODEJS_HOME = tool 'NodeJS-20'  // Must match Jenkins config
    PATH = "${NODEJS_HOME}/bin:${env.PATH}"
}

    stages{
        stage('build'){
            steps{
                sh 'install nodejs npm'
                //sh 'npm install'
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
