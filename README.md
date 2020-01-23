# docker-debian9-build-node

Dockerfile for a Debian 10 (buster) build node.


## Building

    $ docker build -t <tag> <path_to_dockerfile>

To create the official container image, substitute `<tag>` with
_screamingudder/debian10-build-node:<version>_. The build might take relatively long,
as we build Python from source.
