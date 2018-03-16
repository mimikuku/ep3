import groovy.json.JsonSlurper
pipeline {
    agent any
    stages {
        stage ('Clean docker') {
            steps {
                sh 'docker ps -a'
                script {
                    try {
                        sh 'docker stop message-processor rabbitmq message-gateway'
                        sh 'docker rm message-processor rabbitmq message-gateway'
                    } catch (err) {
                        echo 'It have not containers'
                    }
                }
            }
        }
        
        stage ('SCM checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/mkukharchuk']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '9b24a61e-3be1-42bf-8886-7a4a5811873a', url: 'https://github.com/mimikuku/ep3']]])
            }    
        }
        stage ('Pretesting') {
            steps {
                withMaven(maven: 'Maven3') {
                    sh 'mvn clean test'
                }
            }
        }
        stage ('Build launch') {
            steps {
                withMaven(maven: 'Maven3') {
                    sh 'mvn clean package -Dmaven.test.skip=true >> logFile'
                    sh 'echo "\n BUILD JAVA SUCCESSFUL \n" >> logFile'
                }
            }
        }
        stage ('Save built images in docker hub') {
            steps {
                sh 'echo \'FROM java:8\n\n\nCOPY ./message-processor/target/message-processor-1.0-SNAPSHOT.jar /workdir/message-processor-1.0-SNAPSHOT.jar\nCOPY ./message-processor/etc/config.properties /workdir/config.properties\nWORKDIR /workdir/\nENTRYPOINT ["java"]\nCMD ["-jar","message-processor-1.0-SNAPSHOT.jar","config.properties"]\' > Dockerfile'
                sh 'docker build -t msg-processor:$BUILD_NUMBER .'
                sh 'docker tag msg-processor:$BUILD_NUMBER mimisha/msg-processor:$BUILD_NUMBER'
                sh 'docker push mimisha/msg-processor:$BUILD_NUMBER'
                sh 'docker rmi mimisha/msg-processor:$BUILD_NUMBER msg-processor:$BUILD_NUMBER'
                
                sh 'echo \'FROM maven\n\n\nCOPY ./message-gateway/ /workdir/\nWORKDIR /workdir/\nENTRYPOINT ["mvn"]\nCMD ["tomcat7:run"]\' > Dockerfile2'
                sh 'docker build -t msg-gateway:$BUILD_NUMBER -f ./Dockerfile2 .'
                sh 'docker tag msg-gateway:$BUILD_NUMBER mimisha/msg-gateway:$BUILD_NUMBER'
                sh 'docker push mimisha/msg-gateway:$BUILD_NUMBER'
                sh 'docker rmi mimisha/msg-gateway:$BUILD_NUMBER msg-gateway:$BUILD_NUMBER'
                sh 'echo "\n SAVE BUILT CONTAINERS № $BUILD_NUMBER SUCCESSFUL\n" >> logFile'
            }
        }
        stage ('Deploy from docker hub') {
            steps {
                sh 'docker run -d --name message-gateway -p 8888:8080 mimisha/msg-gateway:$BUILD_NUMBER'
                sh 'docker run -d --name rabbitmq --net=container:message-gateway rabbitmq'
                sh 'docker run -d --name message-processor --net=container:message-gateway mimisha/msg-processor:$BUILD_NUMBER'
                script {
                    for (int i = 0; i < 40; i++ ) {
                        sleep 10
                        def var = sh (script:"docker ps -q -f status=exited", returnStdout: true)
                        if ( var != '' ) {
                            println i
                            sh 'docker start message-processor'
                        } else {
                            break
                        }
                    }
                }
                sh 'docker ps -a >> logFile'
                sh 'echo "\n DEPLOY № $BUILD_NUMBER SUCCESSFUL \n" >> logFile'
            }
        }
        stage ('Verify environment') {
            steps {
                script {
                    sleep 90
                    sh 'docker exec message-gateway curl http://localhost:8080/message -X POST -d \'{"messageId":1, "timestamp":1234, "protocolVersion":"1.0.0", "messageData":{"mMX":1234, "mPermGen":1234}}\''
                    sleep 5
                    def notific = sh (script:"docker logs --tail 1 message-processor", returnStdout: true)
                    sh 'docker exec message-gateway curl http://localhost:8080/message -X POST -d \'{"messageId":2, "timestamp":2234, "protocolVersion":"1.0.1", "messageData":{"mMX":1234, "mPermGen":5678, "mOldGen":22222}}\''
                    sleep 5
                    notific += sh (script:"docker logs --tail 1 message-processor", returnStdout: true)
                    sh 'docker exec message-gateway curl http://localhost:8080/message -X POST -d \'{"messageId":3, "timestamp":3234, "protocolVersion":"2.0.0", "payload":{"mMX":1234, "mPermGen":5678, "mOldGen":22222, "mYoungGen":333333}}\''
                    sleep 5
                    notific += sh (script:"docker logs --tail 1 message-processor", returnStdout: true)
                    sleep 5
                    sh "echo $notific"
                    sh 'echo "\n Verification ENDED \n" >> logFile'
                    
                    def var3 = sh (script:"curl -X POST https://requestbin.fullcontact.com/api/v1/bins", returnStdout: true)
                    def pathName = new JsonSlurper().parseText(var3).name.toString()
                    println pathName
                    sh "echo $pathName"
                    sleep 5
                    sh "curl --data @logFile -X POST https://requestbin.fullcontact.com/$pathName"
                    sh "curl -X POST https://requestbin.fullcontact.com/$pathName -d \'$notific\'"
                    sh "echo Look at the https://requestbin.fullcontact.com/$pathName?inspect"
                    sh 'echo "BODY of sent messages"'
                    sh 'cat logFile'
                    println notific
                }
            }
        }
    }
}
