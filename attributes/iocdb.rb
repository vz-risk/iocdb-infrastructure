#default[:iocdb][:install][:branch] = origin/master
default[:iocdb][:install][:branch] = origin/dev-ci
default['set_fqdn'] = '*.vcic.local'
default[:iocdb][:eshosts][:prod] = '[10.114.75.149, 10.114.75.152, 10.114.75.153]'
default[:iocdb][:eshosts][:dev] = '[153.39.107.114]'
default[:iocdb][:eshosts][:qa] = '[166.34.103.214]'

