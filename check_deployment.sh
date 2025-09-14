#!/bin/bash

URL="https://menu-bonnecuisine-production.up.railway.app/"

echo "Checking Railway deployment at $(date)..."
echo "Testing URL: $URL"

# Check HTTP status
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

if [ "$STATUS" = "200" ]; then
    echo "✅ SUCCESS! Site is up and running (HTTP $STATUS)"
    echo "Content preview:"
    curl -s "$URL" | head -20
else
    echo "❌ FAILED! Site returned HTTP $STATUS"
    echo "Possible issues:"
    echo "- Container may have crashed"
    echo "- Database connection failed"
    echo "- Port binding issue"
    echo "- Secret key or environment variable missing"
fi

echo ""
echo "Check Railway logs for details at:"
echo "https://railway.app/project/[your-project-id]/service/[your-service-id]"