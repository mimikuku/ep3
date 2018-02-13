FROM tomcat
RUN mkdir /usr/local/tomcat/webapps/message
COPY message-gateway/target/message-gateway-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/message/
CMD ["catalina.sh", "run"]
