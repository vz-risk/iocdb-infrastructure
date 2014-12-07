# iocdb-infrastructure

IOCDB infrastructure specification (chef cookbook)

## Supported Platforms

Tested in terremark vcloud using ubuntu 1404 images.

## Usage

### General playbook
- Deploy a workstation with chefdk
- On the workstation: git the iocdb-infrastructure repo
- cd iocdb-infrastructure; berks install
- From the vcloud console: "import" a template image
- Log into the new node (using the dynamically allocated IP detected in the 
vcloud console) and get the mac address.
- Update /etc/dhcp/dhcpd.conf on the dhcp server with the new host (reload the new config)
- Restart the interface on the new node `sudo ifdown eth0; sudo ifup eth0`
- from the workstation run the knife bootstrap command
```
sudo knife bootstrap <NODE_IP> -x <ADMIN_USER> --sudo -r iocdb-infrastructure::<NODE_RECIPE> --solo -N <NODE_NAME>
```

