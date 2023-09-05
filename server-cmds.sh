#!/usr/bin/env bash

export IMAGE=$1
sudo docker compose -f docker-compose.yaml up -d
echo "success