#!/bin/bash
###################################
# Socks proxy proxychains manager #
#      Coded by @anestisb         #
###################################


# Customize this
PROXYCHAINS=/usr/local/bin/proxychains4
PROXYCHAINS_CONF=/usr/local/etc/proxychains.conf
TMP_DIR=/tmp
# Check your proxychains version for external conf support (-f)

# Gather the SSH connections with socks proxy usage
N=0
echo -e "\e[32m[*] Detected socks SSH connections.\e[0m"
for i in $(ps -fe | grep 'ssh\ ' | grep '\-D' | awk -F" " '{print $2}'); do
    array[$N]=$(xargs -0 echo < /proc/$i/cmdline)
    echo "$N: ${array[$N]}"
    let "N = $N + 1"
done

# Ask user to choose
while [ 1 ]; do
    echo -n "Place your choice:"
    read -n1 choice
    echo -e "\n"
    if [ $choice -lt ${#array[@]} ]; then
        break
    else
	echo -e "\e[31m[-] Invalid choice!\e[0m"
    fi
done

# Parse the socks proxy port (Yes I know it's dirty)
PORT=$(echo ${array[$choice]} | awk -F"-D" '{print $2}' | awk -F" " '{print $1}')
echo -e "\e[32m[*] Using local socks proxy on port '$PORT'.\e[0m"

# Debug print outs
# echo -e "\e[32m[*]Template config file.\e[0m"
# cat $PROXYCHAINS_CONF | grep -v "#" | grep -v '^$'

# Compose the temp config
cat $PROXYCHAINS_CONF | grep -v "#" | grep -v '^$' | grep -v 'socks' > $TMP_DIR/pt_socks_$choice.conf
echo "socks5 127.0.0.1 $PORT" >> $TMP_DIR/pt_socks_$choice.conf

# More debug
# echo -e "\e[32m[*] Config file available at '$TMP_DIR/pt_socks_$choice.conf', containing:\e[0m"
# cat $TMP_DIR/pt_socks_$choice.conf

# Finally run through the proxy
# Use '-q' for quiet proxychains output
$PROXYCHAINS -f $TMP_DIR/pt_socks_$choice.conf $@

# Comment this to preserve the config
rm $TMP_DIR/pt_socks_$choice.conf
