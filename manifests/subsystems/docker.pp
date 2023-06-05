class vs_kubernetes::subsystems::docker (
	Hash $config    = {},
) {
    class { 'vs_core::docker':
        config              => $config,
        dockerInstallStage  => 'docker-install',
    }
}
