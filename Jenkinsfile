pipeline {
    agent any
    stages {
        stage ('Clean docker') {
            steps {
                tool name: 'docker', type: 'org.jenkinsci.plugins.docker.commons.tools.DockerTool'
                withDockerServer([uri: 'unix:///var/run/docker.sock']) {
                    sh 'docker ps -a'
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
        stage ('Build launch') {
            step {
                echo BUILD
            }
        }
        
    }
}
