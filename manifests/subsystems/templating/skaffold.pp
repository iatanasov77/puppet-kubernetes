class vs_kubernetes::subsystems::templating::skaffold (
    Hash $config  = {},
) {
    wget::fetch { "Download Skaffold Setup.":
        source      => "https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64",
        destination => '/tmp/skaffold',
        verbose     => true,
        mode        => '0777',
        cache_dir   => '/var/cache/wget',
	  } ->
    File { 'Move Skaffold to /usr/local/bin/skaffold':
        ensure  => present,
        path    => '/usr/local/bin/skaffold',
        source  => '/tmp/skaffold',
        mode    => '0777',
    }
}
