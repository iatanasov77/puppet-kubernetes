class vs_kubernetes::kubernetes::dashboard (
	Hash $config    = {},
) {
    #> Expose Kubernetes Dashboard
    Exec { 'Export Kubernetes Dashboard Service.':
        command     => '/usr/bin/kubectl -n kubernetes-dashboard get service kubernetes-dashboard -o yaml > /tmp/dashboard-service.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->
    Exec { 'Edit Kubernetes Dashboard Service.':
        command     => "sed -ri 's/^(\s*)(type\s*:\s*ClusterIP\s*$)/\1type: NodePort/' /tmp/dashboard-service.yaml",
    } ->
    Exec { 'Fix Port of Kubernetes Dashboard Service.':
        command     => "sed -ri '/^(\s*)(targetPort.*)/a \ \ \ \ nodePort: ${config['port']}' /tmp/dashboard-service.yaml",
    } ->
    Exec { 'Apply Kubernetes Dashboard Service.':
        command     => '/usr/bin/kubectl apply -f /tmp/dashboard-service.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->
    #< Expose Kubernetes Dashboard

    # Create Dashboard Admin Account
    File { '/tmp/dashboard-admin.yaml':
        ensure  => file,
        path    => '/tmp/dashboard-admin.yaml',
        content => template( 'vs_kubernetes/dashboard-admin.yaml.erb' ),
        mode    => '0755',
    } ->
    Exec { 'Create Dashboard Admin Account.':
        command     => '/usr/bin/kubectl apply -f /tmp/dashboard-admin.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    }
}
