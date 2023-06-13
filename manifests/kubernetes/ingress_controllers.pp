class vs_kubernetes::kubernetes::ingress_controllers (
    Hash $config  = {},
) {
    $config['controllers'].each |String $controller| {
        class { "::vs_kubernetes::kubernetes::ingress_controllers::${controller}":
            require => [
                #Class['vs_kubernetes::kubernetes::controller'],
                Exec['kubeadm init']
            ],
        }
    }
}
