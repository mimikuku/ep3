pipeline {
    agent any

    stages {
        stage('test') {
            steps {
                 echo 'Test'
               withMaven(maven: 'maven-3.5.2') {
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
