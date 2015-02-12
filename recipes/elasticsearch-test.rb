node.default[:elasticsearch][:cluster][:name] = "#{node['name']}"
include_recipe 'iocdb-infrastructure::elasticsearch'
