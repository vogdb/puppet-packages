require 'spec_helper'

describe 'dotdeb' do

  describe file('/etc/apt/sources.list.d/dotdeb.list') do
    it { should be_file }
  end
end
