#!/bin/bash -eux

echo "Destroying edge"

cat << EOF > pynsxv/nsx.ini
[nsxv]
nsx_manager = $NSX_EDGE_GEN_NSX_MANAGER_ADDRESS
nsx_username = $NSX_EDGE_GEN_NSX_MANAGER_ADMIN_USER
nsx_password = $NSX_EDGE_GEN_NSX_MANAGER_ADMIN_PASSWD

[vcenter]
vcenter = $VCENTER_HOST
vcenter_user = $VCENTER_USR
vcenter_passwd = $VCENTER_PWD

[defaults]
transport_zone = $NSX_EDGE_GEN_NSX_MANAGER_TRANSPORT_ZONE
datacenter_name = $VCENTER_DATA_CENTER
edge_datastore =  $NSX_EDGE_GEN_EDGE_DATASTORE
edge_cluster = $NSX_EDGE_GEN_EDGE_CLUSTER
EOF

pushd pynsxv

pynsxv_local() {
  python pynsxv/cli.py "$@"
}

get_cidr() {
  IP=$1
  MASK=$2
  FIRST_THREE=$(echo $IP|cut -d. -f 1,2,3)
  echo "$FIRST_THREE.0/$MASK"
}

NUM_LOGICAL_SWITCHES=3

# Create an edge
pynsxv_local esg delete -n $NSX_EDGE_GEN_NAME 

# Create logical switches
for labwire_id in $(seq $NUM_LOGICAL_SWITCHES); do
  pynsxv_local lswitch -n "labwire-proto-0$labwire_id" delete
done
