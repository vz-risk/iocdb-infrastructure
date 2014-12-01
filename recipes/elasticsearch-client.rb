node.default[:elasticsearch]['node.data'] = false
node.default[:elasticsearch]['node.master'] = false

include_recipe 'iocdb-infrastructure::elasticsearch'
