source ./.env

rsync -av ./.vscode $RPI_HOSTNAME.local:/home/$RPI_USERNAME/
rsync -av ./raspberrypi/ $RPI_HOSTNAME.local:/home/$RPI_USERNAME/
