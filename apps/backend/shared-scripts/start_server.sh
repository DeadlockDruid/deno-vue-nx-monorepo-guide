#!/bin/bash

set -e         # Exit on error
set -o nounset # Treat unset variables as errors

# Install jq for parsing JSON if not already installed
if ! command -v jq &>/dev/null; then
  mkdir -p $HOME/bin
  curl -L -o $HOME/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
  chmod +x $HOME/bin/jq
  export PATH="$HOME/bin:$PATH"
  echo 'export PATH="$HOME/bin:$PATH"' >>~/.bashrc
  source ~/.bashrc
fi

# Check if Deno is installed, and install it if missing
if ! command -v deno &>/dev/null; then
  echo "Deno is not installed. Installing Deno..."
  curl -fsSL https://deno.land/install.sh | sh
  export PATH="$HOME/.deno/bin:$PATH"
  echo 'export PATH="$HOME/.deno/bin:$PATH"' >>~/.bashrc
  source ~/.bashrc
else
  echo "Deno is already installed."
fi

KEY_VAULT_NAME="my-apps"

# Ensure required environment variables are set
if [[ -z "${IDENTITY_ENDPOINT:-}" || -z "${IDENTITY_HEADER:-}" ]]; then
  echo "Error: IDENTITY_ENDPOINT or IDENTITY_HEADER is not set."
  exit 1
fi

# Fetch token using Managed Identity
TOKEN=$(curl -s "${IDENTITY_ENDPOINT}?api-version=2019-08-01&resource=https://vault.azure.net" \
  -H "X-IDENTITY-HEADER: ${IDENTITY_HEADER}" -H "Metadata:true" | jq -r .access_token || echo "")

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
  echo "Error: Failed to fetch access token using Managed Identity."
  exit 1
fi

fetch_all_secrets_with_values() {
  local url="https://${KEY_VAULT_NAME}.vault.azure.net/secrets?api-version=7.4"
  local all_secrets=()
  local response

  while [[ -n "$url" ]]; do
    echo "Fetching secret names from: $url"

    # Fetch secrets and check for errors
    response=$(curl -s -H "Authorization: Bearer $TOKEN" "$url" || echo "error")

    if [[ "$response" == "error" ]]; then
      echo "Error: Failed to fetch secret names from Azure Key Vault."
      exit 1
    fi

    # Extract secret names from the response
    local secrets_in_response
    secrets_in_response=$(echo "$response" | jq -r '.value[].id | split("/")[-1]')

    if [[ -z "$secrets_in_response" ]]; then
      echo "Warning: No secrets found in the vault."
      break
    fi

    all_secrets+=($secrets_in_response)

    # Get the next page URL if available
    url=$(echo "$response" | jq -r '.nextLink // empty')
  done

  # Fetch the values for each secret
  echo "Fetching secret values..."
  for secret in "${all_secrets[@]}"; do
    value=$(curl -s -H "Authorization: Bearer $TOKEN" \
      "https://${KEY_VAULT_NAME}.vault.azure.net/secrets/${secret}?api-version=7.4" | jq -r '.value')

    if [[ -n "$value" && "$value" != "null" ]]; then
      ENV_KEY=$(echo "$secret" | tr '-' '_' | tr '[:lower:]' '[:upper:]')
      export "$ENV_KEY"="$value"
      echo "Successfully set environment variable: $ENV_KEY"
    else
      echo "Warning: Secret '$secret' not found or has no value."
    fi
  done
}

# Call the function to fetch and export secrets
fetch_all_secrets_with_values

# Define paths and configurations
APP_DIR="/home/site/wwwroot"
BUNDLE_FILE="bundle.js"

echo "Starting the Deno app on port ${PORT}..."

# Ensure the compiled binary exists
if [ ! -f "${APP_DIR}/${BUNDLE_FILE}" ]; then
  echo "Error: Compiled Deno binary '${APP_DIR}/${BUNDLE_FILE}' not found."
  exit 1
fi

# Start the Deno app
deno run --allow-net --allow-env --allow-sys "${APP_DIR}/${BUNDLE_FILE}"
