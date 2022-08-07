class vs_kubernetes::subsystems::nfs_server (
    Hash $config  = {},
) {
    file { "${$config['data_dir']}":
        ensure  => directory,
		mode   	=> '0777',
    }
    class { '::nfs':
        server_enabled              => true,
        nfs_v4                      => true,
        nfs_v4_idmap_domain         => "${$config['domain']}",
        nfs_v4_export_root          => "${$config['root_path']}",
        nfs_v4_export_root_clients  => '*(rw,fsid=0,insecure,no_subtree_check,async,no_root_squash)',
    }
    nfs::server::export { "${$config['data_dir']}":
        ensure  => 'mounted',
        clients => '*(rw,insecure,async,no_root_squash,no_subtree_check)',
    }
}
