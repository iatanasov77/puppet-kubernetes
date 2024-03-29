class vs_kubernetes::subsystems (
    Hash $subsystems    = {},
) {
	$subsystems.each |String $subsysKey, Hash $subsys| {
     
        case $subsysKey
        {
            'docker':
            {
                if ( $subsys['enabled'] ) {
                    class { '::vs_kubernetes::subsystems::docker':
                        config  => $subsys,
                    }
                }
            }
            
            default:
            {
                if ( $subsys['enabled'] ) {
                    class { "::vs_kubernetes::subsystems::${$subsysKey}":
                        config	=> $subsys,
                    }
                }
      
            }
        }
    }
}
