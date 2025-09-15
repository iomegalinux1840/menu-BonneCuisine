#!/bin/bash

# Connect to Railway SSH and check logs
echo "Checking Railway production logs..."
echo "tail -n 200 /rails/log/production.log" | railway ssh --project=9c219e52-7b0f-4a2a-a269-0a73a0b62fd5 --environment=3936365b-1dd1-4111-ac18-eb6048b56617 --service=fcd3dcad-21ee-4e99-aabd-f490bef2f175