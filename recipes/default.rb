#
# Cookbook Name:: sumo-wrapper
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.


include_recipe 'sumologic-collector::sumoconf'
include_recipe 'sumologic-collector::sumojson'

case node['platform_family']
when 'rhel'
  packagecloud_repo 'kennonkwok/sumo-collector'
  package 'SumoCollector'
when 'windows'
  remote_file "#{Chef::Config['file_cache_path']}/SumoCollector_windows-x64.exe" do
    source 'https://collectors.sumologic.com/rest/download/win64'
    notifies :run, 'execute[sumo-installer]'
  end
  execute 'sumo-installer' do 
    command "start /wait #{Chef::Config['file_cache_path']}/SumoCollector_windows-x64.exe -q -dir #{node['sumologic']['installDir']}"
    action :nothing
  end
end
