#!groovy
import groovy.json.JsonSlurper


def workdir = "dir1"

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
            docker.withTool('docker') {
                withDockerServer([uri: 'tcp://192.168.36.1:4243']) {
                    sh 'docker ps'
                }
            }
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
        echo 'Going to create bin'
        def createBody = """
{
  "status": 200,
  "statusText": "OK",
  "httpVersion": "HTTP/1.1",
  "headers": [],
  "cookies": [],
  "content": {
    "mimeType": "text/plain",
    "text": ""
  }
}
        """
        def response = httpRequest(
                httpMode: 'POST',
                url: 'http://mockbin.org/bin/create',
                validResponseCodes: '100:299',
                requestBody: createBody.toString()
        )
        println "-----------------------"
        println response.content.toString()

        println "-----------------------"
        def jsonSlrpBody = new JsonSlurper().parseText(response.content)
        println jsonSlrpBody.toString()

        println "-----------------------"
        def jsonSlrpHeaders = response.headers
        println jsonSlrpHeaders

    }
}