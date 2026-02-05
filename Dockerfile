FROM eclipse-temurin:17-jre-alpine

WORKDIR /opt/Lavalink

# Install dependencies
RUN apk add --no-cache wget curl

# Download Lavalink
RUN wget https://github.com/lavalink-devs/Lavalink/releases/download/4.0.5/Lavalink.jar

# Copy config
COPY application.yml .

# Expose port
EXPOSE 2333

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
  CMD curl -f http://localhost:2333/version || exit 1

# Run with memory limit
CMD ["java", "-Xmx400M", "-Xms128M", "-jar", "Lavalink.jar"]
