class vs_kubernetes::subsystems::templating::kustomize (
    Hash $config  = {},
) {
    wget::fetch { "Download Kustomize Setup.":
        source      => "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh",
        destination => '/tmp/install_kustomize.sh',
        verbose     => true,
        mode        => '0777',
        cache_dir   => '/var/cache/wget',
	  } ->
    Exec { 'Install Kustomize.':
        command     => '/tmp/install_kustomize.sh',
        cwd         => '/tmp',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->
    File { 'Move Kustomize to /usr/local/bin/kustomize':
        ensure  => present,
        path    => '/usr/local/bin/kustomize',
        source  => '/tmp/kustomize',
        mode    => '0777',
    }
}
