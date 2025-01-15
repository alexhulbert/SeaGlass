# SystemdEnable
#     [--no-alias|--no-wanted-by]
#     [--name CUSTOM_NAME]
#     [--type system|user]
#     [--from-file|package] unit
#
# Enable a systemd unit file.
#
# Caveat: This will not process Also directives, as it might in theory require
# handling files from other packages. In addition you might not want to install
# both this unit and the Also unit.
#
# --no-alias and --no-wanted-by can be used to disable installing those types of
# links. This is useful if you want to just use socket and dbus activation and
# don't want the unit to start on boot.
#
# --name is to be used for parameterised units ("foo@.service"), to provide the
# parameter.
#
# --type defaults to system but can be used to override and install default user
# units in /etc/systemd/user.
#
# --from-file is used when unit file is installed by aconfmgr instead of pulled
# from a package. In this case the package name MUST be skipped. Otherwise it is
# REQUIRED.
function SystemdEnable() {
    local type=system
    local do_alias=1 do_wanted_by=1 from_file=0

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --no-alias) do_alias=0 ;;
            --no-wanted-by) do_wanted_by=0 ;;
            --from-file) from_file=1 ;;
            --name)
                local name_override=$2
                shift 1
                ;;
            --type)
                type=$2
                shift 1
                ;;
            *)
                break
                ;;
        esac
        shift 1
    done

    if [[ $from_file -eq 0 ]]; then
        [[ $# -ne 2 ]] && FatalError "Expected 2 arguments, got $#."
        local pkg="$1"
        local unit="$2"
    else
        [[ $# -ne 1 ]] && FatalError "Expected 1 argument, got $#."
        local unit="$1"
    fi

    if [[ "$type" != "system" && "$type" != "user" ]]; then
        FatalError "Unkown type ${type}"
    fi

    local filename="${unit##*/}"

    # Find the unit, either from package data or already added to the output
    # directory
    if [[ $from_file -eq 0 ]]; then
        local unit_source="$tmp_dir/systemd_helpers/$pkg/$filename"

        if [[ ! -f "$unit_source" ]]; then
            mkdir -p "$tmp_dir/systemd_helpers/$pkg"
            AconfGetPackageOriginalFile "$pkg" "$unit" > "$unit_source"
        fi
    else
        local unit_source="$output_dir/files/$unit"
    fi

    [[ ! -f "$unit_source" ]] && FatalError "$unit_source not found"

    local target
    local oIFS="$IFS"
    # Process WantedBy lines (if enabled)
    if [[ $do_wanted_by -eq 1 ]]; then
        local name="${name_override:-${filename}}"
        local -a wantedby

        if grep -q WantedBy= "$unit_source"; then
            IFS=$' \n\t'
            wantedby=( $(grep -E '^WantedBy=' "$unit_source" | cut -d= -f2) )
            IFS="$oIFS"
            for target in "${wantedby[@]}"; do
                CreateLink "/etc/systemd/${type}/${target}.wants/${name}" "${unit}"
            done
        fi
    fi

    # Process Alias lines (if enabled)
    if [[ $do_alias -eq 1 ]]; then
        local -a aliases

        if grep -q Alias= "$unit_source"; then
            IFS=$' \n\t'
            aliases=( $(grep -E '^Alias=' "$unit_source" | cut -d= -f2) )
            IFS="$oIFS"
            for target in "${aliases[@]}"; do
                CreateLink "/etc/systemd/${type}/${target}" "${unit}"
            done
        fi
    fi
}

# SystemdMask unit-name [type]
#
# Mask a unit. Defaults to masking system units
function SystemdMask() {
    local unit="$1"
    local type="${2:-system}"

    if [[ "$type" != "system" && "$type" != "user" ]]; then
        FatalError "Unkown type ${type}"
    fi

    CreateLink "/etc/systemd/${type}/${unit}" /dev/null
}

# Create and enable systemd mount unit
#
#
function CreateNtfsMount() {
    local what=$1
    local where=$2
    local name=$(systemd-escape --path --suffix=mount "$where")
    local unit="/etc/systemd/system/$name"
    cat >$(CreateFile "$unit") <<EOF
[Unit]
Description=Mount $what
[Mount]
What=$what
Where=$where
Type=ntfs3
Options=noauto,nofail,nohidden,gid=1000,dmask=002,fmask=113
[Install]
WantedBy=multi-user.target
EOF

    local autoname=$(systemd-escape --path --suffix=automount "$where")
    local autounit="/etc/systemd/system/$autoname"
    cat >$(CreateFile "$autounit") <<EOF
[Unit]
Description= Auto mount $what
[Automount]
Where=$where
[Install]
WantedBy=multi-user.target
EOF

    SystemdEnable --from-file "$autounit"
}