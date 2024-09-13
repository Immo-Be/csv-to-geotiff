#!/bin/bash

# Input CSV and output file names
CSV_FILE="Bevoelkerung_100m_Gitter.csv"
XYZ_FILE="Bevoelkerung_100m_Gitter.xyz"
CDF_FILE="Bevoelkerung_100m_Gitter.cdf"
GEOTIFF_FILE="Bevoelkerung_100m_Gitter.tif"
GEOTIFF_FILE_4326="Bevoelkerung_100m_Gitter_4326.tif"

# Ensure the CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: CSV file '$CSV_FILE' not found!"
    exit 1
fi

# Create the XYZ file by extracting x, y, and population data (skip header)
echo "NEUU Creating XYZ file from CSV..."
awk 'FS=";" {print $2" "$3" "$4}' $CSV_FILE > $XYZ_FILE

# Check the geographic extents using GMT (you can modify this step if needed)
echo "Determining geographic extents..."
EXTENTS=$(gmt info -I- $XYZ_FILE)
echo "Geo extents: $EXTENTS"

# Set the bounding box manually
REGION="-R4031350/4672550/2684050/3551450"

# Convert XYZ to NetCDF/GRD using GMT
echo "Converting XYZ to GRD/NetCDF..."
gmt xyz2grd $XYZ_FILE $REGION -I100 -h1 --IO_NC4_CHUNK_SIZE=c -G$CDF_FILE

# Convert GRD/NetCDF to GeoTIFF using GDAL
echo "Converting NetCDF to GeoTIFF..."
gdal_translate -co COMPRESS=DEFLATE -a_srs EPSG:3035 -a_nodata -1 $CDF_FILE $GEOTIFF_FILE

# Reproject and compress GeoTIFF to EPSG:4326
echo "Reprojecting GeoTIFF to EPSG:4326..."
gdalwarp -s_srs EPSG:3035 -t_srs EPSG:4326 -co COMPRESS=LZW $GEOTIFF_FILE $GEOTIFF_FILE_4326

# Inspect the resulting GeoTIFF file
echo "Conversion complete. GeoTIFF details:"
# gdalinfo $GEOTIFF_FILE_4326

# Clean up intermediate files if needed (uncomment to enable cleanup)
rm $XYZ_FILE $CDF_FILE $GEOTIFF_FILE

echo "GeoTIFF $GEOTIFF_FILE_4326_COMPRESSED successfully created."
