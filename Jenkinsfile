#!groovy

import groovy.json.JsonSlurper
import groovy.json.JsonOutput

def reqBinHost = 'http://requestbin.fullcontact.com'

node() {
    stage('initial') {
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
                sh 'echo "Testing with Maven..." > overall.log'
                sh 'mvn clean test >> overall.log'
            }

        }
    }
    stage('build package') {
        dir('sources') {
            withMaven(maven: 'maven') {
                sh 'echo "Building project..." >> overall.log'
                sh 'mvn package -Dmaven.test.skip=true >> overall.log'
            }
            sh 'mkdir proc || exit 0'
            sh 'cp message-processor/target/message-processor-1.0-SNAPSHOT.jar proc/processor.jar'
            sh 'cp conf proc/config.properties'
        }
    }
    stage('build and save images') {
        dir('sources/proc') {
            sh 'echo "Building processor image..." >> overall.log'
            sh 'cp ../Dockerfile.proc Dockerfile && docker build -t mess-processor . >> overall.log'
        }
        dir('sources/gate') {
            sh 'echo "Building gateway image..." >> overall.log'
            sh 'cp ../Dockerfile.gate Dockerfile && docker build -t mess-gateway . >> overall.log'
        }
        withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'pass', usernameVariable: 'user')]) {
            sh "docker login -u${user} -p${pass}"
        }
        sh 'docker tag mess-gateway pietarista/gate:1.0'
        sh 'docker tag mess-processor pietarista/proc:1.0'
        sh 'echo "Pushing images to registry..." >> overall.log'
        sh "docker push pietarista/gate:1.0 >> overall.log"
        sh "docker push pietarista/proc:1.0 >> overall.log"
    }
    stage('deploy to env') {
        sh 'echo "Running containers..." >> overall.log'
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
        sh 'echo "Sending requests..." >> overall.log'
        def req = ['curl http://gate:8080/message -v -X POST -d \'{"messageId":1, "timestamp":1234, "protocolVersion":"1.0.0", "messageData":{"mMX":1234, "mPermGen":1234}}\' | tee overall.log',
                   'curl http://gate:8080/message -v -X POST -d \'{"messageId":2, "timestamp":2234, "protocolVersion":"1.0.1", "messageData":{"mMX":1234, "mPermGen":5678, "mOldGen":22222}}\' | tee overall.log',
                   'curl http://gate:8080/message -v -X POST -d \'{"messageId":3, "timestamp":3234, "protocolVersion":"2.0.0", "payload":{"mMX":1234, "mPermGen":5678, "mOldGen":22222, "mYoungGen":333333}}\' | tee overall.log']
        for (i=0; i<3; i++) {
            sh req[i]
            sleep 2
            out = sh(returnStdout: true, script: 'docker logs --tail 1 proc')
            httpRequest(consoleLogResponseBody: true,
                    httpMode: 'POST',
                    url: "${reqBinHost}/${binNumber}",
                    requestBody: 'Test 1: ' + out.toString())
        }
    }
    stage('send report') {
        sh 'echo "Link to reqbin: ${reqBinHost}/${binNumber}?inspect" | tee overall.log'
    }
    stage('cleanup') {
        sh 'docker stop rabbit || exit 0'
        sh 'docker rm rabbit || exit 0'
        sh 'docker stop proc || exit 0'
        sh 'docker rm proc || exit 0'
        sh 'docker stop gate || exit 0'
        sh 'docker rm gate || exit 0'
    }
    post {
        zip archive: true, zipFile: "overall_log.zip", dir: "sources", glob: "overall.log"
    }
}

