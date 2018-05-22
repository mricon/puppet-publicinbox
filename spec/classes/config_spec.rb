require 'spec_helper'
describe 'publicinbox', :type => 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os} mostly defaults" do
      let (:facts) do
        facts
      end
      it { should compile }
      it { should contain_class('publicinbox::config') }

      # example1:
      #   address:
      #     - 'example1@example.com'
      #     - 'example2@example.com'
      #   mainrepo: '/var/lib/public-inbox/example1.git'
      #   url:
      #     - 'https://example.com/example1'
      #   newsgroup: 'com.example.example1'
      #
      # example2:
      #   address: 'example2@example.com'
      #   mainrepo: '/var/lib/public-inbox/example2.git'
      #   url:
      #     - 'https://example.com/example2'
      #   newsgroup: 'com.example.example2'
      #   watch: '/var/spool/mail/example2'
      #   watchheader: 'List-Id:<example2.example.com>'
      it { should contain_file('/etc/public-inbox/config')
          .with_ensure('present')
          .with_owner('root')
          .with_group('root')
          .with_mode('0644')
          .with_content(/\[publicinbox\]/)
          .with_content(/nntpserver=nntp:\/\/bupkes\.example\.com/)
          .with_content(/nntpserver=nntp:\/\/bogus\.example\.com/)
          .with_content(/\[publicinbox "example1"\]/)
          .with_content(/address=example1@example.com/)
          .with_content(/address=example2@example.com/)
          .with_content(/\[publicinbox "example2"\]/)
          .with_content(/mainrepo=\/var\/lib\/public-inbox\/example2\.git/)
          .with_content(/url=https:\/\/example\.com\/example2/)
          .with_content(/newsgroup=com\.example\.example2/)
          .with_content(/watch=\/var\/spool\/mail\/example2/)
          .with_content(/watchheader=List-Id:<example2\.example\.com>/)
          .with_content(/\[publicinboxwatch\]/)
          .with_content(/spamcheck=spamc/)
          .with_content(/watchspam=\/var\/spool\/mail\/testspam/)
      }
    end
  end
end
