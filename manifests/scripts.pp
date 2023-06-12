class vs_kubernetes::scripts
{
    ensure_resource( 'file', '/opt/vs_devenv', {
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0777',
    })
    
    file { '/opt/vs_devenv/fix_containerd.sh':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0777',
        source  => 'puppet:///modules/vs_kubernetes/fix_containerd.sh',
        require => File['/opt/vs_devenv'],
    }
    
    file { '/opt/vs_devenv/pod_network.php':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0777',
        source  => 'puppet:///modules/vs_kubernetes/pod_network.php',
        require => File['/opt/vs_devenv'],
    }
}