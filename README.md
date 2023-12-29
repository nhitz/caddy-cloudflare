# caddy-cloudflare

![docker build](https://github.com/nhitz/caddy-cloudflare/actions/workflows/auto-build-on-base-image-change.yml/badge.svg)


Caddy with integrated support for Cloudflare DNS-01 ACME verification challenges.

**Please see the official [Caddy Docker Image](https://hub.docker.com/_/caddy) for more detailed deployment instructions.**

## Images

Includes image for alpine version of Caddy, rebuilt every Monday morning at 0300 UTC.

## Requirements
1. A Cloudflare account
2. All domains you want to use with Caddy MUST be on your Cloudflare account. Any domains not through Cloudflare should use another verification method using the `tls` block [here](https://caddyserver.com/docs/caddyfile/directives/tls).

## Instructions:

1. Obtain your Cloudflare API token by visiting your Cloudflare dashboard and creating a token with the following permissions:
	- Zone / Zone / Read
	- Zone / DNS / Edit

2. Add this snippet to your Caddyfile:
	```Caddyfile
	(tls-cloudflare) {
		tls {
			dns cloudflare {env.CLOUDFLARE_API_TOKEN}
		}
	}
	```
 
 3. Import the snippet where you declare your domain:
 	```Caddyfile
  	www.example.net, example.net {
		import tls-cloudflare
		respond "wawaweewa"
	}
	```

4. Set your cloudflare api token in CLOUDFLARE_API_TOKEN.txt which will be used as a Docker secret:
	```
 	echo "asdf789adfg78_ad0fgh0dfg70adfg7" | cat > CLOUDFLARE_API_TOKEN.txt
 	```
 
5. Set read only permission to the secret:
	```
	chmod 400 CLOUDFLARE_API_TOKEN.txt
 	```

6. Create an external docker bridge network for caddy and any other containers to use:
	```
 	docker network create --driver bridge caddynet
 	```
 
7. Create a docker-compose.yml (substituting your own email address):
   
	```yaml
	version: "3.8"
	
	services:
	  caddy:
	    image: ghcr.io/nhitz/caddy-cloudflare:alpine
 	    container_name: caddy
	    restart: unless-stopped
	    environment:
	      ACME_EMAIL: "you@example.net"
	      CLOUDFLARE_API_TOKEN: /run/secrets/api_token
	      ACME_AGREE: 'true'
	    ports:
	      - "80:80"
	      - "443:443"
	      - "443:443/udp"
	    volumes:
	      - caddy_data:/data
	      - caddy_config:/config
	      - $PWD/Caddyfile:/etc/caddy/Caddyfile
	    secrets:
	      - api_token
	
	secrets:
	  api_token:
	    file: ./CLOUDFLARE_API_TOKEN.txt
 
	volumes:
	  caddy_data:
	    name: caddy_data
	  caddy_config:
	    name: caddy_config
	
	networks:
	  default:
	    name: caddynet
	    external: true
	```
 
8. Run it!
	```
	docker compose up --detached
	```

10. Verify you can't inspect the api token from the docker environment variable:
	```
	FORMAT='{{range .Config.Env}}{{if eq (index (split . "=") 0) "CLOUDFLARE_API_TOKEN"}}{{println .}}{{end}}{{end}}'
	docker inspect --format="$FORMAT" caddy
	```
