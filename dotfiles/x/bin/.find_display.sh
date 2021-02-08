# source this file
function find_xdisplay () (
    find /tmp/.X11-unix -user "${UID}" -printf "%f" | head -n 1 | tr "X" ":"
)
