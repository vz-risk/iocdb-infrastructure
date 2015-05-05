# TODO: requires root to have a github key. a better solution
# would be an encrypted data bag with the key

include_recipe 'iocdb-infrastructure::iocdb'
include_recipe 'git'
include_recipe 'python'

execute 'add host iocdb-staging to known hosts if not already there' do
  command 'ssh iocdb_prov@iocdb-staging -o StrictHostKeyChecking=no'
  returns 0
end

python_pip 'iocdb' do
  package_name 'git+ssh://iocdb_prov@iocdb-staging/staged-repos/iocdb.git@dev-ci#egg=iocdb'
#  package_name 'git+ssh://iocdb_prov@iocdb-staging/staged-repos/iocdb.git@origin/master#egg=iocdb'
  options '-e'
end

template '/src/iocdb/iocdb/data/settings.yaml' do
  source "host-#{node['hostname']}/settings.yaml"
end

template '/src/iocdb/iocdb/data/iocdb_config.py' do
  source "host-#{node['hostname']}/iocdb_config.erb"
end
