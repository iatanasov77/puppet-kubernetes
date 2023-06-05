class vs_kubernetes::pod_network_plugins::calico (
    Hash $config    = {},
) {
    Exec { 'Install Calico Pod Network.':
        command     => "/usr/bin/kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${config['version']}/manifests/tigera-operator.yaml",
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->
    Exec { 'Install Calico resource definitions.':
        command     => "/usr/bin/kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${config['version']}/manifests/custom-resources.yaml",
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    }
    
    /*
    Exec { 'Install Calico Pod Network.':
        command     => '/usr/bin/kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/tigera-operator.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->
    wget::fetch { "Download Calico resource definitions.":
        source      => "https://raw.githubusercontent.com/projectcalico/calico/master/manifests/custom-resources.yaml",
        destination => '/tmp/custom-resources.yaml',
        verbose     => true,
        mode        => '0777',
        cache_dir   => '/var/cache/wget',
	  } ->
    Exec { 'Edit Calico resource definitions.':
        command     => 'sed -i.bak s/192.168/10.244/g /tmp/custom-resources.yaml',
    } ->
    Exec { 'Apply Calico resource definitions.':
        command     => '/usr/bin/kubectl apply -f /tmp/custom-resources.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    }
    */
}
