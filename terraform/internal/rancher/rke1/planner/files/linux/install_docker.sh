curl https://releases.rancher.com/install-docker/${docker_version}.sh | sh

return=1;
while [ $return != 0 ]; do
    sleep 2;
    docker ps;
    return=$?;
done