#!/bin/bash

HEALTH_URL="http://localhost:5000/api/health"
LOG_FILE="/opt/asiahub/logs/monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
FAIL_COUNT_FILE="/opt/asiahub/logs/fail_count"

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$HEALTH_URL")

if [ "$RESPONSE" = "200" ]; then
    echo "[$TIMESTAMP] OK http_code=$RESPONSE" >> "$LOG_FILE"
    echo "0" > "$FAIL_COUNT_FILE"
else
    FAIL_COUNT=$(cat "$FAIL_COUNT_FILE" 2>/dev/null || echo "0")
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo "$FAIL_COUNT" > "$FAIL_COUNT_FILE"
    echo "[$TIMESTAMP] FAIL http_code=$RESPONSE fail_count=$FAIL_COUNT" >> "$LOG_FILE"

    if [ "$FAIL_COUNT" -ge 2 ]; then
        echo "[$TIMESTAMP] [ALERT] AsiaHub is DOWN. Consecutive failures: $FAIL_COUNT" >> "$LOG_FILE"
    fi
fi
