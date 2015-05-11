# TODO: requires root to have a github key. a better solution
# would be an encrypted data bag with the key

include_recipe 'iocdb-infrastructure::iocdb'
include_recipe 'git'
include_recipe 'python'

execute 'add host iocdb-staging to known hosts if not already there' do
  command 'ssh iocdb_prov@iocdb-staging -o StrictHostKeyChecking=no'
  returns 0
end

apt_package "python-lxml" do
  action :install
end
apt_package "libxml2-dev" do
  action :install
end
apt_package "libxslt1-dev" do
  action :install
end
apt_package "python-dev" do
  action :install
end
apt_package "zlib1g-dev" do
  action :install
end
apt_package "python-psycopg2" do
  action :install
end

python_pip 'iocdb' do
  package_name 'git+ssh://iocdb_prov@iocdb-staging/staged-repos/iocdb.git@dev-ci#egg=iocdb'
#  package_name 'git+ssh://iocdb_prov@iocdb-staging/staged-repos/iocdb.git@origin/master#egg=iocdb'
  options '-e'
end

execute "chmod /src/iocdb to iocdb_prov" do
  cwd '/src/iocdb'
  user "root"
  command "chmod -R iocdb_prov:iocdb_prov /src/iocdb"
end

template '/src/iocdb/iocdb/data/settings.yaml' do
  source "host-#{node['hostname']}/settings.yaml"
end

execute "install requirements" do
  cwd '/src/iocdb'
  user "root"
  command "pip install -r /src/iocdb/requirements.txt"
end

