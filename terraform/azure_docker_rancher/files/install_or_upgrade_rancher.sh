${replace != null ? "REPLACE=\"${replace}\"" : "unset REPLACE"}
VOLUME_COMMAND=""
if [ -n "$(docker ps -aq --filter "name=rancher")" ]; then
    container_id=$(docker stop rancher)
    if [ -n "$(docker ps -aq --filter "name=rancher-data")" ]; then
        docker rm -f rancher-data
    fi
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
-e 'CATTLE_AGENT_IMAGE=${agent_image}' \
${image}
