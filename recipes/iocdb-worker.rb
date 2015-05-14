include_recipe 'iocdb-infrastructure::iocdb-client'

user 'iocdb_worker' do
  system
end

directory '/var/log/iocdb-worker' do
  owner 'iocdb_worker'
end

directory '/var/run/iocdb-worker' do
  owner 'iocdb_worker'
end

directory "/var/data" do
  owner 'root'
  group 'root'
  mode '0777'
end

directory "/var/data/run" do
  owner 'iocdb_prov'
  group 'iocdb_prov'
  mode '0775'
end

directory "/var/data/log" do
  owner 'iocdb_prov'
  group 'iocdb_prov'
  mode '0775'
end

directory "/var/data/incoming" do
  owner 'iocdb_prov'
  group 'iocdb_prov'
  mode '0775'
end

for subdir_name in [ "CISCP", "iid", "iid/INCOMING-ALL-HOSTS", "iid/INCOMING-ALL-IP", "iid/INCOMING-ALL-URL", "iid/INCOMING-DGA", "Shadowserver", "support-intelligence", "support-intelligence/db4i", "support-intelligence/db4i-archive", "support-intelligence/dob", "support-intelligence/dob-archive", "support-intelligence/ip", "support-intelligence/ip-archive", "support-intelligence/ngtld", "support-intelligence/scripts-when-broke", "support-intelligence/url", "support-intelligence/url-archive", "VZW-Damballa", "MSS", "MSS/archive" ] do
  directory "/var/data/incoming/#{subdir_name}" do
    owner "iocdb_prov"
    group "iocdb_prov"
    mode "0777"
  end
end

# Make iocdb dir accessible.  On some hosts there is an iocdb account (owner iocdb), others just a dir (owner root).  
directory "/home/iocdb" do
  group 'iocdb_prov'
  mode '0777'
end

link "/home/iocdb/incoming" do
  to "/var/data/incoming"
end

# add init script for celery beat
cookbook_file "celery-beat" do
  path '/etc/init.d/celery-beat'
  backup 0
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# add init script for celery worker
cookbook_file "celery-worker" do
  path '/etc/init.d/celery-worker'
  backup 0
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# add init script for celery flower
cookbook_file "celery-flower" do
  path '/etc/init.d/celery-flower'
  backup 0
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute 'start workers' do
  command 'service celery-worker start'
  user 'root'
end

execute 'start beat' do
  command 'service celery-beat start'
  user 'root'
end

execute 'start flower' do
  command 'service celery-flower start'
  user 'root'
end
