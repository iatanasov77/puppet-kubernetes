class vs_kubernetes::subsystems::ingress_controllers (
    Hash $config  = {},
) {
    $config['controllers'].each |String $controller| {
        class { "::vs_kubernetes::subsystems::ingress_controllers::${controller}":
            require => [
                Class['vs_kubernetes::kubernetes::controller']
            ],
        }
    }
}
