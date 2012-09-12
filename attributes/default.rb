#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: transmission
# Attribute:: default
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

::Chef::Node.send(:include, Opscode::OpenSSL::Password)

case node['platform']
when "ubuntu","debian"
  default['transmission']['install_method'] = 'package'
  default['transmission']['user']           = 'debian-transmission'
  default['transmission']['group']          = 'debian-transmission'
else
  default['transmission']['install_method'] = 'source'
  default['transmission']['user']           = 'transmission'
  default['transmission']['group']          = 'transmission'
end

default['transmission']['url']              = 'http://download.transmissionbt.com/files'
default['transmission']['version']          = '2.61'
default['transmission']['checksum']         = '5750d2bcd9bf95bff8f36d01a889a2f0ff8651504ee5f5c05f98e5ad8874e4dc'

default['transmission']['peer_port']        = 51413

default['transmission']['rpc_bind_address'] = '0.0.0.0'
default['transmission']['rpc_username']     = 'transmission'
set_unless['transmission']['rpc_password']  = secure_password
default['transmission']['rpc_port']         = 9091

default['transmission']['home']             = '/var/lib/transmission-daemon'
default['transmission']['config_dir']       = '/var/lib/transmission-daemon/info'
default['transmission']['download_dir']     = '/var/lib/transmission-daemon/downloads'
default['transmission']['incomplete_dir']   = '/var/lib/transmission-daemon/incomplete'
default['transmission']['incomplete_dir_enabled'] = 'false'

default['transmission']['speed_limit_down']         = 100 #KB/s
default['transmission']['speed_limit_down_enabled'] = 'false'
default['transmission']['speed_limit_up']           = 100 #KB/s
default['transmission']['speed_limit_up_enabled']   = 'false'
default['transmission']['cache-size-mb']  = 64
default['transmission']['configured']  = false
default['transmission']['ration-limit'] = 2
default['transmission']['ration-limit-enabled'] = true
