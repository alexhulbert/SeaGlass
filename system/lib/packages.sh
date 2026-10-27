declare -A package_pins=()

function PinPackage() {
    local package=${1:?Missing package} version=${2:?Missing version}
    [[ $package =~ ^[a-zA-Z0-9@._+-]+$ && $version =~ ^[a-zA-Z0-9._+:~-]+$ ]] || FatalError 'Invalid package pin\n'
    [[ ! ${package_pins[$package]+present} || ${package_pins[$package]} == "$version" ]] || FatalError 'Conflicting versions pinned for %s\n' "$package"
    AddPackage "$package"
    package_pins[$package]=$version
}

function ApplyPackagePins() {
    [[ ${#package_pins[@]} != 0 ]] || return 0
    local package version architecture filename cache source holds
    local -a names=() archives=()
    mapfile -t names < <(printf '%s\n' "${!package_pins[@]}" | LC_ALL=C sort)
    printf -v holds '%s ' "${names[@]}"
    sed -i -E "s/^#?IgnorePkg[[:space:]]*=.*$/IgnorePkg = ${holds% }/" \
        "$(GetPackageOriginalFile --no-clobber pacman /etc/pacman.conf)"
    for package in "${names[@]}"; do
        version=${package_pins[$package]}
        [[ $("$PACMAN" -Q "$package" 2>/dev/null) != "$package $version" ]] || continue
        if [[ $aconfmgr_action != apply ]]; then
            ConfigWarning 'Exact version required for %s: %s\n' "$package" "$version"
            continue
        fi
        architecture=$("$PACMAN" -Spdd --print-format '%a' "$package")
        filename="$package-${version#*:}-$architecture.pkg.tar.zst"
        source="https://archive.archlinux.org/packages/.all/$filename"
        while IFS= read -r cache; do
            if [[ -f $cache/$filename ]]; then
                source="${cache%/}/$filename"
                break
            fi
        done < <(pacman-conf CacheDir)
        archives+=("$source")
    done
    [[ ${#archives[@]} == 0 ]] || RunExternal sudo "$PACMAN" -U "${archives[@]}"
}

function PatchPackage() (
    local package=$1 release version work
    shift
    if version=$("$PACMAN" -Spdd --print-format '%v' "$package" 2>/dev/null); then
        AddPackage "$package"
    else
        AddPackage --foreign "$package"
        version=$(LC_ALL=C paru -Si --aur "$package" | sed -n 's/^Version *: //p')
    fi
    AddPackage devtools
    AddPackage --foreign customizepkg-git
    release=$((16#$(cat -- "${@:?Missing patch}" | sha256sum | cut -c1-15)))
    if [[ $package == *-git ]]; then
        [[ $("$PACMAN" -Q "$package" 2>/dev/null) != *".$release" ]] || return 0
    else
        [[ $("$PACMAN" -Q "$package" 2>/dev/null) != "$package $version.$release" ]] || return 0
    fi
    [[ $aconfmgr_action == apply ]] || { ConfigWarning 'Source build required for patched %s\n' "$package"; return 0; }
    AconfNeedProgram pkgctl devtools n
    AconfNeedProgram customizepkg customizepkg-git y
    work=$(mktemp -d)
    trap 'rm -rf -- "$work"' EXIT
    mkdir -p "$work/rules/$package.files"
    cat -- "$@" > "$work/rules/$package.files/aconfmgr.patch"
    printf 'patch#1#aconfmgr.patch\naddline#global#^pkgrel=#pkgrel+=.%s\n' "$release" > "$work/rules/$package"
    cd "$work"
    paru -G "$package"
    cd "$(dirname "$(find "$work" -mindepth 2 -maxdepth 2 -name PKGBUILD -print -quit)")"
    [[ $(source PKGBUILD; printf '%s%s-%s' "${epoch:+$epoch:}" "$pkgver" "$pkgrel") == "$version" ]] || { ConfigWarning 'Repository metadata and source recipe disagree for %s\n' "$package"; return 1; }
    CUSTOMIZEPKG_CONFIG="$work/rules" customizepkg -m
    grep -Fq 'patch -Np1 -i ${srcdir}/aconfmgr.patch' PKGBUILD
    RunExternal paru -Bi --mflags "${makepkg_opts[*]:1}" .
)

function LocalPackage() (
    local source=$1 ref=${2:-} dir name version
    if [[ $source == *://* ]]; then
        dir="$HOME/.cache/makepkg/sources/${source##*/}"
        [[ -d $dir ]] || git clone -q "$source" "$dir"
        git -C "$dir" fetch -q origin "$ref"
        git -C "$dir" checkout -q "$ref"
    else
        dir=$source
    fi
    IFS=" " read -r name version < <(cd "$dir" && makepkg --printsrcinfo |
        awk '/^pkgbase =/{n=$3} /^\tpkgver =/{v=$3} /^\tpkgrel =/{r=$3} END{print n, v"-"r}')
    AddPackage --foreign "$name"
    [[ $("$PACMAN" -Q "$name" 2>/dev/null) != "$name $version" ]] || return 0
    [[ $aconfmgr_action == apply ]] || { ConfigWarning 'Build required for %s\n' "$name"; return 0; }
    RunExternal makepkg -si -D "$dir"
)
