#!/bin/bash
CERT=$(kubectl get secret mssql-standalone3-server-cert -n demo -o jsonpath='{.data.tls\.crt}' | base64 -d)
SERIAL=$(echo "$CERT" | openssl x509 -noout -serial | cut -d= -f2)
echo "Serial Number (hex): $SERIAL"	