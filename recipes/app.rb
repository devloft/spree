include_recipe "rvm::system"

group node['spree']['group'] do
  append true
end

user node['spree']['user'] do
  gid node['spree']['group']
  shell '/bin/bash'
  home node['spree']['root_path']
  system true
  action :create
end

directory node['spree']['root_path'] do
  action :create
  owner node['spree']['user']
  group node['spree']['group']
  recursive true
end

package %w(nodejs mysql-devel ImageMagick)  do
  action :install
end

rvm_ruby node['rvm']['ruby'] do
  action :install
end

rvm_default_ruby node['rvm']['ruby']

rvm_shell "install rails" do
  code %Q{gem install rails --no-rdoc --no-ri -v #{node['spree']['rails']}}
  timeout 36000
  not_if 'gem list | grep rails'
end

rvm_shell "New Spree App!" do
  code %Q{rails _4.2.1_ new #{node['spree']['app']} --skip-bundle -d #{node['spree']['db_type']}}
  timeout 36000
  cwd node['spree']['root_path']
  user node['spree']['user']
  group node['spree']['group']
  not_if { ::File.exists?("#{node['spree']['app_path']}/Gemfile") }
end
