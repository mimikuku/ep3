#!groovy

def workdir = "build"

node(){
    stage('test'){
        sh "export"
        dir(workdir) {
            deleteDir()
        }
    }
    stage('get source') {
        dir('sources') {
            checkout scm
        }

    }
    stage('run tests') {
        dir('sources') {
            withMaven(maven: 'maven') {
                sh 'mvn clean test'
            }

        }
    }
    stage('build package') {
        dir('sources') {
            withMaven(maven: 'maven') {
                sh 'mvn package -Dmaven.test.skip=true'
            }
            sh 'mkdir -f proc && cp message-processor/target/message-processor-1.0-SNAPSHOT.jar proc/'
            sh 'cp conf art/config.properties'
            sh 'mkdir -f gate && cp message-gateway/target/message-gateway-1.0-SNAPSHOT.war gate/'	
        }
        dir('sources/proc') {
            sh 'docker build -t mess-processor .'
        }
        dir('sources/gate') {
            sh 'docker build -t mess-gateway .'
        }
    }
    stage('save artifact') {

    }
    stage('deploy to env') {

    }
    stage('provision env') {

    }
    stage('integration test') {

    }
    stage('send report') {

    }
}
