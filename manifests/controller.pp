class vs_kubernetes::controller (
    Hash $pod_network_plugins,
) {
    class { 'kubernetes':
        controller              => true,
        
        manage_etcd             => true,
        manage_docker           => false,
        
        ignore_preflight_errors => [
            'FileExisting-conntrack',
            #all,
        ],
    } ->

    ##############################################################
    # Post-Initialize
    ##############################################################
    Exec { 'Enable Kubernetes for Root User':
        command => 'echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /root/.bashrc'
    } ->
    File { '/tmp/setup_kubernetes_controller.sh':
        ensure  => file,
        path    => '/tmp/setup_kubernetes_controller.sh',
        content => template( 'vs_kubernetes/setup_kubernetes_controller.sh.erb' ),
        mode    => '0755',
    } ->
    Exec { 'Enable Kubernetes for Vagrant User':
        command     => '/tmp/setup_kubernetes_controller.sh',
        user        => 'vagrant',
        environment => ['HOME=/home/vagrant'],
    }

    $pod_network_plugins.each |String $pluginKey, Hash $pluginConfig| {
        if ( $pluginConfig['enabled'] ) {
            class { "::vs_kubernetes::pod_network_plugins::${$pluginKey}":
                config  => $pluginConfig,
                require	=> [
                    Exec['Enable Kubernetes for Root User'],
                ],
            }
        }
    }
}
