source ./.env

rsync -av ./.vscode $GCE_ADDRESS:/home/$GCE_USERNAME/
rsync -av ./gce/ $GCE_ADDRESS:/home/$GCE_USERNAME/
