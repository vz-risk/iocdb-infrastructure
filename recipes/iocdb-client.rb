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

directory "/src" do
  group 'iocdb_prov'
end

cookbook_file "iocdb-15.2.0b20.tar.gz" do
  path '/tmp/iocdb-15.2.0b20.tar.gz'
  backup 0
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute "extract iocdb" do
  cwd "/src"
  command "tar -xzvf /tmp/iocdb-15.2.0b20.tar.gz"
  user "root"
end

link "/src/iocdb" do
  to "/src/iocdb-15.2.0b20"
end

execute "chmod /src/iocdb to iocdb_prov" do
  cwd "/src/iocdb"
  user "root"
  command "chown -R iocdb_prov:iocdb_prov /src/iocdb"
end

template "/src/iocdb/iocdb/data/settings.yaml" do
  source "host-#{node['hostname']}/settings.yaml"
end

execute "install requirements" do
  cwd "/src/iocdb"
  user "root"
  command "pip install -r /src/iocdb/requirements.txt"
end

execute "Install iocdb" do
  cwd "/src/iocdb"
  user "root"
  command "python setup.py install"
end

