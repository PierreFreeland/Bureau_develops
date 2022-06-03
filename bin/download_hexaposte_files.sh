#!/bin/bash -ex

# constantes
HOST=$HEXAPOSTE_HOST
LOGIN=$HEXAPOSTE_LOGIN
PASSWORD=$HEXAPOSTE_PASSWORD
PORT=21

function downloadFile() {
  ncftpget -t 60 -d stdout -u ${LOGIN} -p ${PASSWORD} ${HOST} . ${filename}
}

cd $HEXAPOSTE_DIR


# removes all the previous files
rm -f *.tri

# because of some issues with the ftp server, we need to fetch and parse locally the file list
for filename in `echo 'ls' | ncftp -u ${LOGIN} -p ${PASSWORD} ${HOST} | grep .zip`
do
  retry=0
  maxRetries=5
  retryInterval=15

  echo "downloading ${filename} (iter:${retry}, max:${maxRetries})"

  until [ ${retry} -ge ${maxRetries} ]
  do
    downloadFile && break
    retry=$[${retry}+1]
    echo "Download failed, retrying [${retry}/${maxRetries}] in ${retryInterval}(s)"
    sleep ${retryInterval}
  done

  if [ ${retry} -ge ${maxRetries} ]; then
    echo "File ${filename} download failed after ${maxRetries} attempts!"
    exit 1
  fi
done

echo "full download comleted"

unzip "*.zip"
rm -f *.zip
