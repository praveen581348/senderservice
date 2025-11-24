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
=======
FROM jenkins/jenkins:lts

# -----------------------------
# 1. Switch to root
# -----------------------------
USER root

# -----------------------------
# 2. Install base tooling
# -----------------------------
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    maven \
    docker.io \
    docker-compose \
    unzip \
    jq \
    wget \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------
# 3. Install kubectl
# -----------------------------
RUN curl -LO "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
 && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
 && rm kubectl

# -----------------------------
# 4. Install Helm
# -----------------------------
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
 && chmod 700 get_helm.sh && ./get_helm.sh && rm get_helm.sh

# -----------------------------
# 5. Install Trivy (Debian 13 / trixie compatible)
# -----------------------------
ENV TRIVY_VERSION=0.48.3

RUN wget https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.deb \
 && dpkg -i trivy_${TRIVY_VERSION}_Linux-64bit.deb \
 && rm trivy_${TRIVY_VERSION}_Linux-64bit.deb

# -----------------------------
# 6. Install OWASP Dependency Check
# -----------------------------
ENV DC_VERSION=9.2.0

RUN curl -L -o dependency-check.zip \
    "https://github.com/jeremylong/DependencyCheck/releases/download/v${DC_VERSION}/dependency-check-${DC_VERSION}-release.zip" \
 && unzip dependency-check.zip -d /usr/share \
 && rm dependency-check.zip

ENV PATH="/usr/share/dependency-check/bin:${PATH}"

# -----------------------------
# 7. Add Jenkins user to Docker group
# -----------------------------
RUN usermod -aG docker jenkins

# -----------------------------
# 8. Copy & configure entrypoint (runs dockerd + Jenkins)
# -----------------------------
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# -----------------------------
# 9. Run as root so dockerd works
# -----------------------------
USER root

# -----------------------------
# 10. Start via our DIND entrypoint
# -----------------------------
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
