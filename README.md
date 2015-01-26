# iocdb-infrastructure

IOCDB infrastructure specification (chef cookbook)

## Supported Platforms

Tested in terremark vcloud using ubuntu 1404 images.

## Playbook

### Provisioning a provisioner
- deploy chefdk https://downloads.getchef.com/chef-dk/
- install the knife solo plugin
```
/opt/chefdk/embedded/bin/gem install knife-solo
knife solo init .
```
- git the iocdb-infrastructure repo
- cd iocdb-infrastructure; berks install

### Provisioning a new node
- from the vcloud console: "import" a template image
- allocate an IP to the new node
- deploy chef to the new node
```
knife solo prepare <NODE_IP> -N <NODE_NAME> --bootstrap-version 11
```
- configure the new node found in `nodes/<NODE_NAME>`
(with at least a run\_list). eg:
```
{
  "run_list": [
    "iocdb-infrastructure::rabbitmq",
    "iocdb-infrastructure::iocdb-worker"
  ]
}
```
- provision the new node
```
knife solo cook <NODE_IP> -N <NODE_NAME>
```

