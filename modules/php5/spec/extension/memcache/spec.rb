require 'spec_helper'

describe 'php5::extension::memcache' do

  describe command('php --ri memcache') do
    its(:exit_status) { should eq 0 }
  end

  describe file('/var/log/php/error.log') do
    its(:content) { should_not match /Warning.*memcache.*already loaded/ }
  end
end
