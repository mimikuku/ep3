pipeline {
    agent any

    stages {
        stage('Download') {
            steps {
                 echo 'Downloading'
                 git branch: 'origin/akuplensky', credentialsId: 'test_jenkins_git', url: 'git@gitlab.com:nikolyabb/epam-devops-3rd-stream.git'
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
