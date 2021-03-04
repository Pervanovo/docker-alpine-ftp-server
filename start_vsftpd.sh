#!/bin/sh

if [ $CHROOT_LOCAL_USER ]; then
  echo "chroot_local_user=YES" >> $VSFTP_CONF
fi

if [ $ALLOW_WRITEABLE_CHROOT ]; then
  echo "allow_writeable_chroot=YES" >> $VSFTP_CONF
fi

#Remove all ftp users
grep '/ftp/' /etc/passwd | cut -d':' -f1 | xargs -n1 deluser

#Create users
#USERS='name1|password1|[folder1][|uid1] name2|password2|[folder2][|uid2]'
#may be:
# user|password foo|bar|/home/foo
#OR
# user|password|/home/user/dir|10000
#OR
# user|password||10000

#Default user 'ftp' with password 'alpineftp'

if [ -z "$USERS" ]; then
  USERS="ftp|alpineftp"
fi

for i in $USERS ; do
    NAME=$(echo $i | cut -d'|' -f1)
    PASS=$(echo $i | cut -d'|' -f2)
  FOLDER=$(echo $i | cut -d'|' -f3)
     UID=$(echo $i | cut -d'|' -f4)

  if [ -z "$FOLDER" ]; then
    FOLDER="/ftp/$NAME"
  fi

  if [ ! -z "$UID" ]; then
    UID_OPT="-u $UID"
  fi

  echo -e "$PASS\n$PASS" | adduser -h $FOLDER -s /sbin/nologin $UID_OPT $NAME
  mkdir -p $FOLDER
  chown $NAME:$NAME $FOLDER
  if [ $CHROOT_LOCAL_USER ] && [ ! $ALLOW_WRITEABLE_CHROOT ]; then
    chmod a-w $FOLDER
  fi
  unset NAME PASS FOLDER UID
done


if [ -z "$MIN_PORT" ]; then
  MIN_PORT=21000
fi

if [ -z "$MAX_PORT" ]; then
  MAX_PORT=21010
fi

if [ ! -z "$ADDRESS" ]; then
  ADDR_OPT="-opasv_address=$ADDRESS"
fi

# Used to run custom commands inside container
if [ ! -z "$1" ]; then
  exec "$@"
else
  exec /usr/sbin/vsftpd -opasv_min_port=$MIN_PORT -opasv_max_port=$MAX_PORT $ADDR_OPT $VSFTP_CONF
fi

