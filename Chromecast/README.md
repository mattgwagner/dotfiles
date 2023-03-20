Use a Docker container wrapping a Python app to cast a given URL to a Chromecast.

Based on https://hub.docker.com/r/ryanbarrett/catt-chromecast and https://bitbucket.org/ryan_barrett/catt-chromecast/src/master/ built rebuilt using latest source.

docker run --rm -e ARGUMENTS='-d 10.1.11.86 cast_site https://ismyinternetworking.com/' ryanbarrett/catt-chromecast

Usage: catt [options] command [args]

--device NAME_OR_IP

This isn't working with device names likely because of discovery issues inside Docker to the outside network.

Another option might be: https://github.com/andyoakley/cast-from-container