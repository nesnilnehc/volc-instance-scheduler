#!/bin/bash
set -e

# Check if required environment variables are set
if [ -z "$VOLCENGINE_ACCESS_KEY" ] || [ -z "$VOLCENGINE_SECRET_KEY" ]; then
    echo "Error: VOLCENGINE_ACCESS_KEY and VOLCENGINE_SECRET_KEY must be set."
    exit 1
fi

if [ -z "$INSTANCE_ID" ]; then
    echo "Error: INSTANCE_ID must be set."
    exit 1
fi

# Default schedule if not set (Every day at 22:00)
STOP_SCHEDULE=${STOP_SCHEDULE:-"0 22 * * *"}

echo "Starting Cloud Instance Controller (Cron Mode)..."
echo "Target Instance: $INSTANCE_ID"
echo "Region: ${VOLCENGINE_REGION:-cn-beijing}"
echo "Schedule: $STOP_SCHEDULE"
echo "Timezone: $TZ"

# Create a script for the cron job to run
# We need to export environment variables because cron runs in a limited shell
cat <<EOF > /app/run_stop.sh
#!/bin/bash
# Load environment variables
export VOLCENGINE_ACCESS_KEY="$VOLCENGINE_ACCESS_KEY"
export VOLCENGINE_SECRET_KEY="$VOLCENGINE_SECRET_KEY"
export VOLCENGINE_REGION="${VOLCENGINE_REGION:-cn-beijing}"
export INSTANCE_ID="$INSTANCE_ID"

CURRENT_TIME=\$(date)
echo "[\$CURRENT_TIME] Executing scheduled stop task for \$INSTANCE_ID..."

# Call StopInstance API with StopCharging mode
if /usr/local/bin/ve ecs StopInstance --InstanceId "\$INSTANCE_ID" --StoppedMode StopCharging; then
    echo "[\$CURRENT_TIME] Successfully sent stop command."
else
    echo "[\$CURRENT_TIME] Failed to send stop command."
fi
EOF

# Make the script executable
chmod +x /app/run_stop.sh

# Create the crontab file
# Redirect stdout and stderr to /var/log/cron.log (or /proc/1/fd/1 to see in docker logs)
echo "$STOP_SCHEDULE /app/run_stop.sh >> /proc/1/fd/1 2>&1" > /etc/crontabs/root

# Start crond in foreground (-f) with log level 2 (-l 2)
echo "Scheduler started. Waiting for next run..."
exec crond -f -l 2
