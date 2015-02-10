yum install -y nfs-utils system-config-nfs
systemctl enable rpcbind
systemctl enable nfs-server
service rpcbind start
service nfs-server start


DEFAULT_ZONE=`sudo firewall-cmd --get-default-zone`
firewall-cmd --permanent --zone ${DEFAULT_ZONE} --add-service mountd
firewall-cmd --permanent --zone ${DEFAULT_ZONE} --add-service rpc-bind
firewall-cmd --permanent --zone ${DEFAULT_ZONE} --add-service nfs
firewall-cmd --permanent --zone ${DEFAULT_ZONE} --add-port=2049/udp
firewall-cmd --reload
