class vs_kubernetes::subsystems::ingress_controllers::nginx (
    Hash $config    = {},
) {
    if ! defined( Package['unzip'] ) {
        package { 'unzip':
            ensure => present,
        }
    }

    archive { '/tmp/nginx-ingress.zip':
        ensure        	=> present,
        source        	=> "https://github.com/nginxinc/kubernetes-ingress/archive/refs/heads/main.zip",
        extract       	=> true,
        extract_path  	=> '/tmp',
        cleanup       	=> true,
    } ->

    Exec { 'Apply Nginx Service Account.':
        command     => '/usr/bin/kubectl apply -f /tmp/kubernetes-ingress-main/deployments/common/ns-and-sa.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->

    Exec { 'Apply Nginx Roles.':
        command     => '/usr/bin/kubectl apply -f /tmp/kubernetes-ingress-main/deployments/rbac/rbac.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->

    Exec { 'Apply Nginx Server Config.':
        command     => '/usr/bin/kubectl apply -f /tmp/kubernetes-ingress-main/deployments/common/nginx-config.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->

    Exec { 'Apply Nginx Ingress Class.':
        command     => '/usr/bin/kubectl apply -f /tmp/kubernetes-ingress-main/deployments/common/ingress-class.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->


    Exec { 'Apply Nginx Virtual Servers.':
        command     => '/usr/bin/kubectl apply -f /tmp/kubernetes-ingress-main/deployments/common/crds/k8s.nginx.org_virtualservers.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->
    Exec { 'Apply Nginx Virtual Server Routes.':
        command     => '/usr/bin/kubectl apply -f /tmp/kubernetes-ingress-main/deployments/common/crds/k8s.nginx.org_virtualserverroutes.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->
    Exec { 'Apply Nginx Virtual Server Transports.':
        command     => '/usr/bin/kubectl apply -f /tmp/kubernetes-ingress-main/deployments/common/crds/k8s.nginx.org_transportservers.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->
    Exec { 'Apply Nginx Virtual Server Policies.':
        command     => '/usr/bin/kubectl apply -f /tmp/kubernetes-ingress-main/deployments/common/crds/k8s.nginx.org_policies.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->


    Exec { 'Apply Nginx Ingress Controller Deployment(Installation).':
        command     => '/usr/bin/kubectl apply -f /tmp/kubernetes-ingress-main/deployments/deployment/nginx-ingress.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    } ->


    Exec { 'Apply Nginx Ingress NodePort Service.':
        command     => '/usr/bin/kubectl apply -f /tmp/kubernetes-ingress-main/deployments/service/nodeport.yaml',
        environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    }

}
