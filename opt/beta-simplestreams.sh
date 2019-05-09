sudo apt install simplestreams
KEYRING_FILE=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg
IMAGE_SRC=https://images.maas.io/ephemeral-v3/daily/
IMAGE_DIR=/var/www/html/maas/images/ephemeral-v3/daily
sudo sstream-mirror --keyring=$KEYRING_FILE $IMAGE_SRC $IMAGE_DIR \
'arch=amd64' 'release~(precise|trusty|xenial|bionic|cosmic)' --max=1 --progress
sudo sstream-mirror --keyring=$KEYRING_FILE $IMAGE_SRC $IMAGE_DIR \
'os~(grub*|pxelinux)' --max=1 --progress

sudo apt install nginx

sudo vim /etc/nginx/sites-enabled/default

location /maas {
  autoindex on;
}

sudo systemctl restart nginx.service

maas admin boot-source delete 1

maas admin boot-sources create \
url=http://10.10.0.149/maas/images/ephemeral-v3/daily/ \
keyring_filename=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg

maas admin boot-source-selections create 2 \
    os="ubuntu" release="bionic" arches="amd64" \
    subarches="*" labels="*"

maas admin boot-source-selections create 2 \
    os="ubuntu" release="xenial" arches="amd64" \
    subarches="*" labels="*"

maas admin boot-source-selections create 2 \
    os="ubuntu" release="trusty" arches="amd64" \
    subarches="*" labels="*"

maas admin boot-source-selections create 2 \
    os="ubuntu" release="precise" arches="amd64" \
    subarches="*" labels="*"

maas admin boot-resources import

Cron:
sstream-mirror --keyring=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg https://images.maas.io/ephemeral-v3/daily/ /var/www/html/maas/images/ephemeral-v3/daily 'os~(grub*|pxelinux)' --max=1 --progress
