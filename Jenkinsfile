pipeline{
    agent any
    

    environment {
    NODEJS_HOME = tool 'NodeJS-20'  // Must match Jenkins config
    PATH = "${NODEJS_HOME}/bin:${env.PATH}"
}

    stages{

        stage{
            steps{
                sh '''
                    # Install Node.js 20.x and npm
                    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
                    sudo apt-get install -y nodejs
                    
                    # Verify installation
                    echo "Node version: $(node --version)"
                    echo "npm version: $(npm --version)"
                    
                    # Install Angular CLI
                    sudo npm install -g @angular/cli
                '''
            }
        }
        stage('build'){
            steps{
                sh 'install npm nodejs'
                sh 'ng build'
                sh 'ls'
                sh 'cd dist'
                sh 'cd dist/temp-app/browser && ls'
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
}
