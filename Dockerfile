FROM golang:1.21-alpine AS builder

WORKDIR /app
# Install git and build tools
RUN apk add --no-cache git make bash

# Clone the repository
RUN git clone https://github.com/volcengine/volcengine-cli.git .

# Build the binary using the provided script logic
# The search result mentioned 'sh build.sh linux'
RUN sh build.sh linux

FROM alpine:latest

# Install bash, ca-certificates (needed for HTTPS), and tzdata (for timezone support)
RUN apk add --no-cache bash ca-certificates curl tzdata

WORKDIR /app

# Copy the binary from the builder stage
# The build script produces 've', which we rename to 've'
COPY --from=builder /app/ve /usr/local/bin/ve

# Make it executable
RUN chmod +x /usr/local/bin/ve

# Copy entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
