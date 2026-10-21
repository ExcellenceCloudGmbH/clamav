#!/bin/sh

# Log start time of the scan
echo "Cron job executed at $(date)" >> /var/log/scan.log

# Run the ClamAV scan and capture the output and the exit code of clamdscan:
# 0 = no virus found, 1 = virus(es) found, 2 = an error occurred.
SCAN_RESULT=$(clamdscan /host 2>&1)
SCAN_RC=$?
echo "$SCAN_RESULT" > /var/log/clamav-scan.log

case "$SCAN_RC" in
  0)
    echo "Scan completed successfully." >> /var/log/scan.log
    EMAIL_SUBJECT="ClamAV Scan Report: Clean ($(hostname))"
    EMAIL_BODY="The scan completed successfully at $(date). No infected files found."
    ;;
  1)
    echo "Scan found infected files. Check /var/log/clamav-scan.log for details." >> /var/log/scan.log
    EMAIL_SUBJECT="ClamAV Scan Report: INFECTED FILES FOUND ($(hostname))"
    EMAIL_BODY="The scan found infected files at $(date). Handle as a security finding (malware detection)."
    ;;
  *)
    echo "Scan encountered errors (exit code $SCAN_RC). Check /var/log/clamav-scan.log for details." >> /var/log/scan.log
    EMAIL_SUBJECT="ClamAV Scan Report: Error ($(hostname))"
    EMAIL_BODY="The scan encountered errors at $(date) (clamdscan exit code $SCAN_RC)."
    ;;
esac

EMAIL_BODY="$EMAIL_BODY

Scan Result:
$SCAN_RESULT"

# Send the email
/app/venv/bin/python /send_email.py "$EMAIL_SUBJECT" "$EMAIL_BODY"
