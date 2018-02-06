pipeline {
    agent any

    stages {
        stage('test') {
            steps {
                 echo 'Test'
               withMaven(maven: 'maven') {
                sh "mvn -X clean test"
               }
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
