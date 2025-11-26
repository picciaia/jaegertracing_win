# define a container image based on the official Microsoft Server Core image as base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# copy jaeger.exe
# download jaeger from https://download.jaegertracing.io/v1.75.0/jaeger-2.12.0-windows-amd64.tar.gz
RUN mkdir c:\Jaeger
COPY setup/jaeger.exe C:/Jaeger/jaeger.exe

# copy jaeger configuration file
COPY setup/all-in-one.yaml C:/Jaeger/config.yaml

# expose jaeger ports
EXPOSE 6831 6832 5778 16686 14268 14250 9411

# set working directory
WORKDIR "C:\Jaeger"

# start Jaeger in foreground
CMD ["jaeger.exe", "--config", "config.yaml"]
# CMD ["ping", "-t", "localhost"]





