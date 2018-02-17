#!groovy

import groovy.json.JsonSlurper
import groovy.json.JsonOutput

def reqBinHost = 'http://requestbin.fullcontact.com'

node() {
    stage('test') {
        sh "export"
        sh 'docker stop rabbit || exit 0'
        sh 'docker rm rabbit || exit 0'
        sh 'docker stop proc || exit 0'
        sh 'docker rm proc || exit 0'
        sh 'docker stop gate || exit 0'
        sh 'docker rm gate || exit 0'
    }
    stage('get source') {
        dir('sources') {
            checkout scm
        }
        dir('sources/gate') {
            sh 'cp -r ../message-gateway/* .'
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
            sh 'mkdir proc || exit 0'
            sh 'cp message-processor/target/message-processor-1.0-SNAPSHOT.jar proc/processor.jar'
            sh 'cp conf proc/config.properties'
        }
    }
    stage('save artifact') {
        dir('sources/proc') {
            sh 'cp ../Dockerfile.proc Dockerfile && docker build -t mess-processor .'
        }
        dir('sources/gate') {
            sh 'cp ../Dockerfile.gate Dockerfile && docker build -t mess-gateway .'
        }
        withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'pass', usernameVariable: 'user')]) {
            sh "docker login -u${user} -p${pass}"
        }
        sh 'docker tag mess-gateway pietarista/gate:1.0'
        sh 'docker tag mess-processor pietarista/proc:1.0'
        sh "docker push pietarista/gate:1.0"
        sh "docker push pietarista/proc:1.0"
    }
    stage('deploy to env') {
        sh 'docker run -it -d --name rabbit --network="custom1" library/rabbitmq:3'
        sleep 30
        sh 'docker run -it -d --name proc --network="custom1" pietarista/proc:1.0'
        sh 'docker run -it -d --name gate --network="custom1" pietarista/gate:1.0'
        sleep 30
    }
    stage('create requestbin') {
        def reqBin = httpRequest(consoleLogResponseBody: true,
                                 httpMode: 'POST',
                                 url: "${reqBinHost}/api/v1/bins")
        def json = new JsonSlurper().parseText(reqBin.getContent())
        binNumber = json.name.toString()
        println binNumber
    }
    stage('integration test') {
        def req1 = 'curl http://gate:8080/message -X POST -d \'{"messageId":1, "timestamp":1234, "protocolVersion":"1.0.0", "messageData":{"mMX":1234, "mPermGen":1234}}\''
        sh req1
        sleep 2
        out1 = sh(returnStdout: true, script: 'docker logs --tail 1 proc')
        httpRequest(consoleLogResponseBody: true,
                    httpMode: 'POST',
                    url: "${reqBinHost}/${binNumber}",
                    requestBody: 'Test 1: ' + out1.toString())
        def req2 = 'curl http://gate:8080/message -X POST -d \'{"messageId":2, "timestamp":2234, "protocolVersion":"1.0.1", "messageData":{"mMX":1234, "mPermGen":5678, "mOldGen":22222}}\''
        sh req2
        sleep 2
        out2 = sh(returnStdout: true, script: 'docker logs --tail 1 proc')
        httpRequest(consoleLogResponseBody: true,
                    httpMode: 'POST',
                    url: "${reqBinHost}/${binNumber}",
                    requestBody: 'Test 2: ' + out2.toString())
        def req3 = 'curl http://gate:8080/message -X POST -d \'{"messageId":3, "timestamp":3234, "protocolVersion":"2.0.0", "payload":{"mMX":1234, "mPermGen":5678, "mOldGen":22222, "mYoungGen":333333}\''
        sh req3
        sleep 2
        out3 = sh(returnStdout: true, script: 'docker logs --tail 1 proc')
        httpRequest(consoleLogResponseBody: true,
                    httpMode: 'POST',
                    url: "${reqBinHost}/${binNumber}",
                    requestBody: 'Test 3: ' + out3.toString())
    }
    stage('send report') {
        echo "Link to reqbin: ${reqBinHost}/${binNumber}?inspect"
    }
    stage('cleanup') {
        sh 'docker stop rabbit || exit 0'
        sh 'docker rm rabbit || exit 0'
        sh 'docker stop proc || exit 0'
        sh 'docker rm proc || exit 0'
        sh 'docker stop gate || exit 0'
        sh 'docker rm gate || exit 0'
    }
}
