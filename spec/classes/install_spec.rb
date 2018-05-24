require 'spec_helper'
describe 'publicinbox', :type => 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os} mostly defaults" do
      let (:facts) do
        facts
      end
      it { should compile }
      it { should contain_class('publicinbox::install') }

      it { should contain_file('/usr/local/share/public-inbox').with(
          {
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          }
      )}
      it { should contain_vcsrepo('/usr/local/share/public-inbox').with(
          {
            'ensure'   => 'present',
            'provider' => 'git',
            'source'   => /https:\/\/public-inbox\.org/,
            'revision' => 'master',
          }
      )}
      it { should contain_exec('publicinbox-perl-Makefile.PL').with(
          {
            'command' => 'perl Makefile.PL',
            'cwd'     => '/usr/local/share/public-inbox',
          }
      )}
      it { should contain_file('/var/lib/public-inbox').with(
          {
            'ensure' => 'directory',
            'owner'  => 'archiver',
            'group'  => 'pitestgroup',
            'mode'   => '0750',
          }
      )}
    end
  end
end
