if [ -r /etc/os-release ]; then
    lsb_dist="$(. /etc/os-release && echo "$ID")"
fi

case "$lsb_dist" in
	ubuntu|debian|raspbian)
        echo "Running sudo apt update..."
        sudo apt update -qq
    ;;
esac

echo "Installing Docker..."
curl https://releases.rancher.com/install-docker/${docker_version}.sh | sh;

return=1;
while [ $return != 0 ]; do
    sleep 2; 
    docker ps; 
    return=$?;
done
