# create dir and correct directory permission
directory '/opt/iocdb' do
  owner 'iocdb_prov'
  group 'iocdb_prov'
  mode '0775'
end

# install the legacy data entry gui
cookbook_file "iocdb-data-entry-gui.py" do
  path '/opt/iocdb/iocdb-data-entry-gui.py'
  backup 0
  owner 'iocdb_prov'
  group 'iocdb_prov'
  mode '0775'
  action :create
end

# add init script for legacy data entry gui
cookbook_file "iocdb-data-entry-gui" do
  path '/etc/init.d/iocdb-data-entry-gui'
  backup 0
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute 'start direct entry gui' do
  command 'service iocdb-data-entry-gui start'
  user 'root'
end
