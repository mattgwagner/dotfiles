https://gist.github.com/diegopacheco/a0f5307abbd4e4af8c9b03e599ab10cb

brew install supabase/tap/supabase

systemctl --user enable podman.socket
systemctl --user start podman.socket
systemctl --user status podman.socket
export DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock

supabase init
supabase start