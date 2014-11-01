#
# Cookbook Name:: wordpress
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

filename = node['wp']['filename']
remote_url = node['wp']['site_url'] + node['wp']['filename']
checksum = node['wp']['file_checksum']
install_path = node['wp']['install_path']
user = node['wp']['user']
group = node['wp']['group']

remote_file "/tmp/#{filename}" do
  source "#{remote_url}"
  checksum "#{checksum}"
end

script "install_wordpress" do
  interpreter "bash"
  user        "root"
  code <<-EOL
    install -d #{install_path}
    tar zxvf /tmp/#{filename} -C #{install_path}
    chown -R #{user} #{install_path}
    chgrp -R #{group} #{install_path}
  EOL
end


#########################################################
## MySQLの設定
#########################################################
item = Chef::EncryptedDataBagItem.load('passwords', 'mysql')
root_password = item['pass']
database = node['wp']['database']
sqluser = node['wp']['sqluser']

item = Chef::EncryptedDataBagItem.load('passwords', 'wp')
sqlpass = item['pass']
hostname = node['wp']['hostname'] 
conn_sql = "mysql -u root -p#{root_password}"
execute "exec_set_database" do
  command <<-EOC
    #{conn_sql} -e "CREATE DATABASE #{database};"
    #{conn_sql} -e "GRANT ALL PRIVILEGES ON #{database}.* TO '#{sqluser}'@'#{hostname}' IDENTIFIED BY '#{sqlpass}';"
    #{conn_sql} -e "FLUSH PRIVILEGES;"
  EOC
end
