class vs_kubernetes::lamp (
	String $defaultHost,
    String $defaultDocumentRoot,
    String $apiDocumentRoot,

	Array $apacheModules        = [],
    
    String $mysqllRootPassword	= 'vagrant',
	$mySqlProvider				= 'mariadb',
	
	String $phpVersion			= '7.2',
    Hash $phpModules            = {},
    Boolean $phpunit            = false,
    
    Hash $phpSettings           = {},
    
    Hash $phpMyAdmin			= {},
    Hash $databases				= {},
    
    Boolean $forcePhp7Repo      = true,
) {
    if ( 'source' in $phpMyAdmin ) {
        $hostAliases        = [
            {
                alias => '/phpmyadmin',
                path  => '/usr/share/phpMyAdmin'
            }
        ]
        
        $hostDirectories    = [
            {
                'path'              => '/usr/share/phpMyAdmin',
                'allow_override'    => ['All'],
                'Require'           => 'all granted',
            }
        ]
    } else {
        $hostAliases        = []
        $hostDirectories    = []
    }
    
	class { 'vs_lamp':
        phpVersion                  => $phpVersion,
        apacheModules               => $apacheModules,
        
        mysqllRootPassword          => $mysqllRootPassword,
        mySqlProvider				=> $mySqlProvider,

        phpModules                  => $phpModules,
        phpSettings                 => $phpSettings,
        phpunit                     => $phpunit,
        phpManageRepos              => !$forcePhp7Repo,
        
        phpMyAdmin					=> $phpMyAdmin,
        databases					=> $databases,
    } ->
    
    ##################################################
    # Create Vhost for GUI
    ##################################################
    vs_lamp::apache_vhost{ "${defaultHost}":
        hostName        => $defaultHost,
        documentRoot    => $defaultDocumentRoot,
        aliases         => $hostAliases,
        directories     => $hostDirectories,
    }
    
    vs_lamp::apache_vhost{ "api.${defaultHost}":
        hostName        => "api.${defaultHost}",
        documentRoot    => "${apiDocumentRoot}",
    }
}
