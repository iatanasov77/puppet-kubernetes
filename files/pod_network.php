#!/usr/bin/php
<?php
// php /opt/vs_devenv/pod_network.php calico 3.26.0 10.244.0.0/16
$baseDir    = '/opt/vs_devenv';
$newYamlString;

function getUsage()
{
    return 'php /opt/vs_devenv/pod_network.php <provider> <version> <cidr>';    
}

function createLog( string $data )
{
    global $baseDir;
    
    $logDir = $baseDir . '/log/';
    if ( ! is_dir( $logDir ) ) {
        mkdir( $logDir );
    }
    
    $Now    = new DateTime( 'now', new DateTimeZone( 'Europe/Sofia' ) );
    $logFile    = $logDir . 'pod_network.log';
    $logRow     = "[" . $Now->format( 'Y-m-d H:i:s' ) . "] " . $data;
    
    file_put_contents( $logFile, $logRow . "\n", FILE_APPEND );
}

function ensureDataDir(): string
{
    global $baseDir;
    
    $dataDir = $baseDir . '/data/';
    if ( ! is_dir( $dataDir ) ) {
        mkdir( $dataDir );
    }
    
    return $dataDir;
}

function createFlannelConfig( array $data ): string
{
    $yamlString = yaml_emit( $data[0] ) . "\n\n";
    for ( $i = 1; $i < count( $data ); $i++ ) {
        $yamlString .= yaml_emit( $data[$i] ) . "\n\n";
    }
    
    return $yamlString;
}

function createCalicoConfig( array $data ): string
{
    $yamlString = yaml_emit( $data[0] ) . "\n\n";
    for ( $i = 1; $i < count( $data ); $i++ ) {
        $yamlString .= yaml_emit( $data[$i] ) . "\n\n";
    }
    
    return str_replace( 'spec: []', 'spec: {}', $yamlString );
}

/**
 * MAIN SCRIPT
 */

if ( count( $argv ) < 4 ) {
    echo "Usage: " . getUsage() . "\n"; die;
}

$podNetworkProvider = $argv[1];
$podNetworkVersion  = $argv[2];
$podNetworkCidr     = $argv[3];

switch ( $podNetworkProvider ) {
    case 'flannel':
        $url    = "https://raw.githubusercontent.com/flannel-io/flannel/v{$podNetworkVersion}/Documentation/kube-flannel.yml";
        $yaml   = file_get_contents( $url );
        
        if ( $podNetworkCidr == '10.244.0.0/16' ) {
            $newYamlString  = $yaml;
        } else {
            $ndocs  = 0;
            $data   = yaml_parse( $yaml, -1, $ndocs );
            
            $data[4]['data']['net-conf.json']   = "{\"Network\": \"" . $podNetworkCidr . "\",\"Backend\": {\"Type\": \"vxlan\"}}";
            
            $newYamlString  = createFlannelConfig( $data );
        }
        
        break;
    case 'calico':
        $ndocs  = 0;
        
        $url        = "https://raw.githubusercontent.com/projectcalico/calico/v{$podNetworkVersion}/manifests/custom-resources.yaml";
        $yaml       = file_get_contents( $url );
        $data       = yaml_parse( $yaml, -1, $ndocs );
        
        $data[0]['spec']['calicoNetwork']['ipPools'][0]   = [
            'blockSize'     => 26,
            'cidr'          =>  $podNetworkCidr,
            'encapsulation' => 'VXLANCrossSubnet',
            'natOutgoing'   => 'Enabled',
            'nodeSelector'  => 'all()',
        ];
        
        $newYamlString  = createCalicoConfig( $data );
        
        break;
    default:
        createLog( "Unsupported Network Provider: " . $podNetworkProvider );
}

$dataDir    = ensureDataDir();
$dataFile   = $dataDir . 'pod_network.yaml';

file_put_contents( $dataFile, $newYamlString );

createLog( "Succefully Create Network: " . $podNetworkProvider );
