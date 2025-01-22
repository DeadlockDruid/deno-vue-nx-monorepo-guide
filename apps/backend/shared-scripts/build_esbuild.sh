#!/bin/bash

# Exit on error or unset variable
set -e
set -u

WORKSPACE_IMPORT_MAP=""
PROJECT_IMPORT_MAP=""
OUTPUT_DIR=""
MAIN_FILE=""

usage() {
  echo "Usage: $0 --workspace-import-map <path> --project-import-map <path> --output-dir <path> --main-file <path>"
  echo "Example: $0 --workspace-import-map ../shared_import_map.json --project-import-map deno.json --output-dir dist --main-file main.ts"
  exit 1
}

# Parse arguments
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
  *)
    echo "Unknown argument: $1"
    usage
    ;;
  esac
done

if [[ -z "$WORKSPACE_IMPORT_MAP" || -z "$PROJECT_IMPORT_MAP" || -z "$OUTPUT_DIR" || -z "$MAIN_FILE" ]]; then
  echo "Error: Missing required arguments."
  usage
fi

# Cleanup
echo "Cleaning up old artifacts..."
rm -rf "$OUTPUT_DIR"/*

# Merge import maps
echo "Merging import maps..."
MERGED_IMPORT_MAP="$OUTPUT_DIR/../merged_import_map.json"
mkdir -p "$OUTPUT_DIR"

jq -s '.[0].imports * .[1].imports | {imports: .}' "$WORKSPACE_IMPORT_MAP" "$PROJECT_IMPORT_MAP" >"$MERGED_IMPORT_MAP"

# Bundle with esbuild
echo "Bundling with esbuild..."
deno run --allow-read --allow-write --allow-net --allow-env --allow-run ../shared-scripts/build.js \
  --import-map "$MERGED_IMPORT_MAP" \
  --output-dir "$OUTPUT_DIR" \
  --entry-point "$MAIN_FILE"

echo "Bundling complete: $OUTPUT_DIR/bundle.js"
