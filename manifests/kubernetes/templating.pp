class vs_kubernetes::kubernetes::templating (
    Hash $config  = {},
) {
    $config['tools'].each |String $tool| {
        class { "::vs_kubernetes::kubernetes::templating::${$tool}":
            config  => $config,
        }
    }
}
