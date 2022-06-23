# Burrowed from https://github.com/ayethatsright/MacOS-Hardening-Script/blob/master/hardening_check.sh
# THIS SECTION CHECKS THAT AUTOMATIC UPDATES ARE ENABLED

echo "[i] Checking that automatic updates are enabled"

updates=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled)
updatescorrect="true"

if [ "$updates" == "$updatescorrect" ]; then
        echo "[YES] Automatic updates are enabled"
        exit 0;
else 
	echo "[WARNING] Automatic updates are NOT enabled"
        exit 1;
fi
