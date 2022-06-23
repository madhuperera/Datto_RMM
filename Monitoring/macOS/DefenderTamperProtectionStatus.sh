#!/bin/bash
TamperProtectionStatus=$(/usr/local/bin/mdatp health --field tamper_protection)
echo "Defender Tamper Protection is currently set to $TamperProtectionStatus"

if ["$TamperProtectionStatus" == "disabled"]; then
    echo "Oh No! It is off."
    exit 1;
else
    echo "Hooray. It is switched on!"
    exit 0;
fi
