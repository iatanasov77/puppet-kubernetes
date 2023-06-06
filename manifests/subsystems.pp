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
            
            'ansible':
            {
                if ( $subsys['enabled'] ) {
                    class { '::vs_kubernetes::subsystems::ansible':
                        config  => $subsys,
                    }
                }
            }
            
            'cloud_platforms':
            {
                if ( $subsys['enabled'] ) {
                    class { '::vs_kubernetes::subsystems::cloud_platforms':
                        config  => $subsys,
                    }
                }
            }
            
            'hashicorp':
            {
                if ( $subsys['enabled'] ) {
                    class { '::vs_kubernetes::subsystems::hashicorp':
                        config  => $subsys,
                    }
                }
            }
            
            default:
            {
                if ( $subsys['enabled'] ) {
                    class { "::vs_kubernetes::subsystems::${$subsysKey}":
                        config	=> $subsys,
                        require	=> [ Class['kubernetes'] ],
                        stage   => 'kubernetes-controller',
                    }
                }
      
            }
        }
    }
}
