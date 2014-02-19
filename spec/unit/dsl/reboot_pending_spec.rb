#
# Author:: Bryan McLellan <btm@loftninjas.org>
# Copyright:: Copyright (c) 2014 Chef Software, Inc.
# License:: Apache License, Version 2.0
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

require "chef/dsl/reboot_pending"
require "spec_helper"

# FIXME resource + recipe context

describe Chef::DSL::RebootPending do

  let(:node) { Chef::Node.new } 
  let(:events) { double('Chef::Events').as_null_object }  # mock all the methods
  let(:run_context) { double('Chef::RunContext', :node => node, :events => events) }
  let(:recipe) { Chef::Recipe.new(nil, nil, run_context) }

  describe "reboot_pending?" do
    context "platform is windows" do
      before do
        recipe.stub(:platform_family?).with('windows').and_return(true)
        recipe.stub(:registry_key_exists?).and_return(false)
        recipe.stub(:registry_value_exists?).and_return(false)
      end

      it 'should return true if "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations" exists' do
        recipe.stub(:registry_value_exists?).with('HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations').and_return(true)

        recipe.reboot_pending?.should be_true
      end

      it 'should return true if "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" exists and contains values' do
        recipe.stub(:registry_key_exists?).with('HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired').and_return(true)

        recipe.stub(:registry_get_values).with('HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired').and_return(
              [{:name => "9306cdfc-c4a1-4a22-9996-848cb67eddc3", :type => :dword, :data => 1}])

        recipe.reboot_pending?.should be_true
      end
    end
  end
end
