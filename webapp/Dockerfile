FROM openjdk:8-jre-alpine
COPY ./build/libs/webapp.jar /root/webapp.jar
WORKDIR /root
CMD ["java", "-server", "-jar", "webapp.jar"]
