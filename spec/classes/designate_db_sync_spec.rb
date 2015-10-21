#
# Unit tests for designate::db::sync
#
require 'spec_helper'

describe 'designate::db::sync' do

  let :facts do
    { :osfamily => 'Debian' }
  end

  it 'runs designate-dbsync' do
    is_expected.to contain_exec('designate-dbsync').with(
      :command     => 'designate-manage database sync',
      :path        => '/usr/bin',
      :user        => 'root',
      :refreshonly => 'true',
      :logoutput   => 'on_failure',
      :subscribe   => 'Anchor[designate::config::end]',
      :notify      => 'Anchor[designate::service::begin]',
    )
  end

end