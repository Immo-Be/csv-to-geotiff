# Use an official Ubuntu as a parent image
FROM ubuntu:20.04

# Set environment variables to avoid user interaction during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    gdal-bin \ 
    ghostscript \
    gmt \
    gmt-dcw \
    gmt-gshhg \
    gawk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /data

# Copy the script into the container
COPY convert_xlsx_to_geotiff.sh /data/convert_xlsx_to_geotiff.sh

# Make the script executable
RUN chmod +x /data/convert_xlsx_to_geotiff.sh

# Define the entrypoint
ENTRYPOINT ["/data/convert_xlsx_to_geotiff.sh"]
