#!/bin/sh

if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
  echo "Error: CLOUDFLARE_API_TOKEN is not set."
  exit 1
fi

echo "Verifying Cloudflare API Token..."

RESPONSE=$(curl -s "https://api.cloudflare.com/client/v4/user/tokens/verify" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json")

if echo "$RESPONSE" | grep -q '"success":true'; then
  echo "Cloudflare API Token verification successful."
else
  echo "Error: Cloudflare API Token verification failed."
  echo "Response: $RESPONSE"
  exit 1
fi

exec "$@"
