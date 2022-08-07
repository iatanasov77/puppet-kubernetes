class vs_kubernetes::subsystems (
    Hash $subsystems    = {},
) {
	$subsystems.each |String $subsysKey, Hash $subsys| {
     
        case $subsysKey
        {
            'docker':
            {
                if ( $subsys['enabled'] ) {
                    stage { 'docker-install': before => Stage['main'] }
                    class { '::vs_kubernetes::subsystems::docker':
                        config  => $subsys,
                        stage   => 'docker-install',
                    }
                }
            }
            
            default:
            {
                if ( $subsys['enabled'] ) {
                    class { "::vs_kubernetes::subsystems::${$subsysKey}":
                    	  config	=> $subsys,
                        require	=> [
                            Class['kubernetes'], 
                        ],
                    }
                }
      
            }
        }
    }
}
