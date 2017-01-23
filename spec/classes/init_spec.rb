require 'spec_helper'
describe 'modapp1' do

  context 'with defaults for all parameters' do
    it { should contain_class('modapp1') }
  end
end
