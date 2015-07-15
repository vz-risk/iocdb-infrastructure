include_recipe 'iocdb-infrastructure::iocdb-client'

# iocdb-rest is now installed as part of the iocdb cli (iocdb-client). 

# add init script for iocdb-rest
cookbook_file "iocdb-rest" do
  path '/etc/init.d/iocdb-rest'
  backup 0
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute 'start iocdb-rest' do
  command 'service iocdb-rest start'
  user 'root'
end
