class vs_kubernetes::subsystems::ansible (
	Hash $config    = {},
) {
    # Install Ansible
    class { 'ansible':
        ensure  => 'present',
    }
}
