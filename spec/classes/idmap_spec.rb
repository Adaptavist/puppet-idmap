require 'spec_helper'

describe 'idmap', :type => 'class' do

  context "Should configure idmap on debian based systems" do

   let :params do
    { :nfsv4_domain                =>    'test.com',
      :idmap_nobody_user           =>    'nobody',
      :idmap_verbosity             =>    '0',
      :idmap_translation_method    =>    'nsswitch',
      :config_file                 =>    '/etc/idmapd.conf'
    }   
   end

   let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    it do
      should contain_service('idmapd').with(
        'ensure'  =>  'running',
        'enable'  =>  'true',
        )
      should contain_file('/etc/idmapd.conf').with(
         'ensure' => 'present',
         'mode'   => '0644',
         'owner'  => 'root',
         'group'  => 'root',
         )
      should contain_package('nfs-common').with(
        'ensure'  => 'installed'
        )
    end
  end

  context "Should configure idmap on RedHat based systems" do

   let :params do
    { :nfsv4_domain                =>    'test.com',
      :idmap_nobody_user           =>    'nobody',
      :idmap_verbosity             =>    '0',
      :idmap_translation_method    =>    'nsswitch',
      :config_file                 =>    '/etc/idmapd.conf'
    }   
   end

   let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    it do
      should contain_service('rpcidmapd').with(
        'ensure'  =>  'running',
        'enable'  =>  'true',
        )
      should contain_file('/etc/idmapd.conf').with(
        'ensure' => 'present',
        'mode'   => '0644',
        'owner'  => 'root',
        'group'  => 'root',
        )
      should contain_package('nfs-utils').with(
        'ensure'  => 'installed'
        )
    end
  end

  context "Should notify that nothing will be done" do
    let :params do
      { :nfsv4_domain => '' }
    end
    let :facts do
      {  :osfamily => 'RedHat' }
    end

    it do
      should contain_notify('IDMAP will not be configured as there is no nfsv4 domain set')
    end
  end 

  context "Should fail with unsupported OS family" do

   let :params do
    { :nfsv4_domain                =>    'test.com',
      :idmap_nobody_user           =>    'nobody',
      :idmap_verbosity             =>    '0',
      :idmap_translation_method    =>    'nsswitch',
      :config_file                 =>    '/etc/idmapd.conf'
    }   
   end

   let :facts do
      {
        :osfamily => 'Solaris'
      }
    end

    it do
      should raise_error(Puppet::Error, /idmap - Unsupported Operating System family: Solaris at/)
    end
  end


end
