
import groovy.json.JsonSlurper
import groovy.json.JsonOutput
def binHost = 'http://requestbin.fullcontact.com'
def workdir = "dir1"
def art = "artifactory"
def proc = "message_processor_$BUILD_NUMBER"
def gateway = "message_gateway_$BUILD_NUMBER"
def dockerSock = 'unix:///var/run/docker.sock'
node() {

	stage('preparation') {
		echo 'testing working capacity of docker and check containers of old-builds'
		docker.withTool('docker') {
			withDockerServer([uri: dockerSock]) {
				sh 'docker ps -a'
				try {
					sh 'docker stop message-processor rabbitmq message-gateway'
					sh 'docker rm message-processor rabbitmq message-gateway'
				} catch (err) {
					echo 'Containers not created'
				}
			}
		}
	}
	stage('get source') {
		dir(workdir) {
			echo 'Geting source from git repository'
			git branch: 'mkukharchuk', credentialsId: '9b24a61e-3be1-42bf-8886-7a4a5811873a', url: 'https://github.com/mimikuku/ep3.git'

		}
	}
	stage('run tests') {
		echo 'Runing maven tests and output in file'
	dir(workdir) {
		withMaven(maven: 'maven'){
		   sh 'mvn clean test > maven.tests-$BUILD_NUMBER.txt' //write output in file
	    }
	}
    }
    stage('build package') {
		echo 'Building package'
	 dir(workdir) {
                withMaven(maven: 'maven'){
                   sh 'mvn -X clean package -Dmaven.test.skip=true'
				}
	 		}
	 	}
    stage('save artifact') {
		echo 'saving artifacts and building docker images' //save artifacts, files with tests output and Dockerfiles in directory "artifactory"
	 dir (workdir){
	    dir (art){
			sh 'mv $(find $JENKINS_HOME/workspace/$JOB_NAME/dir1 -name "maven.tests-$BUILD_NUMBER.txt") .'
	     dir (proc) {
			 sh 'cp $(find $JENKINS_HOME/workspace/$JOB_NAME/dir1/message-processor/ -name "message-processor-1.0-SNAPSHOT.jar") .'
			 sh 'cp $(find $JENKINS_HOME/workspace/$JOB_NAME/dir1/message-processor/ -name "config.properties") .'
			 sh 'echo \'FROM java:8\n\n\nCOPY . /workdir/\nWORKDIR /workdir/\nENTRYPOINT ["java"]\nCMD ["-jar","message-processor-1.0-SNAPSHOT.jar","config.properties"]\' > Dockerfile'
			 docker.withTool('docker') {
				 withDockerRegistry([credentialsId: 'fcee4710-876f-4799-92d4-73414aab1258', url: 'https://index.docker.io/v1/']) {
					 withDockerServer([uri: dockerSock]) {
						 sh 'docker build -t messege-processor:$BUILD_NUMBER .'
						 sh 'docker tag messege-processor:$BUILD_NUMBER mimisha/messege-processor:$BUILD_NUMBER'
						 sh 'docker push mimisha/messege-processor:$BUILD_NUMBER'
						 sh 'docker rmi mimisha/messege-processor:$BUILD_NUMBER messege-processor:$BUILD_NUMBER'
					 }
				 }
	        }
		}
		 dir (gateway){
                sh 'cp -R $JENKINS_HOME/workspace/$JOB_NAME/dir1/message-gateway/* .'
                sh 'echo \'FROM maven\n\n\nCOPY . /workdir/\nWORKDIR /workdir/\nENTRYPOINT ["mvn"]\nCMD ["tomcat7:run"]\' > Dockerfile'
				docker.withTool('docker'){
                        withDockerRegistry([credentialsId: 'fcee4710-876f-4799-92d4-73414aab1258', url: 'https://index.docker.io/v1/']) {
                                withDockerServer([uri: dockerSock]) {
                                        sh 'docker build -t messege-gateway:$BUILD_NUMBER .'
                                        sh 'docker tag messege-gateway:$BUILD_NUMBER mimisha/messege-gateway:$BUILD_NUMBER'
                                        sh 'docker push mimisha/messege-gateway:$BUILD_NUMBER'
									    sh 'docker rmi mimisha/messege-gateway:$BUILD_NUMBER messege-gateway:$BUILD_NUMBER'
	                                    }
						        }
				}
		 }
	  }
	}
	stage('deploy to env') {
		echo 'deploing docker images'
	 	docker.withTool('docker'){
                 withDockerServer([uri: dockerSock]) {
                   sh 'docker run -d --name message-gateway -p 8888:8080 mimisha/messege-gateway:$BUILD_NUMBER'
				sleep 30
                   sh 'docker run -d --name rabbitmq --net=container:message-gateway rabbitmq'
				sleep 120
                   sh 'docker run -d --name message-processor --net=container:rabbitmq mimisha/messege-processor:$BUILD_NUMBER'
			       sleep 30 //rabbitmq contauner need 30 seconds to load, and message-gateway contauner wait it.
				  sh 'docker start message-processor'
				  sleep 20 //wait load message-gateway contauner to send messages on frontend.
	  }
	 }
	}

    stage('integration test') {
		def testMessage1 = 'docker exec message-gateway curl -s -o /dev/null/ -w %{http_code} http://localhost:8080/message -X POST -d {"messageId":1, "timestamp":1234, "protocolVersion":"1.0.0", "messageData":{"mMX":1234, "mPermGen":1234}}'
		def procAnswer1 = 'docker logs --tail 1 message-processor'
		def testMessage2 = 'docker exec message-gateway curl -s -o /dev/null/ -w %{http_code} http://localhost:8080/message -X POST -d {"messageId":2, "timestamp":2234, "protocolVersion":"1.0.1", "messageData":{"mMX":1234, "mPermGen":5678, "mOldGen":22222}}'
		def procAnswer2 = 'docker logs --tail 1 message-processor'
		def testMessage3 = 'docker exec message-gateway curl -s -o /dev/null/ -w %{http_code} http://localhost:8080/message -X POST -d {"messageId":3, "timestamp":3234, "protocolVersion":"2.0.0", "payload":{"mMX":1234, "mPermGen":5678, "mOldGen":22222, "mYoungGen":333333}}'
		def procAnswer3 = 'docker logs --tail 1 message-processor'
		echo 'sending test messages and pushing it in backet'
		docker.withTool('docker'){
			withDockerServer([uri: dockerSock]) {
				try {
				sh testMessage1
				report1 = sh (script: procAnswer1,
					returnStdout: true)
				report1 == '200'
				println report1
				}catch (err){
					report1 = err.getMessage()
					println report1
				}
				try {
					sh testMessage2
					report2 = sh (script: procAnswer2,
							returnStdout: true)
					    report2 == '200'
				}catch (err){
					report2 = err.getMessage()
				}
				try {
					sh testMessage3
					report3 = sh (script: procAnswer3,
							returnStdout: true)
					report3 == '200'
				}catch (err){
					report3 = err.getMessage()
				}
				}
			}
	}
}
}
