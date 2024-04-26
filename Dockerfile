FROM mcr.microsoft.com/mssql/server:2022-CU12-ubuntu-22.04

RUN chown -R 10001:10001 /opt/mssql/bin