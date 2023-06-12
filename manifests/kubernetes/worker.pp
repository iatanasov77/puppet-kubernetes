class vs_kubernetes::kubernetes::worker (
    
) {
    class { 'kubernetes':
        worker                  => true,
        
        manage_etcd             => true,
        manage_docker           => false,
        
        ignore_preflight_errors => [
            'FileExisting-conntrack',
            #all,
        ],
    }
}
