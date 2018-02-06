def workdir = "project"

node(){
    stage('test'){
        sh "export"
    }
    stage('get source') {
        dir(workdir) {
            git branch: 'slysikov', credentialsId: 'a4aaa3b8-a6eb-467d-9c7b-165308891f1e', url: 'git@gitlab.com:nikolyabb/epam-devops-3rd-stream.git'
        }
    }
    stage('run tests') {

    }
    stage('build package') {

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
