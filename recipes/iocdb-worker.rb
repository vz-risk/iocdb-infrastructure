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

# add init script for celery beat
cookbook_file "celery-beat" do
  path '/etc/init.d/celery-beat'
  backup 'false'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# add init script for celery worker
cookbook_file "celery-worker" do
  path '/etc/init.d/celery-worker'
  backup 'false'
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
