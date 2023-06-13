class vs_kubernetes::subsystems::templating::helm (
    Hash $config  = {},
) {
    wget::fetch { "Download Helm Setup.":
        source      => "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3",
        destination => '/tmp/helm_setup.sh',
        verbose     => true,
        mode        => '0777',
        cache_dir   => '/var/cache/wget',
	  } ->
    Exec { 'Install Helm.':
        command     => '/tmp/helm_setup.sh',
        cwd         => '/tmp',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    }

    $config['helmRepos'].each |String $repoKey, String $repoUrl| {
        Exec { "Add Helm Repo '${repoKey}'":
            command     => "helm repo add ${repoKey} ${repoUrl}",
            #timeout     => 1800,
            tries       => 3,
            #try_sleep   => 60,
            require	=> [
                Exec['Install Helm.'],
            ],
        }
    }
}
