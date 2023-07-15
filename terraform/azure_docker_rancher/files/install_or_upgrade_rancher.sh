${replace != null ? "REPLACE=\"${replace}\"" : "unset REPLACE"}
VOLUME_COMMAND=""
if docker inspect rancher 1>/dev/null 2>/dev/null; then
    container_id=$(docker stop rancher)
    docker rm -f rancher-data || true
    if [ -z "$REPLACE" ]; then
        docker create --volumes-from rancher --name rancher-data $(docker inspect rancher --format="{{ .Config.Image }}")
        VOLUME_COMMAND="--volumes-from rancher-data"
    fi
    docker rm $container_id
fi

docker run -d --restart=unless-stopped $VOLUME_COMMAND \
--name rancher \
-p 80:80 -p 443:443 -p 6443:6443 \
--privileged \
-e 'CATTLE_BOOTSTRAP_PASSWORD=${bootstrap_password}' \
${image}
