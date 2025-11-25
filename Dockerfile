# Created by Gemini

# ---- Build Stage ----
# Base image with Maven and JDK 17 to build the application
FROM maven:3.8.5-openjdk-17 AS build

# Set the working directory
WORKDIR /app

# Copy the Maven wrapper and the pom.xml
COPY .mvn/ .mvn
COPY mvnw pom.xml ./

# Download Maven dependencies
# This is done as a separate step to leverage Docker layer caching
RUN ./mvnw dependency:go-offline

# Copy the rest of the source code
COPY src ./src

# Build the application, skipping tests
RUN ./mvnw package -DskipTests

# ---- Run Stage ----
# Base image with JRE 17 for running the application
FROM eclipse-temurin:17-jre-focal

# Set the working directory
WORKDIR /app

# Copy the executable jar from the build stage
COPY --from=build /app/target/activity-management-0.0.1-SNAPSHOT.jar ./app.jar

# Expose the port the application runs on (default is 8080)
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
