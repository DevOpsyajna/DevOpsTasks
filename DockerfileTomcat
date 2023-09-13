FROM ubuntu
RUN apt update && apt install openjdk-11-jdk -y
RUN apt install wget -y
WORKDIR /opt/
RUN wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.13/bin/apache-tomcat-10.1.13.tar.gz
RUN tar -xvzf apache-tomcat-10.1.13.tar.gz
RUN mv apache-tomcat-10.1.13 tomcat
RUN chmod -R a+x tomcat
EXPOSE 8080
CMD ["/opt/tomcat/bin/catalina.sh","run"]
