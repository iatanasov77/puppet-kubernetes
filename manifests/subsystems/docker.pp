class vs_kubernetes::subsystems::docker (
	Hash $config   = {},
	Boolean $debug = false,
) {
    if ( $debug ) {
        fail( "COMPOSER VERSION: ${config['composer_version']}" )
    }
    
    class { 'vs_core::docker':
        config              => $config,
        dockerInstallStage  => 'docker-install',
    }
}
