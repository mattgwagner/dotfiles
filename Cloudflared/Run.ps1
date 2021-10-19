.\cloudflared-windows-amd64.exe --version

# cloudflared tunnel login

# cloudflared tunnel create <NAME>

# cloudflared tunnel --config tunnels/config.yaml run

# When you create a tunnel, Cloudflare generates a subdomain of cfargotunnel.com 
# with the UUID of the created tunnel. You can treat that subdomain as if it were 
# an origin target in the Cloudflare dashboard.

# Create a new CNAME record and input the subdomain of your tunnel into the Target field.

# cloudflared tunnel route dns <NAME> <hostname>

# cloudflared tunnel --config path/config.yaml run <NAME>