class vs_kubernetes::subsystems::ingress_controllers::haproxy (
    Hash $config    = {},
) {
    Exec { 'Apply HaProxy Ingress Controller.':
        command     => '/usr/bin/kubectl apply -f https://raw.githubusercontent.com/haproxytech/kubernetes-ingress/master/deploy/haproxy-ingress.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->

    File { '/tmp/haproxy-class.yaml':
        ensure  => file,
        path    => '/tmp/haproxy-class.yaml',
        content => template( 'vs_kubernetes/haproxy-class.yaml.erb' ),
        mode    => '0755',
    } ->
    Exec { 'Apply HaProxy Class.':
        command     => '/usr/bin/kubectl apply -f /tmp/haproxy-class.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    }
}
