#!/bin/bash

# Step 0: Determine SSH username from gcloud account email
email=$(gcloud config get-value account 2>/dev/null)
if [[ -z "$email" ]]; then
    echo "Error: Could not retrieve gcloud account. Make sure you're logged in (gcloud auth login)."
    exit 1
fi

GCP_SSH_USER=$(echo "$email" | tr '@.' '_')

# Step 1: Refresh SSH config entries
gcloud compute config-ssh --quiet

CONFIG="$HOME/.ssh/config"
TMP_CONFIG="$CONFIG.tmp.$$"

# Step 2: Inject User into each Host block if missing
awk -v ssh_user="$GCP_SSH_USER" '
function flush_block() {
    if (block != "") {
        if (block !~ /[[:space:]]User[[:space:]]+/) {
            block = block "\n    User " ssh_user
        }
        print block "\n"
        block = ""
    }
}

BEGIN { in_block = 0 }

/^Host / {
    flush_block()
    block = $0
    in_block = 1
    next
}

/^# End of Google Compute Engine Section/ {
    flush_block()
    print
    next
}

in_block {
    if ($0 ~ /^[[:space:]]*$/) {
        flush_block()
        in_block = 0
        next
    } else {
        block = block "\n" $0
        next
    }
}

{
    print
}
END {
    flush_block()
}
' "$CONFIG" > "$TMP_CONFIG"

mv "$TMP_CONFIG" "$CONFIG"

