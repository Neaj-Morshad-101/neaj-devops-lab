https://www.youtube.com/watch?v=HMoFvRK4HUo&list=PLIFyRwBY_4bTwRX__Zn4-letrtpSj1mzY&pp=iAQB
https://www.youtube.com/watch?v=yzz3bcnWf7M&t=1s
Creating Server Key & Crt:
openssl genrsa -out ca.key 2048
ls -a
./  ../  ca.key
openssl req -x509 -new -nodes -key ca.key -sha256 -days 365 -out ca.crt -subj "/CN=Memcached CA"
ls -a
./  ../  ca.crt  ca.key
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=memcached-server"
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -sha256 \
-extensions v3_req -extfile <(echo "[v3_req]
subjectAltName=IP:127.0.0.1,DNS:localhost")
Certificate request self-signature ok
subject=CN = memcached-server
openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr -subj "/CN=client"
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365 -sha256
Certificate request self-signature ok
subject=CN = client
openssl x509 -in server.crt -text -noout | grep -A1 "Subject Alternative Name"
chmod 644 /home/evan/go/src/evanraisul/mc-tls/ca.key
chmod 644 /home/evan/go/src/evanraisul/mc-tls/server.key
telnet localhost 12345
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
version
VERSION 1.6.31
openssl verify -CAfile /home/evan/go/src/evanraisul/memcached_TLS/ca.crt /home/evan/go/src/evanraisul/memcached_TLS/server.crt
Run Memcached with TLS:
docker run -d \
--name memcached-server \
-p 11211:11211 \
-v /home/evan/go/src/evanraisul/mc-tls/server.crt:/etc/ssl/certs/ssl_cert.pem \
-v /home/evan/go/src/evanraisul/mc-tls/server.key:/etc/ssl/private/ssl_key.pem \
-v /home/evan/go/src/evanraisul/mc-tls/ca.crt:/etc/ssl/certs/ca_cert.pem \
-v /home/evan/go/src/evanraisul/Evan-YAMLs/Memcached/authentication/authfile:/etc/memcached/auth-file \
memcached --enable-ssl \
-u memcache \
-p 11211 \
-o  ssl_chain_cert=/etc/ssl/certs/ssl_cert.pem \
-o  ssl_key=/etc/ssl/private/ssl_key.pem \
-o ssl_ca_cert=/etc/ssl/certs/ca_cert.pem \
--auth-file=/etc/memcached/auth-file
Commands:
docker stop memcached-server
docker remove memcached-server
docker ps
docker ps -a
command:
stats
echo "stats" | openssl s_client -connect localhost:11211 -quiet
docker logs memcached-server
Verify TLS:
openssl s_client -connect host:port
openssl s_client -connect localhost:11211 -CAfile /home/evan/go/src/evanraisul/memcached_TLS/ca.crt -servername memcached-server
Certificate Bundle Location
/etc/ssl/certs/ca-certificates.crt
server setup done.
client connected and ensure tls connection working.
access and insert data.
Socat:
socat -d -d \
TCP-LISTEN:12345,reuseaddr,fork \
OPENSSL:localhost:11211,cert=/home/evan/go/src/evanraisul/mc-tls/client.crt,key=/home/evan/go/src/evanraisul/mc-tls/client.key,cafile=/home/evan/go/src/evanraisul/mc-tls/ca.crt,verify=1
Working Procedure:
docker run -d \
--name memcached-server \
-p 11211:11211 \
-v /home/evan/go/src/evanraisul/mc-tls/server.crt:/etc/ssl/certs/ssl_cert.pem \
-v /home/evan/go/src/evanraisul/mc-tls/server.key:/etc/ssl/private/ssl_key.pem \
-v /home/evan/go/src/evanraisul/mc-tls/ca.crt:/etc/ssl/certs/ca_cert.pem \
-v /home/evan/go/src/evanraisul/Evan-YAMLs/Memcached/authentication/authfile:/etc/memcached/auth-file \
memcached --enable-ssl \
-u memcache \
-p 11211 \
-o  ssl_chain_cert=/etc/ssl/certs/ssl_cert.pem \
-o  ssl_key=/etc/ssl/private/ssl_key.pem \
-o ssl_ca_cert=/etc/ssl/certs/ca_cert.pem \
--auth-file=/etc/memcached/auth-file
socat -d -d \
TCP-LISTEN:12345,reuseaddr,fork \
OPENSSL:localhost:11211,cert=/home/evan/go/src/evanraisul/mc-tls/client.crt,key=/home/evan/go/src/evanraisul/mc-tls/client.key,cafile=/home/evan/go/src/evanraisul/mc-tls/ca.crt,verify=1
telnet localhost 12345
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
version
VERSION 1.6.31
set foo 0 999 3
bar
STORED
get foo
VALUE foo 0 3
bar
END

Overview of the Process
Telnet sends commands in plaintext:
You interact with socat over port 12345 via a plaintext connection.

Socat translates TCP to TLS:
socat takes the plaintext commands from telnet, encrypts them with TLS, and sends them to the Memcached server over the secure 11211 port.

Memcached receives TLS commands:
Memcached processes these commands because the connection is secure and authenticated using the client certificate and key.

Results sent back via socat:
Memcached returns the results of the commands over the secure TLS connection to socat.
socat decrypts the TLS data and passes it back to telnet over the plaintext connection.


Why This Setup is Useful
This setup is useful when:

Your Memcached server is secure and only accepts TLS connections.
You have a legacy client (like telnet or an application) that doesn’t support TLS natively.
Socat acts as a proxy to handle the secure connection on behalf of the plaintext client, allowing you to communicate with Memcached over a secure connection without needing the client to support TLS.

Links:
https://github.com/memcached/memcached/pull/440
https://groups.google.com/g/memcached/c/9virTWYT_6s/m/Mh6b_DGUAwAJ
Install Cert-Manager:
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.yaml
Memcached TLS Argument

args:
        - "--enable-ssl"
        - "-o"
        - "ssl_chain_cert=/usr/certs/server.crt"
        - "-o"
        - "ssl_key=/usr/certs/server.key"
        - "-o"
        - "ssl_ca_cert=/usr/certs/ca.crt"

Exporter TLS Argument:

- --memcached.tls.enable
- --memcached.tls.cert-file=/certs/exporter.crt
- --memcached.tls.key-file=/certs/exporter.key
- --memcached.tls.ca-file=/certs/ca.crt

Certificate Decoder:
https://certlogik.com/decoder/
TLS Rotate Certificate
kc port-forward -n demo memcd-quickstart-0 11211
socat -d - OPENSSL:127.0.0.1:11211,verify=0
openssl s_client -connect 127.0.0.1:11211
openssl x509 -in <(openssl s_client -connect 127.0.0.1:11211 -showcerts < /dev/null 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p') -noout -enddate
make container push