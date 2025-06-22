FROM maven:3.6.3-openjdk-8

ARG APP_VERSION=1.0.0

EXPOSE 8080

COPY . .

RUN mvn clean package

# Without sh -c: ${APP_VERSION} stays as literal text
CMD ["sh", "-c", "java -jar target/java-maven-app-${APP_VERSION}-SNAPSHOT.jar"]