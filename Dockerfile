FROM java:8
ADD message-processor/target/original-message-processor-1.0-SNAPSHOT.jar /opt/test/original-message-processor-1.0-SNAPSHOT.jar
ADD message-processor/etc/config.properties /etc/config.properties
CMD ["java","-jar","/opt/test/original-message-processor-1.0-SNAPSHOT.jar etc/config.properties &"]
