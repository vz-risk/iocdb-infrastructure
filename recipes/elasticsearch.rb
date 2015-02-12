node.default[:elasticsearch][:cluster][:name] = node[:envname]

include_recipe 'iocdb-infrastructure::iocdb'
include_recipe 'java'
include_recipe 'elasticsearch'
include_recipe 'elasticsearch::plugins'

