#!/bin/sh

API_TOKEN_FILE="/run/secrets/cloudflare_api_token"

if [ -f "$API_TOKEN_FILE" ]; then
    export CLOUDFLARE_API_TOKEN=$(cat "$API_TOKEN_FILE")
    echo "Verifying Cloudflare API Token..."

    # Verify the API token
    RESPONSE=$(curl -s "https://api.cloudflare.com/client/v4/user/tokens/verify" \
                    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
                    -H "Content-Type: application/json")

    # Check if the verification was successful
    if echo "$RESPONSE" | grep -q '"success":true'; then
        echo "Cloudflare API Token verification successful."
    else
        echo "Error: Cloudflare API Token verification failed."
        echo "Response: $RESPONSE"
        exit 1
    fi

else
    echo "Error: $API_TOKEN_FILE does not exist or is not a file."
    exit 1
fi

exec "$@"
