execute 'remove todays apache2 backup if it exists' do
  command 'rm -fr /tmp/apache2-$(date +%Y%m%d)'
  user 'root'
end
execute 'archive current apache2 installation' do
  command 'if [ -d /etc/apache2 ]; then cp -p -R /etc/apache2 /tmp/apache2-$(date +%Y%m%d); tar -czvf ~/apache2-$(date +%Y%m%d_%H%M%S).tar.gz /tmp/apache2-$(date +%Y%m%d); fi'
  user 'root'
  returns 0
end

apt_package "libapache2-mod-wsgi" do
  action :install
end

include_recipe 'apache2'
include_recipe 'apache::mod_wsgi'

#apache_module 'wsgi' do
#  enable true
#  conf true
#end

# disable default site
apache_site '000-default' do
  enable false
end

# create apache config
template "#{node['apache']['dir']}/sites-available/iocdb-rest.conf" do
  source 'iocdb-rest.conf.erb'
  notifies :restart, 'service[apache2]'
end

# enable iocdb-rest
#apache_site 'iocdb-rest.conf' do
#  enable true
#end

link "#{node['apache']['dir']}/sites-enabled/iocdb-rest.conf" do
  to "#{node['apache']['dir']}/sites-available/iocdb-rest.conf"
end
