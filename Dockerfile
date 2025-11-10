# Use a base image with a Java Runtime Environment (JRE)
FROM eclipse-temurin:17-jdk-jammy

# Set the working directory inside the container
WORKDIR /app

# Copy the packaged Spring Boot application JAR file into the container
# Assuming you build your application with Maven using `mvn clean package`,
# the JAR will be in the `target` directory.
COPY target/*.jar app.jar

# Expose the port your Spring Boot application runs on (usually 8080)
EXPOSE 8098

# Specify the command to run when the container starts
ENTRYPOINT ["java", "-jar", "app.jar"]