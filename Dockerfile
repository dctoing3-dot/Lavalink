# Use official Eclipse Temurin JRE Alpine image for smaller size
FROM eclipse-temurin:17-jre-alpine

# Set working directory
WORKDIR /opt/Lavalink

# Install required dependencies
# libgcc: Required for JDA-NAS native audio system
# ca-certificates: For HTTPS connections
# curl & wget: For downloading and health checks
# ffmpeg: Optional but recommended for better audio support
RUN apk add --no-cache \
    wget \
    curl \
    ca-certificates \
    libgcc \
    ffmpeg \
    && apk add --no-cache --virtual .build-deps \
    git \
    && rm -rf /var/cache/apk/*

# Download Lavalink JAR (Latest stable version)
RUN wget -O Lavalink.jar \
    https://github.com/lavalink-devs/Lavalink/releases/download/4.0.8/Lavalink.jar

# Create necessary directories
RUN mkdir -p \
    plugins \
    /tmp/youtube-cache \
    logs \
    && chmod -R 755 /opt/Lavalink

# Copy configuration file
COPY application.yml .

# Set proper permissions
RUN chmod 644 application.yml

# Expose Lavalink port
EXPOSE 2333

# Health check configuration
HEALTHCHECK --interval=30s \
            --timeout=10s \
            --start-period=90s \
            --retries=3 \
  CMD curl -f -H "Authorization: ${LAVALINK_PASSWORD:-your_super_strong_password_here}" \
      http://localhost:2333/version || exit 1

# Java runtime options optimized for Render free tier (512MB RAM)
ENV JAVA_OPTS="-Xms128M \
               -Xmx350M \
               -XX:+UseSerialGC \
               -XX:MaxGCPauseMillis=100 \
               -XX:+UnlockExperimentalVMOptions \
               -XX:+DisableExplicitGC \
               -Djava.awt.headless=true \
               -Djdk.tls.client.protocols=TLSv1.2,TLSv1.3 \
               -Dfile.encoding=UTF-8 \
               -Djava.security.egd=file:/dev/./urandom"

# Run Lavalink with optimized settings
CMD ["sh", "-c", "java $JAVA_OPTS -jar Lavalink.jar"]
