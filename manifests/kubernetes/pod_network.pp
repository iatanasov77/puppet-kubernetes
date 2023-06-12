/**
 * Test With
 *===========
 *
 * Flannel
 *---------
 * kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.22.0/Documentation/kube-flannel.yml
 *
 * Calico
 *--------
 * kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/tigera-operator.yaml
 * kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/custom-resources.yaml
 */
class vs_kubernetes::kubernetes::pod_network (
    Hash $kubernetesConfig,
    String $network_provider,
    String $network_cidr,
) {
    $podNetworkProvider = $network_provider
    $podNetworkCidr     = $network_cidr
    
    if ! ( $podNetworkProvider in $kubernetesConfig['pod_network_plugins'] ) {
        fail( 'Pod Network Provider Unsupported !' )
    }
    
    $podNetworkVersion  = $kubernetesConfig['pod_network_plugins'][$podNetworkProvider]['version'];
    
    
    Exec { 'Create Pod Network Config':
        command     => "php /opt/vs_devenv/pod_network.php ${podNetworkProvider} ${podNetworkVersion} ${podNetworkCidr}",
    } ->
    Exec { 'Apply Pod Network Config':
        command     => "/usr/bin/kubectl apply -f /opt/vs_devenv/data/pod_network.yaml",
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    }
    
    
    /*
    
    $kubernetesConfig['pod_network_plugins'].each |String $pluginKey, Hash $pluginConfig| {
        if ( $pluginConfig['enabled'] ) {
            class { "::vs_kubernetes::pod_network_plugins::${$pluginKey}":
                config  => $pluginConfig,
                require => [
                    Exec['Enable Kubernetes for Root User'],
                ],
            }
        }
    }
    
    */
}