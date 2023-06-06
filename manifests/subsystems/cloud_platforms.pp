class vs_kubernetes::subsystems::cloud_platforms (
    Hash $config    = {},
) {
    class { 'vs_core::cloud_platforms':
        config  => $config,
    }
}
