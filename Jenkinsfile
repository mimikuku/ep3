pipeline {
    agent any

    stages {
        stage('Download') {
            steps {
                 echo 'Downloading'
                 git branch: '*/akuplensky', credentialsId: '5e5051dc-e4eb-4113-a221-3ba96870ad6a', url: 'git@gitlab.com:nikolyabb/epam-devops-3rd-stream.git'
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
