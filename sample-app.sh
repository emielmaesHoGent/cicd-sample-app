#!/bin/bash
set -euo pipefail

# Functie om een directory te maken als deze nog niet bestaat
create_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
    else
        echo "Directory '$1' bestaat al."
    fi
}

# Maak de benodigde directories
create_directory tempdir
create_directory tempdir/templates
create_directory tempdir/static

# Kopieer bestanden naar tempdir
cp sample_app.py tempdir/.
cp -r templates/* tempdir/templates/ 2>/dev/null || echo "Geen templates gevonden om te kopiëren."
cp -r static/* tempdir/static/ 2>/dev/null || echo "Geen statische bestanden gevonden om te kopiëren."

# Maak Dockerfile aan
cat > tempdir/Dockerfile << _EOF_
FROM python:3.9-slim
RUN pip install flask
COPY ./static /home/myapp/static/
COPY ./templates /home/myapp/templates/
COPY sample_app.py /home/myapp/
EXPOSE 5050
CMD ["python", "/home/myapp/sample_app.py"]
_EOF_

# Bouw en draai de Docker container
cd tempdir || exit
docker build -t sampleapp .
docker run -t -d -p 5050:5050 --name samplerunning sampleapp
docker ps -a
