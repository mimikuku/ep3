def workdir="project"

node(){
    stage('test'){
        dir(workdir) {
            deleteDir()
        }
        sh "export"
        withDocker(docker: 'docker') {
            withDockerServer([uri: 'tcp://docker.for.win.localhost:2375']) {
                sh 'docker ps'
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
    }
    
    stage('save artifact') {

    }
    stage('deploy to env') {

    }
    stage('provision env') {

    }
    stage('integration test') {

    }
    stage('send report') {

    }
}
