Using https://github.com/NginxProxyManager/nginx-proxy-manager to setup routing to internal hosts.

Default Login:

admin@example.com / changeme

If routing to other containers, you should probably create a named network and you can then add routing proxy hosts in NPM by container name.

Otherwise, you'll add destinations like host.docker.internal.