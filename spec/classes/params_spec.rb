require 'spec_helper'
describe 'publicinbox', :type => 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os} mostly defaults" do
      let (:facts) do
        facts
      end
      it { should compile }
      it { should contain_class('publicinbox::params') }
    end
  end
end
