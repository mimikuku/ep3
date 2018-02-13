def workdir="project"
def gateway="message-gateway"
def processor="message-processor"

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
            environment {
                GIT_WORKDIR = workdir
                sh 'cp -R $WORKSPACE/$GIT_WORKDIR/message-gateway/* .'
            }
            
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
            environment {
                GIT_WORKDIR = workdir
                sh 'cp $(find $WORKSPACE/$GIT_WORKDIR -name "message-processor-1.0-SNAPSHOT.jar") .'
		        sh 'cp $(find $WORKSPACE/$GIT_WORKDIR -name "config.properties") .'
            }
		    
		    writeFile file: 'Dockerfile', text: '''FROM java:8
                COPY . /opt/processor/
                WORKDIR /opt/processor/
                RUN java -jar message-processor-1.0-SNAPSHOT.jar config.properties
                CMD ["java", "Main"]'''
                
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
                sh 'docker rm --force message-gateway'
                //sh 'docker rm --force message-processor'
                sh 'docker rm --force rabbitmq'
                
                sh 'docker network list'
                sh 'docker network rm devops-network'
                sh 'docker network create -d bridge devops-network'
                
                sh 'docker run -d --network=devops-network --name message-gateway -p 8888:8080 barloc/gateway:$BUILD_NUMBER'
                sh 'docker run -d --network=devops-network --name rabbitmq rabbitmq'
                sh 'docker run -d --network=devops-network --name message-processor barloc/processor:$BUILD_NUMBER'
                
                //sleep 30
                //sh 'docker start message-processor'
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
