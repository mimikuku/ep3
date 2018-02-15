import groovy.json.JsonSlurper

def DOCKER_CON_URI = 'tcp://docker.for.win.localhost:2375'
def MESSAGE_GATEWAY_SERVER_FOR_TEST = 'http://172.17.0.1:8088/message'

def TEST_STRING_1 = '"messageId":1, "timestamp":1234, "protocolVersion":"1.0.0", "messageData":{"mMX":1234, "mPermGen":1234}'
def TEST_STRING_2 = '"messageId":2, "timestamp":2234, "protocolVersion":"1.0.1", "messageData":{"mMX":1234, "mPermGen":5678, "mOldGen":22222}'
def TEST_STRING_3 = '"messageId":3, "timestamp":3234, "protocolVersion":"2.0.0", "payload":{"mMX":1234, "mPermGen":5678, "mOldGen":22222, "mYoungGen":333333}'

def resultOfTests = ""

def gateway="gateway"
def processor="processor"

node(){
    stage('test'){
        deleteDir()
        
        sh "export"
        docker.withTool('docker') {
            withDockerServer([uri: DOCKER_CON_URI]) {
                sh 'docker ps'
            }
        }
    }
    stage('get source') {
        git branch: 'slysikov', credentialsId: 'a4aaa3b8-a6eb-467d-9c7b-165308891f1e', url: 'git@gitlab.com:nikolyabb/epam-devops-3rd-stream.git'
    }
    stage('run tests') {
        withMaven(maven: 'mvn') {
                sh 'mvn clean test'
        }
    }
    stage('build package') {
        withMaven(maven: 'mvn') {
                sh 'mvn package -Dmaven.test.skip=true'
        }
        dir(gateway) {
            sh 'cp -R $WORKSPACE/message-gateway/* .'
                
            writeFile file: 'Dockerfile', text: '''FROM maven
                COPY . /opt/gateway/
                WORKDIR /opt/gateway/
                ENTRYPOINT ["mvn"]
                CMD ["tomcat7:run"]'''
                    
            docker.withTool('docker'){
    			withDockerServer([uri: DOCKER_CON_URI]) {
                    sh 'docker build -t gateway:$BUILD_NUMBER .'
    				sh 'docker tag gateway:$BUILD_NUMBER barloc/gateway:$BUILD_NUMBER'
                    }
    	    }
        }
        dir(processor) {
            sh 'cp $(find $WORKSPACE -name "message-processor-1.0-SNAPSHOT.jar") .'
    		sh 'cp $(find $WORKSPACE -name "config.properties") .'
    		    
    		writeFile file: 'Dockerfile', text: '''FROM java:8
                COPY . /opt/processor/
                WORKDIR /opt/processor/
                ENTRYPOINT ["java"]
                CMD ["-jar","message-processor-1.0-SNAPSHOT.jar","config.properties"]'''
                    
            docker.withTool('docker'){
    		    withDockerServer([uri: DOCKER_CON_URI]) {
                    sh 'docker build -t processor:$BUILD_NUMBER .'
    				sh 'docker tag processor:$BUILD_NUMBER barloc/processor:$BUILD_NUMBER'
                }
            }
        }
    }
    stage('save artifact') {
        docker.withTool('docker'){
            withDockerRegistry([credentialsId: 'dockerhub', url: 'https://index.docker.io/v1/']) {
                withDockerServer([uri: DOCKER_CON_URI]) {
                    sh 'docker push barloc/processor:$BUILD_NUMBER'
                    sh 'docker push barloc/gateway:$BUILD_NUMBER'
                }
            }
        }
    }
    stage('deploy to env') {
        docker.withTool('docker'){
            withDockerServer([uri: DOCKER_CON_URI]) {
                sh 'docker rm --force message-gateway || true'
                sh 'docker rm --force message-processor || true'
                sh 'docker rm --force rabbitmq || true'
                
                sh 'docker network rm devops-network || true'
                sh 'docker network create -d bridge devops-network'
                
                sh 'docker run -d --network=devops-network --name rabbitmq rabbitmq'
                sleep 30
                sh 'docker run -d --network=devops-network --name message-gateway -p 8088:8080 barloc/gateway:$BUILD_NUMBER'
                sh 'docker run -d --network=devops-network --name message-processor barloc/processor:$BUILD_NUMBER'
            }
        }
    }
    stage('integration test') {
        sleep 90
        
        def result = "apiv1="
        
        result += verifyViaTestString(TEST_STRING_1, MESSAGE_GATEWAY_SERVER_FOR_TEST, DOCKER_CON_URI) + "&apiv2="
        result += verifyViaTestString(TEST_STRING_2, MESSAGE_GATEWAY_SERVER_FOR_TEST, DOCKER_CON_URI) + "&apiv3="
        result += verifyViaTestString(TEST_STRING_1, MESSAGE_GATEWAY_SERVER_FOR_TEST, DOCKER_CON_URI)
        
        resultOfTests = result
    }
    stage('send report') {
        def responsebin= httpRequest(
            httpMode: 'POST',
            url: 'http://requestbin.fullcontact.com/api/v1/bins',
            validResponseCodes: '200' )
        def bucketID = new JsonSlurper().parseText(responsebin.content)
        reportbucket = bucketID.name
        def urls = 'http://requestbin.fullcontact.com/' + reportbucket
        httpRequest(
            httpMode: 'POST',
            url: urls,
            validResponseCodes: '200',
            responseHandle: 'NONE',
            contentType: 'APPLICATION_FORM',
            requestBody: resultOfTests )
        println "http://requestbin.fullcontact.com/$reportbucket?inspect"
        println report
    }
}

def verifyViaTestString(queryString, serverURI, dockerConURI) {
    def response = httpRequest(
        httpMode: 'POST', 
        requestBody: "{"+queryString+"}", 
        responseHandle: 'NONE', 
        url: serverURI )
    sleep 1
    withDockerServer([uri: dockerConURI]) {
        outString = sh 'docker logs --tail 1 message-processor'
        readyString = outString.trim()
        if (readyString == queryString) {
            testResult = "ok"
        } else {
            testResult = "fail"
        }
    return testResult
    }
}