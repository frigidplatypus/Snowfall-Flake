#!/etc/profiles/per-user/justin/bin/bash


# Define the list of hostnames and their corresponding MAC addresses
declare -A mac_addresses
mac_addresses=(
    ["nasnix"]="00:11:22:33:44:55"
    ["p5810"]="66:77:88:99:AA:BB"
    # Add more hostnames and MAC addresses as needed
)

# Check if the hostname is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <hostname>"
    exit 1
fi

hostname=$1

# Look up the MAC address for the given hostname
mac_address=${mac_addresses[$hostname]}

# Check if the MAC address was found
if [ -z "$mac_address" ]; then
    echo "MAC address for hostname '\$hostname' not found."
    exit 1
fi

\${pkgs.wakelan}/bin/wakelan -m $mac_address -p 192.168.0.255
