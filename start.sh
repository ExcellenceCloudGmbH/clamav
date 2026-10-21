#!/bin/sh

# Start the crond daemon in the background (runs /scan.sh daily, see the
# crontab written in the Dockerfile).
/usr/sbin/crond -L /var/log/cron.log

# Start the main application (ClamAV) and replace the current shell process
# The 'exec' command ensures that signals (like SIGTERM) are passed directly
# to /clamav, allowing the container to shut down gracefully.
echo "Starting ClamAV application..."
exec /clamav
