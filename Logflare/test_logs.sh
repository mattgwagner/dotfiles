#!/bin/bash

# Logflare Test Script - Generates 50 variations of test logs
# This script sends 50 different log entries to test Logflare's search functionality

BASE_URL="https://logs.redleg.app/api/logs"
API_KEY="logflare_public_token_123"
SOURCE="69407f6e-0e20-4166-a72d-99bfbba2a1ff"

# Arrays for random data generation
EVENT_MESSAGES=(
    "User login successful"
    "Database connection established"
    "API request processed"
    "Payment transaction completed"
    "File upload successful"
    "Email sent successfully"
    "Cache miss occurred"
    "Authentication failed"
    "Rate limit exceeded"
    "System backup completed"
    "Memory usage high"
    "Network timeout occurred"
    "Data validation passed"
    "Configuration updated"
    "Service restarted"
    "Error occurred in processing"
    "User session expired"
    "Database query executed"
    "External API called"
    "Log file rotated"
    "Security scan completed"
    "Performance metrics collected"
    "User registration completed"
    "Password reset requested"
    "Account locked due to suspicious activity"
    "Data export completed"
    "System maintenance started"
    "Backup verification failed"
    "New user created"
    "Order processed successfully"
    "Inventory updated"
    "Shipping label generated"
    "Refund processed"
    "Customer support ticket created"
    "System health check passed"
    "Load balancer configured"
    "SSL certificate renewed"
    "Database migration completed"
    "Feature flag toggled"
    "Analytics data collected"
    "Webhook received"
    "Queue processing started"
    "Cache cleared"
    "Session timeout warning"
    "Resource allocation completed"
    "Monitoring alert triggered"
    "Data synchronization started"
    "User permission updated"
    "System configuration validated"
    "External service unavailable"
)

REQUEST_METHODS=("GET" "POST" "PUT" "DELETE" "PATCH" "HEAD" "OPTIONS")
USER_AGENTS=("chrome" "firefox" "safari" "edge" "mobile-app" "api-client" "bot" "curl")
DATACENTERS=("aws" "gcp" "azure" "digitalocean" "linode" "vultr" "self-hosted")
COMPANIES=("Apple" "Google" "Microsoft" "Amazon" "Meta" "Netflix" "Spotify" "Uber" "Airbnb" "Tesla")
CITIES=("New York" "San Francisco" "Los Angeles" "Chicago" "Boston" "Seattle" "Austin" "Denver" "Miami" "Portland")
STATES=("NY" "CA" "IL" "MA" "WA" "TX" "CO" "FL" "OR" "NV")

# Function to get random element from array
get_random() {
    local arr=("$@")
    echo "${arr[$((RANDOM % ${#arr[@]}))]}"
}

# Function to generate random IP
get_random_ip() {
    echo "$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"
}

# Function to generate random user ID
get_random_user_id() {
    echo $((RANDOM % 10000 + 1))
}

# Function to generate random login count
get_random_login_count() {
    echo $((RANDOM % 1000 + 1))
}

# Function to generate random zip code
get_random_zip() {
    echo $((RANDOM % 99999 + 10000))
}

echo "Starting Logflare test with 50 log variations..."
echo "=============================================="

# Send 50 test logs
for i in {1..50}; do
    echo "Sending test log $i/50..."
    
    # Generate random data
    EVENT_MSG=$(get_random "${EVENT_MESSAGES[@]}")
    REQUEST_METHOD=$(get_random "${REQUEST_METHODS[@]}")
    USER_AGENT=$(get_random "${USER_AGENTS[@]}")
    DATACENTER=$(get_random "${DATACENTERS[@]}")
    COMPANY=$(get_random "${COMPANIES[@]}")
    CITY=$(get_random "${CITIES[@]}")
    STATE=$(get_random "${STATES[@]}")
    IP_ADDRESS=$(get_random_ip)
    USER_ID=$(get_random_user_id)
    LOGIN_COUNT=$(get_random_login_count)
    ZIP_CODE=$(get_random_zip)
    VIP_STATUS=$([ $((RANDOM % 2)) -eq 0 ] && echo "true" || echo "false")
    
    # Create the JSON payload
    JSON_PAYLOAD=$(cat <<EOF
{
  "event_message": "$EVENT_MSG",
  "metadata": {
    "ip_address": "$IP_ADDRESS",
    "request_method": "$REQUEST_METHOD",
    "custom_user_data": {
      "vip": $VIP_STATUS,
      "id": $USER_ID,
      "login_count": $LOGIN_COUNT,
      "company": "$COMPANY",
      "address": {
        "zip": "$ZIP_CODE",
        "st": "$STATE",
        "street": "$((RANDOM % 9999 + 1)) $(get_random "Main" "Oak" "Pine" "Elm" "First" "Second" "Third" "Broadway" "Park" "Washington") St",
        "city": "$CITY"
      }
    },
    "datacenter": "$DATACENTER",
    "request_headers": {
      "connection": "close",
      "user_agent": "$USER_AGENT"
    },
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)",
    "severity": "$(get_random "info" "warning" "error" "debug" "critical")",
    "service": "$(get_random "auth" "api" "database" "cache" "queue" "worker" "web" "mobile")",
    "version": "v$((RANDOM % 3 + 1)).$((RANDOM % 10)).$((RANDOM % 10))",
    "environment": "$(get_random "production" "staging" "development" "testing")"
  }
}
EOF
)

    # Send the request
    curl -s -X "POST" "$BASE_URL?source=$SOURCE_ID" \
        -H 'Content-Type: application/json' \
        -H "X-API-KEY: $API_KEY" \
        -d "$JSON_PAYLOAD" > /dev/null
    
    if [ $? -eq 0 ]; then
        echo "✓ Log $i sent successfully"
    else
        echo "✗ Failed to send log $i"
    fi
    
    # Small delay between requests
    sleep 0.1
done

echo "=============================================="
echo "Test completed! 50 log entries sent to Logflare."
echo "You can now test searching at: http://localhost:4000"
echo ""
echo "Try searching for:"
echo "- Specific companies: Apple, Google, Microsoft"
echo "- Severity levels: error, warning, info"
echo "- Services: auth, api, database"
echo "- Environments: production, staging"
echo "- IP addresses or user IDs"
echo "- Event messages containing specific keywords"
