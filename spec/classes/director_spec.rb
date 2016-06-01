require 'spec_helper'

describe 'bacula::director' do
  require 'hiera'
  let(:hiera_config) { 'hiera.yaml' }
  context 'Debian' do
    let(:facts) {
      {
        :osfamily => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemrelease => '7.0',
        :concat_basedir => '/dne',
        :ipaddress => '10.0.0.1'
      }
    }

    require 'hiera'
    let(:hiera_config) { 'spec/fixtures/modules/bacula/hiera.yaml' }
    hiera = Hiera.new({:config => 'spec/fixtures/modules/bacula/hiera.yaml'})
    make_bacula_tables = hiera.lookup('make_bacula_tables', nil, nil)
    let(:params) { { :make_bacula_tables => make_bacula_tables } }

    it {
      Puppet::Util::Log.level = :debug
      Puppet::Util::Log.newdestination(:console)
      should contain_class('bacula::director')
    }
  end
  context 'RedHat' do
    let(:facts) {
      {
        :osfamily => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemrelease => '7.0',
        :operatingsystemmajrelease => '7',
        :concat_basedir => '/dne',
        :ipaddress => '10.0.0.1'
      }
    }
    it { should contain_class('bacula::director') }
    context 'New packages' do
      it { should contain_package('bacula-director').with(
          'ensure' => 'present',
        )
      }
      it { should_not contain_package('bacula-director-common') }
    end
    context 'Old packages' do
      let(:facts) do
        super().merge(
          {
            :operatingsystemrelease => '6.0',
            :operatingsystemmajrelease => '6',
          }
        )
      end
      it { should contain_package('bacula-director-common').with(
          'ensure' => 'present',
        )
      }
      it { should_not contain_package('bacula-director') }
    end
  end
end
