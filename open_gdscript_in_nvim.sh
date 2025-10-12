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

if [ -e "$GODOTHOST" ]; then
    nvim --server "$GODOTHOST" --remote-send "<C-\><C-n>:n $FILE<CR>${LINE}G${COL}|" && exit
fi

# Use AppleScript to open iTerm2, cd to project root, and run nvim
osascript <<EOF
tell application "System Events"
    if not (exists (processes where name is "iTerm2")) then
        tell application "iTerm" to activate
        delay 0.5
    end if
end tell
tell application "iTerm"
    if not (exists window 1) then
        set myterm to (create window with default profile)
    else
        tell current window
            set myterm to (create tab with default profile)
        end tell
    end if
    tell current session of myterm
        write text "cd '$PROJECT_ROOT' && nvim '$FILE' +${LINE}"
    end tell
end tell
EOF
