pipeline {
    agent any

    stages {
        stage('Download') {
            steps {
                 echo 'Downloading'
                 git branch: 'origin/akuplensky', credentialsId: 'lexa500-git', url: 'git@gitlab.com:nikolyabb/epam-devops-3rd-stream.git'
            }
        }       
        stage('Build') {
            steps {
                echo 'Building..'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
