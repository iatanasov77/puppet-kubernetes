class vs_kubernetes::subsystems::nfs_client (
    Hash $config  = {},
) {
    class { '::nfs':
      client_enabled  => true,
      nfs_v4_client   => true,
    }
    Nfs::Client::Mount <<| |>>
}
