# vi: set ft=sh
#
# This module provides package management helpers for Fedora, using either
# `yum` or `dnf` if it's available.

function mdf_pkgman_install () {
    mdf_prinfo "Installing packages with $(basename "${MDF_PKGMAN_COMMAND}")"
    for pkgname in "$@"; do
        mdf_prinfo "\t${pkgname}"
    done
    # Perform the actuall install
    if [ ! -z "${MDF_PKGMAN_SUDO}" ]; then
        mdf_prwarn "You will be asked to provide credentials for the install"
    fi
    ${MDF_PKGMAN_SUDO:-} "${MDF_PKGMAN_COMMAND}" install -y "$@"
}

# We'll work out what package manager to use during initialisation
function __mdf_fedora-pkgman-bash_init () {
    # Find a package manager program
    if [ -z "${MDF_PKGMAN_COMMAND:-}" ]; then
        declare -l found=false
        for candidate in "dnf" "yum"; do
            if command -pv "${candidate}" >/dev/null; then
                declare -glr MDF_PKGMAN_COMMAND="$(
                    command -pv "${candidate}"
                )"
                found=true ; break
            fi
        done
        if ! "${found}" ; then
            echo "Unable to find Fedora package manager"
            "${found}" ; return
        fi
    fi
    # Work out if well need to `sudo` our commands - we work this out by
    # checking if trying to do nothing in a `yum`/`dnf` shell blows up or not.
    # We use `sudo` with the `-k` option to not cache credentials. This means
    # the user will be asked to provide a password for every call to
    # `mdf_pkgman_install()` so try to do batch installs to not be annoying.
    if ! "${MDF_PKGMAN_COMMAND}" shell /dev/null &>/dev/null; then
        declare -glr MDF_PKGMAN_SUDO="$(command -pv sudo) -k"
    fi
    # Load the logging module if we can find the module manager
    if [ ! -z "${MDF_MODULES_PATH:-}" ]; then
        source "${MDF_MODULES_PATH}/modman.bash"
        mdf_modman_load logman
    fi
}
__mdf_fedora-pkgman-bash_init
