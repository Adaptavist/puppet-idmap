# [*nfsv4_domain*]
# The NFSv4 Domain used by the ID Mapper, if this value is set
# /etc/idmapd.conf will be loaded from a template and the ID mapper
# service enabled. Default: undef
#
# [*idmap_service*]
# The name of the idmap service
#
# [*idmap_nobody_group*]
# The idmap nobody group
#
# [*idmap_nobody_user*]
# The idmap nobody user
#
# [*idmap_pipefs_dir*]
# The idmap pipefs directory
#
# [*idmap_verbosity*]
# The idmap verbosity level
#
# [*idmap_translation_method*]
# The idmap translation method.
#
# [*config_file*]
# The idmapd configurtation file

class idmap (
    $nfsv4_domain                =     undef,
    $idmap_nobody_user           =    'nobody',
    $idmap_verbosity             =    '0',
    $idmap_translation_method    =    'nsswitch',
    $config_file                 =    '/etc/idmapd.conf',
    ) {

    #set OS specific variables
    case $::osfamily {
        'RedHat': {
            $idmap_nobody_group='nobody'
            $idmap_pipefs_dir='/var/lib/nfs/rpc_pipefs/'
            $nfs_package='nfs-utils'
            if (versioncmp($::operatingsystemrelease,'7') >= 0 and $::operatingsystem != 'Fedora') {
                $idmap_service='nfs-idmap'
                $pipefs_systemd='var-lib-nfs-rpc_pipefs.mount'
                exec {' mount-pipefs':
                    command => "systemctl start ${pipefs_systemd}",
                    require => [Package[$nfs_package],File[$config_file]],
                    before  => Service[$idmap_service]
                }
            }
            else {
                $idmap_service='rpcidmapd'
            }
        }
        'Debian': {
            $idmap_service='idmapd'
            $idmap_nobody_group='nogroup'
            $idmap_pipefs_dir='/run/rpc_pipefs/'
            $nfs_package='nfs-common'
        }
        default: {
            fail("idmap - Unsupported Operating System family: ${::osfamily}")
        }
    }
    #the nfsv4 domain can be overwritten at host level, check to see if the host hash exists
    if ($::host != undef) {
        #if so validate the hash
        validate_hash($::host)
        #if a host level "merge_config" flag has been set use it, otherwise use the global flag
        $real_nfsv4_domain = $host['idmap::nfsv4_domain']? {
            default => $host['idmap::nfsv4_domain'],
            undef => $nfsv4_domain,
        }
    }
    #if there is no host has use global values
    else {
        $real_nfsv4_domain=$nfsv4_domain
    }


    #if the nfsv4 domain is set create /etc/idmapd.conf from the template and ensure the idmap service is running
    if ($real_nfsv4_domain and $real_nfsv4_domain != '') {

        #if the nfs-pacakage resource has not been defined (can be done via autofs etc) install the packageas it includes idmapd
        if ! defined(Package[$nfs_package]) {
            package { $nfs_package :
                ensure => installed,
            }
        }

        #ensure the idmap service is running and configured to start with the system
        service { $idmap_service :
            ensure  => running,
            enable  => true,
            require => [Package[$nfs_package],File[$config_file]],
        }

        # /etc/idmapd.conf
        file { $config_file :
            ensure  => present,
            mode    => '0644',
            owner   => 'root',
            group   => 'root',
            notify  => Service[$idmap_service],
            content => template ("${module_name}/idmapd.conf.erb"),
        }

    }
    else {
        notify{'IDMAP will not be configured as there is no nfsv4 domain set':}
    }


}

