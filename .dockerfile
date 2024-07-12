# Use the official GCC image as the base image
FROM gcc:latest

# Set the working directory
WORKDIR /usr/src/BME

# Copy the current directory contents into the container
COPY . .

# Install any necessary packages
RUN apt-get update && apt-get install -y \
    clang-format \
    doxygen \
    && rm -rf /var/lib/apt/lists/*

# Build the project
RUN make all

# Run the executable
CMD ["./bin/BlackMarlinExec"]
