#
# Unit tests for designate::keystone::auth
#
require 'spec_helper'

describe 'designate::keystone::auth' do
  shared_examples_for 'designate-keystone-auth' do
    context 'with default class parameters' do
      let :params do
        { :password => 'desigpwd',
          :tenant   => 'fooboozoo' }
      end

      it { is_expected.to contain_keystone_user('designate').with(
        :ensure   => 'present',
        :password => 'desigpwd',
      ) }

      it { is_expected.to contain_keystone_user_role('designate@fooboozoo').with(
        :ensure  => 'present',
        :roles   => ['admin']
      )}

      it { is_expected.to contain_keystone_service('designate::dns').with(
        :ensure      => 'present',
        :description => 'Openstack DNSaas Service'
      ) }

      it { is_expected.to contain_keystone_endpoint('RegionOne/designate::dns').with(
        :ensure       => 'present',
        :public_url   => "http://127.0.0.1:9001/v1",
        :admin_url    => "http://127.0.0.1:9001/v1",
        :internal_url => "http://127.0.0.1:9001/v1"
      ) }
    end


    context 'when overriding endpoint URLs' do
      let :params do
        { :password         => 'desigpwd',
          :public_url       => 'https://10.10.10.10:81/v2',
          :internal_url     => 'https://10.10.10.11:81/v2',
          :admin_url        => 'https://10.10.10.12:81/v2' }
      end

      it { is_expected.to contain_keystone_endpoint('RegionOne/designate::dns').with(
        :ensure       => 'present',
        :public_url   => 'https://10.10.10.10:81/v2',
        :internal_url => 'https://10.10.10.11:81/v2',
        :admin_url    => 'https://10.10.10.12:81/v2'
      ) }
    end

    context 'with deprecated endpoint parameters' do
      let :params do
        { :password         => 'desigpwd',
          :public_protocol  => 'https',
          :public_address   => '10.10.10.10',
          :port             => '81',
          :internal_address => '10.10.10.11',
          :admin_address    => '10.10.10.12' }
      end

      it { is_expected.to contain_keystone_endpoint('RegionOne/designate::dns').with(
        :ensure       => 'present',
        :public_url   => "https://10.10.10.10:81/v1",
        :internal_url => "http://10.10.10.11:81/v1",
        :admin_url    => "http://10.10.10.12:81/v1"
      ) }
    end

    context 'when overriding auth name' do
      let :params do
        { :password => 'foo',
          :auth_name => 'designate1' }
      end

      it { is_expected.to contain_keystone_user('designate1') }
      it { is_expected.to contain_keystone_user_role('designate1@services') }
      it { is_expected.to contain_keystone_service('designate1::dns') }
      it { is_expected.to contain_keystone_endpoint('RegionOne/designate1::dns') }
    end

    context 'when overriding service name' do
      let :params do
        { :service_name => 'designate_service',
          :password => 'foo',
          :auth_name => 'designate1' }
      end

      it { is_expected.to contain_keystone_user('designate1') }
      it { is_expected.to contain_keystone_user_role('designate1@services') }
      it { is_expected.to contain_keystone_service('designate_service::dns') }
      it { is_expected.to contain_keystone_endpoint('RegionOne/designate_service::dns') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'designate-keystone-auth'
    end
  end
end
