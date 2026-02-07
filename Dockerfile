FROM eclipse-temurin:17-jre-alpine

WORKDIR /opt/Lavalink

# Install dependencies
RUN apk add --no-cache wget curl ca-certificates

# Download Lavalink TERBARU (4.0.8 masih latest)
RUN wget https://github.com/lavalink-devs/Lavalink/releases/download/4.0.8/Lavalink.jar

# Buat folder plugins (auto-download by Lavalink)
RUN mkdir -p plugins

# Copy configuration
COPY application.yml .

# Expose port
EXPOSE 2333

# Health check dengan authorization header
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
  CMD curl -f -H "Authorization: ${LAVALINK_PASSWORD}" http://localhost:2333/version || exit 1

# Run with optimized memory untuk Render free tier (512MB)
CMD ["java", "-Xmx350M", "-Xms128M", "-Djdk.tls.client.protocols=TLSv1.2", "-jar", "Lavalink.jar"]
