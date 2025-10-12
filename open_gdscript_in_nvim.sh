#!/bin/bash

## This script is a convenience wrapper for launching iTerm2 to nvim in a godot project.
#  In Editor Settings -> Text Editor -> External
#  Exec Path: /Users/pilot/.config/nvim/open_gdscript_in_nvim.sh
#  Exec Flags: "{project}" "{file}" "{line}" "{col}"

# Arguments from Godot
PROJECT_ROOT="$1"
FILE="$2"      # script file full path
LINE="$3"      # line number
COL="$4"       # column number

# Path to godothost, relative to project root
GODOTHOST="$PROJECT_ROOT/godothost"

echo "HELLO" > ~/.deleteme

if [ -e "$GODOTHOST" ]; then
    nvim --server "$GODOTHOST" --remote-send "<C-\><C-n>:n $FILE<CR>${LINE}G${COL}|"
else
    # Use AppleScript to open iTerm2, cd to project root, and run nvim
    osascript <<EOF
    tell application "iTerm"
        activate
        set myterm to (create window with default profile)
        tell current session of myterm
            write text "cd '$PROJECT_ROOT' && nvim '$FILE' +${LINE} && exit"
        end tell
    end tell
EOF
fi
