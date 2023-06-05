class vs_kubernetes::container_runtime_docker (
    String $docker_log_max_size                     = '100m',
    String $docker_log_max_file                     = '1',
    String $docker_cgroup_driver                    = 'systemd',
) {
    ensure_resource( 'file', '/opt/vs_devenv', {
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0777',
    })
    
    package { 'inotify-tools':
        ensure => present,
    } ->
    
    file { '/etc/containerd':
        ensure => 'directory',
        mode   => '0644',
        owner  => 'root',
        group  => 'root',
    } ->
    
    file { '/opt/vs_devenv/fix_containerd.sh':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0777',
        source  => 'puppet:///modules/vs_kubernetes/fix_containerd.sh',
        require => File['/opt/vs_devenv'],
    } ->
    
    Exec { 'Whait For Containerd Config and Remove It':
        command => '/opt/vs_devenv/fix_containerd.sh > /dev/null 2>&1 &',
    } ->
    
    file { '/etc/docker':
        ensure => 'directory',
        mode   => '0644',
        owner  => 'root',
        group  => 'root',
    } ->

    file { '/etc/docker/daemon.json':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template( 'vs_kubernetes/docker/daemon_redhat.json.erb' ),
        require => [File['/etc/docker'], Package['docker']],
        notify  => Service['docker'],
    } ->
    
    service { 'docker':
        ensure  => running,
        enable  => true,
        #require => Exec['kubernetes-systemd-reload'],
    }
    
    -> Package { 'containerd':
        ensure  => present,
    }
    
    -> file { '/etc/containerd/FuckingWorkaround':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => 'FUCKING WORKAROUND',
    }
}