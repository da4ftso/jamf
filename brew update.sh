&& sudo -u $3 /usr/local/bin/brew cu -ay #!/bin/sh
echo "brew has updated"

# check for existence of brew at /usr/local/bin
# v3 added brew upgrade 

if [ -f "/usr/local/bin/brew" ]; then
    sudo -u $3 /usr/local/bin/brew update && sudo -u $3 /usr/local/bin/brew upgrade && sudo -u $3 /usr/local/bin/brew cu -ay && sudo -u $3 /usr/local/bin/brew cleanup
    echo "brew has updated"
    exit 0
else
    echo "brew not found, exiting.."
    exit 1
fi    
