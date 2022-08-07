class vs_kubernetes::hosts (
    Hash $hosts    = {},
) {
    $hosts.each |String $hostKey, Hash $hostConfig| {
        host { $hostKey:
            ensure          => 'present',
            host_aliases    => $hostConfig['aliases'],
            ip              => "${$hostConfig['ip']}",
            target          => '/etc/hosts',
        }
    }
}
