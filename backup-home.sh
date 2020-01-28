user=${1}
echo user: ${user}
read "press any key to continue"

cp -v --archive "${user}/*.* /run/media/g5/ext-backup-02-ma/bak/acer-centos-7-20200128/${user}"
cp -v --archive "${user}/Desktop /run/media/g5/ext-backup-02-ma/bak/acer-centos-7-20200128/${user}"
cp -v --archive "${user}/Documents /run/media/g5/ext-backup-02-ma/bak/acer-centos-7-20200128/${user}"
cp -v --archive "${user}/Music /run/media/g5/ext-backup-02-ma/bak/acer-centos-7-20200128/${user}"
cp -v --archive "${user}/Pictures /run/media/g5/ext-backup-02-ma/bak/acer-centos-7-20200128/${user}"
cp -v --archive "${user}/Videos /run/media/g5/ext-backup-02-ma/bak/acer-centos-7-20200128/${user}"
