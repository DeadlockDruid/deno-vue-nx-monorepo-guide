#!/bin/bash

# NOTE: All relative paths in this script are resolved based on the directory where the script is executed,
# not where the script itself is located. Since this script will be run from the project root (e.g., "apps/backend/deno-app-1/"),
# paths referring to shared resources (like "../shared-scripts/") need to account for that by using "../" to go one level up.
# Ensure you run this script from the correct directory to avoid path resolution issues.

# Exit on error or unset variable
set -e
set -u

# Initialize variables
WORKSPACE_IMPORT_MAP=""
PROJECT_IMPORT_MAP=""
OUTPUT_DIR=""
MAIN_FILE=""
TARGET="x86_64-unknown-linux-gnu" # Default target platform

# Function to display usage
usage() {
  echo "Usage: $0 --workspace-import-map <path> --project-import-map <path> --output-dir <path> --main-file <path> [--target <platform>]"
  echo "Example: $0 --workspace-import-map ../shared_import_map.json --project-import-map deno.json --output-dir dist --main-file main.ts"
  exit 1
}

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --workspace-import-map)
    WORKSPACE_IMPORT_MAP="$2"
    shift 2
    ;;
  --project-import-map)
    PROJECT_IMPORT_MAP="$2"
    shift 2
    ;;
  --output-dir)
    OUTPUT_DIR="$2"
    shift 2
    ;;
  --main-file)
    MAIN_FILE="$2"
    shift 2
    ;;
  --target)
    TARGET="$2"
    shift 2
    ;;
  *)
    echo "Unknown argument: $1"
    usage
    ;;
  esac
done

# Validate required arguments
if [[ -z "$WORKSPACE_IMPORT_MAP" || -z "$PROJECT_IMPORT_MAP" || -z "$OUTPUT_DIR" || -z "$MAIN_FILE" ]]; then
  echo "Error: Missing required arguments."
  usage
fi

# Step 0: Cleanup old build artifacts
echo "Cleaning up old artifacts..."
rm -rf "$OUTPUT_DIR"/*

# Step 1: Merge the import maps
echo "Merging import maps..."
MERGED_IMPORT_MAP="$OUTPUT_DIR/../merged_import_map.json"
mkdir -p "$OUTPUT_DIR"

jq -s '.[0].imports * .[1].imports | {imports: .}' "$WORKSPACE_IMPORT_MAP" "$PROJECT_IMPORT_MAP" >"$MERGED_IMPORT_MAP"

# Step 2: Compile the Deno app
echo "Compiling Deno app..."

# export DENO_DIR="./.deno_cache"
deno compile --allow-net --allow-env --target "$TARGET" --import-map "$MERGED_IMPORT_MAP" --output "$OUTPUT_DIR/deno-app" "$MAIN_FILE"

echo "Deno app successfully compiled to $OUTPUT_DIR/deno-app"
