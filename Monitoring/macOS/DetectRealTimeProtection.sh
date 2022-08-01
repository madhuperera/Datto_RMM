#!/bin/bash
RealTimeProtectionStatus=$(/usr/local/bin/mdatp health --field real_time_protection_enabled)
echo "Defender Real Time Protection is currently set to $RealTimeProtectionStatus"
ExpectedValue="true"

if ["$RealTimeProtectionStatus" = "$ExpectedValue"]; then
    echo "Hooray. It is switched on!"
    exit 0;
else
    echo "Oh No! It is off."
    exit 1;
fi
