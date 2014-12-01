node.default[:elasticsearch]['node.data'] = false
node.default[:elasticsearch]['node.master'] = true

include_recipe 'iocdb-infrastructure::elasticsearch'
