#!/usr/bin/env bash

echo "password1" >bootstrap/pat.password.example
podman pod rm -f pod_headquarters
podman network rm headquarters_default
podman rm -f soft-serve
docker compose build
docker compose up -d
docker exec soft-serve bash -c "git clone https://github.com/SkogAI/bootstrap.git ~/bootstrap && cd ~/bootstrap && ./bootstrap.sh"
