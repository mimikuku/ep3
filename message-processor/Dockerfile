FROM java:8
ADD /message-processor/target/message-processor-1.0-SNAPSHOT.jar /opt/test/message-processor-1.0-SNAPSHOT.jar
ADD etc/config.properties /etc/config.properties
CMD ["java","-jar","/opt/test/message-processor-1.0-SNAPSHOT.jar","/etc/config.properties"]
