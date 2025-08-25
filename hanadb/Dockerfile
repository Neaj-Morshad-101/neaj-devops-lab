# Dockerfile.sap-hana
FROM sles15-sp4:latest

# Install prerequisites
RUN zypper --non-interactive install \
      curl tar sudo libatomic1 lsof

# Copy SAPCAR and HANA installation media into image
COPY SAPCAR_*.SAR /hana-install/
COPY HANA_SERVER_* /hana-install/

# Unpack and install
WORKDIR /hana-install
RUN SAPCAR -xvf SAPCAR_*.SAR && \
    ./hdbinst --batch --sapmnt=/hana/shared --sid=HDB --number=00 \
              --hostname=$(hostname) --password="$HDBADM_PASS"

# Adjust permissions & create entrypoint
RUN mkdir -p /hana/log /hana/data && \
    chown -R sapsys:sapsys /hana

USER sapsys
ENV PATH=/hana/shared/HDB/HDB00/exe:$PATH

# start HANA when container runs
ENTRYPOINT ["/hana/shared/HDB/HDB00/exe/hdbdaemon"]
CMD ["--start"]
