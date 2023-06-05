class vs_kubernetes (
    String $type                = 'controller',
    Hash $hosts                 = {},
    Hash $dependencies          = {},
    
    String $gitUserName         = 'undefined_user_name',
    String $gitUserEmail        = 'undefined@example.com',
    Array $gitCredentials       = [],
    
    Array $packages             = [],
    Hash $vstools               = {},
    
    Hash $pod_network_plugins   = {},
    String $container_runtime   = 'docker',
    
    Hash $subsystems            = {},
    
    Hash $frontendtools         = {},
    String $defaultDocumentRoot = '/vagrant/gui/vs-kubernetes-gui/dist/vs-kubernetes-gui',
    String $apiDocumentRoot     = '/vagrant/gui/public',
    String $guiVarDirectory     = '/vagrant/gui/var',
) {
    ######################################################################
    # Stages Before Main
    ######################################################################
    stage { 'dependencies-install': before => Stage['main'] }
    stage { 'docker-install': before => Stage['main'] }
    stage { 'generate-hiera': before => Stage['main'] }
    
    ######################################################################
    # Stages After Main
    ######################################################################
    stage { 'git-setup': }
    stage { 'kubernetes-controller': }
    stage { 'vault-setup': }
    stage { 'packer-setup': }
    stage { 'notify-services': }
    
    Stage['main']   -> Stage['git-setup'] -> Stage['kubernetes-controller']
                    -> Stage['vault-setup'] -> Stage['packer-setup']
                    -> Stage['notify-services']
    
    ######################################################################
    # Start Configuration
    ######################################################################

    class { '::vs_kubernetes::hosts':
        hosts => $hosts,
    }
    
    # Create Kubernetes Controller
    ###################################
    if ( $type == 'controller' ) {
    
        class { 'vs_kubernetes::dependencies':
            gitUserName     => $gitUserName,
            gitUserEmail    => $gitUserEmail,
            gitCredentials  => $gitCredentials,
            
            dependencies    => $dependencies,
            packages        => $packages,
            vstools         => $vstools,
        }
        
        class { '::vs_core::frontendtools':
            frontendtools   => $frontendtools,
        }
        
        class { '::vs_kubernetes::lamp':
            defaultHost                 => $hosts['kube-controller']['aliases'][0],
            defaultDocumentRoot         => $defaultDocumentRoot,
            apiDocumentRoot             => $apiDocumentRoot,
        }
        
        if ( $container_runtime == 'docker' ) {
            class { 'vs_kubernetes::container_runtime_docker':
                #notify => Exec['kubernetes-systemd-reload'],
                #stage  => 'docker-install',
            }
        }
        
        class { '::vs_kubernetes::controller':
            pod_network_plugins => $pod_network_plugins,
            stage               => 'kubernetes-controller',
        }
        
        class { '::vs_kubernetes::subsystems':
            subsystems  => $subsystems,
        }
        
        file { "${guiVarDirectory}/subsystems.json":
            ensure  => file,
            content => to_json_pretty( $subsystems ),
        }
    }
    
    # Create Kubernetes Worker
    ###################################
    if ( $type == 'worker' ) {
        class { '::vs_kubernetes::worker':
            
        }
    }
}
