#!/bin/bash
# ======================================
# Pi-hole Blocklist Auto Updater
# ======================================
# Author: Andrew Emmanuel
# Updated: 2025-11-12

# Output file
OUTPUT_FILE="hosts.txt"

# Temporary directory
TMP_DIR=$(mktemp -d)

# Source lists
LISTS=(
  "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts"
  "https://blocklistproject.github.io/Lists/adult.txt"
  "https://o0.pages.dev/Pro/hosts-porn.txt"
)

# Download and combine all lists
echo "# My Custom Combined Blocklist" > $OUTPUT_FILE
echo "# Generated on $(date)" >> $OUTPUT_FILE
echo "# ======================================" >> $OUTPUT_FILE

for URL in "${LISTS[@]}"; do
    echo "Fetching $URL..."
    curl -s "$URL" >> "$TMP_DIR/all.txt"
done

# Add your personal domains
cat my_custom_domains.txt >> "$TMP_DIR/all.txt"

# Clean up: remove comments, blank lines, and duplicates
cat "$TMP_DIR/all.txt" \
  | grep -vE "^#|^$" \
  | awk '{print $2}' \
  | sort -u \
  | sed 's/^/0.0.0.0 /' \
  > "$OUTPUT_FILE"

# Commit and push to GitHub
git add $OUTPUT_FILE
git commit -m "Auto-update blocklist $(date +'%Y-%m-%d %H:%M:%S')" || true
git push origin main

# Cleanup
rm -rf "$TMP_DIR"

echo "✅ Blocklist updated and pushed to GitHub!"
