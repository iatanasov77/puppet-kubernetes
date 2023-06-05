!#/bin/bash
 
if [ -z "$(which inotifywait)" ]; then
    echo "inotifywait not installed."
    echo "In most distros, it is available in the inotify-tools package."
    exit 1
fi
 
counter_containerd_config=0;
counter_containerd_service=0;
 
function execute() {
    
    # eval "$@"
    
    if test -f "/etc/containerd/config.toml"; then
        counter_containerd_config=$((counter_containerd_config+1))
        echo "$counter_containerd_config" > /tmp/counter_containerd_config
        
        rm -f /etc/containerd/config.toml
    fi
    
    if test -f "/usr/lib/systemd/system/containerd.service"; then
        counter_containerd_service=$((counter_containerd_service+1))
        echo "$counter_containerd_service" > /tmp/counter_containerd_service
        
        service containerd restart
    fi
}

inotifywait --monitor --format "%e %w%f" \
--event create /etc/containerd \
| while read changed; do
    echo $changed
    execute "$@"
done