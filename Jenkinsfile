def workdir = "project"

pipeline(){
    agent {
        docker {
            image 'maven:3-alpine'
            args '-v /root/.m2:/root/.m2'
        }
    }
    stages {
        stage('test'){
            steps {
                sh "export"
            }
        }
        stage('get source') {
            steps {
                dir(workdir) {
                    git branch: 'slysikov', credentialsId: 'a4aaa3b8-a6eb-467d-9c7b-165308891f1e', url: 'git@gitlab.com:nikolyabb/epam-devops-3rd-stream.git'
                }
            }
        }
        stage('run tests') {
            steps {
            
            }
        }
        stage('build package') {
                    steps {
            
            }
    
        }
        stage('save artifact') {
                    steps {
            
            }
    
        }
        stage('deploy to env') {
                    steps {
            
            }
    
        }
        stage('provision env') {
                    steps {
            
            }
    
        }
        stage('integration test') {
                    steps {
            
            }
    
        }
        stage('send report') {
                    steps {
            
            }
    
        }
    }
}
