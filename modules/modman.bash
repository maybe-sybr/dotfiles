# vi: set ft=sh
#
# This module handles the loading of other potentially distro-specific modules
function mdf_modman_load () {
    # Make sure we know the distro we're on
    if [ -z "${MDF_DISTRO_SOURCE:-}" ]; then
        declare -glr MDF_DISTRO_SOURCE="$(lsb_release --id | cut -f2)"
    fi
    # Turn off globbing here since the loop expression might expand paths
    set -o noglob
    for module_name in "${@}"; do
        # Distro specific modules override generic ones
        declare -a candidates=(
            "${MDF_MODULES_PATH}/${MDF_DISTRO_SOURCE}"
            "${MDF_MODULES_PATH}"
        )
        declare -l found=false
        for candidate in "${candidates[@]}"; do
            if [ -f "${candidate}/${module_name}.bash" ]; then
                source "${candidate}/${module_name}.bash"
                found=true ; break
            fi
        done
        if ! "${found}" ; then
            echo "Unable to load module ${module_name}"
            "${found}" ; return
        fi
    done
    set +o noglob
}

# We need to know where we are to load other modules, but we'll accept being
# told where to load modules from is someone else got in before we load
function __mdf_modman-bash_init () {
    if [ -z "${MDF_MODULES_PATH:-}" ]; then
        local -r REAL_SCRIPT_PATH="$(realpath -e "${BASH_SOURCE[0]}")"
        declare -glr MDF_MODULES_PATH="${REAL_SCRIPT_PATH%/*}"
    fi
}
__mdf_modman-bash_init
