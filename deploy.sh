#! /bin/bash

set -e

echo "Building..."
docker build -t danbruder/booked:latest .

echo "Pushing..."
docker push danbruder/booked:latest

echo "Deploying..."
caprover deploy -i danbruder/booked:latest -a booked -n captain-01
