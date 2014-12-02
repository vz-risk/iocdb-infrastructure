node.default[:elasticsearch]['node.data'] = true
node.default[:elasticsearch]['node.master'] = false

execute 'parted -a optimal /dev/sdb mklabel msdos' do
  creates '/dev/sdb1'
end

execute 'parted -a optimal /dev/sdb mkpart primary 0% 100%' do
  creates '/dev/sdb1'
end

node.default[:elasticsearch][:data][:devices]['/dev/sdb1'] = {
  'file_system' => 'ext3',
  'mount_options' => 'rw,user',
  'mount_path' => '/usr/local/var/data/elasticsearch/disk1',
  'format_command' => 'mkfs.ext3',
  'fs_check_command' => 'dumpe2fs'
}

node.default[:elasticsearch][:path][:data] = '/usr/local/var/data/elasticsearch/disk1'

include_recipe 'iocdb-infrastructure::elasticsearch'
