class vs_kubernetes::subsystems::hashicorp (
	Hash $config       = {},
) {
    class { 'vs_core::hashicorp':
        config  => $config,
    }
}
