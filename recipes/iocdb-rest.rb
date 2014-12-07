include_recipe 'iocdb-infrastructure::iocdb-client'

user 'iocdb_rest' do
  system
end

file '/var/log/iocdb-rest' do
  owner 'iocdb_rest'
end

directory '/var/run/iocdb' do
  owner 'iocdb_rest'
end

execute 'iocdb-rest' do
  # TODO: I can't figure out why this won't daemonize w/o root
  #user 'iocdb_rest'
end
