# TODO: requires root to have a github key. a better solution
# would be an encrypted data bag with the key

include_recipe 'iocdb-infrastructure::iocdb'
include_recipe 'git'
include_recipe 'python'

#-------------------------------------------------------------------------------------------
# New staged repos method
#   Note: Use iocdb_prov and repos staged at ssh://iocdb_prov@iocdb-staging/staged-repos/ 
#   now instead of nates old account and githib.
#-------------------------------------------------------------------------------------------
execute 'add host iocdb-staging to known hosts if not already there' do
  command 'ssh iocdb_prov@iocdb-staging -o StrictHostKeyChecking=no'
  returns 0
end

python_pip 'mapping-tools' do
  package_name 'git+ssh://iocdb_prov@iocdb-staging/staged-repos/mapping-tools.git#egg=mapping-tools'
  options '-e'
end

python_pip 'query-tools' do
  package_name 'git+ssh://iocdb_prov@iocdb-staging/staged-repos/query-tools.git#egg=query-tools'
  options '-e'
end

python_pip 'iocdb' do
  package_name 'git+ssh://iocdb_prov@iocdb-staging/staged-repos/iocdb.git#egg=iocdb'
  options '-e'
end

#------------------------------------------------------------------------------------
# Old github method
#-------------------------------------------------------------------------------------------
#execute 'add github to known hosts' do
#  command 'ssh git@github.com -o StrictHostKeyChecking=no'
#  returns 1
#end
#
#python_pip 'mapping-tools' do
#  package_name 'git+https://github.com/natb1/mapping-tools.git#egg=mapping-tools'
#  options '-e'
#end
#
#python_pip 'query-tools' do
#  package_name 'git+https://github.com/natb1/query-tools.git#egg=query-tools'
#  options '-e'
#end
#
#python_pip 'iocdb' do
#  package_name 'git+git@github.com:vz-risk/iocdb.git#egg=iocdb'
#  options '-e'
#end

template '/src/iocdb/iocdb/data/iocdb_config.py' do
  source 'iocdb_config.erb'
end
