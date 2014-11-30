# iocdb-infrastructure

IOCDB infrastructure specification (chef cookbook)

## Supported Platforms

Tested in terremark vcloud using ubuntu 1404 images.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['iocdb-infrastructure']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### General playbook
- Deploy a workstation with chefdk
- On the workstation: git the iocdb-infrastructure repo
- From the vcloud console: "import" a template image
- Log into the new node (using the dynamically allocated IP detected in the 
vcloud console) and get the mac address.
- Update /etc/dhcp/dhcpd.conf on the dhcp server with the new host, reboot the
dhcp server with the new config, and reboot the new node.
- from the workstation run the knife bootstrap command
```
sudo knife bootstrap <NODE_IP> -x <ADMIN_USER> --sudo -r iocdb-infrastructure::<NODE_RECIPE> --solo -N <NODE_NAME>
```

### iocdb-infrastructure::default

Include `iocdb-infrastructure` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[iocdb-infrastructure::default]"
  ]
}
```

## License and Authors

Author:: YOUR_NAME (<YOUR_EMAIL>)
