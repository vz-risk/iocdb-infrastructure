# TODO: requires root to have a github key. a better solution
# would be an encrypted data bag with the key

include_recipe 'iocdb-infrastructure::iocdb'

python_pip 'mapping-tools' do
  package_name 'git+https://github.com/natb1/mapping-tools.git#egg=mapping-tools'
  options '-e'
end

python_pip 'query-tools' do
  package_name 'git+https://github.com/natb1/query-tools.git#egg=query-tools'
  options '-e'
end

python_pip 'iocdb' do
  package_name 'git+git@github.com:vz-risk/iocdb.git#egg=iocdb'
  options '-e'
end
