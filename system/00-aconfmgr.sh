cfg_root=$(realpath "$config_dir/..")
cfg_user=${CFG_USER:-$USER}
if [[ ! $cfg_user =~ ^[a-z_][a-z0-9_-]*$ || ! -f "$cfg_root/users/$cfg_user/system/default.sh" ]]; then
    FatalError "Unknown package profile: $cfg_user"
fi

source "$cfg_root/system/lib/systemd.sh"
source "$cfg_root/system/lib/packages.sh"
source "$cfg_root/users/$cfg_user/system/default.sh"
ApplyPackagePins

unset cfg_root cfg_user
