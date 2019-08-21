FROM mcr.microsoft.com/powershell:6.1.0-ubuntu-18.04

RUN apt-get update && apt-get install -y git

COPY pipeline.ps1 /pipeline.ps1
ENTRYPOINT ["pwsh", "/pipeline.ps1"]