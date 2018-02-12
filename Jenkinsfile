#!groovy

def workdir = "build"

node(){
    stage('test'){
        sh "export"
        dir(workdir) {
            deleteDir()
        }
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
            sh 'cp -r message-gateway/* gate/'
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
        sleep 15
        sh 'docker run -it -d --name proc --network="custom1" pietarista/proc:1.0'
        sh 'docker run -it -d --name gate --network="custom1" pietarista/gate:1.0'
    }
    stage('provision env') {

    }
    stage('integration test') {
//        sh 'curl http://gate:8080/message -X POST -d \'{"messageId":1, "timestamp":1234, "protocolVersion":"1.0.0", "messageData":{"mMX":1234, "mPermGen":1234}}\''
        def response = httpRequest contentType: 'APPLICATION_JSON', httpMode: 'POST', requestBody: '{"messageId":1, "timestamp":1234, "protocolVersion":"1.0.0", "messageData":{"mMX":1234, "mPermGen":1234}}', url: "http://gate:8080/message", validResponseCodes: '200'
        println response.content
    }
    stage('send report') {

    }
}
