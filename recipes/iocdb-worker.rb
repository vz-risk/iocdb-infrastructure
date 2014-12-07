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

# TODO: I don't know why this command isn't working, just run manually
#execute 'start workers' do
  #command 'iocdb-worker multi start default --maxtasksperchild=1 -Q:default celery -l INFO --logfile=/var/log/iocdb-worker/%n.log --pidfile=/var/run/iocdb-worker/%n.pid'
  #user 'iocdb_worker'
#end

# TODO: same as above
#bash 'start beat' do
#  command 'iocdb-worker beat -l INFO --logfile=/var/log/iocdb-worker/beat.log --pidfile=/var/run/iocdb-worker/beat.pid -s /var/run/iocdb-worker/beat-schedule --detach'
#  user 'iocdb_worker'
#end
