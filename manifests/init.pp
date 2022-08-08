class vs_kubernetes (
    String $type              = 'controller',
    Hash $hosts               = {},
    
    String $gitUserName       = 'undefined_user_name',
    String $gitUserEmail      = 'undefined@example.com',
    String $gitCredentials    = '',
    
    Array $packages           = [],
    Hash $vstools             = {},
    
    Hash $pod_network_plugins = {},
    Hash $subsystems          = {},
) {
    stage { 'after-main': }
    Stage['main'] -> Stage['after-main']
    
    class { '::vs_kubernetes::hosts':
        hosts => $hosts,
    }
    
    class { 'vs_core::dependencies::git_setup':
        stage           => 'after-main',
        gitCredentials  => $gitCredentials,
    }
    
    class { '::vs_core::packages':
        packages        => $packages,
        gitUserName     => $gitUserName,
        gitUserEmail    => $gitUserEmail,
    }

    class { '::vs_core::vstools':
        vstools => $vstools,
    }
    
    # Create Kubernetes Controller
    ###################################
    if ( $type == 'controller' ) {
        class { '::vs_kubernetes::controller':
            pod_network_plugins => $pod_network_plugins
        } ->

        # Setup Kubernetes Proxy (Expose Dashboard outside of Node)
        ###############################################################
        Exec { 'Setup Kubernetes Proxy.':
            command     => "/usr/bin/kubectl proxy --address='0.0.0.0' --accept-hosts='^*$' &",
            environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
        } ->

        class { '::vs_kubernetes::subsystems':
            subsystems  => $subsystems,
        }
    }
    
    # Create Kubernetes Worker
    ###################################
    if ( $type == 'worker' ) {
        class { '::vs_kubernetes::worker':
            
        }
    }
}
