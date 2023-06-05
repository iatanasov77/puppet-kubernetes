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
    
    /* LAMP SERVER */
    String $defaultDocumentRoot = '/vagrant/gui/vs-kubernetes-gui/dist/vs-kubernetes-gui',
    String $apiDocumentRoot     = '/vagrant/gui/public',
    String $guiVarDirectory     = '/vagrant/gui/var',
    
    Array $apacheModules        = [],
    
    String $mysqllRootPassword  = 'vagrant',
    $mySqlProvider              = 'mariadb',
    
    String $phpVersion          = '7.2',
    Hash $phpModules            = {},
    Boolean $phpunit            = false,
    
    Hash $phpSettings           = {},
    
    Hash $phpMyAdmin            = {},
    Hash $databases             = {},
    
    Boolean $forcePhp7Repo      = true,
    
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
            dependencies    => $dependencies,
            
            gitUserName     => $gitUserName,
            gitUserEmail    => $gitUserEmail,
            gitCredentials  => $gitCredentials,
            
            
            packages        => $packages,
            vstools         => $vstools,
            
            mySqlProvider   => $mySqlProvider,
            phpVersion      => $phpVersion,
            forcePhp7Repo   => $forcePhp7Repo,
        }
        
        class { '::vs_core::frontendtools':
            frontendtools   => $frontendtools,
        }
        
        class { '::vs_kubernetes::lamp':
            defaultHost                 => $hosts['kube-controller']['aliases'][0],
            defaultDocumentRoot         => $defaultDocumentRoot,
            apiDocumentRoot             => $apiDocumentRoot,
            
            forcePhp7Repo               => $forcePhp7Repo,
            phpVersion                  => $phpVersion,
            apacheModules               => $apacheModules,
            
            mysqllRootPassword          => $mysqllRootPassword,
            mySqlProvider               => $mySqlProvider,
        
            phpModules                  => $phpModules,
            phpSettings                 => $phpSettings,
            phpunit                     => $phpunit,
            
            phpMyAdmin                  => $phpMyAdmin,
            databases                   => $databases,
        }
        
        if ( $container_runtime == 'docker' ) {
            class { 'vs_kubernetes::container_runtime_docker': }
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
        if ( container_runtime == 'docker' ) {
            class { 'vs_kubernetes::container_runtime_docker': }
            
            class { '::vs_kubernetes::subsystems::docker':
                config  => $subsystems['docker'],
            }
        }
        
        class { '::vs_kubernetes::worker':
            
        }
    }
}
