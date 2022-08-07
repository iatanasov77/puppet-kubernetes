class vs_kubernetes::subsystems::templating (
    Hash $config  = {},
) {
    $config['tools'].each |String $tool| {
        class { "::vs_kubernetes::subsystems::templating::${$tool}":
            config  => $config,
        }
    }
}
