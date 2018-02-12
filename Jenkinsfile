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
        app_processor = docker.build("message-processor", "-f message-processor/Dockerfile .")
        app_gateway = docker.build("message-gateway", "-f message-gateway/Dockerfile .")
             }
            }        
         }

    stage('Push image') {
        /* Finally, we'll push the image with two tags:
         * First, the incremental build number from Jenkins
         * Second, the 'latest' tag.
         * Pushing multiple tags is cheap, as all the layers are reused. */
docker.withTool('docker'){
                   withDockerServer([uri: 'unix:///var/run/docker.sock']) {

   withDockerRegistry([credentialsId: '35ad3177-1015-478e-bad5-0370cd41e645', url: 'https://index.docker.io/v1/lexa500/epam-test']) {

            def message_processor_image = docker.build("lexa500/epam-test:${env.BUILD_NUMBER}", "-f message-processor/Dockerfile .")
            message_processor_image.push()
            def message_gateway_image = docker.build("lexa500/epam-test:${env.BUILD_NUMBER}", "-f message-gateway/Dockerfile .")
            message_gateway_image.push()


}
                   }

        }
    }
}
