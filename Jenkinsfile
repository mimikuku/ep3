pipeline {
    agent any

    stages {
        stage('test') {
            steps {
                 echo 'Test'
               withMaven(maven: 'maven') {
                sh "mvn -X clean test"
               }
            }
        }       
        stage('Build') {
            steps {
                echo 'Building..'
             withMaven(maven: 'maven') {
             sh "mvn -X clean package -Dmaven.test.skip=true"
              }
             }
        }
        stage('dokerize') {
            steps {
                echo 'docker-shmoker...'
                script{
                docker.withTool("docker"){
                   withDockerServer([uri: "unix:///var/run/docker.sock"]) {
                        sh "docker build -t message-processor ."
                        sh "docker run -it --rm message-processor"                  
                     } 
                }
             }
          }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
