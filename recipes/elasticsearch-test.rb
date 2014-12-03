node.default[:elasticsearch][:cluster][:name] = "#{node['name']}-test"
include_recipe 'iocdb-infrastructure::elasticsearch'
