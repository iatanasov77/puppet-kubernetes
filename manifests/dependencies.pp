class vs_kubernetes::dependencies (
    Hash $dependencies        = {},
    
    String $gitUserName       = 'undefined_user_name',
    String $gitUserEmail      = 'undefined@example.com',
    Array $gitCredentials    = [],
    
    Array $packages           = [],
    Hash $vstools             = {},
    
    $mySqlProvider            = 'mariadb',
    String $phpVersion        = '7.2',
    Boolean $forcePhp7Repo    = true,
) {
    class { 'vs_core::scripts':
        # This Make dependency cycle
        #stage => 'install-dependencies'
    }
    
    class { '::vs_core::dependencies::repos':
        dependencies  => $dependencies,
        forcePhp7Repo => $forcePhp7Repo,
        phpVersion    => $phpVersion,
        mySqlProvider => $mySqlProvider,
        stage         => 'dependencies-install',
    } ->
    class { 'vs_core::dependencies::packages':
        stage           => 'dependencies-install',
        gitUserName     => $gitUserName,
        gitUserEmail    => $gitUserEmail,
    }
    
    class { 'vs_core::dependencies::git_setup':
        stage           => 'git-setup',
        gitUserName     => $gitUserName,
        gitUserEmail    => $gitUserEmail,
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
}