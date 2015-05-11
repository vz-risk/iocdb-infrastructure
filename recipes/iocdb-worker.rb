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

%{CISCP iid iid/INCOMING-ALL-HOSTS iid/INCOMING-ALL-IP iid/INCOMING-ALL-URL iid/INCOMING-DGA Shadowserver support-intelligence support-intelligence/db4i support-intelligence/db4i-archive support-intelligence/dob support-intelligence/dob-archive support-intelligence/ip support-intelligence/ip-archive support-intelligence/ngtld support-intelligence/scripts-when-broke support-intelligence/url support-intelligence/url-archive VZW-Damballa} do |subdir_name|
  directory "/var/data/incoming/#{subdir_name}" do
    owner 'iocdb_prov'
    group 'iocdb_prov'
    mode '0775'
  end
end



  


 



MSS
  archive




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

execute 'start workers' do
  command 'service celery-worker start'
  user 'root'
end

execute 'start beat' do
  command 'service celery-beat start'
  user 'root'
end

# TODO: I don't know why this command isn't working, just run manually
#execute 'start workers' do
  #command 'celery -A dispatcher multi start default --maxtasksperchild=1 -Q:default celery -l INFO --logfile=/var/log/iocdb-worker/%n.log --pidfile=/var/run/iocdb-worker/%n.pid'
  #user 'iocdb_worker'
#end

# TODO: same as above
#bash 'start beat' do
#  command 'celery -A dispatcher beat -l INFO --logfile=/var/log/iocdb-worker/beat.log --pidfile=/var/run/iocdb-worker/beat.pid -s /var/run/iocdb-worker/beat-schedule --detach'
#  user 'iocdb_worker'
#end
