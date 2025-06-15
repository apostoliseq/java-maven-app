FROM maven:3.6.3-openjdk-8

EXPOSE 8080

COPY . .

RUN mvn clean package

CMD ["java", "-jar", "target/java-maven-app-1.1.0-SNAPSHOT.jar"]
