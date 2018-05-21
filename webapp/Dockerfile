FROM openjdk:8-jre-alpine
COPY ./build/libs/webapp-1.0.0.jar /root/webapp-1.0.0.jar
WORKDIR /root
CMD ["java", "-server", "-Xms4g", "-Xmx4g", "-XX:+UseG1GC", "-XX:MaxGCPauseMillis=100", "-XX:+UseStringDeduplication", "-jar", "webapp-1.0.0.jar"]