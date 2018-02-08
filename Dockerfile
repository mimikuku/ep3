FROM java:8
ADD message-processor/target/original-message-processor-1.0-SNAPSHOT.jar /opt/test/original-message-processor-1.0-SNAPSHOT.jar
CMD ["java","-jar","/opt/test/original-message-processor-1.0-SNAPSHOT.jar"]
