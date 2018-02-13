def workdir="project"
def gateway="gateway"
def processor="processor"

node(){
    stage('test'){
        dir(workdir) {
            deleteDir()
        }
        sh "export"
        docker.withTool('docker') {
            withDockerServer([uri: 'tcp://docker.for.win.localhost:2375']) {
                sh 'docker ps'
            }
        }
    }
    stage('get source') {
        dir(workdir) {
            git branch: 'slysikov', credentialsId: 'a4aaa3b8-a6eb-467d-9c7b-165308891f1e', url: 'git@gitlab.com:nikolyabb/epam-devops-3rd-stream.git'
        }
    }
    stage('run tests') {
        dir(workdir) {
            withMaven(maven: 'mvn') {
                sh 'mvn clean test'
            }
        }
    }
    stage('build package') {
        dir(workdir) {
            withMaven(maven: 'mvn') {
                sh 'mvn package -Dmaven.test.skip=true'
            }
        }
        dir(gateway) {
            sh 'cp -R $WORKSPACE/project/message-gateway/* .'
            
            writeFile file: 'Dockerfile', text: '''FROM maven
                COPY . /opt/gateway/
                WORKDIR /opt/gateway/
                ENTRYPOINT ["mvn"]
                CMD ["tomcat7:run"]'''
                
            docker.withTool('docker'){
			    withDockerServer([uri: 'tcp://docker.for.win.localhost:2375']) {
                    sh 'docker build -t gateway:$BUILD_NUMBER .'
					sh 'docker tag gateway:$BUILD_NUMBER barloc/gateway:$BUILD_NUMBER'
	            }
	        }
        }
        dir(processor) {
                sh 'cp $(find $WORKSPACE/project -name "message-processor-1.0-SNAPSHOT.jar") .'
		        sh 'cp $(find $WORKSPACE/project -name "config.properties") .'
		    
		    writeFile file: 'Dockerfile', text: '''FROM java:8
                COPY . /opt/processor/
                WORKDIR /opt/processor/
                ENTRYPOINT ["java"]
                CMD ["-jar","message-processor-1.0-SNAPSHOT.jar","config.properties"]'''
                
            docker.withTool('docker'){
			    withDockerServer([uri: 'tcp://docker.for.win.localhost:2375']) {
                    sh 'docker build -t processor:$BUILD_NUMBER .'
					sh 'docker tag processor:$BUILD_NUMBER barloc/processor:$BUILD_NUMBER'
	            }
	        }
        }
    }
    
    stage('save artifact') {
        docker.withTool('docker'){
            withDockerRegistry([credentialsId: 'dockerhub', url: 'https://index.docker.io/v1/']) {
                withDockerServer([uri: 'tcp://docker.for.win.localhost:2375']) {
                    sh 'docker push barloc/processor:$BUILD_NUMBER'
                    sh 'docker push barloc/gateway:$BUILD_NUMBER'
                }
            }
        }
    }
    stage('deploy to env') {
        docker.withTool('docker'){
            withDockerServer([uri: 'tcp://docker.for.win.localhost:2375']) {
                sh 'docker rm --force message-gateway || true'
                sh 'docker rm --force message-processor || true'
                sh 'docker rm --force rabbitmq || true'
                
                sh 'docker network list'
                sh 'docker network rm devops-network || true'
                sh 'docker network create -d bridge devops-network'
                
                sh 'docker run -d --network=devops-network --name rabbitmq rabbitmq'
                sh 'docker run -d --network=devops-network --name --link=rabbitmq message-gateway -p 8888:8080 barloc/gateway:$BUILD_NUMBER'
                sh 'docker run -d --network=devops-network --name --link=rabbitmq message-processor barloc/processor:$BUILD_NUMBER'
            }
        }
    }
    stage('provision env') {

    }
    stage('integration test') {

    }
    stage('send report') {

    }
}
