# caddy-cloudflare

![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/nhitz/caddy-cloudflare/build-and-push.yml)
![Docker Image Size with architecture (latest by date/latest semver)](https://img.shields.io/docker/image-size/liquidgoat/caddy-cloudflare?arch=arm64&logo=caddy&logoColor=green&link=https%3A%2F%2Fhub.docker.com%2Frepository%2Fdocker%2Fliquidgoat%2Fcaddy-cloudflare%2Fgeneral)
![GitHub License](https://img.shields.io/github/license/nhitz/caddy-cloudflare)

Caddy with integrated support for Cloudflare DNS-01 ACME verification challenges.

**Please see the official [Caddy Docker Image](https://hub.docker.com/_/caddy) for more detailed deployment instructions.**

## Images

Includes image for both amd64 and arm64, rebuilt every Monday morning at 0300 UTC.

## Requirements
1. A Cloudflare account
2. All domains you want to use with Caddy MUST be on your Cloudflare account. Any domains not through Cloudflare should use another verification method using the `tls` block [here](https://caddyserver.com/docs/caddyfile/directives/tls).

## Instructions:

1. Obtain your Cloudflare API token by visiting your Cloudflare dashboard and creating a token with the following permissions:
	- Zone / Zone / Read
	- Zone / DNS / Edit

2. Set your cloudflare api token in secret.txt which will be used as a Docker secret:
	```
 	echo "asdf789adfg78_ad0fgh0dfg70adfg7" | cat > secret.txt
 	```

3. Set read-only permission to the secret:
	```
	chmod 400 secret.txt
 	```

4. Add this snippet to your Caddyfile:
	```Caddyfile
	(tls-cloudflare) {
		tls {
			dns cloudflare {env.CLOUDFLARE_API_TOKEN}
		}
	}
	```
 
 5. Import the snippet where you declare your domain:
 	```Caddyfile
  	www.example.net, example.net {
		import tls-cloudflare
		respond "wawaweewa"
	}
	```
 
6. Create a docker-compose.yml (substituting your own email address):
   
	```yaml
	version: "3.8"
	
	services:
	  caddy:
	    image: ghcr.io/nhitz/caddy-cloudflare:latest
 	    container_name: caddy
	    restart: unless-stopped
	    environment:
	      ACME_EMAIL: "you@example.net"
	      ACME_AGREE: 'true'
	    ports:
	      - "80:80"
	      - "443:443"
	    volumes:
	      - ./caddy_data:/data
	      - ./caddy_config:/config
	      - $PWD/Caddyfile:/etc/caddy/Caddyfile
	    secrets:
	      - cloudflare_api_token
	
	secrets:
	  cloudflare_api_token:
	    file: ./secret.txt
	```
 
7. Do the thing:
	```
	docker compose up --detached
	```
