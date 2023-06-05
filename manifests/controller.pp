class vs_kubernetes::controller (
    Hash $pod_network_plugins,
) {
    
    
    /*
    wait_for { 'containerd':
      query             => 'systemctl status containerd | grep Active',
      regex             => 'Active: active (running)',
      polling_frequency => 5,  # Wait up to 2 minutes (24 * 5 seconds).
      max_retries       => 24,
      refreshonly       => true,
    } ->
    */
    
    wait_for { 'three_minutes_before_containerd_is_ready':
        seconds => 180,
    }
    
    class { 'kubernetes':
        controller                  => true,
        
        manage_etcd                 => true,
        manage_docker               => false,
        
        ignore_preflight_errors     => [
            'FileExisting-conntrack',
            #all,
        ],
        
        stage                       => 'kubernetes-controller',
    }

    ##############################################################
    # Post-Initialize
    ##############################################################
    Exec { 'Enable Kubernetes for Root User':
        command => 'echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /root/.bashrc',
        require => [
            Class['kubernetes'],
            Exec['kubeadm init'],
        ],
    }
    
    File { '/tmp/setup_kubernetes_controller.sh':
        ensure  => file,
        path    => '/tmp/setup_kubernetes_controller.sh',
        content => template( 'vs_kubernetes/setup_kubernetes_controller.sh.erb' ),
        mode    => '0755',
        require => [
            Class['kubernetes'],
        ],
    }
    
    Exec { 'Enable Kubernetes for Vagrant User':
        command     => '/tmp/setup_kubernetes_controller.sh',
        user        => 'vagrant',
        environment => ['HOME=/home/vagrant'],
        require => [
            Class['kubernetes'],
        ],
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
    
    # Setup Kubernetes Proxy (Expose Dashboard outside of Node)
    ###############################################################
    Exec { 'Setup Kubernetes Proxy.':
        command     => "/usr/bin/kubectl proxy --address='0.0.0.0' --accept-hosts='^*$' &",
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
        require => [
            Class['kubernetes'],
        ],
    }
}
