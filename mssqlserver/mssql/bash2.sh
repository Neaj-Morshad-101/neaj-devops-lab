#!/bin/bash

# Retrieve the certificate from the Kubernetes secret and decode it from base64
CERT=$(kubectl get secret mssql-standalone4-server-cert -n demo -o jsonpath='{.data.tls\.crt}' | base64 -d)

# Extract the serial number in hexadecimal format using OpenSSL
SERIAL=$(echo "$CERT" | openssl x509 -noout -serial | cut -d= -f2)

# Display the serial number
echo "Serial Number (hex): $SERIAL"

# Extract the first byte (first two characters) of the serial number
FIRST_BYTE=${SERIAL:0:2}

# Convert the first byte from hex to decimal
FIRST_BYTE_DEC=$(printf "%d" "0x$FIRST_BYTE")

# Determine if the serial number is positive or negative
# - If the first byte < 0x80 (128 in decimal), it's positive
# - If the first byte >= 0x80, it's negative (indicating an encoding issue)
if [ "$FIRST_BYTE_DEC" -lt 128 ]; then
    echo "The serial number is positive."
else
    echo "The serial number is negative."
fi