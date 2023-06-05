class vs_kubernetes::pod_network_plugins::flannel (
    Hash $config    = {},
) {
    Exec { 'Install Pod Network - Flannel':
        command     => "/usr/bin/kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v${config['version']}/Documentation/kube-flannel.yml",
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    }
}
