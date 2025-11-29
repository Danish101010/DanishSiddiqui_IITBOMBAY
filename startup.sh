#!/bin/sh
# Entrypoint wrapper to handle literal "$PORT" in start commands.
# Some platforms (Railway/Render) may pass the command with a literal "$PORT"
# which is not shell-expanded when provided as the container CMD. This wrapper
# replaces occurrences of the literal string "$PORT" with the actual env var
# value and then executes the resulting command.

if [ "$#" -eq 0 ]; then
  echo "No command provided. Defaulting to: python main.py"
  exec python main.py
fi

# Join all arguments into a single string
cmd="$*"

# Normalize escaped "\$PORT" (a backslash before $) to plain "$PORT" so
# subsequent replacement will work whether the Procfile/command supplied
# "$PORT" or "\$PORT". Some deploy systems or quoting can leave the
# backslash in the argument, which prevented the previous replacement.
cmd=$(printf "%s" "$cmd" | sed 's/\\$PORT/$PORT/g')

# Replace occurrences of "$PORT" (dollar-sign-P-O-R-T) with the
# environment variable value (fallback to 8000 if not set).
PORT_VAL=${PORT:-8000}
cmd=$(printf "%s" "$cmd" | sed "s/\$PORT/${PORT_VAL}/g")

echo "[startup.sh] Executing: $cmd"

exec sh -c "$cmd"
