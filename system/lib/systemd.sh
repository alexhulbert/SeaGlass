# SystemdEnable [--name INSTANCE] [--type system|user] PACKAGE UNIT
function SystemdEnable() {
    local IFS=$' \t\n' type=system name pkg unit source target
    while [[ $1 == --* ]]; do
        case $1 in
            --name) name=$2 ;;
            --type) type=$2 ;;
            *) FatalError "Unknown option $1" ;;
        esac
        shift 2
    done
    [[ $# -eq 2 ]] || FatalError "Expected 2 arguments, got $#."
    [[ $type == system || $type == user ]] || FatalError "Unknown type $type"
    pkg=$1 unit=$2
    source="$tmp_dir/systemd_helpers/$pkg/${unit##*/}"
    if [[ ! -s $source ]]; then
        mkdir -p "${source%/*}"
        AconfGetPackageOriginalFile "$pkg" "$unit" > "$source"
        [[ -s $source ]] || FatalError "$unit not found in $pkg"
    fi
    for target in $(sed -n 's/^WantedBy=//p' "$source"); do
        CreateLink "/etc/systemd/$type/$target.wants/${name:-${unit##*/}}" "$unit"
    done
    for target in $(sed -n 's/^Alias=//p' "$source"); do
        CreateLink "/etc/systemd/$type/$target" "$unit"
    done
}
