#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: transmission
# Recipe:: source
#
# Copyright 2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "build-essential"

version = node['transmission']['version']

build_pkgs = value_for_platform(
  ["debian","ubuntu"] => {
    "default" => ["automake","libtool","pkg-config","libcurl4-openssl-dev","intltool","libxml2-dev","libgtk2.0-dev","libnotify-dev","libglib2.0-dev","libevent-dev"]
  },
  ["centos","redhat","fedora"] => {
    "default" => ["curl", "curl-devel", "libevent", "libevent-devel", "intltool", "gettext", "openssl-devel"]
  },
  "default" => ["automake","libtool","pkg-config","libcurl4-openssl-dev","intltool","libxml2-dev","libgtk2.0-dev","libnotify-dev","libglib2.0-dev","libevent-dev"]
)

build_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/transmission-#{version}.tar.bz2" do
  source "#{node['transmission']['url']}/transmission-#{version}.tar.bz2"
  checksum node['transmission']['checksum']
  action :create_if_missing
end

remote_file "#{Chef::Config[:file_cache_path]}/libevent-2.0.20-stable.tar.gz" do
  source "http://cloud.github.com/downloads/libevent/libevent/libevent-2.0.20-stable.tar.gz"
  checksum "10698a0e6abb3ca00b1c9e8cfddc66933bcc4c9c78b5600a7064c4c3ef9c6a24"
  action :create_if_missing
end

bash "compile_libevent" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar xfz libevent-2.0.20-stable.tar.gz
    cd libevent-2.0.20-stable
    ./configure -q && make -s
    make install
  EOH
  creates "/usr/local/lib/libevent.so"
end

bash "compile_transmission" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar xjf transmission-#{version}.tar.bz2
    cd transmission-#{version}
    ./configure -q LIBEVENT_CFLAGS=-I/usr/local/include LIBEVENT_LIBS="-L/usr/local/lib -levent" && make -s
    make install
  EOH
  not_if "transmission-daemon --version 2>&1 | grep #{version}"
end

group node['transmission']['group'] do
  action :create
end

user node['transmission']['user'] do
  comment "Transmission Daemon User"
  gid node['transmission']['group']
  system true
  home node['transmission']['home']
  action :create
end

directory node['transmission']['home'] do
  owner node['transmission']['user']
  group node['transmission']['group']
  mode "0755"
end

directory node['transmission']['config_dir'] do
  owner node['transmission']['user']
  group node['transmission']['group']
  mode "0755"
end

include_recipe "transmission::default"
