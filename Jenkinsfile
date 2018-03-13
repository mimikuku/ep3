#!groovy
import groovy.json.JsonSlurper
import groovy.json.JsonOutput

def binNumber
def binHost = 'http://requestbin.fullcontact.com'
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
                withDockerServer([uri: 'tcp://127.0.0.1:2376']) {
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
    stage('Create bin') {
        echo 'Going to create bin'
        def rbin = httpRequest(
                consoleLogResponseBody: true,
                httpMode: 'POST',
                url: "${binHost}/api/v1/bins"
        )

        def json = new JsonSlurper().parseText(rbin.getContent())

        binNumber = json.name.toString()
        println binNumber
    }
    stage('Send message to bin') {
        echo 'Print bin info'

        def json200 = JsonOutput.toJson(
                [
                        messageId: 3,
                        timestamp: 3234,
                        protocolVersion: '2.0.0',
                        payload: [
                                mMX: 1234,
                                mPermGen: 5678,
                                mOldGen: 22222,
                                mYoungGen: 333333]
                ])

        def resp = httpRequest(
                consoleLogResponseBody: true,
                httpMode: 'POST',
                url: "${binHost}/${binNumber}",
                requestBody: json200
        )
        println binNumber
    }
    stage('Send test message') {
        echo 'Going to send test message'
        println "${binHost}/${binNumber}?inspect"
    }
}
