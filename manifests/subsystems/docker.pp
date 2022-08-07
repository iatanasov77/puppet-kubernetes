class vs_kubernetes::subsystems::docker (
	Hash $config    = {},
) {
  class { 'docker':
        ensure          => 'present',
        version         => "${$config['version']}",
        docker_users    => $config['users'],

        tcp_bind        => ["tcp://${facts['ipaddress_eth1']}:2375"],
        socket_bind     => 'unix:///var/run/docker.sock',
        ip_forward      => true,
        iptables        => true,
        ip_masq         => true,
    }
    
    /* Conflicting With 'Kustomize'

    class { 'docker::compose':
        ensure => present,
    }
    
    */
}
