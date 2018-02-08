node {

    def app_processor
    def app_gw

    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */

        checkout scm
    }

    stage('test maven') {
         echo 'Test'
         withMaven(maven: 'maven') {
          sh "mvn -X clean test"
         }
     }
     stage('Build java apps') {
         echo 'Building..'
         withMaven(maven: 'maven') {   
          sh "mvn -X clean package -Dmaven.test.skip=true"
         }
        }

    stage('Build images') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */
              docker.withTool('docker'){
                   withDockerServer([uri: 'unix:///var/run/docker.sock']) {
                      sh 'docker ps -a'
          }
         }
        }
}
