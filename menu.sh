#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'
C_DIM=$'\033[2m'
C_UL=$'\033[4m'

# Premium Color Palette
C_RED=$'\033[38;5;196m'      # Bright Red
C_GREEN=$'\033[38;5;46m'     # Neon Green
C_YELLOW=$'\033[38;5;226m'   # Bright Yellow
C_BLUE=$'\033[38;5;39m'      # Deep Sky Blue
C_PURPLE=$'\033[38;5;135m'   # Light Purple
C_CYAN=$'\033[38;5;51m'      # Cyan
C_WHITE=$'\033[38;5;255m'    # Bright White
C_GRAY=$'\033[38;5;245m'     # Gray
C_ORANGE=$'\033[38;5;208m'   # Orange

# Semantic Aliases
C_TITLE=$C_PURPLE
C_CHOICE=$C_CYAN
C_PROMPT=$C_BLUE
C_WARN=$C_YELLOW
C_DANGER=$C_RED
C_STATUS_A=$C_GREEN
C_STATUS_I=$C_GRAY
C_ACCENT=$C_ORANGE

DB_DIR="/etc/skylartech"
DB_FILE="$DB_DIR/users.db"
INSTALL_FLAG_FILE="$DB_DIR/.install"
BADVPN_SERVICE_FILE="/etc/systemd/system/badvpn.service"
BADVPN_BUILD_DIR="/root/badvpn-build"
HAPROXY_CONFIG="/etc/haproxy/haproxy.cfg"
NGINX_CONFIG_FILE="/etc/nginx/sites-available/default"
SSL_CERT_DIR="/etc/skylartech/ssl"
SSL_CERT_FILE="$SSL_CERT_DIR/skylartech.pem"
SSL_CERT_CHAIN_FILE="$SSL_CERT_DIR/skylartech.crt"
SSL_CERT_KEY_FILE="$SSL_CERT_DIR/skylartech.key"
EDGE_CERT_INFO_FILE="$DB_DIR/edge_cert.conf"
NGINX_PORTS_FILE="$DB_DIR/nginx_ports.conf"
EDGE_PUBLIC_HTTP_PORT="80"
EDGE_PUBLIC_TLS_PORT="443"
NGINX_INTERNAL_HTTP_PORT="8880"
NGINX_INTERNAL_TLS_PORT="8443"
HAPROXY_INTERNAL_DECRYPT_PORT="10443"
DNSTT_SERVICE_FILE="/etc/systemd/system/dnstt.service"
DNSTT_BINARY="/usr/local/bin/dnstt-server"
DNSTT_KEYS_DIR="/etc/skylartech/dnstt"
DNSTT_CONFIG_FILE="$DB_DIR/dnstt_info.conf"
UDP_CUSTOM_DIR="/root/udp"
UDP_CUSTOM_SERVICE_FILE="/etc/systemd/system/udp-custom.service"
UDPGW_BINARY="/usr/local/bin/udpgw"
UDPGW_SERVICE_FILE="/etc/systemd/system/udpgw.service"
SSH_BANNER_FILE="/etc/bannerssh"
FALCONPROXY_SERVICE_FILE="/etc/systemd/system/falconproxy.service"
FALCONPROXY_BINARY="/usr/local/bin/falconproxy"
FALCONPROXY_CONFIG_FILE="$DB_DIR/falconproxy_config.conf"
LIMITER_SCRIPT="/usr/local/bin/skylartech-limiter.sh"
LIMITER_SERVICE="/etc/systemd/system/skylartech-limiter.service"
BANDWIDTH_DIR="$DB_DIR/bandwidth"
BACKUP_DIR="/root/skylartech_backups"
TRIAL_EXPIRY_DIR="$DB_DIR/trials"
BANDWIDTH_SCRIPT="/usr/local/bin/skylartech-bandwidth.sh"
BANDWIDTH_SERVICE="/etc/systemd/system/skylartech-bandwidth.service"
LEGACY_BANDWIDTH_DIR="/usr/local/bin/skylartech-bandwidth"
TRIAL_CLEANUP_SCRIPT="/usr/local/bin/skylartech-trial-cleanup.sh"
LOGIN_INFO_SCRIPT="/usr/local/bin/skylartech-login-info.sh"
SSHD_FF_CONFIG="/etc/ssh/sshd_config.d/skylartech.conf"

# --- ZiVPN Variables ---
ZIVPN_DIR="/etc/zivpn"
ZIVPN_BIN="/usr/local/bin/zivpn"
ZIVPN_SERVICE_FILE="/etc/systemd/system/zivpn.service"
ZIVPN_CONFIG_FILE="$ZIVPN_DIR/config.json"
ZIVPN_CERT_FILE="$ZIVPN_DIR/zivpn.crt"
ZIVPN_KEY_FILE="$ZIVPN_DIR/zivpn.key"
ZIVPN_LISTEN_PORT="5667"
UDP_CUSTOM_LISTEN_PORT="36712"
BADVPN_LISTEN_PORT="7300"
# Tracks users whose password we pulled from the ZiVPN auth list while locked,
# so unlock can restore exactly what was removed (one file per user, holds pass).
ZIVPN_LOCK_DIR="$DB_DIR/zivpn_locked"

# --- HWID Lock Variables ---
# hwid_allowed.db is the runtime mirror the enforcer daemon reads, so it never
# has to parse the password-bearing main users.db while tailing journals.
HWID_ALLOWED_DB="$DB_DIR/hwid_allowed.db"            # username|password|hwid|strict
HWID_ENFORCER_SCRIPT="/usr/local/bin/skylartech-hwid-enforcer.sh"
HWID_ENFORCER_SERVICE="/etc/systemd/system/skylartech-hwid-enforcer.service"
HWID_STATE_FILE="$DB_DIR/hwid_enforce.state"         # "on" / "off" global flag
HWID_KICK_LOG="/var/log/skylartech_hwid.log"

DESEC_TOKEN="V55cFY8zTictLCPfviiuX5DHjs15"
DESEC_DOMAIN="manager.skylartech.qzz.io"

DOMAIN_OVERRIDE_FILE="$DB_DIR/domain_override"

# --- Repository / binary source -------------------------------------------
# Where release assets (Falcon Proxy) and raw files (udp-custom) are pulled
# from. Defaults preserve the original Codeberg source, so behaviour is
# unchanged. If you host a fork, override these via the environment, e.g.:
#   FF_REPO_HOST=github FF_REPO_OWNER=youruser FF_REPO_NAME=YourRepo menu
# (Codeberg uses the Gitea API; GitHub uses the GitHub API. Both expose
#  .tag_name, so version selection works on either host.)
FF_REPO_HOST="${FF_REPO_HOST:-github}"
FF_REPO_OWNER="${FF_REPO_OWNER:-SONICE-ENCHIL}"
FF_REPO_NAME="${FF_REPO_NAME:-skylartech-SSH}"
FF_REPO_BRANCH="${FF_REPO_BRANCH:-main}"

if [[ "$FF_REPO_HOST" == "github" ]]; then
    FF_RAW_BASE="https://raw.githubusercontent.com/$FF_REPO_OWNER/$FF_REPO_NAME/$FF_REPO_BRANCH"
    FF_RELEASES_API="https://api.github.com/repos/$FF_REPO_OWNER/$FF_REPO_NAME/releases"
    FF_RELEASE_DL_BASE="https://github.com/$FF_REPO_OWNER/$FF_REPO_NAME/releases/download"
else
    FF_RAW_BASE="https://codeberg.org/$FF_REPO_OWNER/$FF_REPO_NAME/raw/branch/$FF_REPO_BRANCH"
    FF_RELEASES_API="https://codeberg.org/api/v1/repos/$FF_REPO_OWNER/$FF_REPO_NAME/releases"
    FF_RELEASE_DL_BASE="https://codeberg.org/$FF_REPO_OWNER/$FF_REPO_NAME/releases/download"
fi

SELECTED_USER=""
UNINSTALL_MODE="interactive"
BANNER_CACHE_TTL=15
BANNER_CACHE_TS=0
BANNER_CACHE_OS_NAME=""
BANNER_CACHE_UP_TIME=""
BANNER_CACHE_RAM_USAGE=""
BANNER_CACHE_CPU_LOAD=""
BANNER_CACHE_ONLINE_USERS=0
BANNER_CACHE_TOTAL_USERS=0
SSH_SESSION_CACHE_TTL=10
SSH_SESSION_CACHE_TS=0
SSH_SESSION_CACHE_DB_MTIME=0
SSH_SESSION_TOTAL=0
APT_CACHE_READY=0
FF_USERS_GROUP="ffusers"
declare -A SSH_SESSION_COUNTS=()
declare -A SSH_SESSION_PIDS=()

# --- Package Manager Abstraction ---
FF_PKG_MGR=""
_detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        FF_PKG_MGR="apt"
    elif command -v dnf &>/dev/null; then
        FF_PKG_MGR="dnf"
    elif command -v yum &>/dev/null; then
        FF_PKG_MGR="yum"
    elif command -v zypper &>/dev/null; then
        FF_PKG_MGR="zypper"
    elif command -v pacman &>/dev/null; then
        FF_PKG_MGR="pacman"
    else
        echo -e "${C_RED}❌ No supported package manager found (apt/dnf/yum/zypper/pacman).${C_RESET}"
        exit 1
    fi
}
_detect_pkg_manager

_map_pkg_names() {
    local -a result=()
    local pkg
    for pkg in "$@"; do
        case "$FF_PKG_MGR" in
            dnf|yum)
                case "$pkg" in
                    build-essential) result+=(gcc gcc-c++ make) ;;
                    libssl-dev) result+=(openssl-devel) ;;
                    libnspr4-dev) result+=(nspr-devel) ;;
                    libnss3-dev) result+=(nss-devel) ;;
                    nginx-common) result+=(nginx) ;;
                    pkg-config) result+=(pkgconf) ;;
                    *) result+=("$pkg") ;;
                esac ;;
            zypper)
                case "$pkg" in
                    build-essential) result+=(gcc gcc-c++ make) ;;
                    libssl-dev) result+=(libopenssl-devel) ;;
                    libnspr4-dev) result+=(mozilla-nspr-devel) ;;
                    libnss3-dev) result+=(mozilla-nss-devel) ;;
                    nginx-common) result+=(nginx) ;;
                    *) result+=("$pkg") ;;
                esac ;;
            pacman)
                case "$pkg" in
                    build-essential) result+=(base-devel) ;;
                    libssl-dev) result+=(openssl) ;;
                    libnspr4-dev) result+=(nspr) ;;
                    libnss3-dev) result+=(nss) ;;
                    nginx-common) result+=(nginx) ;;
                    bc) result+=(bc) ;;
                    *) result+=("$pkg") ;;
                esac ;;
            *) result+=("$pkg") ;;
        esac
    done
    printf '%s\n' "${result[@]}"
}

if [[ $EUID -ne 0 ]]; then
   echo -e "${C_RED}❌ Error: This script requires root privileges to run.${C_RESET}"
   exit 1
fi

get_ubuntu_codename() {
    local codename=""

    if [[ -r /etc/os-release ]]; then
        codename=$(awk -F= '/^(VERSION_CODENAME|UBUNTU_CODENAME)=/{gsub(/"/, "", $2); if ($2 != "") { print $2; exit }}' /etc/os-release 2>/dev/null)
    fi

    if [[ -z "$codename" ]] && command -v lsb_release &>/dev/null; then
        codename=$(lsb_release -sc 2>/dev/null)
    fi

    echo "$codename"
}

is_known_eol_ubuntu_codename() {
    case "$1" in
        yakkety|zesty|artful|cosmic|disco|eoan|groovy|hirsute|impish|kinetic|lunar|mantic|oracular|plucky)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

rewrite_ubuntu_apt_sources() {
    local mode="$1"
    local os_id=""
    local changed=false
    local file backup_file
    local from_archive to_archive from_security to_security from_ports to_ports
    local -a source_files=("/etc/apt/sources.list" /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources)

    if [[ -r /etc/os-release ]]; then
        os_id=$(awk -F= '/^ID=/{gsub(/"/, "", $2); print $2; exit}' /etc/os-release 2>/dev/null)
    fi
    [[ "$os_id" == "ubuntu" ]] || return 1

    case "$mode" in
        primary)
            from_archive='https?://([A-Za-z0-9-]+\.)?archive\.ubuntu\.com/ubuntu'
            to_archive='http://archive.ubuntu.com/ubuntu'
            from_security='https?://security\.ubuntu\.com/ubuntu'
            to_security='http://security.ubuntu.com/ubuntu'
            from_ports='https?://ports\.ubuntu\.com/ubuntu-ports'
            to_ports='http://ports.ubuntu.com/ubuntu-ports'
            ;;
        old-releases)
            from_archive='https?://([A-Za-z0-9-]+\.)?archive\.ubuntu\.com/ubuntu'
            to_archive='http://old-releases.ubuntu.com/ubuntu'
            from_security='https?://security\.ubuntu\.com/ubuntu'
            to_security='http://old-releases.ubuntu.com/ubuntu'
            from_ports='https?://ports\.ubuntu\.com/ubuntu-ports'
            to_ports='http://old-releases.ubuntu.com/ubuntu'
            ;;
        *)
            return 1
            ;;
    esac

    for file in "${source_files[@]}"; do
        [[ -f "$file" ]] || continue
        if grep -Eq "$from_archive|$from_security|$from_ports" "$file" 2>/dev/null; then
            backup_file="${file}.bak.skylartech"
            [[ -f "$backup_file" ]] || cp "$file" "$backup_file" 2>/dev/null || true
            sed -i -E \
                -e "s|$from_archive|$to_archive|g" \
                -e "s|$from_security|$to_security|g" \
                -e "s|$from_ports|$to_ports|g" \
                "$file" 2>/dev/null
            changed=true
        fi
    done

    [[ "$changed" == true ]]
}

repair_ubuntu_apt_mirrors() {
    rewrite_ubuntu_apt_sources "primary"
}

switch_ubuntu_to_old_releases() {
    local codename
    codename=$(get_ubuntu_codename)
    [[ -n "$codename" ]] || return 1
    is_known_eol_ubuntu_codename "$codename" || return 1
    rewrite_ubuntu_apt_sources "old-releases"
}

ff_apt_update() {
    local -a apt_opts=(
        -o Acquire::Retries=3
        -o Acquire::ForceIPv4=true
        -o Acquire::http::Timeout=20
        -o Acquire::https::Timeout=20
        -o Acquire::http::Pipeline-Depth=0
    )

    if (( APT_CACHE_READY == 1 )); then
        return 0
    fi

    if DEBIAN_FRONTEND=noninteractive apt-get "${apt_opts[@]}" update; then
        APT_CACHE_READY=1
        return 0
    fi

    if repair_ubuntu_apt_mirrors; then
        echo -e "${C_YELLOW}⚠️ APT mirror timed out. Switching Ubuntu sources to archive.ubuntu.com and retrying...${C_RESET}"
        apt-get clean >/dev/null 2>&1 || true
        if DEBIAN_FRONTEND=noninteractive apt-get "${apt_opts[@]}" update; then
            APT_CACHE_READY=1
            return 0
        fi
    fi

    if switch_ubuntu_to_old_releases; then
        echo -e "${C_YELLOW}⚠️ Detected an end-of-life Ubuntu release. Switching APT sources to old-releases.ubuntu.com and retrying...${C_RESET}"
        apt-get clean >/dev/null 2>&1 || true
        if DEBIAN_FRONTEND=noninteractive apt-get "${apt_opts[@]}" update; then
            APT_CACHE_READY=1
            return 0
        fi
    fi

    echo -e "${C_RED}❌ Failed to refresh package lists. Please check VPS network, DNS, or blocked Ubuntu mirrors.${C_RESET}"
    return 1
}

ff_apt_install() {
    local -a packages=("$@")
    (( ${#packages[@]} > 0 )) || return 0

    ff_apt_update || return 1
    DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Use-Pty=0 install "${packages[@]}"
}

ff_apt_purge() {
    local -a packages=("$@")
    (( ${#packages[@]} > 0 )) || return 0
    DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Use-Pty=0 purge "${packages[@]}"
}

ff_pkg_install() {
    local -a packages=("$@")
    (( ${#packages[@]} > 0 )) || return 0
    local -a mapped=()
    mapfile -t mapped < <(_map_pkg_names "${packages[@]}")
    case "$FF_PKG_MGR" in
        apt) ff_apt_install "${mapped[@]}" ;;
        dnf) dnf install -y -q "${mapped[@]}" ;;
        yum) yum install -y -q "${mapped[@]}" ;;
        zypper) zypper install -y -q "${mapped[@]}" ;;
        pacman) pacman -S --noconfirm --needed "${mapped[@]}" ;;
        *) echo -e "${C_RED}❌ Unsupported package manager.${C_RESET}"; return 1 ;;
    esac
}

ff_pkg_purge() {
    local -a packages=("$@")
    (( ${#packages[@]} > 0 )) || return 0
    local -a mapped=()
    mapfile -t mapped < <(_map_pkg_names "${packages[@]}")
    case "$FF_PKG_MGR" in
        apt) ff_apt_purge "${mapped[@]}" ;;
        dnf) dnf remove -y -q "${mapped[@]}" ;;
        yum) yum remove -y -q "${mapped[@]}" ;;
        zypper) zypper remove -y "${mapped[@]}" ;;
        pacman) pacman -Rns --noconfirm "${mapped[@]}" 2>/dev/null ;;
        *) echo -e "${C_RED}❌ Unsupported package manager.${C_RESET}"; return 1 ;;
    esac
}

ff_pkg_autoremove() {
    case "$FF_PKG_MGR" in
        apt) apt-get autoremove -y >/dev/null 2>&1 ;;
        dnf) dnf autoremove -y -q >/dev/null 2>&1 ;;
        yum) yum autoremove -y -q >/dev/null 2>&1 ;;
        zypper) zypper packages --unneeded 2>/dev/null | awk -F'|' 'NR>3{print $3}' | xargs -r zypper remove -y >/dev/null 2>&1 ;;
        pacman) pacman -Qdtq 2>/dev/null | xargs -r pacman -Rns --noconfirm >/dev/null 2>&1 ;;
    esac
    return 0
}

ff_pkg_is_installed() {
    local pkg="$1"
    case "$FF_PKG_MGR" in
        apt) dpkg -s "$pkg" &>/dev/null ;;
        dnf|yum) rpm -q "$pkg" &>/dev/null ;;
        zypper) rpm -q "$pkg" &>/dev/null ;;
        pacman) pacman -Q "$pkg" &>/dev/null ;;
    esac
}

# Download a binary and verify it actually is an executable, not an HTML/JSON
# error page (e.g. a 404 from a fork that is missing the release asset). This
# prevents installing a broken "binary" and chmod +x-ing an error page.
# Usage: ff_fetch_binary <dest> <url>
ff_fetch_binary() {
    local dest="$1" url="$2"
    rm -f "$dest" 2>/dev/null
    if ! wget -q --show-progress -O "$dest" "$url"; then
        rm -f "$dest" 2>/dev/null
        return 1
    fi
    # Must be non-empty and a real binary (ELF) or at least not an HTML/JSON page.
    if [[ ! -s "$dest" ]]; then
        rm -f "$dest" 2>/dev/null
        return 1
    fi
    if command -v file &>/dev/null; then
        if ! file -b "$dest" | grep -qiE 'ELF|executable'; then
            rm -f "$dest" 2>/dev/null
            return 1
        fi
    else
        # Fallback: reject obvious HTML/JSON error bodies by their first bytes.
        local head_bytes
        head_bytes=$(head -c 16 "$dest" 2>/dev/null)
        case "$head_bytes" in
            "<"*|"{"*|"["*)
                rm -f "$dest" 2>/dev/null
                return 1 ;;
        esac
    fi
    return 0
}

# Mandatory Dependency Check (Added jq and curl)
check_environment() {
    local missing_packages=()
    local cmd

    for cmd in bc jq curl wget; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_packages+=("$cmd")
        fi
    done

    if (( ${#missing_packages[@]} > 0 )); then
        echo -e "${C_YELLOW}⚠️ Installing missing dependencies: ${missing_packages[*]}${C_RESET}"
        ff_pkg_install "${missing_packages[@]}" >/dev/null 2>&1 || {
            echo -e "${C_RED}❌ Error: Failed to install required dependencies: ${missing_packages[*]}.${C_RESET}"
            exit 1
        }
    fi
}

migrate_from_firewallfalcon() {
    [[ -d /etc/firewallfalcon ]] || return 0
    echo -e "${C_YELLOW}⚠️ Detected old FirewallFalcon installation. Migrating to Skylartech...${C_RESET}"

    # Stop old services
    for svc in firewallfalcon-limiter firewallfalcon-bandwidth firewallfalcon-hwid-enforcer; do
        systemctl stop "$svc" 2>/dev/null || true
        systemctl disable "$svc" 2>/dev/null || true
    done

    # Move data directory
    [[ -d /etc/firewallfalcon ]] && mv /etc/firewallfalcon /etc/skylartech

    # Move backup directory
    [[ -d /root/firewallfalcon_backups ]] && mv /root/firewallfalcon_backups /root/skylartech_backups

    # Rename scripts
    for old in /usr/local/bin/firewallfalcon-*.sh; do
        [[ -f "$old" ]] || continue
        local new="${old//firewallfalcon-/skylartech-}"
        mv "$old" "$new"
    done

    # Rename systemd service files
    for old in /etc/systemd/system/firewallfalcon-*.service; do
        [[ -f "$old" ]] || continue
        local new="${old//firewallfalcon-/skylartech-}"
        mv "$old" "$new"
        # Update service file internals referencing old paths
        sed -i 's|/etc/firewallfalcon|/etc/skylartech|g; s|firewallfalcon-|skylartech-|g; s|FirewallFalcon|Skylartech|g' "$new"
    done

    # Rename log files
    for old in /var/log/firewallfalcon_*.log; do
        [[ -f "$old" ]] || continue
        local new="${old//firewallfalcon_/skylartech_}"
        mv "$old" "$new"
    done

    # Rename sshd config drop-in
    [[ -f /etc/ssh/sshd_config.d/firewallfalcon.conf ]] && mv /etc/ssh/sshd_config.d/firewallfalcon.conf /etc/ssh/sshd_config.d/skylartech.conf

    # Rename backup marker files
    local bak_files
    while IFS= read -r -d '' bak_files; do
        local dir="${bak_files%/*}"
        local base="${bak_files##*/}"
        local new_base="${base//firewallfalcon/skylartech}"
        [[ "$base" != "$new_base" ]] && mv "$bak_files" "$dir/$new_base"
    done < <(find /etc /root /usr/local -name '*.bak.firewallfalcon' -print0 2>/dev/null)
    # Reload systemd and re-enable services
    systemctl daemon-reload 2>/dev/null || true
    for svc in skylartech-limiter skylartech-bandwidth skylartech-hwid-enforcer; do
        if [[ -f "/etc/systemd/system/${svc}.service" ]]; then
            systemctl enable "$svc" 2>/dev/null || true
            systemctl start "$svc" 2>/dev/null || true
        fi
    done

    # Migrate iptables rules file if it exists
    [[ -f /etc/iptables/rules.v4 ]] && sed -i 's|/etc/firewallfalcon|/etc/skylartech|g' /etc/iptables/rules.v4 2>/dev/null || true

    # Update any stale banner references in sshd_config
    sed -i 's|/etc/firewallfalcon|/etc/skylartech|g' /etc/ssh/sshd_config 2>/dev/null || true

    # Remove old empty directory if it still exists
    rmdir /etc/firewallfalcon 2>/dev/null || true

    echo -e "${C_GREEN}✅ Migration complete.${C_RESET}"
}

ensure_skylartech_dirs() {
    mkdir -p "$DB_DIR" "$SSL_CERT_DIR" "$BANDWIDTH_DIR" "$TRIAL_EXPIRY_DIR" /etc/ssh/sshd_config.d
    touch "$DB_FILE"
}

ensure_skylartech_system_group() {
    getent group "$FF_USERS_GROUP" >/dev/null 2>&1 || groupadd "$FF_USERS_GROUP" >/dev/null 2>&1 || true
}

db_has_user() {
    [[ -f "$DB_FILE" ]] || return 1
    awk -F: -v target="$1" '$1 == target { found=1; exit } END { exit(found ? 0 : 1) }' "$DB_FILE"
}

# Safely rewrite a user's record, preserving all fields.
# Usage: db_set_user <user> <pass> <expiry> <limit> <bandwidth> <marker> [hwid] [strict]
# Uses awk+ENVIRON (not sed) so values containing / & \ or other
# metacharacters cannot corrupt the database line.
# Fields 7 (hwid) and 8 (strict) are optional; when omitted they default to
# empty / 0, and a legacy 6-field row is transparently upgraded to 8 fields.
db_set_user() {
    [[ -f "$DB_FILE" ]] || return 1
    local tmp
    tmp=$(mktemp) || return 1
    _FF_DB_USER="$1" _FF_DB_PASS="$2" _FF_DB_EXPIRY="$3" \
    _FF_DB_LIMIT="$4" _FF_DB_BW="$5" _FF_DB_MARKER="$6" \
    _FF_DB_HWID="${7:-}" _FF_DB_STRICT="${8:-0}" _FF_DB_APP="${9:-http}" \
    awk -F: 'BEGIN { OFS=":" }
        $1 == ENVIRON["_FF_DB_USER"] {
            print ENVIRON["_FF_DB_USER"], ENVIRON["_FF_DB_PASS"], ENVIRON["_FF_DB_EXPIRY"], \
                  ENVIRON["_FF_DB_LIMIT"], ENVIRON["_FF_DB_BW"], ENVIRON["_FF_DB_MARKER"], \
                  ENVIRON["_FF_DB_HWID"], ENVIRON["_FF_DB_STRICT"], ENVIRON["_FF_DB_APP"]
            next
        }
        { print }
    ' "$DB_FILE" > "$tmp" && mv "$tmp" "$DB_FILE"
    local rc=$?
    rm -f "$tmp" 2>/dev/null
    return $rc
}

# Read a single colon field (1-based) for a user from users.db. Blank if absent.
# Usage: db_get_field <user> <field_number>
db_get_field() {
    [[ -f "$DB_FILE" ]] || { echo ""; return 1; }
    awk -F: -v u="$1" -v n="$2" '$1 == u { print $n; exit }' "$DB_FILE"
}

# Regenerate the enforcer's runtime mirror from users.db, keeping only rows that
# actually carry an HWID. Called after every create / edit / renew / delete so the
# daemon always sees current state.
# Format: username|hwid|strict|password  — password is placed LAST so a literal '|'
# inside a password can't shift the hwid/strict columns the daemon relies on.
hwid_sync_allowed_db() {
    [[ -n "$DB_DIR" ]] || return 1
    mkdir -p "$DB_DIR" 2>/dev/null
    local tmp
    tmp=$(mktemp) || return 1
    if [[ -f "$DB_FILE" ]]; then
        awk -F: 'BEGIN { OFS="|" }
            { user=$1; pass=$2; hwid=$7; strict=$8 }
            user != "" && user !~ /^#/ {
                # Field 7 may list several devices; entries marked "!" are disabled.
                # The runtime mirror carries only the ENABLED ids (markers stripped),
                # so disabled devices are absent from the allow-list the enforcer reads.
                n = split(hwid, parts, ",")
                enabled = ""
                for (i = 1; i <= n; i++) {
                    t = parts[i]
                    gsub(/^[ \t]+|[ \t]+$/, "", t)
                    if (t == "" || substr(t, 1, 1) == "!") continue
                    enabled = (enabled == "") ? t : enabled "," t
                }
                if (enabled != "") {
                    if (strict == "") strict = "0"
                    print user, enabled, strict, pass
                }
            }
        ' "$DB_FILE" > "$tmp"
    fi
    mv "$tmp" "$HWID_ALLOWED_DB" 2>/dev/null || { rm -f "$tmp"; return 1; }
    chmod 600 "$HWID_ALLOWED_DB" 2>/dev/null
    return 0
}

# --- Per-device HWID parsing -------------------------------------------------
# Field 7 holds a comma-separated device list where each entry is either an
# enabled HWID ("hwidA") or a disabled one marked with a leading '!' ("!hwidA").
# A leading '!' is used (not a ':state' suffix) because device IDs can themselves
# contain ':' (MAC-style ids); a real HWID never starts with '!'. A bare entry
# (no marker) is treated as enabled, so legacy single/multi-HWID rows parse as-is.

# Parse a field-7 string into the globals FF_HWID_IDS[] and FF_HWID_STATES[]
# (parallel arrays; state is "on" or "off"). Whitespace trimmed, marker stripped.
_ff_hwid_parse() {
    FF_HWID_IDS=(); FF_HWID_STATES=()
    local raw="$1" part id state
    local IFS=','
    for part in $raw; do
        part="${part#"${part%%[![:space:]]*}"}"
        part="${part%"${part##*[![:space:]]}"}"
        [[ -z "$part" ]] && continue
        if [[ "${part:0:1}" == "!" ]]; then state="off"; id="${part:1}"; else state="on"; id="$part"; fi
        [[ -z "$id" ]] && continue
        FF_HWID_IDS+=("$id"); FF_HWID_STATES+=("$state")
    done
}

# Rebuild a field-7 string from FF_HWID_IDS[]/FF_HWID_STATES[] (re-emitting the
# '!' marker for disabled devices). Echoes the joined list.
_ff_hwid_join() {
    local out="" i
    for i in "${!FF_HWID_IDS[@]}"; do
        [[ -n "$out" ]] && out+=","
        [[ "${FF_HWID_STATES[$i]}" == "off" ]] && out+="!"
        out+="${FF_HWID_IDS[$i]}"
    done
    printf '%s' "$out"
}

# Normalize a raw comma-separated HWID string: split on ',', trim whitespace, drop
# empties, de-duplicate by device id (last occurrence wins, so re-adding a disabled
# device re-enables it), preserving order and each entry's enabled/disabled marker.
_ff_normalize_hwids() {
    local raw="$1" part id state i
    local -a ids=() states=()
    local IFS=','
    for part in $raw; do
        part="${part#"${part%%[![:space:]]*}"}"
        part="${part%"${part##*[![:space:]]}"}"
        [[ -z "$part" ]] && continue
        if [[ "${part:0:1}" == "!" ]]; then state="off"; id="${part:1}"; else state="on"; id="$part"; fi
        [[ -z "$id" ]] && continue
        # Last-wins: if this id was seen, update its state and keep its position.
        local found=""
        for i in "${!ids[@]}"; do
            if [[ "${ids[$i]}" == "$id" ]]; then states[$i]="$state"; found=1; break; fi
        done
        [[ -n "$found" ]] && continue
        ids+=("$id"); states+=("$state")
    done
    local out=""
    for i in "${!ids[@]}"; do
        [[ -n "$out" ]] && out+=","
        [[ "${states[$i]}" == "off" ]] && out+="!"
        out+="${ids[$i]}"
    done
    printf '%s' "$out"
}

# Human-readable HWID label for summaries/headers. Disabled devices render as
# "id (off)"; the trailer shows device + enabled counts when there's more than one
# device or any disabled one, else the compact "id (word: ON/OFF)".
# Arg1 = field-7 list, Arg2 = strict flag ("1"/"0"), Arg3 = word ("strict"/"enforce").
_ff_hwid_label() {
    local list="$1" strict="$2" word="${3:-strict}" st_msg disp="" i total enabled=0
    [[ -z "$list" ]] && { printf 'none'; return; }
    _ff_hwid_parse "$list"
    total=${#FF_HWID_IDS[@]}
    [[ "$total" -eq 0 ]] && { printf 'none'; return; }
    for i in "${!FF_HWID_IDS[@]}"; do
        [[ -n "$disp" ]] && disp+=", "
        if [[ "${FF_HWID_STATES[$i]}" == "off" ]]; then
            disp+="${FF_HWID_IDS[$i]} (off)"
        else
            disp+="${FF_HWID_IDS[$i]}"; enabled=$((enabled+1))
        fi
    done
    st_msg="off"; [[ "$strict" == "1" ]] && st_msg="ON"
    if (( total > 1 || enabled < total )); then
        printf '%s (%d devices, %d enabled, %s: %s)' "$disp" "$total" "$enabled" "$word" "$st_msg"
    else
        printf '%s (%s: %s)' "$disp" "$word" "$st_msg"
    fi
}

is_skylartech_orphan_user() {
    local username="$1"
    local passwd_line system_user _ uid _ home shell

    passwd_line=$(getent passwd "$username" 2>/dev/null) || return 1
    IFS=: read -r system_user _ uid _ _ home shell <<< "$passwd_line"
    [[ "$uid" =~ ^[0-9]+$ ]] || return 1
    db_has_user "$username" && return 1

    if id -nG "$username" 2>/dev/null | tr ' ' '\n' | grep -Fxq "$FF_USERS_GROUP"; then
        return 0
    fi

    (( uid >= 1000 )) || return 1
    [[ "$home" == "/home/$username" || "$home" == /home/* ]] || return 1

    case "$shell" in
        /usr/sbin/nologin|/usr/bin/false|/bin/false) return 0 ;;
    esac

    return 1
}

get_skylartech_orphan_users() {
    local username
    while IFS=: read -r username _rest; do
        [[ -n "$username" ]] || continue
        if is_skylartech_orphan_user "$username"; then
            echo "$username"
        fi
    done < /etc/passwd
}

get_skylartech_known_users() {
    local username
    local -A seen_users=()

    if [[ -f "$DB_FILE" ]]; then
        while IFS=: read -r username _rest; do
            [[ -n "$username" && "$username" != \#* ]] || continue
            seen_users["$username"]=1
        done < "$DB_FILE"
    fi

    while IFS= read -r username; do
        [[ -n "$username" ]] && seen_users["$username"]=1
    done < <(get_skylartech_orphan_users)

    (( ${#seen_users[@]} > 0 )) || return 0
    printf "%s\n" "${!seen_users[@]}" | sort
}

delete_skylartech_user_accounts() {
    local -a users_to_delete=("$@")
    local username

    [[ ${#users_to_delete[@]} -gt 0 ]] || return 0

    for username in "${users_to_delete[@]}"; do
        [[ -n "$username" ]] || continue
        # Clear any per-user traffic block before the UID is freed/recycled.
        _ff_unblock_user_traffic "$username"
        killall -u "$username" -9 &>/dev/null
        if id "$username" &>/dev/null; then
            if userdel -r "$username" &>/dev/null; then
                echo -e " ✅ System user '${C_YELLOW}$username${C_RESET}' deleted."
            else
                echo -e " ❌ Failed to delete system user '${C_YELLOW}$username${C_RESET}'."
            fi
        else
            echo -e " ℹ️ System user '${C_YELLOW}$username${C_RESET}' was already missing. Removing manager data only."
        fi
        rm -f "$BANDWIDTH_DIR/${username}.usage"
        rm -rf "$BANDWIDTH_DIR/pidtrack/${username}"
        rm -f "$TRIAL_EXPIRY_DIR/${username}.ts"
        rm -f "$ZIVPN_LOCK_DIR/${username}"
    done

    if [[ -f "$DB_FILE" ]]; then
        local db_tmp
        db_tmp=$(mktemp)
        awk -F: 'NR==FNR { drop[$1]=1; next } !($1 in drop)' <(printf "%s\n" "${users_to_delete[@]}") "$DB_FILE" > "$db_tmp" && mv "$db_tmp" "$DB_FILE"
        rm -f "$db_tmp" 2>/dev/null
    fi

    # Keep the HWID enforcer's view current after removals.
    hwid_sync_allowed_db

    invalidate_banner_cache
    refresh_dynamic_banner_routing_if_enabled
}

require_interactive_terminal() {
    if [[ ! -t 0 || ! -t 1 ]]; then
        echo -e "${C_RED}❌ Error: The Skylartech menu must be run from an interactive terminal.${C_RESET}"
        exit 1
    fi
}

initial_setup() {
    migrate_from_firewallfalcon
    echo -e "${C_BLUE}⚙️ Initializing Skylartech Manager setup...${C_RESET}"
    check_environment
    
    ensure_skylartech_dirs
    ensure_skylartech_system_group
    
    echo -e "${C_BLUE}🔹 Configuring user limiter service...${C_RESET}"
    setup_limiter_service
    
    echo -e "${C_BLUE}🔹 Configuring bandwidth monitoring service...${C_RESET}"
    setup_bandwidth_service
    
    echo -e "${C_BLUE}🔹 Installing trial account cleanup script...${C_RESET}"
    setup_trial_cleanup_script

    echo -e "${C_BLUE}🔹 Preparing HWID lock store...${C_RESET}"
    touch "$HWID_ALLOWED_DB" 2>/dev/null
    chmod 600 "$HWID_ALLOWED_DB" 2>/dev/null
    hwid_sync_allowed_db
    # If HWID enforcement was previously enabled, re-arm it after a re-setup.
    if [[ "$(cat "$HWID_STATE_FILE" 2>/dev/null)" == "on" ]]; then
        enable_hwid_lock >/dev/null 2>&1
    fi
    
    echo -e "${C_BLUE}🔹 Cleaning legacy dynamic SSH banner hooks...${C_RESET}"
    disable_dynamic_ssh_banner_system
    systemctl reload sshd 2>/dev/null || systemctl reload ssh 2>/dev/null || true
    
    echo -e "${C_BLUE}🔹 Installing iptables-persistent for reboot survival...${C_RESET}"
    ff_pkg_install iptables-persistent >/dev/null 2>&1 || true
    systemctl enable netfilter-persistent 2>/dev/null || true
    
    echo -e "${C_BLUE}🔹 Applying NAT port forwarding defaults...${C_RESET}"
    apply_default_nat_rules
    
    if [ ! -f "$INSTALL_FLAG_FILE" ]; then
        touch "$INSTALL_FLAG_FILE"
    fi
    echo -e "${C_GREEN}✅ Setup finished.${C_RESET}"
}

_is_valid_ipv4() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

check_and_open_firewall_port() {
    local port="$1"
    local protocol="${2:-tcp}"
    local firewall_detected=false

    if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
        firewall_detected=true
        if ! ufw status | grep -qw "$port/$protocol"; then
            echo -e "${C_YELLOW}🔥 UFW firewall is active and port ${port}/${protocol} is closed.${C_RESET}"
            read -p "👉 Do you want to open this port now? (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                ufw allow "$port/$protocol"
                echo -e "${C_GREEN}✅ Port ${port}/${protocol} has been opened in UFW.${C_RESET}"
            else
                echo -e "${C_RED}❌ Warning: Port ${port}/${protocol} was not opened. The service may not work correctly.${C_RESET}"
                return 1
            fi
        else
             echo -e "${C_GREEN}✅ Port ${port}/${protocol} is already open in UFW.${C_RESET}"
        fi
    fi

    if command -v firewall-cmd &> /dev/null && systemctl is-active --quiet firewalld; then
        firewall_detected=true
        if ! firewall-cmd --list-ports --permanent | grep -qw "$port/$protocol"; then
            echo -e "${C_YELLOW}🔥 firewalld is active and port ${port}/${protocol} is not open.${C_RESET}"
            read -p "👉 Do you want to open this port now? (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                firewall-cmd --add-port="$port/$protocol" --permanent
                firewall-cmd --reload
                echo -e "${C_GREEN}✅ Port ${port}/${protocol} has been opened in firewalld.${C_RESET}"
            else
                echo -e "${C_RED}❌ Warning: Port ${port}/${protocol} was not opened. The service may not work correctly.${C_RESET}"
                return 1
            fi
        else
            echo -e "${C_GREEN}✅ Port ${port}/${protocol} is already open in firewalld.${C_RESET}"
        fi
    fi

    if ! $firewall_detected; then
        echo -e "${C_BLUE}ℹ️ No active firewall (UFW or firewalld) detected. Assuming ports are open.${C_RESET}"
    fi
    return 0
}

check_and_open_firewall_port_range() {
    local port_range="$1"
    local protocol="${2:-tcp}"
    local firewall_detected=false

    if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
        firewall_detected=true
        if ! ufw status | grep -Fq "$port_range/$protocol"; then
            echo -e "${C_YELLOW}🔥 UFW firewall is active and range ${port_range}/${protocol} is closed.${C_RESET}"
            read -p "👉 Do you want to open this port range now? (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                ufw allow "$port_range/$protocol"
                echo -e "${C_GREEN}✅ Range ${port_range}/${protocol} has been opened in UFW.${C_RESET}"
            else
                echo -e "${C_RED}❌ Warning: Range ${port_range}/${protocol} was not opened. The service may not work correctly.${C_RESET}"
                return 1
            fi
        else
            echo -e "${C_GREEN}✅ Range ${port_range}/${protocol} is already open in UFW.${C_RESET}"
        fi
    fi

    if command -v firewall-cmd &> /dev/null && systemctl is-active --quiet firewalld; then
        firewall_detected=true
        if ! firewall-cmd --quiet --query-port="$port_range/$protocol"; then
            echo -e "${C_YELLOW}🔥 firewalld is active and range ${port_range}/${protocol} is not open.${C_RESET}"
            read -p "👉 Do you want to open this port range now? (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                firewall-cmd --add-port="$port_range/$protocol" --permanent
                firewall-cmd --reload
                echo -e "${C_GREEN}✅ Range ${port_range}/${protocol} has been opened in firewalld.${C_RESET}"
            else
                echo -e "${C_RED}❌ Warning: Range ${port_range}/${protocol} was not opened. The service may not work correctly.${C_RESET}"
                return 1
            fi
        else
            echo -e "${C_GREEN}✅ Range ${port_range}/${protocol} is already open in firewalld.${C_RESET}"
        fi
    fi

    if ! $firewall_detected; then
        echo -e "${C_BLUE}ℹ️ No active firewall (UFW or firewalld) detected. Assuming range ${port_range}/${protocol} is open.${C_RESET}"
    fi
    return 0
}

check_and_free_ports() {
    local ports_to_check=("$@")
    for port in "${ports_to_check[@]}"; do
        echo -e "\n${C_BLUE}🔎 Checking if port $port is available...${C_RESET}"
        local conflicting_process_info
        conflicting_process_info=$(
            ss -H -lntp "( sport = :$port )" 2>/dev/null
            ss -H -lunp "( sport = :$port )" 2>/dev/null
        )
        
        if [[ -n "$conflicting_process_info" ]]; then
            local conflicting_pid
            conflicting_pid=$(echo "$conflicting_process_info" | grep -oP 'pid=\K[0-9]+' | head -n 1)
            local conflicting_name
            conflicting_name=$(echo "$conflicting_process_info" | grep -oP 'users:\(\("(\K[^"]+)' | head -n 1)
            
            echo -e "${C_YELLOW}⚠️ Warning: Port $port is in use by process '${conflicting_name:-unknown}' (PID: ${conflicting_pid:-N/A}).${C_RESET}"
            read -p "👉 Do you want to attempt to stop this process? (y/n): " kill_confirm
            if [[ "$kill_confirm" == "y" || "$kill_confirm" == "Y" ]]; then
                if [[ -z "$conflicting_pid" ]]; then
                    echo -e "${C_RED}❌ Could not determine which PID owns port $port. Please free it manually.${C_RESET}"
                    return 1
                fi
                echo -e "${C_GREEN}🛑 Stopping process PID $conflicting_pid...${C_RESET}"
                systemctl stop "$(ps -p "$conflicting_pid" -o comm=)" &>/dev/null || kill -9 "$conflicting_pid"
                sleep 2
                
                if ss -H -lntp "( sport = :$port )" 2>/dev/null | grep -q . || ss -H -lunp "( sport = :$port )" 2>/dev/null | grep -q .; then
                     echo -e "${C_RED}❌ Failed to free port $port. Please handle it manually. Aborting.${C_RESET}"
                     return 1
                else
                     echo -e "${C_GREEN}✅ Port $port has been successfully freed.${C_RESET}"
                fi
            else
                echo -e "${C_RED}❌ Cannot proceed without freeing port $port. Aborting.${C_RESET}"
                return 1
            fi
        else
            echo -e "${C_GREEN}✅ Port $port is free to use.${C_RESET}"
        fi
    done
    return 0
}

setup_limiter_service() {
    # Combined limiter + bandwidth monitoring
    cat > "$LIMITER_SCRIPT" << 'EOF'
#!/bin/bash
# Skylartech limiter version 2026-06-26.4
DB_FILE="/etc/skylartech/users.db"
BW_DIR="/etc/skylartech/bandwidth"
PID_DIR="$BW_DIR/pidtrack"
BANNER_DIR="/etc/skylartech/banners"
TRIAL_DIR="/etc/skylartech/trials"
SCAN_INTERVAL=10
# UDP relay coordinates so auto-locks can cut ZiVPN / udp-custom like the menu does.
ZIVPN_CONFIG_FILE="/etc/zivpn/config.json"
ZIVPN_LOCK_DIR="/etc/skylartech/zivpn_locked"
ZIVPN_LISTEN_PORT="5667"
UDP_CUSTOM_LISTEN_PORT="36712"

mkdir -p "$BW_DIR" "$PID_DIR"
shopt -s nullglob

# Immediately drop / restore all traffic owned by a user's UID so auto-locks
# (expiry, quota, connection-limit) cut live SSH and SSH-tunnel sessions at once.
ff_block_uid() {
    local u="$1" uid x
    uid=$(id -u "$u" 2>/dev/null) || return 0
    [[ "$uid" =~ ^[0-9]+$ ]] || return 0
    for x in iptables ip6tables; do
        command -v "$x" &>/dev/null || continue
        "$x" -D OUTPUT -m owner --uid-owner "$uid" -j DROP 2>/dev/null
        "$x" -I OUTPUT -m owner --uid-owner "$uid" -j DROP 2>/dev/null
    done
}
ff_unblock_uid() {
    local u="$1" uid x
    uid=$(id -u "$u" 2>/dev/null) || return 0
    [[ "$uid" =~ ^[0-9]+$ ]] || return 0
    for x in iptables ip6tables; do
        command -v "$x" &>/dev/null || continue
        while "$x" -D OUTPUT -m owner --uid-owner "$uid" -j DROP 2>/dev/null; do :; done
    done
}

# --- UDP cutoff for auto-locks (mirrors the menu's manual lock) ---------------
# A system shadow lock (usermod -L) stops SSH and udp-custom re-auth, but ZiVPN
# authenticates against a password list in config.json, so an auto-locked user
# could still reconnect over ZiVPN. Pull that password out (recording it under
# ZIVPN_LOCK_DIR so the menu's unlock/renew can restore it precisely).
# Echoes "changed" only when config.json was actually modified.
ff_zivpn_lock_user() {
    local user="$1" pass="$2"
    [[ -n "$pass" ]] || return 1
    [[ -f "$ZIVPN_CONFIG_FILE" ]] || return 1
    command -v jq &>/dev/null || return 1
    jq -e --arg p "$pass" '.auth.config | index($p) != null' "$ZIVPN_CONFIG_FILE" &>/dev/null || return 1
    local tmp; tmp=$(mktemp) || return 1
    if jq --arg p "$pass" '.auth.config |= map(select(. != $p))' "$ZIVPN_CONFIG_FILE" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$ZIVPN_CONFIG_FILE"
        mkdir -p "$ZIVPN_LOCK_DIR" 2>/dev/null
        printf '%s' "$pass" > "$ZIVPN_LOCK_DIR/${user}"
        echo "changed"; return 0
    fi
    rm -f "$tmp" 2>/dev/null
    return 1
}

# Restore a ZiVPN password an auto-lock previously removed (used by the delayed
# connection-limit auto-unlock). Reloads zivpn so the password takes effect.
ff_zivpn_unlock_user() {
    local user="$1" pass marker="$ZIVPN_LOCK_DIR/${user}"
    [[ -f "$marker" ]] || return 1
    pass=$(cat "$marker" 2>/dev/null)
    rm -f "$marker" 2>/dev/null
    [[ -n "$pass" ]] || return 1
    [[ -f "$ZIVPN_CONFIG_FILE" ]] || return 1
    command -v jq &>/dev/null || return 1
    jq -e --arg p "$pass" '.auth.config | index($p) != null' "$ZIVPN_CONFIG_FILE" &>/dev/null && return 1
    local tmp; tmp=$(mktemp) || return 1
    if jq --arg p "$pass" '.auth.config += [$p]' "$ZIVPN_CONFIG_FILE" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$ZIVPN_CONFIG_FILE"
        systemctl is-active --quiet zivpn 2>/dev/null && systemctl try-restart zivpn.service 2>/dev/null
        return 0
    fi
    rm -f "$tmp" 2>/dev/null
    return 1
}

# Add a password to the ZiVPN auth list so a new/existing ZiVPN user can
# authenticate.  Silently returns 0 when ZiVPN is not installed so callers
# can invoke this unconditionally.
# Usage: _ff_zivpn_add_pass <password>
_ff_zivpn_add_pass() {
    local pass="$1"
    [[ -f "$ZIVPN_CONFIG_FILE" ]] || return 0
    command -v jq &>/dev/null || return 0
    jq -e --arg p "$pass" '.auth.config | index($p) != null' "$ZIVPN_CONFIG_FILE" &>/dev/null && return 0
    local tmp; tmp=$(mktemp) || return 1
    if jq --arg p "$pass" '.auth.config += [$p]' "$ZIVPN_CONFIG_FILE" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$ZIVPN_CONFIG_FILE"
        return 0
    fi
    rm -f "$tmp" 2>/dev/null
    return 1
}

# Bounce the UDP relays so a just-locked user's LIVE root-owned session dies at
# once (the relays run as root, so UID drops and pkill can't reach them). Flush
# conntrack first so kernel UDP/NAT state is gone the instant they come back; the
# blip is ~0.3s and healthy clients re-handshake automatically. Bounce ZiVPN only
# when its auth list actually changed, to avoid disturbing other ZiVPN users.
ff_udp_session_blip() {
    local do_zivpn="$1"
    if command -v conntrack &>/dev/null; then
        conntrack -D -p udp --dport "$UDP_CUSTOM_LISTEN_PORT" &>/dev/null
        conntrack -D -p udp --dport "$BADVPN_LISTEN_PORT" &>/dev/null
        if [[ "$do_zivpn" == "1" ]]; then
            conntrack -D -p udp --dport "$ZIVPN_LISTEN_PORT" &>/dev/null
            conntrack -D -p udp --dport 6000:19999 &>/dev/null || true
        fi
    fi
    systemctl is-active --quiet udp-custom 2>/dev/null && systemctl try-restart udp-custom.service 2>/dev/null
    systemctl is-active --quiet badvpn 2>/dev/null && systemctl try-restart badvpn.service 2>/dev/null
    systemctl is-active --quiet udpgw 2>/dev/null && systemctl try-restart udpgw.service 2>/dev/null
    if [[ "$do_zivpn" == "1" ]]; then
        systemctl is-active --quiet zivpn 2>/dev/null && systemctl try-restart zivpn.service 2>/dev/null
    fi
}

write_banner_if_changed() {
    local user="$1"
    local content="$2"
    local banner_file="$BANNER_DIR/${user}.txt"
    local tmp_file="${banner_file}.tmp"

    printf "%s" "$content" > "$tmp_file"
    if ! cmp -s "$tmp_file" "$banner_file" 2>/dev/null; then
        mv "$tmp_file" "$banner_file"
    else
        rm -f "$tmp_file"
    fi
}

while true; do
    if [[ ! -s "$DB_FILE" ]]; then
        sleep "$SCAN_INTERVAL"
        continue
    fi

    printf -v current_ts '%(%s)T' -1
    dynamic_banners_enabled=false
    # Per-cycle UDP cutoff flags: when any user is newly auto-locked this pass we
    # bounce the relays exactly once (after the scan), not once per user.
    udp_blip_needed=false
    udp_blip_zivpn=false

    # Reset associative arrays each cycle (unset first to avoid stale data)
    unset session_pids locked_users uid_to_user loginuid_pids
    declare -A session_pids=()
    declare -A locked_users=()
    declare -A uid_to_user=()
    declare -A loginuid_pids=()

    while IFS=: read -r username _ uid _rest; do
        [[ -n "$username" && "$uid" =~ ^[0-9]+$ ]] && uid_to_user["$uid"]="$username"
    done < /etc/passwd

    # Method 1: process owner from ps
    while read -r ssh_pid ssh_owner; do
        [[ "$ssh_pid" =~ ^[0-9]+$ ]] || continue
        if [[ -n "$ssh_owner" && "$ssh_owner" != "root" && "$ssh_owner" != "sshd" ]]; then
            session_pids["$ssh_owner"]+="$ssh_pid "
        fi
    done < <(ps -C sshd -o pid=,user= 2>/dev/null)

    # Method 2: kernel loginuid (reliable even when sshd runs as root)
    for p in /proc/[0-9]*/loginuid; do
        [[ -f "$p" ]] || continue
        login_uid=""
        read -r login_uid < "$p" || login_uid=""
        [[ "$login_uid" =~ ^[0-9]+$ && "$login_uid" != "4294967295" ]] || continue

        session_user="${uid_to_user[$login_uid]}"
        [[ -n "$session_user" ]] || continue

        pid_dir=$(dirname "$p")
        pid_num=$(basename "$pid_dir")
        comm=""
        read -r comm < "$pid_dir/comm" || comm=""
        [[ "$comm" == "sshd" ]] || continue

        ppid_val=""
        while read -r key value; do
            if [[ "$key" == "PPid:" ]]; then
                ppid_val="${value:-}"
                break
            fi
        done < "$pid_dir/status"
        [[ "$ppid_val" == "1" ]] && continue

        loginuid_pids["$session_user"]+="$pid_num "
    done

    # Detect locked users via /etc/shadow (cheaper than passwd -Sa)
    if [[ -r /etc/shadow ]]; then
        while IFS=: read -r shadow_user shadow_hash _rest; do
            [[ -n "$shadow_user" && "${shadow_hash:0:1}" == "!" ]] && locked_users["$shadow_user"]=1
        done < /etc/shadow
    else
        while read -r passwd_user _ passwd_status _rest; do
            [[ "$passwd_status" == "L" ]] && locked_users["$passwd_user"]=1
        done < <(passwd -Sa 2>/dev/null)
    fi

    if [[ -f "/etc/skylartech/banners_enabled" ]]; then
        mkdir -p "$BANNER_DIR"
        dynamic_banners_enabled=true
    fi

    while IFS=: read -r user pass expiry limit bandwidth_gb _extra; do
        [[ -z "$user" || "$user" == \#* ]] && continue

        # CRITICAL: unset before declare to reset per-user (bash declare is function-scoped)
        unset unique_pids
        declare -A unique_pids=()

        # Merge BOTH sources (union) for reliable counting
        for pid in ${session_pids[$user]} ${loginuid_pids[$user]}; do
            [[ "$pid" =~ ^[0-9]+$ ]] && unique_pids["$pid"]=1
        done

        online_count=${#unique_pids[@]}
        user_locked=false
        if [[ -n "${locked_users[$user]+x}" ]]; then
            user_locked=true
        fi

        # Precise trial expiry: enforced from a timestamp file so sub-day
        # trials end on time even if the scheduled 'at' cleanup was lost.
        trial_ts_file="$TRIAL_DIR/${user}.ts"
        if [[ "$_extra" == "trial" && -f "$trial_ts_file" ]]; then
            trial_expiry=0
            read -r trial_expiry < "$trial_ts_file" || trial_expiry=0
            if [[ "$trial_expiry" =~ ^[0-9]+$ ]] && (( trial_expiry > 0 && trial_expiry <= current_ts )); then
                usermod -L "$user" &>/dev/null
                ff_block_uid "$user"
                killall -u "$user" -9 &>/dev/null
                # Kill live ZiVPN session before deleting the user.
                [[ "$(ff_zivpn_lock_user "$user" "$pass")" == "changed" ]] && udp_blip_zivpn=true
                udp_blip_needed=true
                ff_unblock_uid "$user"
                userdel -r "$user" &>/dev/null
                sed -i "/^${user}:/d" "$DB_FILE" 2>/dev/null
                rm -f "$BW_DIR/${user}.usage" "$trial_ts_file"
                rm -rf "$PID_DIR/${user}" 2>/dev/null
                continue
            fi
        fi

        expiry_ts=0
        if [[ "$expiry" != "Never" && -n "$expiry" && "$expiry" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            expiry_ts=$(date -d "$expiry" +%s 2>/dev/null || echo 0)
            if [[ "$expiry_ts" =~ ^[0-9]+$ ]] && (( expiry_ts > 0 && expiry_ts < current_ts )); then
                if ! $user_locked; then
                    usermod -L "$user" &>/dev/null
                    ff_block_uid "$user"
                    killall -u "$user" -9 &>/dev/null
                    udp_blip_needed=true
                    [[ "$(ff_zivpn_lock_user "$user" "$pass")" == "changed" ]] && udp_blip_zivpn=true
                    locked_users["$user"]=1
                fi
                continue
            fi
        fi

        [[ "$limit" =~ ^[0-9]+$ ]] || limit=1
        if (( online_count > limit )); then
            if ! $user_locked; then
                usermod -L "$user" &>/dev/null
                ff_block_uid "$user"
                killall -u "$user" -9 &>/dev/null
                udp_blip_needed=true
                [[ "$(ff_zivpn_lock_user "$user" "$pass")" == "changed" ]] && udp_blip_zivpn=true
                (sleep 120; usermod -U "$user" &>/dev/null; ff_unblock_uid "$user"; ff_zivpn_unlock_user "$user"; systemctl try-restart udp-custom.service &>/dev/null) &
                locked_users["$user"]=1
                user_locked=true
            else
                killall -u "$user" -9 &>/dev/null
            fi
        fi

        if $dynamic_banners_enabled; then
            days_left="N/A"
            if [[ "$expiry" != "Never" && -n "$expiry" && "$expiry_ts" =~ ^[0-9]+$ && $expiry_ts -gt 0 ]]; then
                diff_secs=$((expiry_ts - current_ts))
                if (( diff_secs <= 0 )); then
                    days_left="EXPIRED"
                else
                    d_l=$(( diff_secs / 86400 ))
                    h_l=$(( (diff_secs % 86400) / 3600 ))
                    if (( d_l == 0 )); then
                        days_left="${h_l}h left"
                    else
                        days_left="${d_l}d ${h_l}h"
                    fi
                fi
            fi

            bw_info="Unlimited"
            if [[ "$bandwidth_gb" != "0" && -n "$bandwidth_gb" ]]; then
                usagefile="$BW_DIR/${user}.usage"
                accum_disp=0
                if [[ -f "$usagefile" ]]; then
                    read -r accum_disp < "$usagefile"
                    [[ "$accum_disp" =~ ^[0-9]+$ ]] || accum_disp=0
                fi
                used_gb_int=$((accum_disp / 1073741824))
                used_gb_frac=$(( (accum_disp % 1073741824) * 100 / 1073741824 ))
                printf -v used_gb "%d.%02d" "$used_gb_int" "$used_gb_frac"
                quota_b=$(( ${bandwidth_gb%%.*} * 1073741824 ))
                remain_b=$(( quota_b - accum_disp ))
                (( remain_b < 0 )) && remain_b=0
                remain_gb_int=$((remain_b / 1073741824))
                remain_gb_frac=$(( (remain_b % 1073741824) * 100 / 1073741824 ))
                printf -v remain_gb "%d.%02d" "$remain_gb_int" "$remain_gb_frac"
                bw_info="${used_gb}/${bandwidth_gb} GB used | ${remain_gb} GB left"
            fi

            banner_content="<br><font color=\"yellow\"><b>      ✨ ACCOUNT STATUS ✨      </b></font><br><br>"
            banner_content+="<font color=\"white\">👤 <b>Username   :</b> $user</font><br>"
            banner_content+="<font color=\"white\">📅 <b>Expiration :</b> $expiry ($days_left)</font><br>"
            banner_content+="<font color=\"white\">📊 <b>Bandwidth  :</b> $bw_info</font><br>"
            banner_content+="<font color=\"white\">🔌 <b>Sessions   :</b> $online_count/$limit</font><br><br>"
            write_banner_if_changed "$user" "$banner_content"
        fi

        [[ -z "$bandwidth_gb" || "$bandwidth_gb" == "0" ]] && continue

        usagefile="$BW_DIR/${user}.usage"
        accumulated=0
        if [[ -f "$usagefile" ]]; then
            read -r accumulated < "$usagefile"
            [[ "$accumulated" =~ ^[0-9]+$ ]] || accumulated=0
        fi

        if (( ${#unique_pids[@]} == 0 )); then
            rm -f "$PID_DIR/${user}__"*.last 2>/dev/null
            continue
        fi

        delta_total=0
        for pid in "${!unique_pids[@]}"; do
            io_file="/proc/$pid/io"
            cur=0
            if [[ -r "$io_file" ]]; then
                rchar=0
                wchar=0
                while read -r key value; do
                    case "$key" in
                        rchar:) rchar=${value:-0} ;;
                        wchar:) wchar=${value:-0} ;;
                    esac
                done < "$io_file"
                cur=$((rchar + wchar))
            fi

            pidfile="$PID_DIR/${user}__${pid}.last"
            if [[ -f "$pidfile" ]]; then
                read -r prev < "$pidfile"
                [[ "$prev" =~ ^[0-9]+$ ]] || prev=0
                if (( cur >= prev )); then
                    d=$((cur - prev))
                else
                    d=$cur
                fi
                delta_total=$((delta_total + d))
            fi
            printf "%s\n" "$cur" > "$pidfile"
        done

        for f in "$PID_DIR/${user}__"*.last; do
            [[ -f "$f" ]] || continue
            fpid=${f##*__}
            fpid=${fpid%.last}
            [[ -d "/proc/$fpid" ]] || rm -f "$f"
        done

        new_total=$((accumulated + delta_total))
        printf "%s\n" "$new_total" > "$usagefile"

        quota_bytes=$(( ${bandwidth_gb%%.*} * 1073741824 ))
        if [[ "$quota_bytes" =~ ^[0-9]+$ ]] && (( new_total >= quota_bytes )); then
            if ! $user_locked; then
                usermod -L "$user" &>/dev/null
                ff_block_uid "$user"
                killall -u "$user" -9 &>/dev/null
                udp_blip_needed=true
                [[ "$(ff_zivpn_lock_user "$user" "$pass")" == "changed" ]] && udp_blip_zivpn=true
                locked_users["$user"]=1
            fi
        fi
    done < "$DB_FILE"

    # One relay blip for the whole pass so newly auto-locked users' live UDP
    # sessions (zivpn / udp-custom) drop at once — fastest without restart storms.
    if $udp_blip_needed; then
        if $udp_blip_zivpn; then ff_udp_session_blip 1; else ff_udp_session_blip 0; fi
    fi

    sleep "$SCAN_INTERVAL"
done
EOF
    chmod +x "$LIMITER_SCRIPT"
    # Strip DOS line endings in case menu.sh was uploaded from Windows
    sed -i 's/\r$//' "$LIMITER_SCRIPT" 2>/dev/null

    cat > "$LIMITER_SERVICE" << EOF
[Unit]
Description=Skylartech Active User Limiter
After=network.target

[Service]
Type=simple
ExecStart=$LIMITER_SCRIPT
Restart=always
RestartSec=10
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=7
MemoryHigh=48M
MemoryMax=64M

[Install]
WantedBy=multi-user.target
EOF
    sed -i 's/\r$//' "$LIMITER_SERVICE" 2>/dev/null

    pkill -f "skylartech-limiter" 2>/dev/null

    if ! systemctl is-active --quiet skylartech-limiter; then
        systemctl daemon-reload
        systemctl enable skylartech-limiter &>/dev/null
        systemctl start skylartech-limiter --no-block &>/dev/null
        
    else
        systemctl restart skylartech-limiter --no-block &>/dev/null
        
    fi
}

sync_runtime_components_if_needed() {
    local limiter_marker="# Skylartech limiter version 2026-06-26.4"
    # Safety net: guarantee core directories and the user group exist even when
    # the menu is launched directly (e.g. `bash menu.sh` from a git clone)
    # without the one-time `--install-setup` having been run first.
    ensure_skylartech_dirs
    ensure_skylartech_system_group
    cleanup_legacy_bandwidth_runtime
    setup_trial_cleanup_script >/dev/null 2>&1
    if [[ ! -f "$LIMITER_SCRIPT" ]] || ! grep -Fqx "$limiter_marker" "$LIMITER_SCRIPT" 2>/dev/null; then
        setup_limiter_service >/dev/null 2>&1
    fi
    if [[ -f "$BADVPN_SERVICE_FILE" ]]; then
        ensure_badvpn_service_is_quiet
    fi
    if [[ -f "/etc/skylartech/banners_enabled" ]]; then
        update_ssh_banners_config
    elif [[ -f "$SSHD_FF_CONFIG" ]]; then
        disable_dynamic_ssh_banner_system
        systemctl reload sshd 2>/dev/null || systemctl reload ssh 2>/dev/null || true
    fi
    # Refresh the HWID mirror and re-arm the enforcer if it was left enabled.
    touch "$HWID_ALLOWED_DB" 2>/dev/null && chmod 600 "$HWID_ALLOWED_DB" 2>/dev/null
    hwid_sync_allowed_db
    if [[ "$(cat "$HWID_STATE_FILE" 2>/dev/null)" == "on" ]]; then
        local hwid_enforcer_marker="# Skylartech HWID enforcer version 2026-06-26.1"
        if ! systemctl is-active --quiet skylartech-hwid-enforcer 2>/dev/null; then
            enable_hwid_lock >/dev/null 2>&1
        elif ! grep -Fq "$hwid_enforcer_marker" "$HWID_ENFORCER_SCRIPT" 2>/dev/null; then
            # Already running an older enforcer (single-HWID match) — rewrite the
            # script with the comma-list matcher and restart so it takes effect.
            write_hwid_enforcer
            systemctl restart skylartech-hwid-enforcer 2>/dev/null
        fi
    fi
}

setup_bandwidth_service() {
    mkdir -p "$BANDWIDTH_DIR"
    # Bandwidth monitoring is now integrated into the limiter service above.
    cleanup_legacy_bandwidth_runtime
}

cleanup_legacy_bandwidth_runtime() {
    local needs_reload=false

    systemctl stop skylartech-bandwidth &>/dev/null || true
    systemctl disable skylartech-bandwidth &>/dev/null || true
    pkill -f "skylartech-bandwidth" &>/dev/null || true

    if [[ -e "$BANDWIDTH_SERVICE" || -e "$BANDWIDTH_SCRIPT" || -e "$LEGACY_BANDWIDTH_DIR" ]]; then
        rm -f "$BANDWIDTH_SERVICE" "$BANDWIDTH_SCRIPT" 2>/dev/null
        rm -rf "$LEGACY_BANDWIDTH_DIR" 2>/dev/null
        needs_reload=true
    fi

    if $needs_reload; then
        systemctl daemon-reload &>/dev/null || true
    fi
}

setup_trial_cleanup_script() {
    cat > "$TRIAL_CLEANUP_SCRIPT" << 'TREOF'
#!/bin/bash
# Skylartech Trial Account Auto-Cleanup
# Usage: skylartech-trial-cleanup.sh <username>
DB_FILE="/etc/skylartech/users.db"
BW_DIR="/etc/skylartech/bandwidth"
TRIAL_DIR="/etc/skylartech/trials"

username="$1"
if [[ -z "$username" ]]; then exit 1; fi

db_line=$(grep "^${username}:" "$DB_FILE" 2>/dev/null | head -n 1)
if [[ -z "$db_line" ]]; then exit 0; fi

IFS=: read -r _ _ _ _ _ trial_marker _rest <<< "$db_line"
if [[ "$trial_marker" != "trial" ]]; then
    exit 0
fi

# Kill active sessions
killall -u "$username" -9 &>/dev/null
sleep 1

# Delete system user
userdel -r "$username" &>/dev/null

# Remove from DB
sed -i "/^${username}:/d" "$DB_FILE"

# Remove bandwidth tracking
rm -f "$BW_DIR/${username}.usage"
rm -rf "$BW_DIR/pidtrack/${username}"
rm -f "$TRIAL_DIR/${username}.ts"
TREOF
    chmod +x "$TRIAL_CLEANUP_SCRIPT"
}

disable_dynamic_ssh_banner_system() {
    rm -f "/etc/skylartech/banners_enabled" "$SSHD_FF_CONFIG" /usr/local/bin/skylartech-login-info.sh 2>/dev/null
    rm -rf "/etc/skylartech/banners" 2>/dev/null
    invalidate_banner_cache
}

disable_static_ssh_banner_in_sshd_config() {
    sed -i.bak -E "s|^[[:space:]]*Banner[[:space:]]+${SSH_BANNER_FILE}[[:space:]]*$|# Banner $SSH_BANNER_FILE|" /etc/ssh/sshd_config 2>/dev/null
}

is_static_ssh_banner_enabled() {
    grep -q -E "^[[:space:]]*Banner[[:space:]]+${SSH_BANNER_FILE}[[:space:]]*$" /etc/ssh/sshd_config 2>/dev/null && [ -f "$SSH_BANNER_FILE" ]
}

is_dynamic_ssh_banner_enabled() {
    [[ -f "/etc/skylartech/banners_enabled" && -f "$SSHD_FF_CONFIG" ]]
}

get_ssh_banner_mode() {
    if is_dynamic_ssh_banner_enabled; then
        echo "dynamic"
    elif is_static_ssh_banner_enabled; then
        echo "static"
    else
        echo "disabled"
    fi
}

refresh_dynamic_banner_routing_if_enabled() {
    if is_dynamic_ssh_banner_enabled; then
        update_ssh_banners_config
    fi
}

update_ssh_banners_config() {
    local tmp_conf

    if [[ ! -f "/etc/skylartech/banners_enabled" ]]; then
        if [[ -f "$SSHD_FF_CONFIG" ]]; then
            rm -f "$SSHD_FF_CONFIG" 2>/dev/null
            systemctl reload sshd 2>/dev/null || systemctl reload ssh 2>/dev/null
        fi
        return
    fi

    ensure_skylartech_dirs
    tmp_conf="/tmp/ff_banners_new.conf"
    echo "# Skylartech - Dynamic per-user SSH banners" > "$tmp_conf"

    if [[ -f "$DB_FILE" ]]; then
        while IFS=: read -r u _rest; do
            [[ -z "$u" || "$u" == \#* ]] && continue
            echo "Match User $u" >> "$tmp_conf"
            echo "    Banner /etc/skylartech/banners/${u}.txt" >> "$tmp_conf"
        done < "$DB_FILE"
    fi

    if ! cmp -s "$tmp_conf" "$SSHD_FF_CONFIG" 2>/dev/null; then
        mv "$tmp_conf" "$SSHD_FF_CONFIG"
        if ! grep -q "^Include /etc/ssh/sshd_config.d/" /etc/ssh/sshd_config 2>/dev/null; then
            echo "Include /etc/ssh/sshd_config.d/*.conf" >> /etc/ssh/sshd_config
        fi
        systemctl reload sshd 2>/dev/null || systemctl reload ssh 2>/dev/null
    else
        rm -f "$tmp_conf"
    fi
}

setup_ssh_login_info() {
    ensure_skylartech_dirs || return 1
    if ! touch "/etc/skylartech/banners_enabled"; then
        echo -e "${C_RED}❌ Failed to enable dynamic SSH banners.${C_RESET}"
        return 1
    fi
    disable_static_ssh_banner_in_sshd_config
    update_ssh_banners_config
    return 0
}


_select_user_interface() {
    local title="$1"
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}${title}${C_RESET}\n"
    if [[ ! -s $DB_FILE ]]; then
        echo -e "${C_YELLOW}ℹ️ No users found in the database.${C_RESET}"
        SELECTED_USER="NO_USERS"; return
    fi
    
    mapfile -t all_users < <(cut -d: -f1 "$DB_FILE" | sort)
    local -A all_user_lookup=()
    local username
    for username in "${all_users[@]}"; do
        all_user_lookup["$username"]=1
    done
    
    if [ ${#all_users[@]} -ge 15 ]; then
        read -p "👉 Enter a search term (or press Enter to list all): " search_term
        if [[ -n "$search_term" ]]; then
            mapfile -t users < <(printf "%s\n" "${all_users[@]}" | grep -i "$search_term")
        else
            users=("${all_users[@]}")
        fi
    else
        users=("${all_users[@]}")
    fi

    if [ ${#users[@]} -eq 0 ]; then
        echo -e "\n${C_YELLOW}ℹ️ No users found matching your criteria.${C_RESET}"
        SELECTED_USER="NO_USERS"; return
    fi
    echo -e "\nPlease select a user:\n"
    for i in "${!users[@]}"; do
        printf "  ${C_GREEN}[%2d]${C_RESET} %s\n" "$((i+1))" "${users[$i]}"
    done
    echo -e "\n  ${C_RED} [ 0]${C_RESET} ↩️ Cancel"
    echo -e "${C_CYAN}💡 Tip: you can also type the exact username directly.${C_RESET}"
    echo
    local choice
    while true; do
        if ! read -r -p "👉 Enter the number or exact username: " choice; then
            echo
            SELECTED_USER=""
            return
        fi
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -le "${#users[@]}" ]; then
            if [ "$choice" -eq 0 ]; then
                SELECTED_USER=""; return
            else
                SELECTED_USER="${users[$((choice-1))]}"; return
            fi
        elif [[ -n "${all_user_lookup[$choice]+x}" ]]; then
            SELECTED_USER="$choice"; return
        else
            echo -e "${C_RED}❌ Invalid selection. Please try again.${C_RESET}"
        fi
    done
}

_select_multi_user_interface() {
    local title="$1"
    local include_orphan_users="${2:-false}"
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}${title}${C_RESET}\n"
    SELECTED_USERS=()
    local -a all_users=()
    local -a orphan_users=()
    local -A all_user_lookup=()
    local -A orphan_user_lookup=()
    local username

    if [[ -s $DB_FILE ]]; then
        mapfile -t all_users < <(cut -d: -f1 "$DB_FILE" | sort)
    fi

    if [[ "$include_orphan_users" == "true" ]]; then
        mapfile -t orphan_users < <(get_skylartech_orphan_users)
        for username in "${orphan_users[@]}"; do
            orphan_user_lookup["$username"]=1
            if ! printf "%s\n" "${all_users[@]}" | grep -Fxq "$username"; then
                all_users+=("$username")
            fi
        done
        if [[ ${#all_users[@]} -gt 0 ]]; then
            mapfile -t all_users < <(printf "%s\n" "${all_users[@]}" | sort)
        fi
    fi

    if [[ ${#all_users[@]} -eq 0 ]]; then
        echo -e "${C_YELLOW}ℹ️ No users found in the manager database.${C_RESET}"
        if [[ "$include_orphan_users" == "true" ]]; then
            echo -e "${C_DIM}No orphan Skylartech system users were found either.${C_RESET}"
        fi
        SELECTED_USERS=("NO_USERS"); return
    fi

    for username in "${all_users[@]}"; do
        all_user_lookup["$username"]=1
    done
    
    if [ ${#all_users[@]} -ge 15 ]; then
        read -p "👉 Enter a search term (or press Enter to list all): " search_term
        if [[ -n "$search_term" ]]; then
            mapfile -t users < <(printf "%s\n" "${all_users[@]}" | grep -i "$search_term")
        else
            users=("${all_users[@]}")
        fi
    else
        users=("${all_users[@]}")
    fi

    if [ ${#users[@]} -eq 0 ]; then
        echo -e "\n${C_YELLOW}ℹ️ No users found matching your criteria.${C_RESET}"
        SELECTED_USERS=("NO_USERS"); return
    fi
    echo -e "\nPlease select users:\n"
    for i in "${!users[@]}"; do
        local display_user="${users[$i]}"
        if [[ "$include_orphan_users" == "true" && -n "${orphan_user_lookup[${users[$i]}]+x}" ]]; then
            display_user="${display_user} ${C_DIM}(system-only)${C_RESET}"
        fi
        printf "  ${C_GREEN}[%2d]${C_RESET} %s\n" "$((i+1))" "$display_user"
    done
    echo -e "\n  ${C_GREEN}[all]${C_RESET} Select ALL listed users"
    echo -e "  ${C_RED}  [0]${C_RESET} ↩️ Cancel and return to main menu"
    echo -e "\n${C_CYAN}💡 You can select multiple by number, range, or exact username.${C_RESET}"
    echo -e "${C_CYAN}   Examples: '1 3 5' or '1,3' or '1-4' or 'alice bob'${C_RESET}"
    if [[ "$include_orphan_users" == "true" ]]; then
        echo -e "${C_CYAN}   Users marked '(system-only)' are old accounts still on the VPS but missing from users.db${C_RESET}"
    fi
    echo
    local choice
    while true; do
        if ! read -r -p "👉 Enter user numbers or usernames: " choice; then
            echo
            SELECTED_USERS=()
            return
        fi
        choice=${choice//,/ } # Replace commas with spaces
        
        if [[ -z "$choice" ]]; then
            echo -e "${C_RED}❌ Invalid selection. Please try again.${C_RESET}"
            continue
        fi

        if [[ "$choice" == "0" ]]; then
            SELECTED_USERS=(); return
        fi
        
        if [[ "${choice,,}" == "all" ]]; then
            SELECTED_USERS=("${users[@]}")
            return
        fi
        
        local valid=true
        local selected_indices=()
        local selected_names=()
        for token in $choice; do
            if [[ "$token" =~ ^[0-9]+-[0-9]+$ ]]; then
                local start=${token%-*}
                local end=${token#*-}
                if [ "$start" -le "$end" ]; then
                    for (( idx=start; idx<=end; idx++ )); do
                        if [ "$idx" -ge 1 ] && [ "$idx" -le "${#users[@]}" ]; then
                            selected_indices+=($idx)
                        else
                            valid=false; break
                        fi
                    done
                else
                    valid=false; break
                fi
            elif [[ "$token" =~ ^[0-9]+$ ]]; then
                if [ "$token" -ge 1 ] && [ "$token" -le "${#users[@]}" ]; then
                    selected_indices+=($token)
                elif [[ -n "${all_user_lookup[$token]+x}" ]]; then
                    selected_names+=("$token")
                else
                    valid=false; break
                fi
            elif [[ -n "${all_user_lookup[$token]+x}" ]]; then
                selected_names+=("$token")
            else
                valid=false; break
            fi
        done
        
        if [[ "$valid" == true && ( ${#selected_indices[@]} -gt 0 || ${#selected_names[@]} -gt 0 ) ]]; then
            mapfile -t unique_indices < <(printf "%s\n" "${selected_indices[@]}" | sort -u -n)
            for idx in "${unique_indices[@]}"; do
                SELECTED_USERS+=("${users[$((idx-1))]}")
            done
            mapfile -t unique_names < <(printf "%s\n" "${selected_names[@]}" | sort -u)
            for username in "${unique_names[@]}"; do
                if ! printf "%s\n" "${SELECTED_USERS[@]}" | grep -Fxq "$username"; then
                    SELECTED_USERS+=("$username")
                fi
            done
            return
        else
            echo -e "${C_RED}❌ Invalid selection. Please check your numbers or usernames.${C_RESET}"
            SELECTED_USERS=()
            selected_indices=()
            selected_names=()
        fi
    done
}

get_user_status() {
    local username="$1"
    if ! id "$username" &>/dev/null; then echo -e "${C_RED}Not Found${C_RESET}"; return; fi
    local expiry_date=$(grep "^$username:" "$DB_FILE" | cut -d: -f3)
    if passwd -S "$username" 2>/dev/null | grep -q " L "; then echo -e "${C_YELLOW}🔒 Locked${C_RESET}"; return; fi
    local expiry_ts=$(date -d "$expiry_date" +%s 2>/dev/null || echo 0)
    local current_ts=$(date +%s)
    if [[ $expiry_ts -lt $current_ts ]]; then echo -e "${C_RED}🗓️ Expired${C_RESET}"; return; fi
    echo -e "${C_GREEN}🟢 Active${C_RESET}"
}

create_user() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- ✨ Create New SSH User ---${C_RESET}"
    read -p "👉 Enter username (or '0' to cancel): " username
    local adopt_existing=false
    if [[ "$username" == "0" ]]; then
        echo -e "\n${C_YELLOW}❌ User creation cancelled.${C_RESET}"
        return
    fi
    if [[ -z "$username" ]]; then
        echo -e "\n${C_RED}❌ Error: Username cannot be empty.${C_RESET}"
        return
    fi
    if db_has_user "$username"; then
        echo -e "\n${C_RED}❌ Error: User '$username' already exists in Skylartech.${C_RESET}"
        return
    fi
    if id "$username" &>/dev/null; then
        if is_skylartech_orphan_user "$username"; then
            echo -e "\n${C_YELLOW}⚠️ User '$username' already exists on the system but is missing from users.db.${C_RESET}"
            echo -e "${C_DIM}This usually happens after uninstalling the script without deleting the SSH users.${C_RESET}"
            read -p "👉 Do you want to take control of this existing user and manage it with Skylartech? (y/n): " adopt_confirm
            if [[ "$adopt_confirm" == "y" || "$adopt_confirm" == "Y" ]]; then
                adopt_existing=true
            else
                echo -e "\n${C_YELLOW}❌ User creation cancelled.${C_RESET}"
                return
            fi
        else
            echo -e "\n${C_RED}❌ Error: System user '$username' already exists and does not look like a Skylartech SSH account.${C_RESET}"
            return
        fi
    fi
    local password=""
    while true; do
        read -p "🔑 Enter password (or press Enter for auto-generated): " password
        if [[ -z "$password" ]]; then
            password=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 8)
            echo -e "${C_GREEN}🔑 Auto-generated password: ${C_YELLOW}$password${C_RESET}"
            break
        else
            break
        fi
    done
    read -p "🗓️ Enter account duration (in days) [30]: " days
    days=${days:-30}
    if ! [[ "$days" =~ ^[0-9]+$ ]]; then echo -e "\n${C_RED}❌ Invalid number.${C_RESET}"; return; fi
    read -p "📶 Enter simultaneous connection limit [1]: " limit
    limit=${limit:-1}
    if ! [[ "$limit" =~ ^[0-9]+$ ]]; then echo -e "\n${C_RED}❌ Invalid number.${C_RESET}"; return; fi
    read -p "📦 Enter bandwidth limit in GB (0 = unlimited) [0]: " bandwidth_gb
    bandwidth_gb=${bandwidth_gb:-0}
    if ! [[ "$bandwidth_gb" =~ ^[0-9]+\.?[0-9]*$ ]]; then echo -e "\n${C_RED}❌ Invalid number.${C_RESET}"; return; fi
    # App type selector
    local app="http"
    echo -e "\n${C_DIM}Select the target application for this account:${C_RESET}"
    printf "  ${C_GREEN}[1]${C_RESET} %-15s ${C_DIM}(HTTP Custom / SSH Tunnel)${C_RESET}\n" "HTTP Custom"
    printf "  ${C_GREEN}[2]${C_RESET} %-15s ${C_DIM}(ZiVPN / UDP VPN)${C_RESET}\n" "ZiVPN"
    read -p "👉 App type [1]: " app_choice
    app_choice=${app_choice:-1}
    case "$app_choice" in
        2|z|Z|zivpn|ZiVPN) app="zivpn" ;;
        *) app="http" ;;
    esac
    echo -e "${C_GREEN}✅ App type set to: ${C_YELLOW}$app${C_RESET}\n"

    # Optional HWID device lock. Blank = no restriction (credentials usable on any
    # device). When set, the user can optionally be strict-enforced by the daemon.
    local hwid="" strict="0"
    echo -e "${C_DIM}Leave blank for no device lock (works on multiple devices).${C_RESET}"
    echo -e "${C_DIM}For several devices, separate HWIDs with commas (e.g. hwidA,hwidB).${C_RESET}"
    read -p "🔒 Enter HWID(s) from VPN app (optional): " hwid
    hwid=$(_ff_normalize_hwids "$hwid")
    if [[ -n "$hwid" ]]; then
        local s_choice="y"
        read -p "🛡️ Strict-enforce these device(s)? (y/n) [y]: " s_choice
        s_choice=${s_choice:-y}
        [[ "$s_choice" == "y" || "$s_choice" == "Y" ]] && strict=1
    fi
    # Only relevant when udp-custom is installed: ask the port range to advertise
    # in the UDP-Custom connection string (IP:range@user:pass).
    local udp_port_range=""
    if [[ "$app" == "http" ]] && systemctl is-active --quiet udp-custom; then
        read -p "🚀 Enter UDP-Custom port range [1000-5000]: " udp_port_range
        udp_port_range=${udp_port_range:-1000-5000}
    fi
    local expire_date
    expire_date=$(date -d "+$days days" +%Y-%m-%d)
    ensure_skylartech_system_group
    if [[ "$adopt_existing" == "true" ]]; then
        usermod -s /usr/sbin/nologin "$username" &>/dev/null
    else
        useradd -m -s /usr/sbin/nologin "$username"
    fi
    usermod -aG "$FF_USERS_GROUP" "$username" 2>/dev/null
    echo "$username:$password" | chpasswd; chage -E "$expire_date" "$username"
    # Fields: user:pass:expiry:limit:bw:marker:hwid:strict
    # 6th field is the account marker: empty = normal account, "trial" = auto-expiring trial.
    echo "$username:$password:$expire_date:$limit:$bandwidth_gb::$hwid:$strict:$app" >> "$DB_FILE"
    hwid_sync_allowed_db

    if [[ "$app" == "zivpn" ]] && _ff_zivpn_add_pass "$password"; then
        systemctl is-active --quiet zivpn 2>/dev/null && systemctl try-restart zivpn.service 2>/dev/null
    fi

    local bw_display="Unlimited"
    if [[ "$bandwidth_gb" != "0" ]]; then bw_display="${bandwidth_gb} GB"; fi

    clear; show_banner
    if [[ "$adopt_existing" == "true" ]]; then
        echo -e "${C_GREEN}✅ Existing system user '$username' has been imported into Skylartech!${C_RESET}\n"
    else
        echo -e "${C_GREEN}✅ User '$username' created successfully!${C_RESET}\n"
    fi
    echo -e "  - 👤 Username:          ${C_YELLOW}$username${C_RESET}"
    echo -e "  - 🔑 Password:          ${C_YELLOW}$password${C_RESET}"
    echo -e "  - 🗓️ Expires on:        ${C_YELLOW}$expire_date${C_RESET}"
    echo -e "  - 📶 Connection Limit:  ${C_YELLOW}$limit${C_RESET}"
    echo -e "  - 📦 Bandwidth Limit:   ${C_YELLOW}$bw_display${C_RESET}"
    if [[ -n "$hwid" ]]; then
        echo -e "  - 🔒 HWID Lock:         ${C_YELLOW}$(_ff_hwid_label "$hwid" "$strict" strict)${C_RESET}"
    else
        echo -e "  - 🔒 HWID Lock:         ${C_DIM}none (multi-device)${C_RESET}"
    fi
    if [[ -n "$udp_port_range" ]] && systemctl is-active --quiet udp-custom; then
        local udp_host
        udp_host=$(detect_preferred_host)
        [[ -z "$udp_host" ]] && udp_host=$(curl -s -4 icanhazip.com)
        echo -e "  - 🚀 UDP-Custom:        ${C_YELLOW}${udp_host}:${udp_port_range}@${username}:${password}${C_RESET}"
    fi
    echo -e "    ${C_DIM}(Active monitoring service will enforce these limits)${C_RESET}"

    # Auto-ask for config generation
    echo
    read -p "👉 Do you want to generate a client connection config for this user? (y/n): " gen_conf
    if [[ "$gen_conf" == "y" || "$gen_conf" == "Y" ]]; then
        generate_client_config "$username" "$password"
    fi
    
    invalidate_banner_cache
    refresh_dynamic_banner_routing_if_enabled
}

delete_user() {
    _select_multi_user_interface "--- 🗑️ Delete Skylartech Users ---" "true"
    if [[ ${#SELECTED_USERS[@]} -eq 0 || "${SELECTED_USERS[0]}" == "NO_USERS" ]]; then return; fi
    
    echo -e "\n${C_RED}⚠️ You selected ${#SELECTED_USERS[@]} user(s) to delete: ${C_YELLOW}${SELECTED_USERS[*]}${C_RESET}"
    read -p "👉 Are you sure you want to PERMANENTLY delete them? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then echo -e "\n${C_YELLOW}❌ Deletion cancelled.${C_RESET}"; return; fi
    
    echo -e "\n${C_BLUE}🗑️ Deleting selected users...${C_RESET}"
    delete_skylartech_user_accounts "${SELECTED_USERS[@]}"
}

view_user_details() {
    _select_user_interface "--- 👁️ View User Details ---"
    local username=$SELECTED_USER
    if [[ "$username" == "NO_USERS" ]] || [[ -z "$username" ]]; then return; fi

    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 👁️ User Details: ${C_YELLOW}$username${C_PURPLE} ---${C_RESET}"

    local line; line=$(grep "^$username:" "$DB_FILE")
    if [[ -z "$line" ]]; then
        echo -e "\n${C_RED}❌ User '$username' not found in database.${C_RESET}"
        return
    fi

    local cur_pass cur_expiry cur_limit cur_bw cur_marker cur_hwid cur_strict cur_app
    IFS=: read -r _ cur_pass cur_expiry cur_limit cur_bw cur_marker cur_hwid cur_strict cur_app <<< "$line"
    [[ -z "$cur_bw" ]] && cur_bw="0"
    [[ -z "$cur_strict" ]] && cur_strict="0"
    [[ -z "$cur_app" ]] && cur_app="http"

    local bw_display="Unlimited"; [[ "$cur_bw" != "0" ]] && bw_display="${cur_bw} GB"

    local bw_used_display="N/A"
    if [[ -f "$BANDWIDTH_DIR/${username}.usage" ]]; then
        local used_bytes=0; read -r used_bytes < "$BANDWIDTH_DIR/${username}.usage" 2>/dev/null || used_bytes=0
        if [[ -n "$used_bytes" && "$used_bytes" != "0" ]]; then
            bw_used_display=$(awk "BEGIN {printf \"%.2f GB\", $used_bytes / 1073741824}")
        else
            bw_used_display="0.00 GB"
        fi
    fi

    local _now_ts; printf -v _now_ts '%(%s)T' -1
    local _days_str; _days_str=$(_ff_days_left_str "$cur_expiry" "$_now_ts")
    local _days_color; _days_color=$(_ff_days_left_color "$_days_str")

    local hwid_display="${C_DIM}none (multi-device)${C_RESET}"
    if [[ -n "$cur_hwid" ]]; then
        hwid_display="${C_YELLOW}$(_ff_hwid_label "$cur_hwid" "$cur_strict" enforce)${C_RESET}"
    fi

    local marker_display="${C_DIM}normal${C_RESET}"
    [[ "$cur_marker" == "trial" ]] && marker_display="${C_YELLOW}trial${C_RESET}"

    local app_display="${C_CYAN}HTTP Custom${C_RESET}"
    [[ "$cur_app" == "zivpn" ]] && app_display="${C_CYAN}ZiVPN${C_RESET}"

    echo
    echo -e "  ${C_DIM}Field${C_RESET}               ${C_DIM}Value${C_RESET}"
    echo -e "  ${C_GREEN}──────────────────────────────────────────${C_RESET}"
    echo -e "  👤 ${C_BOLD}Username${C_RESET}:        ${C_YELLOW}$username${C_RESET}"
    echo -e "  🔑 ${C_BOLD}Password${C_RESET}:        ${C_YELLOW}$cur_pass${C_RESET}"
    echo -e "  🗓️ ${C_BOLD}Expires${C_RESET}:         ${C_YELLOW}$cur_expiry${C_RESET}  (${_days_color}${_days_str} left${C_RESET})"
    echo -e "  📶 ${C_BOLD}Conn Limit${C_RESET}:      ${C_YELLOW}$cur_limit${C_RESET}"
    echo -e "  📦 ${C_BOLD}BW Limit${C_RESET}:        ${C_YELLOW}$bw_display${C_RESET}"
    echo -e "  📊 ${C_BOLD}BW Used${C_RESET}:         ${C_CYAN}$bw_used_display${C_RESET}"
    echo -e "  🔒 ${C_BOLD}HWID Lock${C_RESET}:       ${hwid_display}"
    echo -e "  🏷️ ${C_BOLD}Account Type${C_RESET}:   ${marker_display}"
    echo -e "  📱 ${C_BOLD}Target App${C_RESET}:      ${app_display}"

    echo -e "\n${C_YELLOW}[Enter]${C_RESET} to return..." && read -r
}

edit_user() {
    _select_user_interface "--- ✏️ Edit a User ---"
    local username=$SELECTED_USER
    if [[ "$username" == "NO_USERS" ]] || [[ -z "$username" ]]; then return; fi
    while true; do
        clear; show_banner; echo -e "${C_BOLD}${C_PURPLE}--- Editing User: ${C_YELLOW}$username${C_PURPLE} ---${C_RESET}"
        
        # Show current user details
        local current_line; current_line=$(grep "^$username:" "$DB_FILE")
        local cur_pass cur_expiry cur_limit cur_bw cur_marker cur_hwid cur_strict cur_app
        IFS=: read -r _ cur_pass cur_expiry cur_limit cur_bw cur_marker cur_hwid cur_strict cur_app <<< "$current_line"
        [[ -z "$cur_bw" ]] && cur_bw="0"
        [[ -z "$cur_strict" ]] && cur_strict="0"
        [[ -z "$cur_app" ]] && cur_app="http"
        local cur_bw_display="Unlimited"; [[ "$cur_bw" != "0" ]] && cur_bw_display="${cur_bw} GB"
        
        # Show bandwidth usage
        local bw_used_display="N/A"
        if [[ -f "$BANDWIDTH_DIR/${username}.usage" ]]; then
            local used_bytes=0; read -r used_bytes < "$BANDWIDTH_DIR/${username}.usage" 2>/dev/null || used_bytes=0
            if [[ -n "$used_bytes" && "$used_bytes" != "0" ]]; then
                bw_used_display=$(awk "BEGIN {printf \"%.2f GB\", $used_bytes / 1073741824}")
            else
                bw_used_display="0.00 GB"
            fi
        fi
        
        local hwid_display="${C_DIM}none (multi-device)${C_RESET}"
        if [[ -n "$cur_hwid" ]]; then
            hwid_display="${C_YELLOW}$(_ff_hwid_label "$cur_hwid" "$cur_strict" enforce)${C_RESET}"
        fi
        local _now_ts; printf -v _now_ts '%(%s)T' -1
        local _days_disp; _days_disp=$(_ff_days_left_str "$cur_expiry" "$_now_ts")
        local app_display="${C_CYAN}HTTP Custom${C_RESET}"
        [[ "$cur_app" == "zivpn" ]] && app_display="${C_CYAN}ZiVPN${C_RESET}"
        echo -e "\n  ${C_DIM}Current: Pass=${C_YELLOW}$cur_pass${C_RESET}${C_DIM} Exp=${C_YELLOW}$cur_expiry${C_RESET}${C_DIM} (${C_CYAN}${_days_disp} left${C_RESET}${C_DIM}) Conn=${C_YELLOW}$cur_limit${C_RESET}${C_DIM} BW=${C_YELLOW}$cur_bw_display${C_RESET}${C_DIM} Used=${C_CYAN}$bw_used_display${C_RESET}"
        echo -e "  ${C_DIM}HWID=${C_RESET}${hwid_display}  ${C_DIM}App=${C_RESET}${app_display}"
        echo -e "\nSelect a detail to edit:\n"
        printf "  ${C_GREEN}[ 1]${C_RESET} %-35s\n" "🔑 Change Password"
        printf "  ${C_GREEN}[ 2]${C_RESET} %-35s\n" "🗓️ Change Expiration Date"
        printf "  ${C_GREEN}[ 3]${C_RESET} %-35s\n" "📶 Change Connection Limit"
        printf "  ${C_GREEN}[ 4]${C_RESET} %-35s\n" "📦 Change Bandwidth Limit"
        printf "  ${C_GREEN}[ 5]${C_RESET} %-35s\n" "🔄 Reset Bandwidth Counter"
        printf "  ${C_GREEN}[ 6]${C_RESET} %-35s\n" "🔒 Add HWID device(s)"
        printf "  ${C_GREEN}[ 7]${C_RESET} %-35s\n" "🧹 Remove HWID device(s)"
        printf "  ${C_GREEN}[ 8]${C_RESET} %-35s\n" "🛡️ Toggle Strict Enforcement"
        printf "  ${C_GREEN}[ 9]${C_RESET} %-35s\n" "🔁 Enable / Disable a device"
        printf "  ${C_GREEN}[10]${C_RESET} %-35s\n" "📱 Change Target App Type"
        echo -e "\n  ${C_RED}[ 0]${C_RESET} ✅ Finish Editing"
        echo
        if ! read -r -p "👉 Enter your choice: " edit_choice; then
            echo
            return
        fi
        case $edit_choice in
            1)
               local new_pass=""
               read -p "Enter new password (or press Enter for auto-generated): " new_pass
               if [[ -z "$new_pass" ]]; then
                   new_pass=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 8)
                   echo -e "${C_GREEN}🔑 Auto-generated: ${C_YELLOW}$new_pass${C_RESET}"
               fi
                echo "$username:$new_pass" | chpasswd
                db_set_user "$username" "$new_pass" "$cur_expiry" "$cur_limit" "$cur_bw" "$cur_marker" "$cur_hwid" "$cur_strict" "$cur_app"
                 # Password is part of the enforcer's identity match for ZiVPN, so resync.
                hwid_sync_allowed_db
                if [[ "$cur_app" == "zivpn" ]] && _ff_zivpn_add_pass "$new_pass"; then
                    systemctl is-active --quiet zivpn 2>/dev/null && systemctl try-restart zivpn.service 2>/dev/null
                fi
                echo -e "\n${C_GREEN}✅ Password for '$username' changed to: ${C_YELLOW}$new_pass${C_RESET}"
               ;;
            2) read -p "Enter new duration (in days from today): " days
               if [[ "$days" =~ ^[0-9]+$ ]]; then
                   local new_expire_date; new_expire_date=$(date -d "+$days days" +%Y-%m-%d); chage -E "$new_expire_date" "$username"
                   # Manually setting a date promotes a trial to a normal account:
                   # drop the trial marker and its precise-expiry timestamp.
                   rm -f "$TRIAL_EXPIRY_DIR/${username}.ts"
                   cur_marker=""
                    db_set_user "$username" "$cur_pass" "$new_expire_date" "$cur_limit" "$cur_bw" "$cur_marker" "$cur_hwid" "$cur_strict" "$cur_app"
                    echo -e "\n${C_GREEN}✅ Expiration for '$username' set to ${C_YELLOW}$new_expire_date${C_RESET}."
               else echo -e "\n${C_RED}❌ Invalid number of days.${C_RESET}"; fi ;;
            3) read -p "Enter new simultaneous connection limit: " new_limit
               if [[ "$new_limit" =~ ^[0-9]+$ ]]; then
                    db_set_user "$username" "$cur_pass" "$cur_expiry" "$new_limit" "$cur_bw" "$cur_marker" "$cur_hwid" "$cur_strict" "$cur_app"
                    echo -e "\n${C_GREEN}✅ Connection limit for '$username' set to ${C_YELLOW}$new_limit${C_RESET}."
               else echo -e "\n${C_RED}❌ Invalid limit.${C_RESET}"; fi ;;
            4) read -p "Enter new bandwidth limit in GB (0 = unlimited): " new_bw
               if [[ "$new_bw" =~ ^[0-9]+\.?[0-9]*$ ]]; then
                    db_set_user "$username" "$cur_pass" "$cur_expiry" "$cur_limit" "$new_bw" "$cur_marker" "$cur_hwid" "$cur_strict" "$cur_app"
                    local bw_msg="Unlimited"; [[ "$new_bw" != "0" ]] && bw_msg="${new_bw} GB"
                   echo -e "\n${C_GREEN}✅ Bandwidth limit for '$username' set to ${C_YELLOW}$bw_msg${C_RESET}."
                   # Unlock user if they were locked due to bandwidth
                   if [[ "$new_bw" == "0" ]] || [[ -f "$BANDWIDTH_DIR/${username}.usage" ]]; then
                       local used_bytes; used_bytes=$(cat "$BANDWIDTH_DIR/${username}.usage" 2>/dev/null || echo 0)
                       local new_quota_bytes; new_quota_bytes=$(awk "BEGIN {printf \"%.0f\", $new_bw * 1073741824}")
                       if [[ "$new_bw" == "0" ]] || [[ "$used_bytes" -lt "$new_quota_bytes" ]]; then
                           _ff_restore_user_all_protocols "$username"
                       fi
                   fi
               else echo -e "\n${C_RED}❌ Invalid bandwidth value.${C_RESET}"; fi ;;
            5)
               echo "0" > "$BANDWIDTH_DIR/${username}.usage"
               # Unlock user if they were locked due to bandwidth (all protocols).
               _ff_restore_user_all_protocols "$username"
               echo -e "\n${C_GREEN}✅ Bandwidth counter for '$username' has been reset to 0.${C_RESET}"
               ;;
            6) local add_hwid="" merged="" new_strict="$cur_strict"
               echo -e "${C_DIM}Paste the device HWID shown in the client VPN app.${C_RESET}"
               echo -e "${C_DIM}Separate multiple devices with commas (e.g. hwidA,hwidB).${C_RESET}"
               read -p "🔒 Enter HWID(s) to ADD for '$username': " add_hwid
               add_hwid=$(_ff_normalize_hwids "$add_hwid")
               if [[ -z "$add_hwid" ]]; then
                   echo -e "\n${C_YELLOW}⚠️ No HWID entered — unchanged. Use [7] to remove a device.${C_RESET}"
               else
                   if [[ -n "$cur_hwid" ]]; then
                       local repl="n"
                       read -p "🔁 Replace existing HWID(s) instead of adding? (y/N): " repl
                       if [[ "$repl" == "y" || "$repl" == "Y" ]]; then
                           merged="$add_hwid"
                       else
                           merged=$(_ff_normalize_hwids "${cur_hwid},${add_hwid}")
                       fi
                   else
                       merged="$add_hwid"
                   fi
                   # Strict is a per-user flag. Ask only when the user had no HWIDs
                   # before; when growing an existing set, added devices inherit it.
                   if [[ -z "$cur_hwid" ]]; then
                       local s_choice="y"
                       read -p "🛡️ Strict-enforce these device(s) now? (y/n) [y]: " s_choice
                       s_choice=${s_choice:-y}
                       new_strict=0; [[ "$s_choice" == "y" || "$s_choice" == "Y" ]] && new_strict=1
                   else
                       local inh="off"; [[ "$cur_strict" == "1" ]] && inh="ON"
                       echo -e "${C_DIM}ℹ️ Added device(s) inherit current strict enforcement: ${inh}.${C_RESET}"
                   fi
                    db_set_user "$username" "$cur_pass" "$cur_expiry" "$cur_limit" "$cur_bw" "$cur_marker" "$merged" "$new_strict" "$cur_app"
                    cur_hwid="$merged"; cur_strict="$new_strict"
                   hwid_sync_allowed_db
                   # A freshly-assigned device shouldn't stay blocked from a prior session.
                   _ff_unblock_user_traffic "$username"
                   echo -e "\n${C_GREEN}✅ HWID(s) for '$username': ${C_YELLOW}$(_ff_hwid_label "$cur_hwid" "$cur_strict" strict)${C_RESET}"
                   if ! systemctl is-active --quiet skylartech-hwid-enforcer 2>/dev/null; then
                       echo -e "${C_DIM}ℹ️ Global HWID Lock is OFF — enable it in Protocol Manager to enforce.${C_RESET}"
                   fi
               fi ;;
            7) if [[ -z "$cur_hwid" ]]; then
                   echo -e "\n${C_YELLOW}ℹ️ '$username' has no HWID set.${C_RESET}"
               else
                   _ff_hwid_parse "$cur_hwid"
                   echo -e "\n${C_DIM}Registered devices for '$username':${C_RESET}"
                   local i badge
                   for i in "${!FF_HWID_IDS[@]}"; do
                       if [[ "${FF_HWID_STATES[$i]}" == "off" ]]; then badge="${C_DIM}⚪ disabled${C_RESET}"; else badge="${C_GREEN}🟢 enabled${C_RESET}"; fi
                       printf "  ${C_GREEN}[%d]${C_RESET} %-24s %b\n" "$((i+1))" "${FF_HWID_IDS[$i]}" "$badge"
                   done
                   echo -e "${C_DIM}Enter number(s) to remove (e.g. 1 3), or 'all' to clear every device.${C_RESET}"
                   local sel; read -p "🧹 Remove which device(s)? " sel
                   if [[ -z "$sel" ]]; then
                       echo -e "\n${C_YELLOW}⚠️ Nothing entered — no devices removed.${C_RESET}"
                   else
                       local -A drop_idx=()
                       local remaining=""
                       if [[ "$sel" == "all" || "$sel" == "ALL" ]]; then
                           remaining=""
                       else
                           local tok
                           for tok in $sel; do
                               [[ "$tok" =~ ^[0-9]+$ ]] && drop_idx["$tok"]=1
                           done
                           for i in "${!FF_HWID_IDS[@]}"; do
                               [[ -n "${drop_idx[$((i+1))]+x}" ]] && continue
                               [[ -n "$remaining" ]] && remaining+=","
                               [[ "${FF_HWID_STATES[$i]}" == "off" ]] && remaining+="!"
                               remaining+="${FF_HWID_IDS[$i]}"
                           done
                       fi
                       remaining=$(_ff_normalize_hwids "$remaining")
                       if [[ "$remaining" == "$cur_hwid" ]]; then
                           echo -e "\n${C_YELLOW}⚠️ No valid selection — nothing removed.${C_RESET}"
                       else
                           local new_strict="$cur_strict"
                           [[ -z "$remaining" ]] && new_strict="0"
                            db_set_user "$username" "$cur_pass" "$cur_expiry" "$cur_limit" "$cur_bw" "$cur_marker" "$remaining" "$new_strict" "$cur_app"
                            cur_hwid="$remaining"; cur_strict="$new_strict"
                           hwid_sync_allowed_db
                           _ff_unblock_user_traffic "$username"
                           # Clear lingering IP drops; enforcer re-adds within seconds
                           # for any device still in violation of the remaining list.
                           _hwid_flush_drops
                           if [[ -z "$cur_hwid" ]]; then
                               echo -e "\n${C_GREEN}✅ All HWIDs removed for '$username'. Device lock cleared (multi-device allowed).${C_RESET}"
                           else
                               echo -e "\n${C_GREEN}✅ HWID(s) for '$username' now: ${C_YELLOW}$(_ff_hwid_label "$cur_hwid" "$cur_strict" strict)${C_RESET}"
                           fi
                       fi
                   fi
               fi ;;
            8) if [[ -z "$cur_hwid" ]]; then
                   echo -e "\n${C_YELLOW}⚠️ Assign an HWID first ([6]) before toggling strict enforcement.${C_RESET}"
               else
                   local new_strict=1; [[ "$cur_strict" == "1" ]] && new_strict=0
                    db_set_user "$username" "$cur_pass" "$cur_expiry" "$cur_limit" "$cur_bw" "$cur_marker" "$cur_hwid" "$new_strict" "$cur_app"
                    cur_strict="$new_strict"
                    hwid_sync_allowed_db
                   [[ "$new_strict" == "0" ]] && { _ff_unblock_user_traffic "$username"; _hwid_flush_drops; }
                   local st_msg="OFF"; [[ "$new_strict" == "1" ]] && st_msg="ON"
                   echo -e "\n${C_GREEN}✅ Strict enforcement for '$username' is now ${C_YELLOW}${st_msg}${C_GREEN}.${C_RESET}"
               fi ;;
            9) if [[ -z "$cur_hwid" ]]; then
                   echo -e "\n${C_YELLOW}ℹ️ '$username' has no HWID set. Add one with [6] first.${C_RESET}"
               else
                   _ff_hwid_parse "$cur_hwid"
                   echo -e "\n${C_DIM}Registered devices for '$username':${C_RESET}"
                   local i badge
                   for i in "${!FF_HWID_IDS[@]}"; do
                       if [[ "${FF_HWID_STATES[$i]}" == "off" ]]; then badge="${C_DIM}⚪ disabled${C_RESET}"; else badge="${C_GREEN}🟢 enabled${C_RESET}"; fi
                       printf "  ${C_GREEN}[%d]${C_RESET} %-24s %b\n" "$((i+1))" "${FF_HWID_IDS[$i]}" "$badge"
                   done
                   local pick; read -p "🔁 Toggle which device on/off? (number) " pick
                   if ! [[ "$pick" =~ ^[0-9]+$ ]] || (( pick < 1 || pick > ${#FF_HWID_IDS[@]} )); then
                       echo -e "\n${C_RED}❌ Invalid device number.${C_RESET}"
                   else
                       local idx=$((pick-1)) was="${FF_HWID_STATES[$((pick-1))]}" devid="${FF_HWID_IDS[$((pick-1))]}"
                       local disabling=false
                       if [[ "$was" == "on" ]]; then FF_HWID_STATES[$idx]="off"; disabling=true; else FF_HWID_STATES[$idx]="on"; fi
                        cur_hwid=$(_ff_hwid_join)
                        db_set_user "$username" "$cur_pass" "$cur_expiry" "$cur_limit" "$cur_bw" "$cur_marker" "$cur_hwid" "$cur_strict" "$cur_app"
                        hwid_sync_allowed_db
                       # Count remaining enabled devices for the warning below.
                       local still_enabled=0
                       for i in "${!FF_HWID_STATES[@]}"; do [[ "${FF_HWID_STATES[$i]}" == "on" ]] && still_enabled=$((still_enabled+1)); done
                       if $disabling; then
                           echo -e "\n${C_GREEN}✅ Device ${C_YELLOW}${devid}${C_GREEN} is now ${C_RED}DISABLED${C_GREEN}.${C_RESET}"
                           # Instant cutoff: bounce the UDP relays so the just-disabled
                           # device re-handshakes and is dropped by the enforcer at once.
                            if [[ "$cur_strict" == "1" ]] && systemctl is-active --quiet skylartech-hwid-enforcer 2>/dev/null; then
                                local -a blip=()
                                systemctl is-active --quiet udp-custom 2>/dev/null && blip+=(udp-custom)
                                systemctl is-active --quiet badvpn 2>/dev/null && blip+=(badvpn)
                                systemctl is-active --quiet udpgw 2>/dev/null && blip+=(udpgw)
                                systemctl is-active --quiet zivpn 2>/dev/null && blip+=(zivpn)
                                if [[ ${#blip[@]} -gt 0 ]]; then
                                    echo -e "${C_DIM}⚡ Bouncing UDP relays (${blip[*]}) — all UDP users blip ~0.3s; the disabled device is cut now.${C_RESET}"
                                    _ff_udp_session_blip "${blip[@]}"
                                fi
                               if (( still_enabled == 0 )); then
                                   echo -e "${C_YELLOW}⚠️ No enabled devices remain — '$username' is now effectively un-enforced (multi-device) until you re-enable a device or turn strict off.${C_RESET}"
                               fi
                           fi
                       else
                           echo -e "\n${C_GREEN}✅ Device ${C_YELLOW}${devid}${C_GREEN} is now ${C_GREEN}ENABLED${C_GREEN}.${C_RESET}"
                           # Clear any stale enforcer drop so the device can reconnect now.
                           _ff_unblock_user_traffic "$username"
                           _hwid_flush_drops
                       fi
                    fi
                fi ;;
             10) local new_app="$cur_app"
                 echo -e "\n${C_DIM}Current target app: ${app_display}${C_RESET}"
                 echo -e "${C_DIM}Select new application type:${C_RESET}"
                 printf "  ${C_GREEN}[1]${C_RESET} HTTP Custom\n"
                 printf "  ${C_GREEN}[2]${C_RESET} ZiVPN\n"
                 read -p "👉 App type [1]: " app_choice
                 app_choice=${app_choice:-1}
                 case "$app_choice" in
                     2|z|Z|zivpn|ZiVPN) new_app="zivpn" ;;
                     *) new_app="http" ;;
                 esac
                  db_set_user "$username" "$cur_pass" "$cur_expiry" "$cur_limit" "$cur_bw" "$cur_marker" "$cur_hwid" "$cur_strict" "$new_app"
                 # Sync ZiVPN auth list when app type changes.
                 if [[ "$new_app" != "$cur_app" ]]; then
                     if [[ "$new_app" == "zivpn" ]]; then
                         _ff_zivpn_add_pass "$cur_pass"
                     elif [[ "$cur_app" == "zivpn" && -f "$ZIVPN_CONFIG_FILE" ]] && command -v jq &>/dev/null; then
                         local tmp; tmp=$(mktemp) 2>/dev/null || true
                         if [[ -n "$tmp" ]]; then
                             jq --arg p "$cur_pass" '.auth.config |= map(select(. != $p))' "$ZIVPN_CONFIG_FILE" > "$tmp" 2>/dev/null && mv "$tmp" "$ZIVPN_CONFIG_FILE"
                             rm -f "$tmp" 2>/dev/null
                         fi
                     fi
                     systemctl is-active --quiet zivpn 2>/dev/null && systemctl try-restart zivpn.service 2>/dev/null
                 fi
                 cur_app="$new_app"
                 echo -e "\n${C_GREEN}✅ Target app for '$username' changed to ${C_YELLOW}$new_app${C_RESET}"
                 ;;
             0) return ;;
             *) echo -e "\n${C_RED}❌ Invalid option.${C_RESET}" ;;
        esac
        echo -e "\nPress ${C_YELLOW}[Enter]${C_RESET} to continue editing..." && read -r || return
    done
}

# --- Immediate per-user network cutoff ------------------------------------
# Drop every packet owned by a user's UID so live SSH / SSH-tunnel sessions die
# at once instead of waiting for the 30s limiter pass. The owner match applies
# to locally-generated (OUTPUT) traffic, severing the return path for any
# session the user's own processes carry.
# NOTE: udp-custom / zivpn / badvpn run as root, so their *live* sessions are
# not user-owned and cannot be singled out here; the usermod -L password lock
# blocks any new or re-authenticated UDP connection immediately.
_ff_block_user_traffic() {
    local user="$1" uid ipt
    command -v iptables &>/dev/null || return 0
    uid=$(id -u "$user" 2>/dev/null) || return 0
    [[ "$uid" =~ ^[0-9]+$ ]] || return 0
    for ipt in iptables ip6tables; do
        command -v "$ipt" &>/dev/null || continue
        # Delete first (idempotent), then insert at the top of OUTPUT.
        "$ipt" -D OUTPUT -m owner --uid-owner "$uid" -j DROP 2>/dev/null
        "$ipt" -I OUTPUT -m owner --uid-owner "$uid" -j DROP 2>/dev/null
    done
}

_ff_unblock_user_traffic() {
    local user="$1" uid ipt
    command -v iptables &>/dev/null || return 0
    uid=$(id -u "$user" 2>/dev/null) || return 0
    [[ "$uid" =~ ^[0-9]+$ ]] || return 0
    for ipt in iptables ip6tables; do
        command -v "$ipt" &>/dev/null || continue
        # Remove every copy of the rule in case duplicates accumulated.
        while "$ipt" -D OUTPUT -m owner --uid-owner "$uid" -j DROP 2>/dev/null; do :; done
    done
}

_ff_kill_user_sessions() {
    local user="$1"
    killall -u "$user" -9 &>/dev/null
    pkill -9 -u "$user" &>/dev/null
}

# Restart udp-custom to forcibly drop a locked user's already-live UDP session.
# udp-custom authenticates against the system shadow DB, so once usermod -L has
# run the locked user cannot re-authenticate; other clients auto-reconnect after
# the brief (~0.3s) restart. try-restart is a no-op when the service is stopped.
# ZiVPN is intentionally excluded: it uses its own password list, not system
# users, so a system-user lock has no bearing on it.
_ff_fast_restart_udp() {
    systemctl try-restart udp-custom.service 2>/dev/null
}

# --- Cross-protocol "very fast blip" UDP session kill -----------------------
# UDP relays (udp-custom / zivpn / udpgw) run as root, so a locked user's LIVE
# session is not user-owned and cannot be dropped by UID match or pkill. The only
# reliable, immediate lever is to bounce the relay: every client re-handshakes,
# and a locked user fails re-auth (shadow lock for udp-custom; password removed
# from config.json for zivpn). conntrack is flushed first so stale UDP/NAT state
# is gone the instant the relay comes back. The blip is ~0.3s; healthy users
# reconnect automatically. Pass the services to bounce as args.
_ff_udp_session_blip() {
    local svc port
    local -a targets=("$@")
    [[ ${#targets[@]} -eq 0 ]] && targets=(udp-custom zivpn)

    # 1) Flush conntrack for the relay listen ports so kernel state dies at once.
    if command -v conntrack &>/dev/null; then
        for svc in "${targets[@]}"; do
            case "$svc" in
                udp-custom) port="$UDP_CUSTOM_LISTEN_PORT" ;;
                zivpn)      port="$ZIVPN_LISTEN_PORT" ;;
                badvpn)     port="$BADVPN_LISTEN_PORT" ;;
                udpgw)      port="" ;;  # localhost only, no external port to flush
                *)          port="" ;;
            esac
            [[ -n "$port" ]] && conntrack -D -p udp --dport "$port" &>/dev/null
        done
        # ZiVPN also accepts the 6000-19999 range (DNAT -> 5667); clear those too.
        if printf '%s\n' "${targets[@]}" | grep -qx zivpn; then
            conntrack -D -p udp --dport 6000:19999 &>/dev/null || true
        fi
    fi

    # 2) Bounce only the relays that are actually running (fast blip).
    for svc in "${targets[@]}"; do
        systemctl is-active --quiet "$svc" 2>/dev/null && \
            systemctl try-restart "${svc}.service" 2>/dev/null
    done
}

# Remove a user's password from the ZiVPN auth list (config.json) so a ZiVPN
# client using those credentials can no longer authenticate. Records what was
# removed under ZIVPN_LOCK_DIR so unlock can restore it precisely.
# Echoes "changed" when the config was actually modified.
_ff_zivpn_lock_user() {
    local user="$1" pass
    [[ -f "$ZIVPN_CONFIG_FILE" ]] || return 1
    command -v jq &>/dev/null || return 1
    pass=$(db_get_field "$user" 2)
    [[ -n "$pass" ]] || return 1
    # Only act if this password is actually present in the auth list.
    jq -e --arg p "$pass" '.auth.config | index($p) != null' "$ZIVPN_CONFIG_FILE" &>/dev/null || return 1
    local tmp; tmp=$(mktemp) || return 1
    if jq --arg p "$pass" '.auth.config |= map(select(. != $p))' "$ZIVPN_CONFIG_FILE" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$ZIVPN_CONFIG_FILE"
        mkdir -p "$ZIVPN_LOCK_DIR" 2>/dev/null
        printf '%s' "$pass" > "$ZIVPN_LOCK_DIR/${user}"
        echo "changed"; return 0
    fi
    rm -f "$tmp" 2>/dev/null
    return 1
}

# Restore a user's ZiVPN password that lock previously removed.
# Echoes "changed" when the config was actually modified.
_ff_zivpn_unlock_user() {
    local user="$1" pass marker="$ZIVPN_LOCK_DIR/${user}"
    [[ -f "$marker" ]] || return 1
    pass=$(cat "$marker" 2>/dev/null)
    rm -f "$marker" 2>/dev/null
    [[ -n "$pass" ]] || return 1
    [[ -f "$ZIVPN_CONFIG_FILE" ]] || return 1
    command -v jq &>/dev/null || return 1
    # Skip if it somehow already came back.
    if jq -e --arg p "$pass" '.auth.config | index($p) != null' "$ZIVPN_CONFIG_FILE" &>/dev/null; then
        return 1
    fi
    local tmp; tmp=$(mktemp) || return 1
    if jq --arg p "$pass" '.auth.config += [$p]' "$ZIVPN_CONFIG_FILE" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$ZIVPN_CONFIG_FILE"
        echo "changed"; return 0
    fi
    rm -f "$tmp" 2>/dev/null
    return 1
}

# Single-user "fully restore access" used by renew / edit-user unlock paths:
# clear the SSH/traffic block, restore any ZiVPN password that lock removed, and
# reload zivpn only when that actually changed the auth list.
_ff_restore_user_all_protocols() {
    local u="$1"
    usermod -U "$u" &>/dev/null
    _ff_unblock_user_traffic "$u"
    if [[ "$(_ff_zivpn_unlock_user "$u")" == "changed" ]]; then
        systemctl is-active --quiet zivpn 2>/dev/null && systemctl try-restart zivpn.service 2>/dev/null
    fi
    systemctl is-active --quiet udp-custom 2>/dev/null && systemctl try-restart udp-custom.service 2>/dev/null
}

lock_user() {
    _select_multi_user_interface "--- 🔒 Lock Users (from DB) ---"
    if [[ ${#SELECTED_USERS[@]} -eq 0 || "${SELECTED_USERS[0]}" == "NO_USERS" ]]; then return; fi

    echo -e "\n${C_BLUE}🔒 Locking selected users...${C_RESET}"
    local any_locked=false zivpn_changed=false
    for u in "${SELECTED_USERS[@]}"; do
        if ! id "$u" &>/dev/null; then
             echo -e " ❌ User '${C_YELLOW}$u${C_RESET}' does not exist on this system."
             continue
        fi

        usermod -L "$u"
        if [ $? -eq 0 ]; then
            # SSH + udp-custom: shadow lock blocks re-auth; drop owned traffic and
            # kill the user's own processes (SSH / SSH-tunnel sessions) instantly.
            _ff_block_user_traffic "$u"
            _ff_kill_user_sessions "$u"
            # ZiVPN: pull the password from the auth list (system lock can't touch it).
            [[ "$(_ff_zivpn_lock_user "$u")" == "changed" ]] && zivpn_changed=true
            any_locked=true
            echo -e " ✅ ${C_YELLOW}$u${C_RESET} locked — SSH/UDP auth blocked, owned sessions killed."
        else
            echo -e " ❌ Failed to lock ${C_YELLOW}$u${C_RESET}."
        fi
    done

    # One fast blip for the whole batch so live root-owned UDP sessions die now.
    # udp-custom: any FF user can auth against shadow, so we can't know which
    # locked user holds a live session — bounce it whenever it's running.
    # zivpn: identity is the password, so we only bounce it when we actually
    # removed a locked user's password (no collateral drop for other zivpn users).
    if [[ "$any_locked" == true ]]; then
        local -a blip=()
        systemctl is-active --quiet udp-custom 2>/dev/null && blip+=(udp-custom)
        systemctl is-active --quiet badvpn 2>/dev/null && blip+=(badvpn)
        systemctl is-active --quiet udpgw 2>/dev/null && blip+=(udpgw)
        [[ "$zivpn_changed" == true ]] && blip+=(zivpn)
        if [[ ${#blip[@]} -gt 0 ]]; then
            echo -e "${C_DIM}⚡ Dropping live UDP sessions (fast blip: ${blip[*]})...${C_RESET}"
            _ff_udp_session_blip "${blip[@]}"
        fi
    fi
}

unlock_user() {
    _select_multi_user_interface "--- 🔓 Unlock Users (from DB) ---"
    if [[ ${#SELECTED_USERS[@]} -eq 0 || "${SELECTED_USERS[0]}" == "NO_USERS" ]]; then return; fi

    echo -e "\n${C_BLUE}🔓 Unlocking selected users...${C_RESET}"
    local zivpn_changed=false
    for u in "${SELECTED_USERS[@]}"; do
        if ! id "$u" &>/dev/null; then
             echo -e " ❌ User '${C_YELLOW}$u${C_RESET}' does not exist on this system."
             continue
        fi

        usermod -U "$u"
        if [ $? -eq 0 ]; then
            _ff_unblock_user_traffic "$u"
            # ZiVPN: restore the password we removed at lock time, if any.
            [[ "$(_ff_zivpn_unlock_user "$u")" == "changed" ]] && zivpn_changed=true
            echo -e " ✅ ${C_YELLOW}$u${C_RESET} unlocked — can reconnect immediately (all protocols)."
        else
            echo -e " ❌ Failed to unlock ${C_YELLOW}$u${C_RESET}."
        fi
    done

    # Reload ZiVPN so restored passwords take effect.
    if [[ "$zivpn_changed" == true ]] && systemctl is-active --quiet zivpn 2>/dev/null; then
        systemctl try-restart zivpn.service 2>/dev/null
    fi
    # Restart udp-custom to clear any stale shadow-auth cache from the lock period.
    systemctl is-active --quiet udp-custom 2>/dev/null && systemctl try-restart udp-custom.service 2>/dev/null
}

# Compact "days left until expiry" string for an expiry date (YYYY-MM-DD), given
# the current epoch. Echoes "Never" / "Expired" / "<1d" / "${n}d".
_ff_days_left_str() {
    local expiry="$1" now="$2" ts diff d
    [[ -z "$expiry" || "$expiry" == "Never" ]] && { printf 'Never'; return; }
    ts=$(date -d "$expiry" +%s 2>/dev/null || echo 0)
    [[ "$ts" =~ ^[0-9]+$ ]] && (( ts > 0 )) || { printf 'N/A'; return; }
    diff=$(( ts - now ))
    (( diff <= 0 )) && { printf 'Expired'; return; }
    d=$(( diff / 86400 ))
    (( d == 0 )) && { printf '<1d'; return; }
    printf '%dd' "$d"
}

# Pick a color for a days-left string produced by _ff_days_left_str.
_ff_days_left_color() {
    local s="$1"
    case "$s" in
        Never)   printf '%s' "$C_DIM" ;;
        Expired) printf '%s' "$C_RED" ;;
        "<1d")   printf '%s' "$C_RED" ;;
        N/A)     printf '%s' "$C_DIM" ;;
        *) local n="${s%d}"
           if [[ "$n" =~ ^[0-9]+$ ]] && (( n <= 3 )); then printf '%s' "$C_RED"
           elif [[ "$n" =~ ^[0-9]+$ ]] && (( n <= 7 )); then printf '%s' "$C_YELLOW"
           else printf '%s' "$C_GREEN"; fi ;;
    esac
}

list_users() {
    clear; show_banner
    if [[ ! -s "$DB_FILE" ]]; then
        echo -e "\n${C_YELLOW}ℹ️ No users are currently being managed.${C_RESET}"
        return
    fi
    echo -e "${C_BOLD}${C_PURPLE}--- 📋 Managed Users ---${C_RESET}"
    echo -e "${C_CYAN}=====================================================================================================${C_RESET}"
    printf "${C_BOLD}${C_WHITE}%-18s | %-12s | %-10s | %-10s | %-15s | %-20s${C_RESET}\n" "USERNAME" "EXPIRES" "DAYS LEFT" "CONNS" "BANDWIDTH" "STATUS"
    echo -e "${C_CYAN}-----------------------------------------------------------------------------------------------------${C_RESET}"

    local current_ts
    printf -v current_ts '%(%s)T' -1
    local -A system_user_lookup=()
    local -A locked_user_lookup=()

    while IFS=: read -r system_user _rest; do
        [[ -n "$system_user" ]] && system_user_lookup["$system_user"]=1
    done < /etc/passwd

    if [[ -r /etc/shadow ]]; then
        while IFS=: read -r shadow_user shadow_hash _rest; do
            [[ -n "$shadow_user" && "${shadow_hash:0:1}" == "!" ]] && locked_user_lookup["$shadow_user"]=1
        done < /etc/shadow
    else
        while read -r passwd_user _ passwd_status _rest; do
            [[ -z "$passwd_user" ]] && continue
            [[ "$passwd_status" == "L" ]] && locked_user_lookup["$passwd_user"]=1
        done < <(passwd -Sa 2>/dev/null)
    fi
    refresh_ssh_session_cache

    while IFS=: read -r user pass expiry limit bandwidth_gb _extra; do
        local online_count="${SSH_SESSION_COUNTS[$user]:-0}"
        local connection_string="$online_count / $limit"
        local plain_status="Active"
        local status="${C_GREEN}🟢 Active${C_RESET}"
        local quota_exceeded=false

        [[ -z "$bandwidth_gb" ]] && bandwidth_gb="0"
        local bw_string="Unlimited"
        if [[ "$bandwidth_gb" != "0" ]]; then
            local used_bytes=0
            if [[ -f "$BANDWIDTH_DIR/${user}.usage" ]]; then
                read -r used_bytes < "$BANDWIDTH_DIR/${user}.usage" 2>/dev/null || used_bytes=0
                [[ "$used_bytes" =~ ^[0-9]+$ ]] || used_bytes=0
            fi
            local used_gb
            used_gb=$(awk "BEGIN {printf \"%.1f\", $used_bytes / 1073741824}")
            bw_string="${used_gb}/${bandwidth_gb}GB"
            local quota_bytes
            quota_bytes=$(awk "BEGIN {printf \"%.0f\", $bandwidth_gb * 1073741824}")
            if [[ "$quota_bytes" =~ ^[0-9]+$ ]] && (( used_bytes >= quota_bytes )); then
                quota_exceeded=true
            fi
        fi

        if [[ -z "${system_user_lookup[$user]+x}" ]]; then
            plain_status="Not Found"
            status="${C_RED}Not Found${C_RESET}"
        elif [[ -n "$expiry" && "$expiry" != "Never" ]]; then
            local expiry_ts
            expiry_ts=$(date -d "$expiry" +%s 2>/dev/null || echo 0)
            if [[ "$expiry_ts" =~ ^[0-9]+$ ]] && (( expiry_ts > 0 && expiry_ts < current_ts )); then
                plain_status="Expired"
                status="${C_RED}🗓️ Expired${C_RESET}"
            fi
        fi

        if [[ "$plain_status" == "Active" && "$quota_exceeded" == true ]]; then
            if [[ -n "${locked_user_lookup[$user]+x}" ]]; then
                plain_status="BW Locked"
                status="${C_RED}🔒 BW Locked${C_RESET}"
            else
                plain_status="Quota Exceeded"
                status="${C_RED}📦 Quota Exceeded${C_RESET}"
            fi
        elif [[ "$plain_status" == "Active" && -n "${locked_user_lookup[$user]+x}" ]]; then
            plain_status="Locked"
            status="${C_YELLOW}🔒 Locked${C_RESET}"
        fi

        local line_color="$C_WHITE"
        case "$plain_status" in
            "Active") line_color="$C_GREEN" ;;
            "Locked") line_color="$C_YELLOW" ;;
            "Expired") line_color="$C_RED" ;;
            "BW Locked") line_color="$C_RED" ;;
            "Quota Exceeded") line_color="$C_RED" ;;
            "Not Found") line_color="$C_DIM" ;;
        esac

        local days_left_disp; days_left_disp=$(_ff_days_left_str "$expiry" "$current_ts")
        local days_left_color; days_left_color=$(_ff_days_left_color "$days_left_disp")

        printf "${line_color}%-18s ${C_RESET}| ${C_YELLOW}%-12s ${C_RESET}| ${days_left_color}%-10s ${C_RESET}| ${C_CYAN}%-10s ${C_RESET}| ${C_ORANGE}%-15s ${C_RESET}| %-20s\n" "$user" "$expiry" "$days_left_disp" "$connection_string" "$bw_string" "$status"
    done < <(sort "$DB_FILE")
    echo -e "${C_CYAN}=====================================================================================================${C_RESET}\n"
}

renew_user() {
    _select_multi_user_interface "--- 🔄 Renew Users ---"
    if [[ ${#SELECTED_USERS[@]} -eq 0 || "${SELECTED_USERS[0]}" == "NO_USERS" ]]; then return; fi
    read -p "👉 Enter number of days to extend the account(s): " days; if ! [[ "$days" =~ ^[0-9]+$ ]]; then echo -e "\n${C_RED}❌ Invalid number.${C_RESET}"; return; fi
    local new_expire_date; new_expire_date=$(date -d "+$days days" +%Y-%m-%d)
    
    echo -e "\n${C_BLUE}🔄 Renewing selected users for $days days...${C_RESET}"
    for u in "${SELECTED_USERS[@]}"; do
        chage -E "$new_expire_date" "$u"
        local line pass _expiry limit bw marker hwid strict app
        line=$(grep "^$u:" "$DB_FILE")
        IFS=: read -r _ pass _expiry limit bw marker hwid strict app <<< "$line"
        [[ -z "$bw" ]] && bw="0"
        [[ -z "$strict" ]] && strict="0"
        [[ -z "$app" ]] && app="http"
        # Renewing for a fixed number of days promotes a trial to a normal
        # dated account: drop the trial marker and precise-expiry timestamp.
        rm -f "$TRIAL_EXPIRY_DIR/${u}.ts"
        db_set_user "$u" "$pass" "$new_expire_date" "$limit" "$bw" "" "$hwid" "$strict" "$app"
        # Restore access immediately in case the account was auto-locked/blocked
        # for expiry before this renewal (SSH + UDP, incl. ZiVPN password).
        _ff_restore_user_all_protocols "$u"
        echo -e " ✅ ${C_YELLOW}$u${C_RESET} renewed until ${C_GREEN}${new_expire_date}${C_RESET}."
    done
}

cleanup_expired() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🧹 Cleanup Expired Users ---${C_RESET}"
    
    local expired_users=()
    local current_ts
    current_ts=$(date +%s)

    if [[ ! -s "$DB_FILE" ]]; then
        echo -e "\n${C_GREEN}✅ User database is empty. No expired users found.${C_RESET}"
        return
    fi
    
    while IFS=: read -r user pass expiry limit bandwidth_gb _extra; do
        local expiry_ts
        expiry_ts=$(date -d "$expiry" +%s 2>/dev/null || echo 0)
        
        if [[ $expiry_ts -lt $current_ts && $expiry_ts -ne 0 ]]; then
            expired_users+=("$user")
        fi
    done < "$DB_FILE"

    if [ ${#expired_users[@]} -eq 0 ]; then
        echo -e "\n${C_GREEN}✅ No expired users found.${C_RESET}"
        return
    fi

    echo -e "\nThe following users have expired: ${C_RED}${expired_users[*]}${C_RESET}"
    read -p "👉 Do you want to delete all of them? (y/n): " confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "\n${C_BLUE}🗑️ Deleting expired users...${C_RESET}"
        delete_skylartech_user_accounts "${expired_users[@]}"
        echo -e "\n${C_GREEN}✅ Expired users have been cleaned up.${C_RESET}"
    else
        echo -e "\n${C_YELLOW}❌ Cleanup cancelled.${C_RESET}"
    fi
}


backup_user_data() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 💾 Backup User Data ---${C_RESET}"
    if [ ! -d "$DB_DIR" ] || [ ! -s "$DB_FILE" ]; then
        echo -e "\n${C_YELLOW}ℹ️ No user data found to back up.${C_RESET}"
        return
    fi
    mkdir -p "$BACKUP_DIR"
    local auto_name="skylartech_users_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"
    local auto_path="$BACKUP_DIR/$auto_name"
    read -p "👉 Enter path or press Enter for auto-named backup [$auto_path]: " backup_path
    backup_path=${backup_path:-$auto_path}
    local parent_dir; parent_dir=$(dirname "$backup_path")
    mkdir -p "$parent_dir"
    echo -e "\n${C_BLUE}⚙️ Backing up user database and settings to ${C_YELLOW}$backup_path${C_RESET}..."
    tar -czf "$backup_path" -C "$(dirname "$DB_DIR")" "$(basename "$DB_DIR")"
    if [ $? -eq 0 ]; then
        echo -e "\n${C_GREEN}✅ SUCCESS: User data backup created at ${C_YELLOW}$backup_path${C_RESET}"
        echo -e "${C_DIM}   Size: $(du -h "$backup_path" | cut -f1)${C_RESET}"
    else
        echo -e "\n${C_RED}❌ ERROR: Backup failed.${C_RESET}"
    fi
}

restore_user_data() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 📥 Restore User Data ---${C_RESET}"

    local -a backups=()
    local dir f
    for dir in "$BACKUP_DIR" /root; do
        [[ -d "$dir" ]] || continue
        while IFS= read -r f; do
            [[ -n "$f" ]] && backups+=("$f")
        done < <(find "$dir" -maxdepth 1 -name 'skylartech_users*.tar.gz' -printf '%T@ %p\n' 2>/dev/null | sort -rn | cut -d' ' -f2-)
    done

    local backup_path=""
    if [[ ${#backups[@]} -gt 0 ]]; then
        echo -e "\n${C_DIM}Select a backup file or enter a custom path:${C_RESET}\n"
        local idx=0
        for f in "${backups[@]}"; do
            idx=$((idx + 1))
            local size; size=$(du -h "$f" 2>/dev/null | cut -f1)
            printf "     ${C_CHOICE}[%2s]${C_RESET}  %s  ${C_DIM}(%s)${C_RESET}\n" "$idx" "$f" "${size:-?}"
        done
        echo
        printf "     ${C_CHOICE}[ C]${C_RESET}  Enter custom path\n"
        printf "     ${C_WARN}[ 0]${C_RESET}  Cancel\n"
        echo
        read -p "$(echo -e ${C_PROMPT}"👉 Select option: "${C_RESET})" sel
        if [[ "$sel" == "0" ]]; then
            echo -e "\n${C_YELLOW}❌ Restore cancelled.${C_RESET}"; return
        fi
        if [[ "$sel" =~ ^[Cc]$ ]]; then
            read -p "👉 Enter the full path to the backup file: " backup_path
        elif [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#backups[@]} )); then
            backup_path="${backups[$((sel - 1))]}"
        else
            echo -e "\n${C_RED}❌ Invalid selection.${C_RESET}"; return
        fi
    else
        echo -e "\n${C_YELLOW}ℹ️ No saved backups found.${C_RESET}"
        read -p "👉 Enter the full path to the backup file: " backup_path
    fi

    [[ -z "$backup_path" ]] && { echo -e "\n${C_YELLOW}❌ No file selected.${C_RESET}"; return; }
    if [ ! -f "$backup_path" ]; then
        echo -e "\n${C_RED}❌ ERROR: Backup file not found at '$backup_path'.${C_RESET}"
        return
    fi
    echo -e "\n${C_RED}${C_BOLD}⚠️ WARNING:${C_RESET} This will overwrite all current users and settings."
    echo -e "It will restore user accounts, passwords, limits, and expiration dates from the backup file."
    read -p "👉 Are you absolutely sure you want to proceed? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then echo -e "\n${C_YELLOW}❌ Restore cancelled.${C_RESET}"; return; fi
    local temp_dir
    temp_dir=$(mktemp -d)
    echo -e "\n${C_BLUE}⚙️ Extracting backup file to a temporary location...${C_RESET}"
    tar -xzf "$backup_path" -C "$temp_dir"
    if [ $? -ne 0 ]; then
        echo -e "\n${C_RED}❌ ERROR: Failed to extract backup file. Aborting.${C_RESET}"
        rm -rf "$temp_dir"
        return
    fi
    local restored_db_file="$temp_dir/skylartech/users.db"
    if [ ! -f "$restored_db_file" ]; then
        echo -e "\n${C_RED}❌ ERROR: users.db not found in the backup. Cannot restore user accounts.${C_RESET}"
        rm -rf "$temp_dir"
        return
    fi
    echo -e "${C_BLUE}⚙️ Overwriting current user database...${C_RESET}"
    mkdir -p "$DB_DIR"
    cp "$restored_db_file" "$DB_FILE"
    if [ -d "$temp_dir/skylartech/ssl" ]; then
        cp -r "$temp_dir/skylartech/ssl" "$DB_DIR/"
    fi
    if [ -d "$temp_dir/skylartech/dnstt" ]; then
        cp -r "$temp_dir/skylartech/dnstt" "$DB_DIR/"
    fi
    if [ -f "$temp_dir/skylartech/dnstt_info.conf" ]; then
        cp "$temp_dir/skylartech/dnstt_info.conf" "$DB_DIR/"
    fi
    if [ -f "$temp_dir/skylartech/falconproxy_config.conf" ]; then
        cp "$temp_dir/skylartech/falconproxy_config.conf" "$DB_DIR/"
    fi
    
    echo -e "${C_BLUE}⚙️ Re-synchronizing system accounts with the restored database...${C_RESET}"
    ensure_skylartech_system_group
    
    while IFS=: read -r user pass expiry limit bandwidth_gb marker hwid strict app; do
        [[ -z "$user" || "$user" == \#* ]] && continue
        echo "Processing user: ${C_YELLOW}$user${C_RESET}"
        if ! id "$user" &>/dev/null; then
            echo " - User does not exist in system. Creating..."
            useradd -m -s /usr/sbin/nologin "$user"
        fi
        usermod -aG "$FF_USERS_GROUP" "$user" 2>/dev/null
        echo " - Setting password..."
        echo "$user:$pass" | chpasswd
        echo " - Setting expiration to $expiry..."
        chage -E "$expiry" "$user"
        [[ -z "$bandwidth_gb" ]] && bandwidth_gb="0"
        local bw_note="Unlimited"; [[ "$bandwidth_gb" != "0" ]] && bw_note="${bandwidth_gb} GB"
        echo " - Connection limit ${limit:-1}, bandwidth ${bw_note} (enforced by the limiter service)"
    done < "$DB_FILE"

    # Sync all ZiVPN-app user passwords into the ZiVPN auth list.
    if [[ -f "$ZIVPN_CONFIG_FILE" ]] && command -v jq &>/dev/null; then
        local zivpn_reloaded=false
        while IFS=: read -r user pass _ _ _ _ _ _ app; do
            [[ -z "$user" || "$user" == \#* ]] && continue
            if [[ "$app" == "zivpn" ]] && _ff_zivpn_add_pass "$pass"; then
                zivpn_reloaded=true
            fi
        done < "$DB_FILE"
        if [[ "$zivpn_reloaded" == true ]]; then
            systemctl is-active --quiet zivpn 2>/dev/null && systemctl try-restart zivpn.service 2>/dev/null
        fi
    fi

    rm -rf "$temp_dir"
    # Rebuild the HWID mirror from the restored database.
    hwid_sync_allowed_db
    echo -e "\n${C_GREEN}✅ SUCCESS: User data restore completed.${C_RESET}"
    
    invalidate_banner_cache
    refresh_dynamic_banner_routing_if_enabled
}

_enable_banner_in_sshd_config() {
    echo -e "\n${C_BLUE}⚙️ Configuring sshd_config...${C_RESET}"
    disable_dynamic_ssh_banner_system
    sed -i.bak -E 's/^( *Banner *).*/#\1/' /etc/ssh/sshd_config
    if ! grep -q -E "^Banner $SSH_BANNER_FILE" /etc/ssh/sshd_config; then
        echo -e "\n# Skylartech SSH Banner\nBanner $SSH_BANNER_FILE" >> /etc/ssh/sshd_config
    fi
    echo -e "${C_GREEN}✅ sshd_config updated.${C_RESET}"
}

_restart_ssh() {
    echo -e "\n${C_BLUE}🔄 Restarting SSH service to apply changes...${C_RESET}"
    local ssh_service_name=""
    if [ -f /lib/systemd/system/sshd.service ]; then
        ssh_service_name="sshd.service"
    elif [ -f /lib/systemd/system/ssh.service ]; then
        ssh_service_name="ssh.service"
    else
        echo -e "${C_RED}❌ Could not find sshd.service or ssh.service. Cannot restart SSH.${C_RESET}"
        return 1
    fi

    systemctl restart "${ssh_service_name}"
    if [ $? -eq 0 ]; then
        echo -e "${C_GREEN}✅ SSH service ('${ssh_service_name}') restarted successfully.${C_RESET}"
    else
        echo -e "${C_RED}❌ Failed to restart SSH service ('${ssh_service_name}'). Please check 'journalctl -u ${ssh_service_name}' for errors.${C_RESET}"
    fi
}

set_ssh_banner_paste() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 📋 Paste Static SSH Banner ---${C_RESET}"
    echo -e "Paste your custom banner below. Press ${C_YELLOW}[Ctrl+D]${C_RESET} when you are finished."
    echo -e "${C_DIM}This will be shown to all SSH users through 'Banner $SSH_BANNER_FILE'.${C_RESET}"
    echo -e "${C_DIM}The current banner (if any) will be overwritten.${C_RESET}"
    echo -e "--------------------------------------------------"
    cat > "$SSH_BANNER_FILE"
    chmod 644 "$SSH_BANNER_FILE"
    echo -e "\n--------------------------------------------------"
    echo -e "\n${C_GREEN}✅ Static banner content saved.${C_RESET}"
    _enable_banner_in_sshd_config
    _restart_ssh
    echo -e "\nPress ${C_YELLOW}[Enter]${C_RESET} to return..." && read -r
}

view_ssh_banner() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 👁️ Current SSH Banner ---${C_RESET}"
    if [ -f "$SSH_BANNER_FILE" ]; then
        echo -e "\n${C_CYAN}--- BEGIN BANNER ---${C_RESET}"
        cat "$SSH_BANNER_FILE"
        echo -e "${C_CYAN}---- END BANNER ----${C_RESET}"
    else
        echo -e "\n${C_YELLOW}ℹ️ No banner file found at $SSH_BANNER_FILE.${C_RESET}"
    fi
    echo -e "\nPress ${C_YELLOW}[Enter]${C_RESET} to return..." && read -r
}

remove_ssh_banner() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🗑️ Disable SSH Banners ---${C_RESET}"
    read -p "👉 Are you sure you want to disable all SSH banners? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo -e "\n${C_YELLOW}❌ Action cancelled.${C_RESET}"
        echo -e "\nPress ${C_YELLOW}[Enter]${C_RESET} to return..." && read -r
        return
    fi
    if [ -f "$SSH_BANNER_FILE" ]; then
        rm -f "$SSH_BANNER_FILE"
        echo -e "\n${C_GREEN}✅ Removed banner file: $SSH_BANNER_FILE${C_RESET}"
    else
        echo -e "\n${C_YELLOW}ℹ️ No banner file to remove.${C_RESET}"
    fi
    disable_dynamic_ssh_banner_system
    echo -e "\n${C_BLUE}⚙️ Disabling banner in sshd_config...${C_RESET}"
    disable_static_ssh_banner_in_sshd_config
    echo -e "${C_GREEN}✅ Banner disabled in configuration.${C_RESET}"
    _restart_ssh
    echo -e "\nPress ${C_YELLOW}[Enter]${C_RESET} to return..." && read -r
}

preview_dynamic_ssh_banner() {
    if ! is_dynamic_ssh_banner_enabled; then
        echo -e "\n${C_RED}❌ Dynamic banners are not enabled right now.${C_RESET}"
        press_enter
        return
    fi

    echo -e "${C_DIM}Refreshing dynamic banner worker...${C_RESET}"
    setup_limiter_service >/dev/null 2>&1
    _select_user_interface "--- 📝 Preview Dynamic Banner ---"
    local u=$SELECTED_USER
    if [[ -z "$u" || "$u" == "NO_USERS" ]]; then
        return
    fi

    echo -e "\n${C_CYAN}--- Dynamic Banner Preview for user '$u' ---${C_RESET}\n"
    if [[ -f "/etc/skylartech/banners/${u}.txt" ]]; then
        cat "/etc/skylartech/banners/${u}.txt"
    else
        echo -e "${C_RED}Banner file not generated yet. Waiting up to 10s for the worker...${C_RESET}"
        sleep 5
        if ! cat "/etc/skylartech/banners/${u}.txt" 2>/dev/null; then
            echo -e "\n${C_RED}Still not generated. Here are the last limiter logs:${C_RESET}"
            echo -e "----------------------------------------------------------------------"
            journalctl -u skylartech-limiter -n 15 --no-pager
            echo -e "----------------------------------------------------------------------"
        fi
    fi
    press_enter
}

install_udp_custom() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🚀 Installing udp-custom ---${C_RESET}"
    if [ -f "$UDP_CUSTOM_SERVICE_FILE" ] || [ -f "$UDPGW_SERVICE_FILE" ]; then
        echo -e "\n${C_YELLOW}ℹ️ udp-custom is already installed.${C_RESET}"
        return
    fi

    check_and_free_ports 36712 7800 || return
    check_and_open_firewall_port 36712 udp || return

    echo -e "\n${C_GREEN}⚙️ Creating directory for udp-custom...${C_RESET}"
    rm -rf "$UDP_CUSTOM_DIR"
    mkdir -p "$UDP_CUSTOM_DIR"

    echo -e "\n${C_GREEN}⚙️ Detecting system architecture...${C_RESET}"
    local arch
    arch=$(uname -m)
    local binary_url="" binary_asset=""
    if [[ "$arch" == "x86_64" ]]; then
        binary_asset="udp-custom-linux-amd64"
        echo -e "${C_BLUE}ℹ️ Detected x86_64 (amd64) architecture.${C_RESET}"
    elif [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
        binary_asset="udp-custom-linux-arm"
        echo -e "${C_BLUE}ℹ️ Detected ARM64 architecture.${C_RESET}"
    else
        echo -e "\n${C_RED}❌ Unsupported architecture: $arch. Cannot install udp-custom.${C_RESET}"
        rm -rf "$UDP_CUSTOM_DIR"
        return
    fi
    binary_url="$FF_RAW_BASE/udp/$binary_asset"

    echo -e "\n${C_GREEN}📥 Downloading udp-custom binary...${C_RESET}"
    if ! ff_fetch_binary "$UDP_CUSTOM_DIR/udp-custom" "$binary_url"; then
        # Fall back to a copy bundled alongside this script (offline / fork safety).
        local bundled="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/udp/$binary_asset"
        if [[ -s "$bundled" ]]; then
            echo -e "${C_YELLOW}ℹ️ Remote download failed; using bundled binary: $bundled${C_RESET}"
            cp "$bundled" "$UDP_CUSTOM_DIR/udp-custom"
        else
            echo -e "\n${C_RED}❌ Failed to download a valid udp-custom binary from:${C_RESET}"
            echo -e "   ${C_YELLOW}$binary_url${C_RESET}"
            rm -rf "$UDP_CUSTOM_DIR"
            return
        fi
    fi
    chmod +x "$UDP_CUSTOM_DIR/udp-custom"

    echo -e "\n${C_GREEN}📦 Setting up udpgw helper...${C_RESET}"
    if [[ "$arch" == "x86_64" ]]; then
        if ! ff_fetch_binary "$UDPGW_BINARY" "https://raw.githubusercontent.com/http-custom/udp-custom/main/module/udpgw"; then
            echo -e "\n${C_RED}❌ Failed to download a valid udpgw helper binary.${C_RESET}"
            rm -rf "$UDP_CUSTOM_DIR"
            return
        fi
        chmod +x "$UDPGW_BINARY"
    else
        echo -e "${C_YELLOW}ℹ️ Architecture is $arch. Compiling udpgw from source (this may take a minute)...${C_RESET}"
        ff_pkg_install cmake g++ make git >/dev/null 2>&1
        local temp_build="/tmp/badvpn_build"
        rm -rf "$temp_build"
        git clone -q https://github.com/ambrop72/badvpn.git "$temp_build"
        (cd "$temp_build" && cmake . >/dev/null 2>&1 && make >/dev/null 2>&1)
        local compiled_bin=$(find "$temp_build" -name "badvpn-udpgw" -type f | head -n 1)
        if [[ -n "$compiled_bin" && -f "$compiled_bin" ]]; then
            cp "$compiled_bin" "$UDPGW_BINARY"
            chmod +x "$UDPGW_BINARY"
        else
            echo -e "\n${C_RED}❌ Failed to compile udpgw helper for $arch.${C_RESET}"
            rm -rf "$UDP_CUSTOM_DIR" "$temp_build"
            return
        fi
        rm -rf "$temp_build"
    fi

    echo -e "\n${C_GREEN}📝 Creating default config.json...${C_RESET}"
    cat > "$UDP_CUSTOM_DIR/config.json" <<EOF
{
  "listen": ":36712",
  "stream_buffer": 33554432,
  "receive_buffer": 83886080,
  "auth": {
    "mode": "passwords"
  }
}
EOF
    chmod 644 "$UDP_CUSTOM_DIR/config.json"

    echo -e "\n${C_GREEN}📝 Creating udpgw systemd service file...${C_RESET}"
    cat > "$UDPGW_SERVICE_FILE" <<EOF
[Unit]
Description=Skylartech UDPGW Backend
After=network.target

[Service]
User=root
Type=simple
ExecStart=$UDPGW_BINARY --listen-addr 127.0.0.1:7800 --max-clients 1000 --max-connections-for-client 100
Restart=always
RestartSec=2s

[Install]
WantedBy=multi-user.target
EOF

    echo -e "\n${C_GREEN}📝 Creating systemd service file...${C_RESET}"
    cat > "$UDP_CUSTOM_SERVICE_FILE" <<EOF
[Unit]
Description=UDP Custom by Skylartech
After=network.target

[Service]
User=root
Type=simple
ExecStart=$UDP_CUSTOM_DIR/udp-custom server
WorkingDirectory=$UDP_CUSTOM_DIR/
Restart=always
# Near-instant restart so a lock-triggered restart drops a user's live UDP
# session with a sub-second outage for other connected clients.
RestartSec=100ms

[Install]
WantedBy=multi-user.target
EOF

    echo -e "\n${C_GREEN}▶️ Enabling and starting udp-custom service...${C_RESET}"
    systemctl daemon-reload
    systemctl enable udpgw.service
    systemctl start udpgw.service
    systemctl enable udp-custom.service
    systemctl start udp-custom.service
    sleep 2
    if systemctl is-active --quiet udpgw && systemctl is-active --quiet udp-custom; then
        echo -e "\n${C_GREEN}✅ SUCCESS: udp-custom is installed and active.${C_RESET}"
    else
        echo -e "\n${C_RED}❌ ERROR: udp-custom service failed to start.${C_RESET}"
        echo -e "${C_YELLOW}ℹ️ Displaying last 15 lines of the udp-custom and udpgw logs for diagnostics:${C_RESET}"
        journalctl -u udp-custom.service -n 15 --no-pager
        journalctl -u udpgw.service -n 15 --no-pager
    fi
}

uninstall_udp_custom() {
    echo -e "\n${C_BOLD}${C_PURPLE}--- 🗑️ Uninstalling udp-custom ---${C_RESET}"
    if [ ! -f "$UDP_CUSTOM_SERVICE_FILE" ] && [ ! -f "$UDPGW_SERVICE_FILE" ]; then
        echo -e "${C_YELLOW}ℹ️ udp-custom is not installed, skipping.${C_RESET}"
        return
    fi
    echo -e "${C_GREEN}🛑 Stopping and disabling udpgw service...${C_RESET}"
    systemctl stop udpgw.service >/dev/null 2>&1
    systemctl disable udpgw.service >/dev/null 2>&1
    echo -e "${C_GREEN}🛑 Stopping and disabling udp-custom service...${C_RESET}"
    systemctl stop udp-custom.service >/dev/null 2>&1
    systemctl disable udp-custom.service >/dev/null 2>&1
    echo -e "${C_GREEN}🗑️ Removing systemd service file...${C_RESET}"
    rm -f "$UDP_CUSTOM_SERVICE_FILE"
    rm -f "$UDPGW_SERVICE_FILE"
    systemctl daemon-reload
    echo -e "${C_GREEN}🗑️ Removing udp-custom directory and files...${C_RESET}"
    rm -rf "$UDP_CUSTOM_DIR"
    rm -f "$UDPGW_BINARY"
    echo -e "${C_GREEN}✅ udp-custom has been uninstalled successfully.${C_RESET}"
}


ensure_badvpn_service_is_quiet() {
    if [[ ! -f "$BADVPN_SERVICE_FILE" ]] || grep -q "^StandardOutput=null$" "$BADVPN_SERVICE_FILE" 2>/dev/null; then
        return
    fi

    local tmp_service
    tmp_service=$(mktemp)
    awk '
        /^\[Service\]$/ {
            print
            print "StandardOutput=null"
            print "StandardError=null"
            next
        }
        { print }
    ' "$BADVPN_SERVICE_FILE" > "$tmp_service" && mv "$tmp_service" "$BADVPN_SERVICE_FILE"
    rm -f "$tmp_service" 2>/dev/null
    systemctl daemon-reload
    systemctl restart badvpn.service >/dev/null 2>&1 || true
}

install_badvpn() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🚀 Installing badvpn (udpgw) ---${C_RESET}"
    if [ -f "$BADVPN_SERVICE_FILE" ]; then
        echo -e "\n${C_YELLOW}ℹ️ badvpn is already installed.${C_RESET}"
        return
    fi
    check_and_open_firewall_port 7300 udp || return
    echo -e "\n${C_GREEN}🔄 Updating package lists...${C_RESET}"
    ff_apt_update || return
    echo -e "\n${C_GREEN}📦 Installing all required packages...${C_RESET}"
    ff_pkg_install cmake g++ make screen git build-essential libssl-dev libnspr4-dev libnss3-dev pkg-config || {
        echo -e "${C_RED}❌ Failed to install badvpn build dependencies.${C_RESET}"
        return
    }
    echo -e "\n${C_GREEN}📥 Cloning badvpn from github...${C_RESET}"
    git clone https://github.com/ambrop72/badvpn.git "$BADVPN_BUILD_DIR"
    cd "$BADVPN_BUILD_DIR" || { echo -e "${C_RED}❌ Failed to change directory to build folder.${C_RESET}"; return; }
    echo -e "\n${C_GREEN}⚙️ Running CMake...${C_RESET}"
    cmake . || { echo -e "${C_RED}❌ CMake configuration failed.${C_RESET}"; rm -rf "$BADVPN_BUILD_DIR"; return; }
    echo -e "\n${C_GREEN}🛠️ Compiling source...${C_RESET}"
    make || { echo -e "${C_RED}❌ Compilation (make) failed.${C_RESET}"; rm -rf "$BADVPN_BUILD_DIR"; return; }
    local badvpn_binary
    badvpn_binary=$(find "$BADVPN_BUILD_DIR" -name "badvpn-udpgw" -type f | head -n 1)
    if [[ -z "$badvpn_binary" || ! -f "$badvpn_binary" ]]; then
        echo -e "${C_RED}❌ ERROR: Could not find the compiled 'badvpn-udpgw' binary after compilation.${C_RESET}"
        rm -rf "$BADVPN_BUILD_DIR"
        return
    fi
    echo -e "${C_GREEN}ℹ️ Found binary at: $badvpn_binary${C_RESET}"
    chmod +x "$badvpn_binary"
    echo -e "\n${C_GREEN}📝 Creating systemd service file...${C_RESET}"
    cat > "$BADVPN_SERVICE_FILE" <<-EOF
[Unit]
Description=BadVPN UDP Gateway
After=network.target
[Service]
ExecStart=$badvpn_binary --listen-addr 0.0.0.0:7300 --max-clients 1000 --max-connections-for-client 8
User=root
Restart=always
RestartSec=3
StandardOutput=null
StandardError=null
[Install]
WantedBy=multi-user.target
EOF
    echo -e "\n${C_GREEN}▶️ Enabling and starting badvpn service...${C_RESET}"
    systemctl daemon-reload
    systemctl enable badvpn.service
    systemctl start badvpn.service
    sleep 2
    if systemctl is-active --quiet badvpn; then
        echo -e "\n${C_GREEN}✅ SUCCESS: badvpn (udpgw) is installed and active on port 7300.${C_RESET}"
    else
        echo -e "\n${C_RED}❌ ERROR: badvpn service failed to start.${C_RESET}"
        echo -e "${C_YELLOW}ℹ️ Displaying last 15 lines of the service log for diagnostics:${C_RESET}"
        journalctl -u badvpn.service -n 15 --no-pager
    fi
}

uninstall_badvpn() {
    echo -e "\n${C_BOLD}${C_PURPLE}--- 🗑️ Uninstalling badvpn (udpgw) ---${C_RESET}"
    if [ ! -f "$BADVPN_SERVICE_FILE" ]; then
        echo -e "${C_YELLOW}ℹ️ badvpn is not installed, skipping.${C_RESET}"
        return
    fi
    echo -e "${C_GREEN}🛑 Stopping and disabling badvpn service...${C_RESET}"
    systemctl stop badvpn.service >/dev/null 2>&1
    systemctl disable badvpn.service >/dev/null 2>&1
    echo -e "${C_GREEN}🗑️ Removing systemd service file...${C_RESET}"
    rm -f "$BADVPN_SERVICE_FILE"
    systemctl daemon-reload
    echo -e "${C_GREEN}🗑️ Removing badvpn build directory...${C_RESET}"
    rm -rf "$BADVPN_BUILD_DIR"
    echo -e "${C_GREEN}✅ badvpn has been uninstalled successfully.${C_RESET}"
}

load_edge_cert_info() {
    EDGE_CERT_MODE=""
    EDGE_DOMAIN=""
    EDGE_EMAIL=""
    if [ -f "$EDGE_CERT_INFO_FILE" ]; then
        source "$EDGE_CERT_INFO_FILE"
    fi
}

save_edge_cert_info() {
    local cert_mode="$1"
    local cert_domain="$2"
    local cert_email="$3"
    mkdir -p "$DB_DIR"
    cat > "$EDGE_CERT_INFO_FILE" <<EOF
EDGE_CERT_MODE="$cert_mode"
EDGE_DOMAIN="$cert_domain"
EDGE_EMAIL="$cert_email"
EOF
}

detect_preferred_host() {
    local host_domain=""
    load_edge_cert_info
    if [[ -n "$EDGE_DOMAIN" ]]; then
        host_domain="$EDGE_DOMAIN"
    fi
    if [[ -z "$host_domain" && -f "$NGINX_CONFIG_FILE" ]]; then
        local nginx_domain
        nginx_domain=$(grep -oP 'server_name \K[^\s;]+' "$NGINX_CONFIG_FILE" 2>/dev/null | head -n 1)
        if [[ "$nginx_domain" != "_" && -n "$nginx_domain" ]]; then
            host_domain="$nginx_domain"
        fi
    fi
    if [[ -z "$host_domain" ]]; then
        host_domain=$(curl -s -4 icanhazip.com)
    fi
    echo "$host_domain"
}

backup_edge_configs() {
    if [ -f "$NGINX_CONFIG_FILE" ] && [ ! -f "${NGINX_CONFIG_FILE}.bak.skylartech" ]; then
        cp "$NGINX_CONFIG_FILE" "${NGINX_CONFIG_FILE}.bak.skylartech" 2>/dev/null
    fi
    if [ -f "$HAPROXY_CONFIG" ] && [ ! -f "${HAPROXY_CONFIG}.bak.skylartech" ]; then
        cp "$HAPROXY_CONFIG" "${HAPROXY_CONFIG}.bak.skylartech" 2>/dev/null
    fi
}

ensure_edge_stack_packages() {
    local missing_packages=()
    if ! command -v haproxy &> /dev/null || [ ! -f "/etc/haproxy/haproxy.cfg" ]; then
        missing_packages+=("haproxy")
    fi
    if ! command -v nginx &> /dev/null || [ ! -f "/etc/nginx/nginx.conf" ]; then
        missing_packages+=("nginx")
    fi
    command -v openssl &> /dev/null || missing_packages+=("openssl")

    if (( ${#missing_packages[@]} > 0 )); then
        echo -e "\n${C_BLUE}📦 Installing required packages: ${missing_packages[*]}${C_RESET}"
        if ! ff_pkg_install "${missing_packages[@]}"; then
            echo -e "${C_YELLOW}⚠️ Package installation failed. Attempting to fix broken configurations...${C_RESET}"
            if command -v apt-get &>/dev/null; then
                apt-get purge -y nginx nginx-common haproxy >/dev/null 2>&1
            fi
            if ! ff_pkg_install "${missing_packages[@]}"; then
                echo -e "${C_RED}❌ Failed to install the required packages.${C_RESET}"
                return 1
            fi
        fi
    fi
    return 0
}

build_shared_tls_bundle() {
    if [ ! -s "$SSL_CERT_CHAIN_FILE" ] || [ ! -s "$SSL_CERT_KEY_FILE" ]; then
        echo -e "${C_RED}❌ Certificate chain or key is missing.${C_RESET}"
        return 1
    fi
    cat "$SSL_CERT_CHAIN_FILE" "$SSL_CERT_KEY_FILE" > "$SSL_CERT_FILE" || return 1
    chmod 644 "$SSL_CERT_CHAIN_FILE"
    chmod 600 "$SSL_CERT_KEY_FILE" "$SSL_CERT_FILE"
    return 0
}

generate_self_signed_edge_cert() {
    local common_name="$1"
    mkdir -p "$SSL_CERT_DIR"
    echo -e "\n${C_GREEN}🔐 Generating a shared self-signed certificate...${C_RESET}"
    openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
        -keyout "$SSL_CERT_KEY_FILE" \
        -out "$SSL_CERT_CHAIN_FILE" \
        -subj "/CN=$common_name" \
        >/dev/null 2>&1 || {
            echo -e "${C_RED}❌ Failed to generate the self-signed certificate.${C_RESET}"
            return 1
        }
    build_shared_tls_bundle || return 1
    save_edge_cert_info "self-signed" "$common_name" ""
    echo -e "${C_GREEN}✅ Shared certificate created for ${C_YELLOW}$common_name${C_RESET}"
    return 0
}

_install_certbot() {
    if command -v certbot &> /dev/null; then
        echo -e "${C_GREEN}✅ Certbot is already installed.${C_RESET}"
        return 0
    fi
    echo -e "${C_BLUE}📦 Installing Certbot...${C_RESET}"
    ff_pkg_install certbot || {
        echo -e "${C_RED}❌ Failed to install Certbot.${C_RESET}"
        return 1
    }
    echo -e "${C_GREEN}✅ Certbot installed successfully.${C_RESET}"
    return 0
}

obtain_certbot_edge_cert() {
    local domain_name="$1"
    local email="$2"
    local restart_haproxy=0
    local restart_nginx=0

    mkdir -p "$SSL_CERT_DIR"
    _install_certbot || return 1

    if systemctl is-active --quiet haproxy; then restart_haproxy=1; fi
    if systemctl is-active --quiet nginx; then restart_nginx=1; fi

    echo -e "\n${C_BLUE}🛑 Stopping HAProxy and Nginx for Certbot validation...${C_RESET}"
    systemctl stop haproxy >/dev/null 2>&1
    systemctl stop nginx >/dev/null 2>&1
    sleep 2

    check_and_free_ports "$EDGE_PUBLIC_HTTP_PORT" "$EDGE_PUBLIC_TLS_PORT" || {
        [[ "$restart_nginx" -eq 1 ]] && systemctl start nginx >/dev/null 2>&1
        [[ "$restart_haproxy" -eq 1 ]] && systemctl start haproxy >/dev/null 2>&1
        return 1
    }

    echo -e "\n${C_BLUE}🚀 Requesting a Certbot certificate for ${C_YELLOW}$domain_name${C_RESET}"
    certbot certonly --standalone -d "$domain_name" --non-interactive --agree-tos -m "$email"
    if [ $? -ne 0 ]; then
        echo -e "\n${C_RED}❌ Certbot failed to obtain a certificate.${C_RESET}"
        echo -e "${C_YELLOW}ℹ️ Make sure the domain points to this server and port 80 is reachable.${C_RESET}"
        [[ "$restart_nginx" -eq 1 ]] && systemctl start nginx >/dev/null 2>&1
        [[ "$restart_haproxy" -eq 1 ]] && systemctl start haproxy >/dev/null 2>&1
        return 1
    fi

    local certbot_chain="/etc/letsencrypt/live/$domain_name/fullchain.pem"
    local certbot_key="/etc/letsencrypt/live/$domain_name/privkey.pem"
    if [ ! -f "$certbot_chain" ] || [ ! -f "$certbot_key" ]; then
        echo -e "\n${C_RED}❌ Certbot completed, but the certificate files were not found.${C_RESET}"
        [[ "$restart_nginx" -eq 1 ]] && systemctl start nginx >/dev/null 2>&1
        [[ "$restart_haproxy" -eq 1 ]] && systemctl start haproxy >/dev/null 2>&1
        return 1
    fi

    cp "$certbot_chain" "$SSL_CERT_CHAIN_FILE"
    cp "$certbot_key" "$SSL_CERT_KEY_FILE"
    build_shared_tls_bundle || {
        [[ "$restart_nginx" -eq 1 ]] && systemctl start nginx >/dev/null 2>&1
        [[ "$restart_haproxy" -eq 1 ]] && systemctl start haproxy >/dev/null 2>&1
        return 1
    }
    save_edge_cert_info "certbot" "$domain_name" "$email"
    echo -e "${C_GREEN}✅ Certbot certificate copied into ${C_YELLOW}$SSL_CERT_DIR${C_RESET}"
    return 0
}

select_edge_certificate() {
    local preferred_host
    local cert_choice
    local has_existing_cert=false

    preferred_host=$(detect_preferred_host)
    if [[ -z "$preferred_host" ]]; then
        preferred_host="skylartech.local"
    fi

    if [ -s "$SSL_CERT_FILE" ] && [ -s "$SSL_CERT_CHAIN_FILE" ] && [ -s "$SSL_CERT_KEY_FILE" ]; then
        has_existing_cert=true
    fi

    load_edge_cert_info

    echo -e "\n${C_BOLD}${C_PURPLE}--- 🔐 Shared TLS Certificate ---${C_RESET}"
    echo -e "${C_DIM}The same certificate will be used by HAProxy and the internal Nginx proxy.${C_RESET}"

    if $has_existing_cert; then
        local existing_label="${EDGE_CERT_MODE:-existing}"
        if [[ -n "$EDGE_DOMAIN" ]]; then
            existing_label="$existing_label - $EDGE_DOMAIN"
        fi
        printf "  ${C_CHOICE}[ 1]${C_RESET} %-52s\n" "Reuse existing certificate (${existing_label})"
        printf "  ${C_CHOICE}[ 2]${C_RESET} %-52s\n" "Replace with a new self-signed certificate"
        printf "  ${C_CHOICE}[ 3]${C_RESET} %-52s\n" "Replace with a Certbot certificate"
        echo
        read -p "👉 Enter choice [1]: " cert_choice
        cert_choice=${cert_choice:-1}
    else
        printf "  ${C_CHOICE}[ 1]${C_RESET} %-52s\n" "Generate a self-signed certificate"
        printf "  ${C_CHOICE}[ 2]${C_RESET} %-52s\n" "Use a Certbot certificate"
        echo
        read -p "👉 Enter choice [1]: " cert_choice
        cert_choice=${cert_choice:-1}
    fi

    case "$cert_choice" in
        1)
            if $has_existing_cert; then
                echo -e "${C_GREEN}✅ Reusing the existing shared certificate.${C_RESET}"
                return 0
            fi
            local common_name
            read -p "👉 Enter the certificate Common Name / SNI label [$preferred_host]: " common_name
            common_name=${common_name:-$preferred_host}
            generate_self_signed_edge_cert "$common_name"
            ;;
        2)
            if $has_existing_cert; then
                local common_name
                read -p "👉 Enter the certificate Common Name / SNI label [$preferred_host]: " common_name
                common_name=${common_name:-$preferred_host}
                generate_self_signed_edge_cert "$common_name"
            else
                local default_domain=""
                local domain_name
                local email
                if ! _is_valid_ipv4 "$preferred_host"; then
                    default_domain="$preferred_host"
                fi
                if [[ -n "$default_domain" ]]; then
                    read -p "👉 Enter your domain name [$default_domain]: " domain_name
                    domain_name=${domain_name:-$default_domain}
                else
                    read -p "👉 Enter your domain name (e.g. vpn.example.com): " domain_name
                fi
                if [[ -z "$domain_name" ]]; then
                    echo -e "${C_RED}❌ Domain name cannot be empty.${C_RESET}"
                    return 1
                fi
                if _is_valid_ipv4 "$domain_name"; then
                    echo -e "${C_RED}❌ Certbot requires a real domain name, not a raw IP address.${C_RESET}"
                    return 1
                fi
                read -p "👉 Enter your email for Let's Encrypt: " email
                if [[ -z "$email" ]]; then
                    echo -e "${C_RED}❌ Email cannot be empty.${C_RESET}"
                    return 1
                fi
                obtain_certbot_edge_cert "$domain_name" "$email"
            fi
            ;;
        3)
            if ! $has_existing_cert; then
                echo -e "${C_RED}❌ Invalid option.${C_RESET}"
                return 1
            fi
            local default_domain=""
            local domain_name
            local email
            if [[ -n "$EDGE_DOMAIN" ]] && ! _is_valid_ipv4 "$EDGE_DOMAIN"; then
                default_domain="$EDGE_DOMAIN"
            fi
            if [[ -z "$default_domain" ]] && ! _is_valid_ipv4 "$preferred_host"; then
                default_domain="$preferred_host"
            fi
            if [[ -n "$default_domain" ]]; then
                read -p "👉 Enter your domain name [$default_domain]: " domain_name
                domain_name=${domain_name:-$default_domain}
            else
                read -p "👉 Enter your domain name (e.g. vpn.example.com): " domain_name
            fi
            if [[ -z "$domain_name" ]]; then
                echo -e "${C_RED}❌ Domain name cannot be empty.${C_RESET}"
                return 1
            fi
            if _is_valid_ipv4 "$domain_name"; then
                echo -e "${C_RED}❌ Certbot requires a real domain name, not a raw IP address.${C_RESET}"
                return 1
            fi
            read -p "👉 Enter your email for Let's Encrypt [${EDGE_EMAIL}]: " email
            email=${email:-$EDGE_EMAIL}
            if [[ -z "$email" ]]; then
                echo -e "${C_RED}❌ Email cannot be empty.${C_RESET}"
                return 1
            fi
            obtain_certbot_edge_cert "$domain_name" "$email"
            ;;
        *)
            echo -e "${C_RED}❌ Invalid option.${C_RESET}"
            return 1
            ;;
    esac
}

write_internal_nginx_config() {
    local server_name="$1"
    [[ -z "$server_name" ]] && server_name="_"
    mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled
    cat > "$NGINX_CONFIG_FILE" <<EOF
server {
    listen 127.0.0.1:${NGINX_INTERNAL_HTTP_PORT} default_server;
    listen 127.0.0.1:${NGINX_INTERNAL_TLS_PORT} ssl http2 default_server;
    server_tokens off;
    server_name ${server_name};

    ssl_certificate ${SSL_CERT_CHAIN_FILE};
    ssl_certificate_key ${SSL_CERT_KEY_FILE};
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!eNULL:!MD5:!DES:!RC4:!ADH:!SSLv3:!EXP:!PSK:!DSS;
    resolver 1.1.1.1 8.8.8.8 ipv6=off valid=300s;

    location ~ ^/(?<fwdport>\d+)/(?<fwdpath>.*)$ {
        client_max_body_size 0;
        client_body_timeout 1d;
        grpc_read_timeout 1d;
        grpc_socket_keepalive on;
        proxy_read_timeout 1d;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_socket_keepalive on;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        if (\$content_type ~* "GRPC") { grpc_pass grpc://127.0.0.1:\$fwdport\$is_args\$args; break; }
        proxy_pass http://127.0.0.1:\$fwdport\$is_args\$args;
        break;
    }

    location / {
        proxy_read_timeout 3600s;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_http_version 1.1;
        proxy_socket_keepalive on;
        tcp_nodelay on;
        tcp_nopush off;
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
    ln -sf "$NGINX_CONFIG_FILE" /etc/nginx/sites-enabled/default
}

write_haproxy_edge_config() {
    mkdir -p /etc/haproxy
    cat > "$HAPROXY_CONFIG" <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    timeout connect 5s
    timeout client  24h
    timeout server  24h

# ====================================================================
# TIER 1: PORT ${EDGE_PUBLIC_HTTP_PORT} (Cleartext Payloads & Raw SSH)
# ====================================================================
frontend port_80_edge
    bind *:${EDGE_PUBLIC_HTTP_PORT}
    mode tcp
    tcp-request inspect-delay 2s

    acl is_ssh payload(0,7) -m bin 5353482d322e30

    tcp-request content accept if is_ssh
    tcp-request content accept if HTTP

    use_backend direct_ssh if is_ssh
    default_backend nginx_cleartext

# ====================================================================
# TIER 1: PORT ${EDGE_PUBLIC_TLS_PORT} (TLS v2ray, SSL Payloads, Raw SSH)
# ====================================================================
frontend port_443_edge
    bind *:${EDGE_PUBLIC_TLS_PORT}
    mode tcp
    tcp-request inspect-delay 2s

    acl is_ssh payload(0,7) -m bin 5353482d322e30
    acl is_tls req.ssl_hello_type 1
    acl has_web_alpn req.ssl_alpn -m sub h2 http/1.1

    tcp-request content accept if is_ssh
    tcp-request content accept if HTTP
    tcp-request content accept if is_tls

    use_backend direct_ssh if is_ssh
    use_backend nginx_cleartext if HTTP
    use_backend nginx_tls if is_tls has_web_alpn
    default_backend loopback_ssl_terminator

# ====================================================================
# TIER 2: INTERNAL DECRYPTOR (Only for Any-SNI SSH-TLS)
# ====================================================================
frontend internal_decryptor
    bind 127.0.0.1:${HAPROXY_INTERNAL_DECRYPT_PORT} ssl crt ${SSL_CERT_FILE}
    mode tcp
    tcp-request inspect-delay 2s

    acl is_ssh payload(0,7) -m bin 5353482d322e30
    tcp-request content accept if is_ssh
    tcp-request content accept if HTTP

    use_backend direct_ssh if is_ssh
    default_backend nginx_cleartext

# ====================================================================
# DESTINATION BACKENDS (Clean handoffs, no proxy headers)
# ====================================================================
backend direct_ssh
    mode tcp
    server ssh_server 127.0.0.1:22

backend nginx_cleartext
    mode tcp
    server nginx_8880 127.0.0.1:${NGINX_INTERNAL_HTTP_PORT}

backend nginx_tls
    mode tcp
    server nginx_8443 127.0.0.1:${NGINX_INTERNAL_TLS_PORT}

backend loopback_ssl_terminator
    mode tcp
    server haproxy_ssl 127.0.0.1:${HAPROXY_INTERNAL_DECRYPT_PORT}
EOF
}

save_edge_ports_info() {
    cat > "$NGINX_PORTS_FILE" <<EOF
EDGE_HTTP_PORT="${EDGE_PUBLIC_HTTP_PORT}"
EDGE_TLS_PORT="${EDGE_PUBLIC_TLS_PORT}"
HTTP_PORTS="${NGINX_INTERNAL_HTTP_PORT}"
TLS_PORTS="${NGINX_INTERNAL_TLS_PORT}"
EOF
}

configure_edge_stack() {
    local server_name="$1"
    [[ -z "$server_name" ]] && server_name="_"

    backup_edge_configs

    echo -e "\n${C_BLUE}📝 Writing internal Nginx config (127.0.0.1:${NGINX_INTERNAL_HTTP_PORT}/${NGINX_INTERNAL_TLS_PORT})...${C_RESET}"
    write_internal_nginx_config "$server_name"

    echo -e "${C_BLUE}📝 Writing HAProxy edge config (${EDGE_PUBLIC_HTTP_PORT}/${EDGE_PUBLIC_TLS_PORT})...${C_RESET}"
    write_haproxy_edge_config

    echo -e "\n${C_BLUE}🧪 Validating Nginx configuration...${C_RESET}"
    if ! nginx -t >/dev/null 2>&1; then
        echo -e "${C_RED}❌ Nginx configuration validation failed.${C_RESET}"
        nginx -t
        return 1
    fi

    echo -e "${C_BLUE}🧪 Validating HAProxy configuration...${C_RESET}"
    if ! haproxy -c -f "$HAPROXY_CONFIG" >/dev/null 2>&1; then
        echo -e "${C_RED}❌ HAProxy configuration validation failed.${C_RESET}"
        haproxy -c -f "$HAPROXY_CONFIG"
        return 1
    fi

    systemctl daemon-reload
    systemctl enable nginx >/dev/null 2>&1
    systemctl enable haproxy >/dev/null 2>&1

    echo -e "\n${C_BLUE}▶️ Restarting internal Nginx...${C_RESET}"
    systemctl restart nginx || {
        echo -e "${C_RED}❌ Nginx failed to restart.${C_RESET}"
        systemctl status nginx --no-pager
        return 1
    }

    echo -e "${C_BLUE}▶️ Restarting HAProxy edge...${C_RESET}"
    systemctl restart haproxy || {
        echo -e "${C_RED}❌ HAProxy failed to restart.${C_RESET}"
        systemctl status haproxy --no-pager
        return 1
    }

    sleep 2
    if ! systemctl is-active --quiet nginx; then
        echo -e "${C_RED}❌ Nginx is not active after restart.${C_RESET}"
        systemctl status nginx --no-pager
        return 1
    fi
    if ! systemctl is-active --quiet haproxy; then
        echo -e "${C_RED}❌ HAProxy is not active after restart.${C_RESET}"
        systemctl status haproxy --no-pager
        return 1
    fi

    save_edge_ports_info
    return 0
}

install_ssl_tunnel() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🚀 Installing HAProxy Edge Stack (80/443 -> 8880/8443) ---${C_RESET}"
    echo -e "\n${C_CYAN}This installer will configure:${C_RESET}"
    echo -e "   • HAProxy on ${C_WHITE}${EDGE_PUBLIC_HTTP_PORT}/${EDGE_PUBLIC_TLS_PORT}${C_RESET}"
    echo -e "   • Internal Nginx on ${C_WHITE}${NGINX_INTERNAL_HTTP_PORT}/${NGINX_INTERNAL_TLS_PORT}${C_RESET}"
    echo -e "   • Loopback SSL decryptor on ${C_WHITE}${HAPROXY_INTERNAL_DECRYPT_PORT}${C_RESET}"

    if [ -f "$HAPROXY_CONFIG" ] || [ -f "$NGINX_CONFIG_FILE" ]; then
        echo -e "\n${C_YELLOW}⚠️ Existing HAProxy/Nginx configs will be replaced with the Skylartech edge layout.${C_RESET}"
        read -p "👉 Continue with the replacement? (y/n): " confirm_replace
        if [[ "$confirm_replace" != "y" && "$confirm_replace" != "Y" ]]; then
            echo -e "${C_RED}❌ Installation cancelled.${C_RESET}"
            return
        fi
    fi

    mkdir -p "$DB_DIR" "$SSL_CERT_DIR"

    ensure_edge_stack_packages || return

    systemctl stop haproxy >/dev/null 2>&1
    systemctl stop nginx >/dev/null 2>&1
    sleep 1

    check_and_free_ports \
        "$EDGE_PUBLIC_HTTP_PORT" \
        "$EDGE_PUBLIC_TLS_PORT" \
        "$NGINX_INTERNAL_HTTP_PORT" \
        "$NGINX_INTERNAL_TLS_PORT" \
        "$HAPROXY_INTERNAL_DECRYPT_PORT" || return

    check_and_open_firewall_port "$EDGE_PUBLIC_HTTP_PORT" tcp || return
    check_and_open_firewall_port "$EDGE_PUBLIC_TLS_PORT" tcp || return

    select_edge_certificate || return

    load_edge_cert_info
    local server_name="${EDGE_DOMAIN:-$(detect_preferred_host)}"
    [[ -z "$server_name" ]] && server_name="_"

    configure_edge_stack "$server_name" || return

    echo -e "\n${C_GREEN}✅ SUCCESS: HAProxy edge stack is active.${C_RESET}"
    echo -e "   • Public edge ports: ${C_YELLOW}${EDGE_PUBLIC_HTTP_PORT}/${EDGE_PUBLIC_TLS_PORT}${C_RESET}"
    echo -e "   • Internal Nginx ports: ${C_YELLOW}${NGINX_INTERNAL_HTTP_PORT}/${NGINX_INTERNAL_TLS_PORT}${C_RESET}"
    echo -e "   • Shared certificate: ${C_YELLOW}${EDGE_CERT_MODE:-unknown}${C_RESET}"
}

uninstall_ssl_tunnel() {
    echo -e "\n${C_BOLD}${C_PURPLE}--- 🗑️ Uninstalling HAProxy Edge Stack ---${C_RESET}"
    if ! command -v haproxy &> /dev/null; then
        echo -e "${C_YELLOW}ℹ️ HAProxy is not installed, skipping service removal.${C_RESET}"
    else
        echo -e "${C_GREEN}🛑 Stopping and disabling HAProxy...${C_RESET}"
        systemctl stop haproxy >/dev/null 2>&1
        systemctl disable haproxy >/dev/null 2>&1
    fi

    if [ -f "$HAPROXY_CONFIG" ]; then
        cat > "$HAPROXY_CONFIG" <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice

defaults
    log     global
EOF
    fi

    local delete_cert="n"
    if [[ "$UNINSTALL_MODE" == "silent" ]]; then
        delete_cert="y"
    elif [ -f "$SSL_CERT_FILE" ] || [ -f "$SSL_CERT_CHAIN_FILE" ] || [ -f "$SSL_CERT_KEY_FILE" ]; then
        if systemctl is-active --quiet nginx; then
            echo -e "${C_YELLOW}⚠️ The shared certificate is also used by the internal Nginx proxy.${C_RESET}"
        fi
        read -p "👉 Delete the shared TLS certificate too? (y/n): " delete_cert
    fi

    if [[ "$delete_cert" == "y" || "$delete_cert" == "Y" ]]; then
        if systemctl is-active --quiet nginx; then
            echo -e "${C_GREEN}🛑 Stopping Nginx because the shared certificate is being removed...${C_RESET}"
            systemctl stop nginx >/dev/null 2>&1
        fi
        rm -f "$SSL_CERT_FILE" "$SSL_CERT_CHAIN_FILE" "$SSL_CERT_KEY_FILE" "$EDGE_CERT_INFO_FILE"
        rm -f "$NGINX_PORTS_FILE"
        echo -e "${C_GREEN}🗑️ Shared certificate files removed.${C_RESET}"
    fi

    echo -e "${C_GREEN}✅ HAProxy edge stack has been removed.${C_RESET}"
    if systemctl is-active --quiet nginx; then
        echo -e "${C_DIM}The internal Nginx proxy is still installed on ${NGINX_INTERNAL_HTTP_PORT}/${NGINX_INTERNAL_TLS_PORT}.${C_RESET}"
    fi
}

show_dnstt_details() {
    if [ -f "$DNSTT_CONFIG_FILE" ]; then
        source "$DNSTT_CONFIG_FILE"
        echo -e "\n${C_GREEN}=====================================================${C_RESET}"
        echo -e "${C_GREEN}            📡 DNSTT Connection Details             ${C_RESET}"
        echo -e "${C_GREEN}=====================================================${C_RESET}"
        echo -e "\n${C_WHITE}Your connection details:${C_RESET}"
        echo -e "  - ${C_CYAN}Tunnel Domain:${C_RESET} ${C_YELLOW}$TUNNEL_DOMAIN${C_RESET}"
        echo -e "  - ${C_CYAN}Public Key:${C_RESET}    ${C_YELLOW}$PUBLIC_KEY${C_RESET}"
        if [[ -n "$FORWARD_DESC" ]]; then
            echo -e "  - ${C_CYAN}Forwarding To:${C_RESET} ${C_YELLOW}$FORWARD_DESC${C_RESET}"
        else
            echo -e "  - ${C_CYAN}Forwarding To:${C_RESET} ${C_YELLOW}Unknown (config_missing)${C_RESET}"
        fi
        if [[ -n "$MTU_VALUE" ]]; then
            echo -e "  - ${C_CYAN}MTU Value:${C_RESET}     ${C_YELLOW}$MTU_VALUE${C_RESET}"
        fi
        if [[ "$DNSTT_RECORDS_MANAGED" == "false" && -n "$NS_DOMAIN" ]]; then
             echo -e "  - ${C_CYAN}NS Record:${C_RESET}     ${C_YELLOW}$NS_DOMAIN${C_RESET}"
        fi
        
        if [[ "$FORWARD_DESC" == *"V2Ray"* ]]; then
             echo -e "  - ${C_CYAN}Action Required:${C_RESET} ${C_YELLOW}Ensure a V2Ray service (vless/vmess/trojan) listens on port 8787 (no TLS)${C_RESET}"
        elif [[ "$FORWARD_DESC" == *"SSH"* ]]; then
             echo -e "  - ${C_CYAN}Action Required:${C_RESET} ${C_YELLOW}Ensure your SSH client is configured to use the DNS tunnel.${C_RESET}"
        fi
        
        echo -e "\n${C_DIM}Use these details in your client configuration.${C_RESET}"
    else
        echo -e "\n${C_YELLOW}ℹ️ DNSTT configuration file not found. Details are unavailable.${C_RESET}"
    fi
}

install_dnstt() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 📡 DNSTT (DNS Tunnel) Management ---${C_RESET}"
    if [ -f "$DNSTT_SERVICE_FILE" ]; then
        echo -e "\n${C_YELLOW}ℹ️ DNSTT is already installed.${C_RESET}"
        show_dnstt_details
        return
    fi
    
    # --- FIX: Force release of Port 53 / Disable systemd-resolved ---
    echo -e "${C_GREEN}⚙️ Forcing release of Port 53 (stopping systemd-resolved)...${C_RESET}"
    systemctl stop systemd-resolved >/dev/null 2>&1
    systemctl disable systemd-resolved >/dev/null 2>&1
    rm -f /etc/resolv.conf
    echo "nameserver 8.8.8.8" | tee /etc/resolv.conf > /dev/null
    # ----------------------------------------------------------------
    
    echo -e "\n${C_BLUE}🔎 Checking if port 53 (UDP) is available...${C_RESET}"
    if ss -lunp | grep -q ':53\s'; then
        if [[ $(ps -p $(ss -lunp | grep ':53\s' | grep -oP 'pid=\K[0-9]+') -o comm=) == "systemd-resolve" ]]; then
            echo -e "${C_YELLOW}⚠️ Warning: Port 53 is in use by 'systemd-resolved'.${C_RESET}"
            echo -e "${C_YELLOW}This is the system's DNS stub resolver. It must be disabled to run DNSTT.${C_RESET}"
            read -p "👉 Allow the script to automatically disable it and reconfigure DNS? (y/n): " resolve_confirm
            if [[ "$resolve_confirm" == "y" || "$resolve_confirm" == "Y" ]]; then
                echo -e "${C_GREEN}⚙️ Stopping and disabling systemd-resolved to free port 53...${C_RESET}"
                systemctl stop systemd-resolved
                systemctl disable systemd-resolved
                chattr -i /etc/resolv.conf &>/dev/null
                rm -f /etc/resolv.conf
                echo "nameserver 8.8.8.8" > /etc/resolv.conf
                chattr +i /etc/resolv.conf
                echo -e "${C_GREEN}✅ Port 53 has been freed and DNS set to 8.8.8.8.${C_RESET}"
            else
                echo -e "${C_RED}❌ Cannot proceed without freeing port 53. Aborting.${C_RESET}"
                return
            fi
        else
            check_and_free_ports "53" || return
        fi
    else
        echo -e "${C_GREEN}✅ Port 53 (UDP) is free to use.${C_RESET}"
    fi

    check_and_open_firewall_port 53 udp || return



    local forward_port=""
    local forward_desc=""
    echo -e "\n${C_BLUE}Please choose where DNSTT should forward traffic:${C_RESET}"
    echo -e "  ${C_GREEN}[ 1]${C_RESET} ➡️ Forward to local SSH service (port 22)"
    echo -e "  ${C_GREEN}[ 2]${C_RESET} ➡️ Forward to local V2Ray backend (port 8787)"
    read -p "👉 Enter your choice [2]: " fwd_choice
    fwd_choice=${fwd_choice:-2}
    if [[ "$fwd_choice" == "1" ]]; then
        forward_port="22"
        forward_desc="SSH (port 22)"
        echo -e "${C_GREEN}ℹ️ DNSTT will forward to SSH on 127.0.0.1:22.${C_RESET}"
        

        
    elif [[ "$fwd_choice" == "2" ]]; then
        forward_port="8787"
        forward_desc="V2Ray (port 8787)"
        echo -e "${C_GREEN}ℹ️ DNSTT will forward to V2Ray on 127.0.0.1:8787.${C_RESET}"
    else
        echo -e "${C_RED}❌ Invalid choice. Aborting.${C_RESET}"
        return
    fi
    local FORWARD_TARGET="127.0.0.1:$forward_port"
    
    local NS_DOMAIN=""
    local TUNNEL_DOMAIN=""
    local DNSTT_RECORDS_MANAGED="true"
    local NS_SUBDOMAIN=""
    local TUNNEL_SUBDOMAIN=""
    local HAS_IPV6="false"

    read -p "👉 Auto-generate DNS records or use custom ones? (auto/custom) [auto]: " dns_choice
    dns_choice=${dns_choice:-auto}

    if [[ "$dns_choice" == "custom" ]]; then
        DNSTT_RECORDS_MANAGED="false"
        read -p "👉 Enter your full nameserver domain (e.g., ns1.yourdomain.com): " NS_DOMAIN
        if [[ -z "$NS_DOMAIN" ]]; then echo -e "\n${C_RED}❌ Nameserver domain cannot be empty. Aborting.${C_RESET}"; return; fi
        read -p "👉 Enter your full tunnel domain (e.g., tun.yourdomain.com): " TUNNEL_DOMAIN
        if [[ -z "$TUNNEL_DOMAIN" ]]; then echo -e "\n${C_RED}❌ Tunnel domain cannot be empty. Aborting.${C_RESET}"; return; fi
    else
        echo -e "\n${C_BLUE}⚙️ Configuring DNS records for DNSTT...${C_RESET}"
        local SERVER_IPV4
        SERVER_IPV4=$(curl -s -4 icanhazip.com)
        if ! _is_valid_ipv4 "$SERVER_IPV4"; then
            echo -e "\n${C_RED}❌ Error: Could not retrieve a valid public IPv4 address from icanhazip.com.${C_RESET}"
            echo -e "${C_YELLOW}ℹ️ Please check your server's network connection and DNS resolver settings.${C_RESET}"
            echo -e "   Output received: '$SERVER_IPV4'"
            return 1
        fi
        
        local SERVER_IPV6
        SERVER_IPV6=$(curl -s -6 icanhazip.com --max-time 5)
        
        local RANDOM_STR
        RANDOM_STR=$(tr -dc a-z0-9 < /dev/urandom | head -c 6)
        NS_SUBDOMAIN="ns-$RANDOM_STR"
        TUNNEL_SUBDOMAIN="tun-$RANDOM_STR"
        NS_DOMAIN="$NS_SUBDOMAIN.$DESEC_DOMAIN"
        TUNNEL_DOMAIN="$TUNNEL_SUBDOMAIN.$DESEC_DOMAIN"

        local API_DATA
        API_DATA=$(printf '[{"subname": "%s", "type": "A", "ttl": 3600, "records": ["%s"]}, {"subname": "%s", "type": "NS", "ttl": 3600, "records": ["%s."]}]' \
            "$NS_SUBDOMAIN" "$SERVER_IPV4" "$TUNNEL_SUBDOMAIN" "$NS_DOMAIN")

        if [[ -n "$SERVER_IPV6" ]]; then
            local aaaa_record
            aaaa_record=$(printf ',{"subname": "%s", "type": "AAAA", "ttl": 3600, "records": ["%s"]}' "$NS_SUBDOMAIN" "$SERVER_IPV6")
            API_DATA="${API_DATA%?}${aaaa_record}]"
            HAS_IPV6="true"
        fi

        local CREATE_RESPONSE
        CREATE_RESPONSE=$(curl -s -w "%{http_code}" -X POST "https://desec.io/api/v1/domains/$DESEC_DOMAIN/rrsets/" \
            -H "Authorization: Token $DESEC_TOKEN" -H "Content-Type: application/json" \
            --data "$API_DATA")
        
        local HTTP_CODE=${CREATE_RESPONSE: -3}
        local RESPONSE_BODY=${CREATE_RESPONSE:0:${#CREATE_RESPONSE}-3}

        if [[ "$HTTP_CODE" -ne 201 ]]; then
            echo -e "${C_RED}❌ Failed to create DNSTT records. API returned HTTP $HTTP_CODE.${C_RESET}"
            echo "Response: $RESPONSE_BODY" | jq
            return 1
        fi
    fi
    
    read -p "👉 Enter MTU value (e.g., 512, 1200) or press [Enter] for default: " mtu_value
    local mtu_string=""
    if [[ "$mtu_value" =~ ^[0-9]+$ ]]; then
        mtu_string=" -mtu $mtu_value"
        echo -e "${C_GREEN}ℹ️ Using MTU: $mtu_value${C_RESET}"
    else
        mtu_value=""
        echo -e "${C_YELLOW}ℹ️ Using default MTU.${C_RESET}"
    fi

    echo -e "\n${C_BLUE}📥 Downloading pre-compiled DNSTT server binary...${C_RESET}"
    local arch
    arch=$(uname -m)
    local binary_url=""
    if [[ "$arch" == "x86_64" ]]; then
        binary_url="https://dnstt.network/dnstt-server-linux-amd64"
        echo -e "${C_BLUE}ℹ️ Detected x86_64 (amd64) architecture.${C_RESET}"
    elif [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
        binary_url="https://dnstt.network/dnstt-server-linux-arm64"
        echo -e "${C_BLUE}ℹ️ Detected ARM64 architecture.${C_RESET}"
    else
        echo -e "\n${C_RED}❌ Unsupported architecture: $arch. Cannot install DNSTT.${C_RESET}"
        return
    fi
    
    if ! ff_fetch_binary "$DNSTT_BINARY" "$binary_url"; then
        echo -e "\n${C_RED}❌ Failed to download a valid DNSTT binary from:${C_RESET}"
        echo -e "   ${C_YELLOW}$binary_url${C_RESET}"
        return
    fi
    chmod +x "$DNSTT_BINARY"

    echo -e "${C_BLUE}🔐 Generating cryptographic keys...${C_RESET}"
    mkdir -p "$DNSTT_KEYS_DIR"
    "$DNSTT_BINARY" -gen-key -privkey-file "$DNSTT_KEYS_DIR/server.key" -pubkey-file "$DNSTT_KEYS_DIR/server.pub"
    if [[ ! -f "$DNSTT_KEYS_DIR/server.key" ]]; then echo -e "${C_RED}❌ Failed to generate DNSTT keys.${C_RESET}"; return; fi
    
    local PUBLIC_KEY
    PUBLIC_KEY=$(cat "$DNSTT_KEYS_DIR/server.pub")
    
    echo -e "\n${C_BLUE}📝 Creating systemd service...${C_RESET}"
    cat > "$DNSTT_SERVICE_FILE" <<-EOF
[Unit]
Description=DNSTT (DNS Tunnel) Server for $forward_desc
After=network.target
[Service]
Type=simple
User=root
ExecStart=$DNSTT_BINARY -udp :53$mtu_string -privkey-file $DNSTT_KEYS_DIR/server.key $TUNNEL_DOMAIN $FORWARD_TARGET
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF
    echo -e "\n${C_BLUE}💾 Saving configuration and starting service...${C_RESET}"
    cat > "$DNSTT_CONFIG_FILE" <<-EOF
NS_SUBDOMAIN="$NS_SUBDOMAIN"
TUNNEL_SUBDOMAIN="$TUNNEL_SUBDOMAIN"
NS_DOMAIN="$NS_DOMAIN"
TUNNEL_DOMAIN="$TUNNEL_DOMAIN"
PUBLIC_KEY="$PUBLIC_KEY"
FORWARD_DESC="$forward_desc"
DNSTT_RECORDS_MANAGED="$DNSTT_RECORDS_MANAGED"
HAS_IPV6="$HAS_IPV6"
MTU_VALUE="$mtu_value"
EOF
    systemctl daemon-reload
    systemctl enable dnstt.service
    systemctl start dnstt.service
    sleep 2
    if systemctl is-active --quiet dnstt.service; then
        echo -e "\n${C_GREEN}✅ SUCCESS: DNSTT has been installed and started!${C_RESET}"
        show_dnstt_details
    else
        echo -e "\n${C_RED}❌ ERROR: DNSTT service failed to start.${C_RESET}"
        journalctl -u dnstt.service -n 15 --no-pager
    fi
}

uninstall_dnstt() {
    echo -e "\n${C_BOLD}${C_PURPLE}--- 🗑️ Uninstalling DNSTT ---${C_RESET}"
    if [ ! -f "$DNSTT_SERVICE_FILE" ]; then
        echo -e "${C_YELLOW}ℹ️ DNSTT does not appear to be installed, skipping.${C_RESET}"
        return
    fi
    local confirm="y"
    if [[ "$UNINSTALL_MODE" != "silent" ]]; then
        read -p "👉 Are you sure you want to uninstall DNSTT? This will delete DNS records if they were auto-generated. (y/n): " confirm
    fi
    if [[ "$confirm" != "y" ]]; then
        echo -e "\n${C_YELLOW}❌ Uninstallation cancelled.${C_RESET}"
        return
    fi
    echo -e "${C_BLUE}🛑 Stopping and disabling DNSTT service...${C_RESET}"
    systemctl stop dnstt.service > /dev/null 2>&1
    systemctl disable dnstt.service > /dev/null 2>&1
    if [ -f "$DNSTT_CONFIG_FILE" ]; then
        source "$DNSTT_CONFIG_FILE"
        if [[ "$DNSTT_RECORDS_MANAGED" == "true" ]]; then
            echo -e "${C_BLUE}🗑️ Removing auto-generated DNS records...${C_RESET}"
            curl -s -X DELETE "https://desec.io/api/v1/domains/$DESEC_DOMAIN/rrsets/$TUNNEL_SUBDOMAIN/NS/" \
                 -H "Authorization: Token $DESEC_TOKEN" > /dev/null
            curl -s -X DELETE "https://desec.io/api/v1/domains/$DESEC_DOMAIN/rrsets/$NS_SUBDOMAIN/A/" \
                 -H "Authorization: Token $DESEC_TOKEN" > /dev/null
            if [[ "$HAS_IPV6" == "true" ]]; then
                curl -s -X DELETE "https://desec.io/api/v1/domains/$DESEC_DOMAIN/rrsets/$NS_SUBDOMAIN/AAAA/" \
                     -H "Authorization: Token $DESEC_TOKEN" > /dev/null
            fi
            echo -e "${C_GREEN}✅ DNS records have been removed.${C_RESET}"
        else
            echo -e "${C_YELLOW}⚠️ DNS records were manually configured. Please delete them from your DNS provider.${C_RESET}"
        fi
    fi
    echo -e "${C_BLUE}🗑️ Removing service files and binaries...${C_RESET}"
    rm -f "$DNSTT_SERVICE_FILE"
    rm -f "$DNSTT_BINARY"
    rm -rf "$DNSTT_KEYS_DIR"
    rm -f "$DNSTT_CONFIG_FILE"
    systemctl daemon-reload
    
    echo -e "${C_YELLOW}ℹ️ Making /etc/resolv.conf writable again...${C_RESET}"
    chattr -i /etc/resolv.conf &>/dev/null

    echo -e "\n${C_GREEN}✅ DNSTT has been successfully uninstalled.${C_RESET}"
}

install_falcon_proxy() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🦅 Installing Falcon Proxy (Websockets/Socks) ---${C_RESET}"
    
    if [ -f "$FALCONPROXY_SERVICE_FILE" ]; then
        echo -e "\n${C_YELLOW}ℹ️ Falcon Proxy is already installed.${C_RESET}"
        if [ -f "$FALCONPROXY_CONFIG_FILE" ]; then
            source "$FALCONPROXY_CONFIG_FILE"
            echo -e "   It is configured to run on port(s): ${C_YELLOW}$PORTS${C_RESET}"
            echo -e "   Installed Version: ${C_YELLOW}${INSTALLED_VERSION:-Unknown}${C_RESET}"
        fi
        read -p "👉 Do you want to reinstall/update? (y/n): " confirm_reinstall
        if [[ "$confirm_reinstall" != "y" ]]; then return; fi
    fi

    echo -e "\n${C_BLUE}🌐 Fetching available versions from $FF_REPO_HOST...${C_RESET}"
    local releases_json=$(curl -s "$FF_RELEASES_API")
    if [[ -z "$releases_json" || "$releases_json" == "[]" ]]; then
        echo -e "${C_RED}❌ Error: Could not fetch releases. Check internet or API limits.${C_RESET}"
        return
    fi

    # Extract tag names
    mapfile -t versions < <(echo "$releases_json" | jq -r '.[].tag_name')
    
    if [ ${#versions[@]} -eq 0 ]; then
        echo -e "${C_RED}❌ No releases found in the repository.${C_RESET}"
        return
    fi

    echo -e "\n${C_CYAN}Select a version to install:${C_RESET}"
    for i in "${!versions[@]}"; do
        printf "  ${C_GREEN}[%2d]${C_RESET} %s\n" "$((i+1))" "${versions[$i]}"
    done
    echo -e "  ${C_RED} [ 0]${C_RESET} ↩️ Cancel"
    
    local choice
    while true; do
        if ! read -r -p "👉 Enter version number [1]: " choice; then
            echo
            return
        fi
        choice=${choice:-1}
        if [[ "$choice" == "0" ]]; then return; fi
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -le "${#versions[@]}" ]; then
            SELECTED_VERSION="${versions[$((choice-1))]}"
            break
        else
            echo -e "${C_RED}❌ Invalid selection.${C_RESET}"
        fi
    done

    local ports
    read -p "👉 Enter port(s) for Falcon Proxy (e.g., 8080 or 8080 8888) [8080]: " ports
    ports=${ports:-8080}

    local port_array=($ports)
    for port in "${port_array[@]}"; do
        if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
            echo -e "\n${C_RED}❌ Invalid port number: $port. Aborting.${C_RESET}"
            return
        fi
        check_and_free_ports "$port" || return
        check_and_open_firewall_port "$port" tcp || return
    done

    echo -e "\n${C_GREEN}⚙️ Detecting system architecture...${C_RESET}"
    local arch=$(uname -m)
    local binary_name=""
    if [[ "$arch" == "x86_64" ]]; then
        binary_name="falconproxy"
        echo -e "${C_BLUE}ℹ️ Detected x86_64 (amd64) architecture.${C_RESET}"
    elif [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
        binary_name="falconproxyarm"
        echo -e "${C_BLUE}ℹ️ Detected ARM64 architecture.${C_RESET}"
    else
        echo -e "\n${C_RED}❌ Unsupported architecture: $arch. Cannot install Falcon Proxy.${C_RESET}"
        return
    fi
    
    # Construct download URL based on selected version
    local download_url="$FF_RELEASE_DL_BASE/$SELECTED_VERSION/$binary_name"

    echo -e "\n${C_GREEN}📥 Downloading Falcon Proxy $SELECTED_VERSION ($binary_name)...${C_RESET}"
    if ! ff_fetch_binary "$FALCONPROXY_BINARY" "$download_url"; then
        echo -e "\n${C_RED}❌ Failed to download a valid binary from:${C_RESET}"
        echo -e "   ${C_YELLOW}$download_url${C_RESET}"
        echo -e "${C_YELLOW}ℹ️ Ensure release '$SELECTED_VERSION' on $FF_REPO_OWNER/$FF_REPO_NAME has an asset named '$binary_name'.${C_RESET}"
        echo -e "${C_YELLOW}   (If you forked this project, set FF_REPO_HOST/FF_REPO_OWNER/FF_REPO_NAME and upload the falconproxy assets to your own releases.)${C_RESET}"
        return
    fi
    chmod +x "$FALCONPROXY_BINARY"

    echo -e "\n${C_GREEN}📝 Creating systemd service file...${C_RESET}"
    cat > "$FALCONPROXY_SERVICE_FILE" <<EOF
[Unit]
Description=Falcon Proxy ($SELECTED_VERSION)
After=network.target

[Service]
User=root
Type=simple
ExecStart=$FALCONPROXY_BINARY -p $ports
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF

    echo -e "\n${C_GREEN}💾 Saving configuration...${C_RESET}"
    cat > "$FALCONPROXY_CONFIG_FILE" <<EOF
PORTS="$ports"
INSTALLED_VERSION="$SELECTED_VERSION"
EOF

    echo -e "\n${C_GREEN}▶️ Enabling and starting Falcon Proxy service...${C_RESET}"
    systemctl daemon-reload
    systemctl enable falconproxy.service
    systemctl restart falconproxy.service
    sleep 2
    
    if systemctl is-active --quiet falconproxy; then
        echo -e "\n${C_GREEN}✅ SUCCESS: Falcon Proxy $SELECTED_VERSION is installed and active.${C_RESET}"
        echo -e "   Listening on port(s): ${C_YELLOW}$ports${C_RESET}"
    else
        echo -e "\n${C_RED}❌ ERROR: Falcon Proxy service failed to start.${C_RESET}"
        echo -e "${C_YELLOW}ℹ️ Displaying last 15 lines of the service log for diagnostics:${C_RESET}"
        journalctl -u falconproxy.service -n 15 --no-pager
    fi
}

uninstall_falcon_proxy() {
    echo -e "\n${C_BOLD}${C_PURPLE}--- 🗑️ Uninstalling Falcon Proxy ---${C_RESET}"
    if [ ! -f "$FALCONPROXY_SERVICE_FILE" ]; then
        echo -e "${C_YELLOW}ℹ️ Falcon Proxy is not installed, skipping.${C_RESET}"
        return
    fi
    echo -e "${C_GREEN}🛑 Stopping and disabling Falcon Proxy service...${C_RESET}"
    systemctl stop falconproxy.service >/dev/null 2>&1
    systemctl disable falconproxy.service >/dev/null 2>&1
    echo -e "${C_GREEN}🗑️ Removing service file...${C_RESET}"
    rm -f "$FALCONPROXY_SERVICE_FILE"
    systemctl daemon-reload
    echo -e "${C_GREEN}🗑️ Removing binary and config files...${C_RESET}"
    rm -f "$FALCONPROXY_BINARY"
    rm -f "$FALCONPROXY_CONFIG_FILE"
    echo -e "${C_GREEN}✅ Falcon Proxy has been uninstalled successfully.${C_RESET}"
}

# --- ZiVPN Installation Logic ---
install_zivpn() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🚀 Installing ZiVPN (UDP/VPN) ---${C_RESET}"
    
    if [ -f "$ZIVPN_SERVICE_FILE" ]; then
        echo -e "\n${C_YELLOW}ℹ️ ZiVPN is already installed.${C_RESET}"
        return
    fi

    if [ ! -f "$BADVPN_SERVICE_FILE" ]; then
        echo -e "\n${C_YELLOW}⚠️ ZiVPN requires the badvpn (udpgw) backend to provide internet access.${C_RESET}"
        echo -e "${C_GREEN}📦 Automatically installing badvpn backend...${C_RESET}"
        sleep 2
        install_badvpn
        clear; show_banner
        echo -e "${C_BOLD}${C_PURPLE}--- 🚀 Resuming ZiVPN Installation ---${C_RESET}"
    fi

    check_and_free_ports 5667 || return
    check_and_open_firewall_port 5667 udp || return
    check_and_open_firewall_port_range "6000:19999" udp || return

    echo -e "\n${C_GREEN}⚙️ Checking system architecture...${C_RESET}"
    local arch=$(uname -m)
    local zivpn_url=""
    
    if [[ "$arch" == "x86_64" ]]; then
        zivpn_url="https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64"
        echo -e "${C_BLUE}ℹ️ Detected AMD64/x86_64 architecture.${C_RESET}"
    elif [[ "$arch" == "aarch64" ]]; then
        zivpn_url="https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-arm64"
        echo -e "${C_BLUE}ℹ️ Detected ARM64 architecture.${C_RESET}"
    elif [[ "$arch" == "armv7l" || "$arch" == "arm" ]]; then
         zivpn_url="https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-arm"
         echo -e "${C_BLUE}ℹ️ Detected ARM architecture.${C_RESET}"
    else
        echo -e "${C_RED}❌ Unsupported architecture: $arch${C_RESET}"
        return
    fi

    echo -e "\n${C_GREEN}📦 Downloading ZiVPN binary...${C_RESET}"
    if ! ff_fetch_binary "$ZIVPN_BIN" "$zivpn_url"; then
        echo -e "${C_RED}❌ Failed to download a valid ZiVPN binary from:${C_RESET}"
        echo -e "   ${C_YELLOW}$zivpn_url${C_RESET}"
        return
    fi
    chmod +x "$ZIVPN_BIN"

    echo -e "\n${C_GREEN}⚙️ Configuring ZIVPN...${C_RESET}"
    mkdir -p "$ZIVPN_DIR"
    
    # Generate Certificates
    echo -e "${C_BLUE}🔐 Generating self-signed certificates...${C_RESET}"
    if ! command -v openssl &>/dev/null; then
        ff_pkg_install openssl >/dev/null 2>&1 || {
            echo -e "${C_RED}❌ Failed to install openssl for ZiVPN certificate generation.${C_RESET}"
            return
        }
    fi
    
    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" \
        -keyout "$ZIVPN_KEY_FILE" -out "$ZIVPN_CERT_FILE" 2>/dev/null

    if [ ! -f "$ZIVPN_CERT_FILE" ]; then
        echo -e "${C_RED}❌ Failed to generate certificates.${C_RESET}"
        return
    fi

    # System Tuning
    echo -e "${C_BLUE}🔧 Tuning system network parameters...${C_RESET}"
    sysctl -w net.core.rmem_max=16777216 >/dev/null
    sysctl -w net.core.wmem_max=16777216 >/dev/null

    # Create Service
    echo -e "${C_BLUE}📝 Creating systemd service file...${C_RESET}"
    cat <<EOF > "$ZIVPN_SERVICE_FILE"
[Unit]
Description=zivpn VPN Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$ZIVPN_DIR
ExecStart=$ZIVPN_BIN server -c $ZIVPN_CONFIG_FILE
Restart=always
RestartSec=3
Environment=ZIVPN_LOG_LEVEL=info
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

    # Configure Passwords
    echo -e "\n${C_YELLOW}🔑 ZiVPN Password Setup${C_RESET}"
    read -p "👉 Enter passwords separated by commas (e.g., user1,user2) [Default: 'zi']: " input_config
    
    if [ -n "$input_config" ]; then
        IFS=',' read -r -a config_array <<< "$input_config"
        # Ensure array format for JSON
        json_passwords=$(printf '"%s",' "${config_array[@]}")
        json_passwords="[${json_passwords%,}]"
    else
        json_passwords='["zi"]'
    fi

    # Create Config File
    cat <<EOF > "$ZIVPN_CONFIG_FILE"
{
  "listen": ":5667",
   "cert": "$ZIVPN_CERT_FILE",
   "key": "$ZIVPN_KEY_FILE",
   "obfs":"zivpn",
   "auth": {
    "mode": "passwords", 
    "config": $json_passwords
  }
}
EOF

    echo -e "\n${C_GREEN}🚀 Starting ZiVPN Service...${C_RESET}"
    systemctl daemon-reload
    systemctl enable zivpn.service
    systemctl start zivpn.service

    # Port Forwarding / Firewall
    echo -e "${C_BLUE}🔥 Configuring Firewall Rules (Redirecting 6000-19999 -> 5667)...${C_RESET}"
    
    # Determine primary interface
    local iface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
    
    if [ -n "$iface" ]; then
        iptables -t nat -C PREROUTING -i "$iface" -p udp --dport 6000:19999 -j DNAT --to-destination :5667 2>/dev/null || \
            iptables -t nat -A PREROUTING -i "$iface" -p udp --dport 6000:19999 -j DNAT --to-destination :5667
        # Note: IPTables rules are not persistent by default without iptables-persistent package
    else
        echo -e "${C_YELLOW}⚠️ Could not detect default interface for IPTables redirection.${C_RESET}"
    fi

    # Cleanup
    rm -f zi.sh zi2.sh 2>/dev/null

    if systemctl is-active --quiet zivpn.service; then
        echo -e "\n${C_GREEN}✅ ZiVPN Installed Successfully!${C_RESET}"
        echo -e "   - UDP Port: 5667 (Direct)"
        echo -e "   - UDP Ports: 6000-19999 (Forwarded)"
    else
        echo -e "\n${C_RED}❌ ZiVPN Service failed to start. Check logs: journalctl -u zivpn.service${C_RESET}"
    fi
}

uninstall_zivpn() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🗑️ Uninstall ZiVPN ---${C_RESET}"
    
    if [ ! -f "$ZIVPN_SERVICE_FILE" ] && [ ! -f "$ZIVPN_BIN" ]; then
        echo -e "\n${C_YELLOW}ℹ️ ZiVPN does not appear to be installed.${C_RESET}"
        return
    fi

    read -p "👉 Are you sure you want to uninstall ZiVPN? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then echo -e "${C_YELLOW}Cancelled.${C_RESET}"; return; fi

    echo -e "\n${C_BLUE}🛑 Stopping services...${C_RESET}"
    systemctl stop zivpn.service 2>/dev/null
    systemctl disable zivpn.service 2>/dev/null

    local iface
    iface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
    if [ -n "$iface" ]; then
        iptables -t nat -D PREROUTING -i "$iface" -p udp --dport 6000:19999 -j DNAT --to-destination :5667 2>/dev/null || true
    fi
    
    echo -e "${C_BLUE}🗑️ Removing files...${C_RESET}"
    rm -f "$ZIVPN_SERVICE_FILE"
    rm -rf "$ZIVPN_DIR"
    rm -f "$ZIVPN_BIN"
    
    systemctl daemon-reload
    
    # Clean cache (from original uninstall script logic)
    echo -e "${C_BLUE}🧹 Cleaning memory cache...${C_RESET}"
    sync; echo 3 > /proc/sys/vm/drop_caches

    echo -e "\n${C_GREEN}✅ ZiVPN Uninstalled Successfully.${C_RESET}"
}

# --- HWID Lock Enforcer ----------------------------------------------------
# Best-effort, reactive device lock. The daemon tails udp-custom + zivpn journals
# and, for any connection log line that carries an identifiable device token, kicks
# the source IP when it doesn't match the user's allowed HWID (strict rows only).
# It NEVER blocks when the log line lacks an HWID token, so users on binaries that
# don't emit HWID are left untouched rather than false-blocked.

# Remove any HWID-origin INPUT DROP rules the enforcer added (keyed by a stable
# iptables comment) — used on disable / remove-HWID so blocks don't linger.
_hwid_flush_drops() {
    command -v iptables &>/dev/null || return 0
    local ip ips
    # Collect every source IP currently carrying our tagged DROP rule. The comment
    # appears as "ffhwid" in iptables-save output; we delete by full rule spec so
    # the running-rule match (comment stored without quotes) succeeds.
    ips=$(iptables-save 2>/dev/null | awk '/--comment "ffhwid"/ {
        for (i=1; i<=NF; i++) if ($i == "-s") { print $(i+1); break }
    }' | sort -u)
    for ip in $ips; do
        # Strip any /32 CIDR iptables-save may append.
        ip="${ip%/*}"
        # Delete every duplicate copy for this IP.
        while iptables -D INPUT -p udp -s "$ip" -m comment --comment "ffhwid" -j DROP 2>/dev/null; do :; done
    done
}

write_hwid_enforcer() {
    cat > "$HWID_ENFORCER_SCRIPT" <<'HWIDEOF'
#!/bin/bash
# Skylartech HWID enforcer version 2026-06-26.1
# Skylartech HWID Lock Enforcer (best-effort, reactive).
# Reads username|hwid|strict|password from the allowed DB and watches the VPN
# journals. The hwid column may be a comma-separated list of allowed devices; a
# connection is OK if its device id matches ANY entry. On a strict mismatch it
# drops the offending source IP (tagged with an iptables comment so it can be
# cleanly removed later).
# Force a UTF-8 locale so grep -P (PCRE) is always available.
export LC_ALL=C.UTF-8 LANG=C.UTF-8
HWID_DB="/etc/skylartech/hwid_allowed.db"
LOG_FILE="/var/log/skylartech_hwid.log"
KICK_LOG="/var/log/skylartech_hwid.log"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"; }

touch "$LOG_FILE" 2>/dev/null
log "HWID enforcer started."

# Look up the allowed hwid list + strict for a token that may be a username OR a
# password. Echoes the (possibly comma-separated) hwid list, or empty if the
# token isn't an enforced (strict, hwid-set) identity.
# Password is the LAST pipe field, so $4 captures it even if it contains '|'.
lookup_identity() {
    local token="$1"
    [ -f "$HWID_DB" ] || return 1
    awk -F'|' -v t="$token" '
        {
            user=$1; hwid=$2; strict=$3;
            pass=$4;
            for (i=5; i<=NF; i++) pass=pass "|" $i;   # rejoin a password containing '|'
        }
        (user == t || pass == t) && strict == "1" && hwid != "" { print hwid; found=1; exit }
        END { exit(found ? 0 : 1) }
    ' "$HWID_DB"
}

drop_ip() {
    local ip="$1" who="$2"
    command -v iptables &>/dev/null || return 0
    # Idempotent: delete a prior identical rule, then insert. Comment lets the
    # menu flush these rules without touching unrelated firewall entries.
    iptables -D INPUT -p udp -s "$ip" -m comment --comment "ffhwid" -j DROP 2>/dev/null
    iptables -I INPUT -p udp -s "$ip" -m comment --comment "ffhwid" -j DROP 2>/dev/null
    command -v conntrack &>/dev/null && conntrack -D -p udp -s "$ip" 2>/dev/null
    echo "$(date '+%Y-%m-%d %H:%M:%S') - KICKED $ip (wrong HWID) for $who" >> "$KICK_LOG"
}

journalctl -u udp-custom -u zivpn -n0 -f --no-pager 2>/dev/null | while IFS= read -r line; do
    # Only react to lines that look like a successful client connection.
    echo "$line" | grep -qiE 'client connected|user connected|accepted|authenticated|new session' || continue

    # Best-effort token extraction. Patterns are deliberately broad; adjust here
    # if the installed VPN binary uses a different log vocabulary.
    # 1) key=value / key: value forms (require a delimiter so bare words like
    #    "client connected" don't get mistaken for the identity token).
    token=$(echo "$line" | grep -oiP '(username|user|client|account)[=:][ ]*\K[^ ,;]+' | head -1)
    # 2) "user <name>" / "account <name>" space form.
    [ -z "$token" ] && token=$(echo "$line" | grep -oiP '\b(username|user|account)[ ]+\K[A-Za-z0-9._-]+' | head -1)
    # 3) password/auth token fallback (ZiVPN identity is its password).
    [ -z "$token" ] && token=$(echo "$line" | grep -oiP '(password|pass|auth)[=:][ ]*\K[^ ,;]+' | head -1)
    ip=$(echo "$line" | grep -oP '\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b' | head -1)
    hwid=$(echo "$line" | grep -oiP 'hwid[=:][ ]*\K[^ ,;]+' | head -1)

    [ -z "$token" ] && continue
    [ -z "$ip" ] && continue

    allowed_list=$(lookup_identity "$token") || continue   # not a strict/locked user

    if [ -z "$hwid" ]; then
        # Binary did not log a device id — we cannot verify, so do NOT block.
        log "UNVERIFIABLE - $token from $ip (no hwid in log); allowed=$allowed_list"
        continue
    fi

    # allowed_list may hold several comma-separated HWIDs; the device is OK if it
    # matches ANY of them. Otherwise the source IP is dropped.
    matched=0
    IFS=',' read -ra _hlist <<< "$allowed_list"
    for h in "${_hlist[@]}"; do
        # Trim surrounding whitespace before comparing.
        h="${h#"${h%%[![:space:]]*}"}"; h="${h%"${h##*[![:space:]]}"}"
        [ -n "$h" ] && [ "$h" = "$hwid" ] && { matched=1; break; }
    done

    if [ "$matched" -eq 0 ]; then
        log "BLOCK - $token from $ip wrong hwid=$hwid (allowed=$allowed_list)"
        drop_ip "$ip" "$token"
    else
        log "OK - $token from $ip hwid matched"
    fi
done
HWIDEOF
    chmod +x "$HWID_ENFORCER_SCRIPT"
}

enable_hwid_lock() {
    mkdir -p "$DB_DIR" 2>/dev/null
    hwid_sync_allowed_db
    write_hwid_enforcer
    cat > "$HWID_ENFORCER_SERVICE" <<EOF
[Unit]
Description=Skylartech HWID Lock Enforcer
After=network.target

[Service]
Type=simple
User=root
ExecStart=$HWID_ENFORCER_SCRIPT
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable skylartech-hwid-enforcer 2>/dev/null
    systemctl restart skylartech-hwid-enforcer 2>/dev/null
    echo "on" > "$HWID_STATE_FILE"
    if systemctl is-active --quiet skylartech-hwid-enforcer; then
        echo -e "\n${C_GREEN}✅ HWID Lock enforcement ENABLED.${C_RESET}"
        echo -e "${C_DIM}Only users with an HWID + strict flag are enforced; others stay multi-device.${C_RESET}"
    else
        echo -e "\n${C_RED}❌ Enforcer failed to start. Check: journalctl -u skylartech-hwid-enforcer${C_RESET}"
    fi
}

disable_hwid_lock() {
    systemctl stop skylartech-hwid-enforcer 2>/dev/null
    systemctl disable skylartech-hwid-enforcer 2>/dev/null
    rm -f "$HWID_ENFORCER_SERVICE" "$HWID_ENFORCER_SCRIPT"
    systemctl daemon-reload 2>/dev/null
    _hwid_flush_drops
    echo "off" > "$HWID_STATE_FILE"
    echo -e "\n${C_YELLOW}⚠️ HWID Lock enforcement DISABLED. All device blocks cleared.${C_RESET}"
}

hwid_lock_status() {
    if systemctl is-active --quiet skylartech-hwid-enforcer 2>/dev/null; then
        echo -e "  ${C_GREEN}● Enabled${C_RESET} ${C_DIM}(watching udp-custom + zivpn)${C_RESET}"
    else
        echo -e "  ${C_RED}● Disabled${C_RESET}"
    fi
}

hwid_lock_menu() {
    while true; do
        clear; show_banner
        echo -e "${C_BOLD}${C_PURPLE}--- 🔒 HWID Lock Enforcement ---${C_RESET}\n"
        echo -ne "  Status: "; hwid_lock_status
        local locked_count=0
        [[ -f "$HWID_ALLOWED_DB" ]] && locked_count=$(grep -c . "$HWID_ALLOWED_DB" 2>/dev/null || echo 0)
        echo -e "  ${C_DIM}Users with an enforced HWID: ${C_CYAN}${locked_count}${C_RESET}"
        echo -e "\n  ${C_DIM}Note: enforcement is best-effort/reactive. It kicks a wrong device only"
        echo -e "  when the VPN log exposes a device id; users without an HWID are never${C_RESET}"
        echo -e "  ${C_DIM}restricted. See plan/limitations for details.${C_RESET}\n"
        printf "  ${C_GREEN}[ 1]${C_RESET} %-35s\n" "✅ Enable enforcement"
        printf "  ${C_GREEN}[ 2]${C_RESET} %-35s\n" "🛑 Disable enforcement"
        printf "  ${C_GREEN}[ 3]${C_RESET} %-35s\n" "📜 View recent kick log"
        echo -e "\n  ${C_RED}[ 0]${C_RESET} ⬅️  Back"
        echo
        read -r -p "👉 Enter your choice: " hc || return
        case $hc in
            1) enable_hwid_lock; press_enter ;;
            2) disable_hwid_lock; press_enter ;;
            3) if [[ -f "$HWID_KICK_LOG" ]]; then
                   echo; tail -n 30 "$HWID_KICK_LOG" 2>/dev/null
               else echo -e "\n${C_YELLOW}ℹ️ No HWID activity logged yet.${C_RESET}"; fi
               press_enter ;;
            0) return ;;
            *) invalid_option ;;
        esac
    done
}

purge_nginx() {
    local mode="$1"
    if [[ "$mode" != "silent" ]]; then
        clear; show_banner
        echo -e "${C_BOLD}${C_PURPLE}--- 🔥 Purge Internal Nginx Proxy ---${C_RESET}"
        if ! command -v nginx &> /dev/null; then
            rm -f "$NGINX_PORTS_FILE"
            echo -e "\n${C_YELLOW}ℹ️ Nginx is not installed. Nothing to do.${C_RESET}"
            return
        fi
        echo -e "\n${C_YELLOW}⚠️ This removes the internal Nginx proxy on ${NGINX_INTERNAL_HTTP_PORT}/${NGINX_INTERNAL_TLS_PORT}.${C_RESET}"
        if systemctl is-active --quiet haproxy; then
            echo -e "${C_YELLOW}⚠️ HAProxy will stay installed, but web payload routing from ${EDGE_PUBLIC_HTTP_PORT}/${EDGE_PUBLIC_TLS_PORT} will stop until you reinstall the stack.${C_RESET}"
        fi
        read -p "👉 Continue and purge Nginx? (y/n): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo -e "\n${C_YELLOW}❌ Uninstallation cancelled.${C_RESET}"
            return
        fi
    fi
    echo -e "\n${C_BLUE}🛑 Stopping Nginx service...${C_RESET}"
    systemctl stop nginx >/dev/null 2>&1
    systemctl disable nginx >/dev/null 2>&1
    echo -e "\n${C_BLUE}🗑️ Purging Nginx packages...${C_RESET}"
    ff_pkg_purge nginx nginx-common >/dev/null 2>&1
    ff_pkg_autoremove
    echo -e "\n${C_BLUE}🗑️ Removing leftover files...${C_RESET}"
    rm -f /etc/ssl/certs/nginx-selfsigned.pem
    rm -f /etc/ssl/private/nginx-selfsigned.key
    rm -rf /etc/nginx
    rm -f "${NGINX_CONFIG_FILE}.bak"
    rm -f "${NGINX_CONFIG_FILE}.bak.certbot"
    rm -f "${NGINX_CONFIG_FILE}.bak.selfsigned"
    rm -f "${NGINX_CONFIG_FILE}.bak.skylartech"
    rm -f "$NGINX_PORTS_FILE"
    if [[ "$mode" != "silent" ]]; then
        echo -e "\n${C_GREEN}✅ Internal Nginx proxy purged. Shared Skylartech certificates were kept.${C_RESET}"
    fi
}

install_nginx_proxy() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🚀 Reconfiguring Internal Nginx Proxy (8880/8443) ---${C_RESET}"
    echo -e "\n${C_CYAN}This keeps HAProxy on ${EDGE_PUBLIC_HTTP_PORT}/${EDGE_PUBLIC_TLS_PORT} and rewrites the internal Nginx proxy on ${NGINX_INTERNAL_HTTP_PORT}/${NGINX_INTERNAL_TLS_PORT}.${C_RESET}"

    if [ ! -s "$SSL_CERT_FILE" ] || [ ! -s "$SSL_CERT_CHAIN_FILE" ] || [ ! -s "$SSL_CERT_KEY_FILE" ]; then
        echo -e "\n${C_YELLOW}⚠️ No shared Skylartech certificate was found.${C_RESET}"
        echo -e "${C_DIM}Running the full HAProxy edge installer so the certificate and both services stay aligned.${C_RESET}"
        install_ssl_tunnel
        return
    fi

    mkdir -p "$DB_DIR" "$SSL_CERT_DIR"
    ensure_edge_stack_packages || return

    systemctl stop haproxy >/dev/null 2>&1
    systemctl stop nginx >/dev/null 2>&1
    sleep 1

    check_and_free_ports \
        "$EDGE_PUBLIC_HTTP_PORT" \
        "$EDGE_PUBLIC_TLS_PORT" \
        "$NGINX_INTERNAL_HTTP_PORT" \
        "$NGINX_INTERNAL_TLS_PORT" \
        "$HAPROXY_INTERNAL_DECRYPT_PORT" || return

    check_and_open_firewall_port "$EDGE_PUBLIC_HTTP_PORT" tcp || return
    check_and_open_firewall_port "$EDGE_PUBLIC_TLS_PORT" tcp || return

    load_edge_cert_info
    local server_name="${EDGE_DOMAIN:-$(detect_preferred_host)}"
    [[ -z "$server_name" ]] && server_name="_"

    configure_edge_stack "$server_name" || return

    echo -e "\n${C_GREEN}✅ Internal Nginx proxy reconfigured successfully.${C_RESET}"
    echo -e "   • Public HAProxy edge: ${C_YELLOW}${EDGE_PUBLIC_HTTP_PORT}/${EDGE_PUBLIC_TLS_PORT}${C_RESET}"
    echo -e "   • Internal Nginx: ${C_YELLOW}${NGINX_INTERNAL_HTTP_PORT}/${NGINX_INTERNAL_TLS_PORT}${C_RESET}"
}

request_certbot_ssl() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🔒 Shared Certbot Certificate (HAProxy + Nginx) ---${C_RESET}"
    echo -e "\n${C_DIM}This will replace the shared certificate used by HAProxy on ${EDGE_PUBLIC_TLS_PORT} and internal Nginx on ${NGINX_INTERNAL_TLS_PORT}.${C_RESET}"

    mkdir -p "$DB_DIR" "$SSL_CERT_DIR"
    ensure_edge_stack_packages || return
    load_edge_cert_info

    local preferred_host
    local default_domain=""
    local domain_name
    local email

    preferred_host=$(detect_preferred_host)
    if [[ -n "$EDGE_DOMAIN" ]] && ! _is_valid_ipv4 "$EDGE_DOMAIN"; then
        default_domain="$EDGE_DOMAIN"
    elif [[ -n "$preferred_host" ]] && ! _is_valid_ipv4 "$preferred_host"; then
        default_domain="$preferred_host"
    fi

    if [[ -n "$default_domain" ]]; then
        read -p "👉 Enter your domain name [$default_domain]: " domain_name
        domain_name=${domain_name:-$default_domain}
    else
        read -p "👉 Enter your domain name (e.g. vpn.example.com): " domain_name
    fi
    if [[ -z "$domain_name" ]]; then
        echo -e "\n${C_RED}❌ Domain name cannot be empty.${C_RESET}"
        return
    fi
    if _is_valid_ipv4 "$domain_name"; then
        echo -e "\n${C_RED}❌ Certbot requires a real domain name, not a raw IP address.${C_RESET}"
        return
    fi

    read -p "👉 Enter your email for Let's Encrypt [${EDGE_EMAIL}]: " email
    email=${email:-$EDGE_EMAIL}
    if [[ -z "$email" ]]; then
        echo -e "\n${C_RED}❌ Email address cannot be empty.${C_RESET}"
        return
    fi

    check_and_open_firewall_port "$EDGE_PUBLIC_HTTP_PORT" tcp || return
    check_and_open_firewall_port "$EDGE_PUBLIC_TLS_PORT" tcp || return

    obtain_certbot_edge_cert "$domain_name" "$email" || return
    configure_edge_stack "$domain_name" || return

    echo -e "\n${C_GREEN}✅ Shared Certbot certificate applied successfully.${C_RESET}"
    echo -e "   • Domain: ${C_YELLOW}${domain_name}${C_RESET}"
    echo -e "   • Public edge: ${C_YELLOW}${EDGE_PUBLIC_HTTP_PORT}/${EDGE_PUBLIC_TLS_PORT}${C_RESET}"
}

nginx_proxy_menu() {
    while true; do
    show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🌐 Internal Nginx Proxy Management ---${C_RESET}"

    local nginx_status="${C_STATUS_I}Inactive${C_RESET}"
    local haproxy_status="${C_STATUS_I}Inactive${C_RESET}"
    if systemctl is-active --quiet nginx; then
        nginx_status="${C_STATUS_A}Active${C_RESET}"
    fi
    if systemctl is-active --quiet haproxy; then
        haproxy_status="${C_STATUS_A}Active${C_RESET}"
    fi

    load_edge_cert_info
    local cert_info="${EDGE_CERT_MODE:-Not configured}"
    if [[ -n "$EDGE_DOMAIN" ]]; then
        cert_info="${cert_info} - ${EDGE_DOMAIN}"
    fi

    echo -e "\n${C_WHITE}Nginx:${C_RESET} ${nginx_status}"
    echo -e "${C_WHITE}HAProxy:${C_RESET} ${haproxy_status}"
    echo -e "${C_DIM}Public Edge: ${EDGE_PUBLIC_HTTP_PORT}/${EDGE_PUBLIC_TLS_PORT} | Internal Nginx: ${NGINX_INTERNAL_HTTP_PORT}/${NGINX_INTERNAL_TLS_PORT}${C_RESET}"
    echo -e "${C_DIM}Shared Certificate: ${cert_info}${C_RESET}"

    echo -e "\n${C_BOLD}Select an action:${C_RESET}\n"
    
    if systemctl is-active --quiet nginx; then
         printf "  ${C_CHOICE}[ 1]${C_RESET} %-40s\n" "🛑 Stop Nginx Service"
         printf "  ${C_CHOICE}[ 2]${C_RESET} %-40s\n" "🔄 Restart HAProxy + Nginx Stack"
         printf "  ${C_CHOICE}[ 3]${C_RESET} %-40s\n" "⚙️ Re-install/Re-configure Edge Stack"
         printf "  ${C_CHOICE}[ 4]${C_RESET} %-40s\n" "🔒 Switch/Renew Shared SSL (Certbot)"
         printf "  ${C_CHOICE}[ 5]${C_RESET} %-40s\n" "🔥 Uninstall/Purge Nginx"
    else
         printf "  ${C_CHOICE}[ 1]${C_RESET} %-40s\n" "▶️ Start Nginx Service"
         printf "  ${C_CHOICE}[ 3]${C_RESET} %-40s\n" "⚙️ Install/Configure Edge Stack"
         printf "  ${C_CHOICE}[ 4]${C_RESET} %-40s\n" "🔒 Switch/Renew Shared SSL (Certbot)"
         printf "  ${C_CHOICE}[ 5]${C_RESET} %-40s\n" "🔥 Uninstall/Purge Nginx"
    fi

    echo -e "\n  ${C_WARN}[ 0]${C_RESET} ↩️ Return"
    echo
    if ! read -r -p "$(echo -e ${C_PROMPT}"👉 Select an option: "${C_RESET})" choice; then
        echo
        return
    fi
    
    case $choice in
        1) 
            if systemctl is-active --quiet nginx; then
                echo -e "\n${C_BLUE}🛑 Stopping Nginx...${C_RESET}"
                systemctl stop nginx
                echo -e "${C_GREEN}✅ Nginx stopped.${C_RESET}"
                if systemctl is-active --quiet haproxy; then
                    echo -e "${C_YELLOW}⚠️ HAProxy is still running, but web traffic that depends on internal Nginx will not work until Nginx starts again.${C_RESET}"
                fi
            else
                echo -e "\n${C_BLUE}▶️ Starting Nginx...${C_RESET}"
                systemctl start nginx
                if systemctl is-active --quiet nginx; then
                    echo -e "${C_GREEN}✅ Nginx started.${C_RESET}"
                else
                    echo -e "${C_RED}❌ Failed to start Nginx.${C_RESET}"
                fi
            fi
            press_enter
            ;;
        2)
            echo -e "\n${C_BLUE}🔄 Restarting Nginx and HAProxy...${C_RESET}"
            local restart_ok=true
            systemctl restart nginx || restart_ok=false
            if command -v haproxy &> /dev/null; then
                systemctl restart haproxy || restart_ok=false
            else
                restart_ok=false
            fi
            if $restart_ok && systemctl is-active --quiet nginx && systemctl is-active --quiet haproxy; then
                echo -e "${C_GREEN}✅ HAProxy + Nginx stack restarted.${C_RESET}"
            else
                echo -e "${C_RED}❌ One or more services failed to restart.${C_RESET}"
            fi
            press_enter
            ;;
        3) 
             install_nginx_proxy; press_enter
             ;;
        4)
             request_certbot_ssl; press_enter
             ;;
        5)
             purge_nginx; press_enter
             ;;
        0) return ;;
        *) invalid_option ;;
    esac
    done
}

install_panel_menu() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 💻 Install X-UI / 3X-UI Panel ---${C_RESET}"
    echo -e "\n${C_CYAN}Select which panel to install:${C_RESET}\n"
    printf "  ${C_CHOICE}[ 1]${C_RESET} %-45s %s\n" "🚀 3X-UI Panel (MHSanaei)" "${C_STATUS_A}⭐ Default${C_RESET}"
    printf "  ${C_CHOICE}[ 2]${C_RESET} %-45s %s\n" "📦 X-UI Panel (alireza0)" ""
    echo -e "\n  ${C_RED}[ 0]${C_RESET} ❌ Cancel"
    echo
    read -p "👉 Select panel [1]: " panel_choice
    panel_choice=${panel_choice:-1}
    case $panel_choice in
        1) install_3xui_panel ;;
        2) install_xui_panel ;;
        0) echo -e "\n${C_YELLOW}❌ Installation cancelled.${C_RESET}" ;;
        *) echo -e "\n${C_RED}❌ Invalid option.${C_RESET}" ;;
    esac
}

install_3xui_panel() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🚀 Install 3X-UI Panel ---${C_RESET}"
    echo -e "\nThis will download and run the official installation script for 3X-UI (MHSanaei)."
    echo -e "Choose an installation option:\n"
    printf "  ${C_GREEN}[ 1]${C_RESET} %-40s\n" "Install the latest version of 3X-UI"
    printf "  ${C_GREEN}[ 2]${C_RESET} %-40s\n" "Install a specific version of 3X-UI"
    echo -e "\n  ${C_RED}[ 0]${C_RESET} ❌ Cancel Installation"
    echo
    read -p "👉 Select an option: " choice
    case $choice in
        1)
            echo -e "\n${C_BLUE}⚙️ Installing the latest version...${C_RESET}"
            bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
            ;;
        2)
            read -p "👉 Enter the version to install (e.g., 2.4.5): " version
            if [[ -z "$version" ]]; then
                echo -e "\n${C_RED}❌ Version number cannot be empty.${C_RESET}"
                return
            fi
            echo -e "\n${C_BLUE}⚙️ Installing version ${C_YELLOW}$version...${C_RESET}"
            bash <(curl -Ls "https://raw.githubusercontent.com/mhsanaei/3x-ui/v$version/install.sh") "v$version"
            ;;
        0)
            echo -e "\n${C_YELLOW}❌ Installation cancelled.${C_RESET}"
            ;;
        *)
            echo -e "\n${C_RED}❌ Invalid option.${C_RESET}"
            ;;
    esac
}

install_xui_panel() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 📦 Install X-UI Panel (Legacy) ---${C_RESET}"
    echo -e "\nThis will download and run the installation script for X-UI (alireza0)."
    echo -e "Choose an installation option:\n"
    printf "  ${C_GREEN}[ 1]${C_RESET} %-40s\n" "Install the latest version of X-UI"
    printf "  ${C_GREEN}[ 2]${C_RESET} %-40s\n" "Install a specific version of X-UI"
    echo -e "\n  ${C_RED}[ 0]${C_RESET} ❌ Cancel Installation"
    echo
    read -p "👉 Select an option: " choice
    case $choice in
        1)
            echo -e "\n${C_BLUE}⚙️ Installing the latest version...${C_RESET}"
            bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)
            ;;
        2)
            read -p "👉 Enter the version to install (e.g., 1.8.0): " version
            if [[ -z "$version" ]]; then
                echo -e "\n${C_RED}❌ Version number cannot be empty.${C_RESET}"
                return
            fi
            echo -e "\n${C_BLUE}⚙️ Installing version ${C_YELLOW}$version...${C_RESET}"
            VERSION=$version bash <(curl -Ls "https://raw.githubusercontent.com/alireza0/x-ui/$version/install.sh") "$version"
            ;;
        0)
            echo -e "\n${C_YELLOW}❌ Installation cancelled.${C_RESET}"
            ;;
        *)
            echo -e "\n${C_RED}❌ Invalid option.${C_RESET}"
            ;;
    esac
}

uninstall_xui_panel() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🗑️ Uninstall X-UI / 3X-UI Panel ---${C_RESET}"
    if ! command -v x-ui &> /dev/null; then
        echo -e "\n${C_YELLOW}ℹ️ No X-UI/3X-UI panel appears to be installed.${C_RESET}"
        return
    fi
    read -p "👉 Are you sure you want to thoroughly uninstall X-UI/3X-UI? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        echo -e "\n${C_BLUE}⚙️ Running the default uninstaller first...${C_RESET}"
        x-ui uninstall >/dev/null 2>&1
        echo -e "\n${C_BLUE}🧹 Performing a full cleanup to ensure complete removal...${C_RESET}"
        echo " - Stopping and disabling x-ui service..."
        systemctl stop x-ui >/dev/null 2>&1
        systemctl disable x-ui >/dev/null 2>&1
        echo " - Removing x-ui files and directories..."
        rm -f /etc/systemd/system/x-ui.service
        rm -f /usr/local/bin/x-ui
        rm -rf /usr/local/x-ui/
        rm -rf /etc/x-ui/
        echo " - Reloading systemd daemon..."
        systemctl daemon-reload
        echo -e "\n${C_GREEN}✅ X-UI/3X-UI has been thoroughly uninstalled.${C_RESET}"
    else
        echo -e "\n${C_YELLOW}❌ Uninstallation cancelled.${C_RESET}"
    fi
}

refresh_ssh_session_cache() {
    local now db_mtime
    printf -v now '%(%s)T' -1
    db_mtime=$(stat -c %Y "$DB_FILE" 2>/dev/null || echo 0)

    if (( SSH_SESSION_CACHE_TS > 0 && now - SSH_SESSION_CACHE_TS < SSH_SESSION_CACHE_TTL && db_mtime == SSH_SESSION_CACHE_DB_MTIME )); then
        return
    fi

    SSH_SESSION_COUNTS=()
    SSH_SESSION_PIDS=()
    SSH_SESSION_TOTAL=0
    SSH_SESSION_CACHE_DB_MTIME=$db_mtime

    if [[ ! -s "$DB_FILE" ]]; then
        SSH_SESSION_CACHE_TS=$now
        return
    fi

    local -A managed_user_lookup=()
    local -A uid_user_lookup=()
    local -A session_pids=()
    local -A loginuid_pids=()
    local managed_user system_user system_uid ssh_pid ssh_owner candidate_user login_uid

    while IFS=: read -r managed_user _rest; do
        [[ -n "$managed_user" && "$managed_user" != \#* ]] && managed_user_lookup["$managed_user"]=1
    done < "$DB_FILE"

    while IFS=: read -r system_user _ system_uid _rest; do
        [[ -n "$system_user" && "$system_uid" =~ ^[0-9]+$ ]] && uid_user_lookup["$system_uid"]="$system_user"
    done < /etc/passwd

    while read -r ssh_pid ssh_owner; do
        [[ "$ssh_pid" =~ ^[0-9]+$ ]] || continue

        # Method 1: process owner matches a managed user directly
        if [[ -n "$ssh_owner" && "$ssh_owner" != "root" && "$ssh_owner" != "sshd" && -n "${managed_user_lookup[$ssh_owner]+x}" ]]; then
            session_pids["$ssh_owner"]+="$ssh_pid "
        fi
    done < <(ps -C sshd,sshd-session -o pid=,user= 2>/dev/null)

    # Method 2: kernel loginuid with comm/PPid validation (more robust — matches limiter logic)
    local p pid_dir pid_num comm ppid_val session_user
    for p in /proc/[0-9]*/loginuid; do
        [[ -f "$p" ]] || continue
        login_uid=""
        read -r login_uid < "$p" || login_uid=""
        [[ "$login_uid" =~ ^[0-9]+$ && "$login_uid" != "4294967295" ]] || continue

        candidate_user="${uid_user_lookup[$login_uid]}"
        [[ -n "$candidate_user" && -n "${managed_user_lookup[$candidate_user]+x}" ]] || continue

        pid_dir=$(dirname "$p")
        pid_num=$(basename "$pid_dir")
        comm=""
        read -r comm < "$pid_dir/comm" 2>/dev/null || comm=""
        [[ "$comm" == "sshd" || "$comm" == "sshd-session" ]] || continue

        # Filter out the master sshd process (PPid=1)
        ppid_val=""
        while read -r key value; do
            [[ "$key" == "PPid:" ]] && { ppid_val="$value"; break; }
        done < "$pid_dir/status" 2>/dev/null
        [[ "$ppid_val" == "1" ]] && continue

        loginuid_pids["$candidate_user"]+="$pid_num "
    done

    local user pid
    for user in "${!managed_user_lookup[@]}"; do
        # CRITICAL: unset before declare to reset per-user (bash declare is function-scoped)
        unset unique_pids
        local -A unique_pids=()

        # Merge BOTH sources (union) — not fallback
        for pid in ${session_pids[$user]} ${loginuid_pids[$user]}; do
            [[ "$pid" =~ ^[0-9]+$ ]] && unique_pids["$pid"]=1
        done

        SSH_SESSION_COUNTS["$user"]=${#unique_pids[@]}
        if (( ${#unique_pids[@]} > 0 )); then
            for pid in "${!unique_pids[@]}"; do
                SSH_SESSION_PIDS["$user"]+="$pid "
            done
            SSH_SESSION_TOTAL=$((SSH_SESSION_TOTAL + ${#unique_pids[@]}))
        fi
    done

    SSH_SESSION_CACHE_TS=$now
}

count_managed_online_sessions() {
    refresh_ssh_session_cache
    echo "$SSH_SESSION_TOTAL"
}

invalidate_banner_cache() {
    BANNER_CACHE_TS=0
    SSH_SESSION_CACHE_TS=0
}

refresh_banner_cache() {
    local now
    printf -v now '%(%s)T' -1
    if (( BANNER_CACHE_TS > 0 && now - BANNER_CACHE_TS < BANNER_CACHE_TTL )); then
        return
    fi

    if [[ -z "$BANNER_CACHE_OS_NAME" ]]; then
        BANNER_CACHE_OS_NAME=$(grep -oP 'PRETTY_NAME="\K[^"]+' /etc/os-release 2>/dev/null || echo "Linux")
    fi
    BANNER_CACHE_UP_TIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "unknown")
    local w=0 d=0 h=0 m=0
    if [[ "$BANNER_CACHE_UP_TIME" =~ ([0-9]+)[[:space:]]*week ]]; then w=${BASH_REMATCH[1]}; fi
    if [[ "$BANNER_CACHE_UP_TIME" =~ ([0-9]+)[[:space:]]*day ]]; then d=${BASH_REMATCH[1]}; fi
    if [[ "$BANNER_CACHE_UP_TIME" =~ ([0-9]+)[[:space:]]*hour ]]; then h=${BASH_REMATCH[1]}; fi
    if [[ "$BANNER_CACHE_UP_TIME" =~ ([0-9]+)[[:space:]]*minute ]]; then m=${BASH_REMATCH[1]}; fi
    local parts=()
    ((w)) && parts+=("($w)wks")
    ((d)) && parts+=("($d)days")
    local IFS=,
    BANNER_CACHE_UP_TIME="${parts[*]}"
    BANNER_CACHE_RAM_USAGE=$(free -m | awk '/^Mem:/{if($2>0){printf "%.2f", $3*100/$2}else{print "0.00"}}')
    BANNER_CACHE_CPU_LOAD=$(awk '{print $1}' /proc/loadavg 2>/dev/null)
    if [[ -z "$BANNER_CACHE_IP" ]]; then
        BANNER_CACHE_IP=$(curl -s -4 --max-time 3 icanhazip.com 2>/dev/null || echo "unknown")
    fi
    if [[ -z "$BANNER_CACHE_BASE" ]]; then
        local arch
        arch=$(uname -m 2>/dev/null || echo "unknown")
        case "$arch" in
            x86_64)  BANNER_CACHE_BASE="x64" ;;
            aarch64) BANNER_CACHE_BASE="ARM64" ;;
            armv7l)  BANNER_CACHE_BASE="ARM32" ;;
            i686|i386) BANNER_CACHE_BASE="x86" ;;
            *)       BANNER_CACHE_BASE="$arch" ;;
        esac
    fi
    BANNER_CACHE_CPU_COUNT=$(nproc 2>/dev/null || echo "1")
    if [[ -z "$BANNER_CACHE_DOMAIN" ]]; then
        if [[ -f "$DOMAIN_OVERRIDE_FILE" ]]; then
            BANNER_CACHE_DOMAIN=$(<"$DOMAIN_OVERRIDE_FILE")
        else
            BANNER_CACHE_DOMAIN=$(dig +short -x "$BANNER_CACHE_IP" 2>/dev/null | sed 's/\.$//' || true)
            BANNER_CACHE_DOMAIN="${BANNER_CACHE_DOMAIN:-$(hostname -f 2>/dev/null || hostname 2>/dev/null || echo "unknown")}"
        fi
    fi
    if [[ -s "$DB_FILE" ]]; then
        BANNER_CACHE_TOTAL_USERS=0
        while IFS=: read -r _u _rest; do
            [[ -n "$_u" && "$_u" != \#* ]] && (( BANNER_CACHE_TOTAL_USERS++ ))
        done < "$DB_FILE"
    else
        BANNER_CACHE_TOTAL_USERS=0
    fi
    BANNER_CACHE_ONLINE_USERS=$(count_managed_online_sessions)
    BANNER_CACHE_TS=$now
}

show_banner() {
    refresh_banner_cache
    [[ -t 1 ]] && clear
    echo
    echo -e "${C_TITLE}          Skylartech ${C_RESET}${C_DIM}| Premium Edition V1.0.0         ${C_RESET}"
    echo -e "${C_BLUE}   ─────────────────────────────────────────────────────${C_RESET}"
    printf "   ${C_GRAY}◦ %-6s${C_RESET} ${C_GREEN}%-19s${C_RESET} ${C_GRAY}◦ %-6s${C_RESET} ${C_GREEN}%s${C_RESET}\n" "Base" "$BANNER_CACHE_BASE" "Load" "$BANNER_CACHE_CPU_LOAD"
    printf "   ${C_GRAY}◦ %-6s${C_RESET} ${C_GREEN}%-19s${C_RESET} ${C_GRAY}◦ %-6s${C_RESET} ${C_GREEN}%s${C_RESET}\n" "CPU'S" "$BANNER_CACHE_CPU_COUNT" "Domain" "$BANNER_CACHE_DOMAIN"
    printf "   ${C_GRAY}◦ %-6s${C_RESET} ${C_GREEN}%-19s${C_RESET} ${C_GRAY}◦ %-6s${C_RESET} ${C_GREEN}%s${C_RESET}\n" "Users" "$BANNER_CACHE_TOTAL_USERS Managed" "UpTime" "$BANNER_CACHE_UP_TIME"
    printf "   ${C_GRAY}◦ %-6s${C_RESET} ${C_GREEN}%-19s${C_RESET} ${C_GRAY}◦ %-6s${C_RESET} ${C_GREEN}%s${C_RESET}\n" "IP" "$BANNER_CACHE_IP" "OS" "$BANNER_CACHE_OS_NAME"
    echo -e "${C_BLUE}   ·····················································${C_RESET}"
    echo -e "   ${C_GRAY}·${C_RESET}${C_TITLE}              🔧 ACTIVE SERVICES               ${C_RESET}${C_GRAY}·${C_RESET}"
    echo -e "${C_BLUE}   ·····················································${C_RESET}"

    local -a svc_lbl=() svc_val=()
    svc_lbl+=("SSH:"); svc_val+=("22")
    if systemctl is-active --quiet haproxy; then
        svc_lbl+=("SSL (HAProxy):"); svc_val+=("${EDGE_PUBLIC_HTTP_PORT:-80}, ${EDGE_PUBLIC_TLS_PORT:-443}")
    fi
    if systemctl is-active --quiet zivpn.service; then
        svc_lbl+=("ZiVPN:"); svc_val+=("${ZIVPN_LISTEN_PORT:-5667}")
    fi
    if systemctl is-active --quiet udp-custom; then
        svc_lbl+=("UDP-Custom:"); svc_val+=("${UDP_CUSTOM_LISTEN_PORT:-36712}")
    fi
    if systemctl is-active --quiet badvpn; then
        svc_lbl+=("BadVPN:"); svc_val+=("${BADVPN_LISTEN_PORT:-7300}")
    fi
    if systemctl is-active --quiet dnstt.service; then
        svc_lbl+=("DNSTT:"); svc_val+=("53")
    fi
    if systemctl is-active --quiet nginx; then
        svc_lbl+=("Nginx Int.:"); svc_val+=("${NGINX_INTERNAL_HTTP_PORT:-8880}, ${NGINX_INTERNAL_TLS_PORT:-8443}")
    fi
    if systemctl is-active --quiet falconproxy; then
        local fp_ports="8080"
        if [ -f "$FALCONPROXY_CONFIG_FILE" ]; then
            fp_ports=$(grep -oP '^PORTS="\K[^"]*' "$FALCONPROXY_CONFIG_FILE" 2>/dev/null || echo "8080")
        fi
        svc_lbl+=("FalconProxy:"); svc_val+=("$fp_ports")
    fi
    
    local i total=${#svc_lbl[@]}
    for ((i=0; i<total; i+=2)); do
        if (( i+1 < total )); then
            printf "   ${C_GRAY}·  ◦ %-12s${C_RESET} ${C_ORANGE}%-7s${C_RESET}  ${C_GRAY}◦ %-12s${C_RESET} ${C_ORANGE}%s${C_RESET}  ${C_GRAY}·${C_RESET}\n" "${svc_lbl[i]}" "${svc_val[i]}" "${svc_lbl[i+1]}" "${svc_val[i+1]}"
        else
            printf "   ${C_GRAY}·  ◦ %-12s${C_RESET} ${C_ORANGE}%s${C_RESET}  ${C_GRAY}·${C_RESET}\n" "${svc_lbl[i]}" "${svc_val[i]}"
        fi
    done
    echo -e "${C_BLUE}   ·····················································${C_RESET}"
}

protocol_menu() {
    while true; do
        show_banner
        local badvpn_status; if systemctl is-active --quiet badvpn; then badvpn_status="${C_STATUS_A}(Active)${C_RESET}"; else badvpn_status="${C_STATUS_I}(Inactive)${C_RESET}"; fi
        local udp_custom_status; if systemctl is-active --quiet udp-custom; then udp_custom_status="${C_STATUS_A}(Active)${C_RESET}"; else udp_custom_status="${C_STATUS_I}(Inactive)${C_RESET}"; fi
        local zivpn_status; if systemctl is-active --quiet zivpn.service; then zivpn_status="${C_STATUS_A}(Active)${C_RESET}"; else zivpn_status="${C_STATUS_I}(Inactive)${C_RESET}"; fi
        
        local ssl_tunnel_text="HAProxy Edge Stack (80/443)"
        local ssl_tunnel_status="${C_STATUS_I}(Inactive)${C_RESET}"
        if systemctl is-active --quiet haproxy; then
            ssl_tunnel_status="${C_STATUS_A}(Active)${C_RESET}"
        fi
        
        local dnstt_status; if systemctl is-active --quiet dnstt.service; then dnstt_status="${C_STATUS_A}(Active)${C_RESET}"; else dnstt_status="${C_STATUS_I}(Inactive)${C_RESET}"; fi
        
        local falconproxy_status="${C_STATUS_I}(Inactive)${C_RESET}"
        local falconproxy_ports=""
        if systemctl is-active --quiet falconproxy; then
            if [ -f "$FALCONPROXY_CONFIG_FILE" ]; then source "$FALCONPROXY_CONFIG_FILE"; fi
            falconproxy_ports=" ($PORTS)"
            falconproxy_status="${C_STATUS_A}(Active - ${INSTALLED_VERSION:-latest})${C_RESET}"
        fi

        local nginx_status; if systemctl is-active --quiet nginx; then nginx_status="${C_STATUS_A}(Active)${C_RESET}"; else nginx_status="${C_STATUS_I}(Inactive)${C_RESET}"; fi
        local xui_status; if command -v x-ui &> /dev/null; then xui_status="${C_STATUS_A}(Installed)${C_RESET}"; else xui_status="${C_STATUS_I}(Not Installed)${C_RESET}"; fi  # 3X-UI uses same 'x-ui' binary name
        
        echo -e "\n   ${C_TITLE}══════════════[ ${C_BOLD}🔌 PROTOCOL & PANEL MANAGEMENT ${C_RESET}${C_TITLE}]══════════════${C_RESET}"
        echo -e "     ${C_ACCENT}--- TUNNELLING PROTOCOLS---${C_RESET}"
        printf "     ${C_CHOICE}[ 1]${C_RESET} %-45s %s\n" "🚀 Install badvpn (UDP 7300)" "$badvpn_status"
        printf "     ${C_CHOICE}[ 2]${C_RESET} %-45s\n" "🗑️ Uninstall badvpn"
        printf "     ${C_CHOICE}[ 3]${C_RESET} %-45s %s\n" "🚀 Install udp-custom" "$udp_custom_status"
        printf "     ${C_CHOICE}[ 4]${C_RESET} %-45s\n" "🗑️ Uninstall udp-custom"
        printf "     ${C_CHOICE}[ 5]${C_RESET} %-45s %s\n" "🔒 Install ${ssl_tunnel_text}" "$ssl_tunnel_status"
        printf "     ${C_CHOICE}[ 6]${C_RESET} %-45s\n" "🗑️ Uninstall HAProxy Edge Stack"
        printf "     ${C_CHOICE}[ 7]${C_RESET} %-45s %s\n" "📡 Install/View DNSTT (Port 53)" "$dnstt_status"
        printf "     ${C_CHOICE}[ 8]${C_RESET} %-45s\n" "🗑️ Uninstall DNSTT"
        printf "     ${C_CHOICE}[ 9]${C_RESET} %-45s %s\n" "🦅 Install Falcon Proxy (Select Version)" "$falconproxy_status"
        printf "     ${C_CHOICE}[10]${C_RESET} %-45s\n" "🗑️ Uninstall Falcon Proxy"
        printf "     ${C_CHOICE}[11]${C_RESET} %-45s %s\n" "🌐 Install/Manage Internal Nginx (8880/8443)" "$nginx_status"
        printf "     ${C_CHOICE}[14]${C_RESET} %-45s %s\n" "🛡️ Install ZiVPN (UDP 5667)" "$zivpn_status"
        printf "     ${C_CHOICE}[15]${C_RESET} %-45s\n" "🗑️ Uninstall ZiVPN"
        local hwid_status; if systemctl is-active --quiet skylartech-hwid-enforcer 2>/dev/null; then hwid_status="${C_STATUS_A}(On)${C_RESET}"; else hwid_status="${C_STATUS_I}(Off)${C_RESET}"; fi
        printf "     ${C_CHOICE}[16]${C_RESET} %-45s %s\n" "🔒 HWID Lock Enforcement (udp-custom + ZiVPN)" "$hwid_status"
        
        echo -e "     ${C_ACCENT}--- 💻 MANAGEMENT PANELS ---${C_RESET}"
        printf "     ${C_CHOICE}[12]${C_RESET} %-45s %s\n" "💻 Install X-UI / 3X-UI Panel" "$xui_status"
        printf "     ${C_CHOICE}[13]${C_RESET} %-45s\n" "🗑️ Uninstall X-UI / 3X-UI Panel"
        
        echo -e "   ${C_DIM}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${C_RESET}"
        echo -e "     ${C_WARN}[ 0]${C_RESET} ↩️ Return"
        echo
        if ! read -r -p "$(echo -e ${C_PROMPT}"👉 Select an option: "${C_RESET})" choice; then
            echo
            return
        fi
        case $choice in
            1) install_badvpn; press_enter ;; 2) uninstall_badvpn; press_enter ;;
            3) install_udp_custom; press_enter ;; 4) uninstall_udp_custom; press_enter ;;
            5) install_ssl_tunnel; press_enter ;; 6) uninstall_ssl_tunnel; press_enter ;;
            7) install_dnstt; press_enter ;; 8) uninstall_dnstt; press_enter ;;
            9) install_falcon_proxy; press_enter ;; 10) uninstall_falcon_proxy; press_enter ;;
            11) nginx_proxy_menu ;;
            12) install_panel_menu; press_enter ;; 13) uninstall_xui_panel; press_enter ;;
            14) install_zivpn; press_enter ;; 15) uninstall_zivpn; press_enter ;;
            16) hwid_lock_menu ;;
            0) return ;;
            *) invalid_option ;;
        esac
    done
}

set_domain() {
    echo
    echo -e "${C_TITLE}--- 🌐 Set Custom Domain ---${C_RESET}"
    echo
    local current=""
    if [[ -f "$DOMAIN_OVERRIDE_FILE" ]]; then
        current=$(<"$DOMAIN_OVERRIDE_FILE")
        echo -e "${C_GRAY}Current override:${C_RESET} ${C_GREEN}$current${C_RESET}"
    else
        echo -e "${C_GRAY}No custom domain set. Using auto-detected value.${C_RESET}"
    fi
    echo
    read -r -p "$(echo -e ${C_PROMPT}"👉 Enter domain (leave empty to clear override): "${C_RESET})" new_domain
    if [[ -z "$new_domain" ]]; then
        rm -f "$DOMAIN_OVERRIDE_FILE"
        echo -e "${C_GREEN}✅ Domain override cleared. Will auto-detect on next refresh.${C_RESET}"
    else
        echo "$new_domain" > "$DOMAIN_OVERRIDE_FILE"
        echo -e "${C_GREEN}✅ Domain set to: ${new_domain}${C_RESET}"
    fi
    BANNER_CACHE_DOMAIN=""
    press_enter
}

uninstall_script() {
    clear; show_banner
    echo -e "${C_RED}=====================================================${C_RESET}"
    echo -e "${C_RED}       🔥 DANGER: UNINSTALL SCRIPT & ALL DATA 🔥      ${C_RESET}"
    echo -e "${C_RED}=====================================================${C_RESET}"
    echo -e "${C_YELLOW}This will PERMANENTLY remove this script and all its components, including:"
    echo -e " - The main command ($(command -v menu))"
    echo -e " - All configuration and user data ($DB_DIR)"
    echo -e " - The active limiter service ($LIMITER_SERVICE)"
    echo -e " - All installed services (badvpn, udp-custom, HAProxy Edge Stack, Nginx, DNSTT)"
    echo -e "\n${C_RED}This action is irreversible.${C_RESET}"
    echo ""
    read -p "👉 Type 'yes' to confirm and proceed with uninstallation: " confirm
    if [[ "$confirm" != "yes" ]]; then
        echo -e "\n${C_GREEN}✅ Uninstallation cancelled.${C_RESET}"
        return
    fi
    local -a removable_users=()
    local remove_users_confirm
    local remove_users_on_uninstall=false
    mapfile -t removable_users < <(get_skylartech_known_users)
    if [[ ${#removable_users[@]} -gt 0 ]]; then
        echo -e "\n${C_YELLOW}Skylartech SSH users detected on this VPS:${C_RESET} ${removable_users[*]}"
        read -p "👉 Do you also want to permanently delete these SSH users before uninstalling? (y/n): " remove_users_confirm
        if [[ "$remove_users_confirm" == "y" || "$remove_users_confirm" == "Y" ]]; then
            remove_users_on_uninstall=true
        fi
    fi
    export UNINSTALL_MODE="silent"
    echo -e "\n${C_BLUE}--- 💥 Starting Uninstallation 💥 ---${C_RESET}"
    
    if [[ "$remove_users_on_uninstall" == "true" ]]; then
        echo -e "\n${C_BLUE}🗑️ Removing Skylartech SSH users before uninstall...${C_RESET}"
        delete_skylartech_user_accounts "${removable_users[@]}"
    fi
    
    echo -e "\n${C_BLUE}🗑️ Removing active limiter service...${C_RESET}"
    systemctl stop skylartech-limiter &>/dev/null
    systemctl disable skylartech-limiter &>/dev/null
    rm -f "$LIMITER_SERVICE"
    rm -f "$LIMITER_SCRIPT"
    
    echo -e "\n${C_BLUE}🗑️ Removing bandwidth monitoring service...${C_RESET}"
    systemctl stop skylartech-bandwidth &>/dev/null
    systemctl disable skylartech-bandwidth &>/dev/null
    rm -f "$BANDWIDTH_SERVICE"
    rm -f "$BANDWIDTH_SCRIPT"
    rm -rf "$LEGACY_BANDWIDTH_DIR"
    rm -f "$TRIAL_CLEANUP_SCRIPT"
    
    echo -e "\n${C_BLUE}\ud83d\uddd1\ufe0f Removing SSH login banner...${C_RESET}"
    rm -f "$LOGIN_INFO_SCRIPT"
    rm -f "$SSHD_FF_CONFIG"
    systemctl reload sshd 2>/dev/null || systemctl reload ssh 2>/dev/null
    
    chattr -i /etc/resolv.conf &>/dev/null

    purge_nginx "silent"
    uninstall_dnstt
    uninstall_badvpn
    uninstall_udp_custom
    uninstall_ssl_tunnel
    uninstall_falcon_proxy
    uninstall_zivpn
    echo -e "\n${C_BLUE}🗑️ Removing HWID lock enforcer...${C_RESET}"
    systemctl stop skylartech-hwid-enforcer &>/dev/null
    systemctl disable skylartech-hwid-enforcer &>/dev/null
    rm -f "$HWID_ENFORCER_SERVICE" "$HWID_ENFORCER_SCRIPT"
    _hwid_flush_drops
    
    echo -e "\n${C_BLUE}🔄 Reloading systemd daemon...${C_RESET}"
    systemctl daemon-reload
    
    echo -e "\n${C_BLUE}🗑️ Removing script and configuration files...${C_RESET}"
    rm -rf "$BADVPN_BUILD_DIR"
    rm -rf "$UDP_CUSTOM_DIR"
    rm -rf "$DB_DIR"
    rm -f "$(command -v menu)"
    
    echo -e "\n${C_GREEN}=============================================${C_RESET}"
    echo -e "${C_GREEN}      Script has been successfully uninstalled.     ${C_RESET}"
    echo -e "${C_GREEN}=============================================${C_RESET}"
    echo -e "\nAll associated files and services have been removed."
    echo "The 'menu' command will no longer work."
    exit 0
}

# --- NEW FEATURES ---

create_trial_account() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- ⏱️ Create Trial/Test Account ---${C_RESET}"
    
    # Ensure 'at' daemon is available
    if ! command -v at &>/dev/null; then
        echo -e "${C_YELLOW}⚠️ 'at' command not found. Installing...${C_RESET}"
        ff_pkg_install at >/dev/null 2>&1 || {
            echo -e "${C_RED}❌ Failed to install 'at'. Cannot schedule auto-expiry.${C_RESET}"
            return
        }
        systemctl enable atd &>/dev/null
        systemctl start atd &>/dev/null
    fi
    
    # Ensure atd is running
    if ! systemctl is-active --quiet atd; then
        systemctl start atd &>/dev/null
    fi
    
    echo -e "\n${C_CYAN}Select trial duration:${C_RESET}\n"
    printf "  ${C_GREEN}[ 1]${C_RESET} ⏱️  1 Hour\n"
    printf "  ${C_GREEN}[ 2]${C_RESET} ⏱️  2 Hours\n"
    printf "  ${C_GREEN}[ 3]${C_RESET} ⏱️  3 Hours\n"
    printf "  ${C_GREEN}[ 4]${C_RESET} ⏱️  6 Hours\n"
    printf "  ${C_GREEN}[ 5]${C_RESET} ⏱️  12 Hours\n"
    printf "  ${C_GREEN}[ 6]${C_RESET} 📅  1 Day\n"
    printf "  ${C_GREEN}[ 7]${C_RESET} 📅  3 Days\n"
    printf "  ${C_GREEN}[ 8]${C_RESET} ⚙️  Custom (enter hours)\n"
    echo -e "\n  ${C_RED}[ 0]${C_RESET} ↩️ Cancel"
    echo
    read -p "👉 Select duration: " dur_choice
    
    local duration_hours=0
    local duration_label=""
    case $dur_choice in
        1) duration_hours=1;   duration_label="1 Hour" ;;
        2) duration_hours=2;   duration_label="2 Hours" ;;
        3) duration_hours=3;   duration_label="3 Hours" ;;
        4) duration_hours=6;   duration_label="6 Hours" ;;
        5) duration_hours=12;  duration_label="12 Hours" ;;
        6) duration_hours=24;  duration_label="1 Day" ;;
        7) duration_hours=72;  duration_label="3 Days" ;;
        8) read -p "👉 Enter custom duration in hours: " custom_hours
           if ! [[ "$custom_hours" =~ ^[0-9]+$ ]] || [[ "$custom_hours" -lt 1 ]]; then
               echo -e "\n${C_RED}❌ Invalid number of hours.${C_RESET}"; return
           fi
           duration_hours=$custom_hours
           duration_label="$custom_hours Hours"
           ;;
        0) echo -e "\n${C_YELLOW}❌ Cancelled.${C_RESET}"; return ;;
        *) echo -e "\n${C_RED}❌ Invalid option.${C_RESET}"; return ;;
    esac
    
    # Username
    local rand_suffix=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 5)
    local default_username="trial_${rand_suffix}"
    read -p "👤 Username [${default_username}]: " username
    username=${username:-$default_username}
    
    if id "$username" &>/dev/null || grep -q "^$username:" "$DB_FILE"; then
        echo -e "\n${C_RED}❌ Error: User '$username' already exists.${C_RESET}"; return
    fi
    
    # Password
    local password=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 8)
    read -p "🔑 Password [${password}]: " custom_pass
    password=${custom_pass:-$password}
    
    # Connection limit
    read -p "📶 Connection limit [1]: " limit
    limit=${limit:-1}
    if ! [[ "$limit" =~ ^[0-9]+$ ]]; then echo -e "\n${C_RED}❌ Invalid number.${C_RESET}"; return; fi
    
    # Bandwidth limit
    read -p "📦 Bandwidth limit in GB (0 = unlimited) [0]: " bandwidth_gb
    bandwidth_gb=${bandwidth_gb:-0}
    if ! [[ "$bandwidth_gb" =~ ^[0-9]+\.?[0-9]*$ ]]; then echo -e "\n${C_RED}❌ Invalid number.${C_RESET}"; return; fi
    
    # App type selector
    local app="http"
    echo -e "\n${C_DIM}Select target application:${C_RESET}"
    printf "  ${C_GREEN}[1]${C_RESET} %-15s ${C_DIM}(HTTP Custom)${C_RESET}\n" "HTTP Custom"
    printf "  ${C_GREEN}[2]${C_RESET} %-15s ${C_DIM}(ZiVPN)${C_RESET}\n" "ZiVPN"
    read -p "👉 App type [1]: " app_choice
    app_choice=${app_choice:-1}
    case "$app_choice" in
        2|z|Z|zivpn|ZiVPN) app="zivpn" ;;
        *) app="http" ;;
    esac

    # Calculate expiry
    local expire_date
    if [[ "$duration_hours" -ge 24 ]]; then
        local days=$((duration_hours / 24))
        expire_date=$(date -d "+$days days" +%Y-%m-%d)
    else
        # For sub-day durations, set expiry to tomorrow to be safe (at job does the real cleanup)
        expire_date=$(date -d "+1 day" +%Y-%m-%d)
    fi
    local expiry_timestamp
    expiry_timestamp=$(date -d "+${duration_hours} hours" '+%Y-%m-%d %H:%M:%S')
    local expiry_epoch
    expiry_epoch=$(date -d "+${duration_hours} hours" +%s)

    # Create the system user
    ensure_skylartech_system_group
    useradd -m -s /usr/sbin/nologin "$username"
    usermod -aG "$FF_USERS_GROUP" "$username" 2>/dev/null
    echo "$username:$password" | chpasswd
    chage -E "$expire_date" "$username"
    echo "$username:$password:$expire_date:$limit:$bandwidth_gb:trial::0:$app" >> "$DB_FILE"

    if [[ "$app" == "zivpn" ]] && _ff_zivpn_add_pass "$password"; then
        systemctl is-active --quiet zivpn 2>/dev/null && systemctl try-restart zivpn.service 2>/dev/null
    fi

    # Record the precise expiry epoch so the limiter can enforce sub-day
    # trials even if the 'at' job is lost (reboot, atd restart, etc.).
    mkdir -p "$TRIAL_EXPIRY_DIR"
    printf '%s\n' "$expiry_epoch" > "$TRIAL_EXPIRY_DIR/${username}.ts"

    # Schedule auto-cleanup via 'at' (best-effort; limiter is the safety net)
    echo "$TRIAL_CLEANUP_SCRIPT $username" | at now + ${duration_hours} hours 2>/dev/null
    
    local bw_display="Unlimited"
    if [[ "$bandwidth_gb" != "0" ]]; then bw_display="${bandwidth_gb} GB"; fi
    
    clear; show_banner
    echo -e "${C_GREEN}✅ Trial account created successfully!${C_RESET}\n"
    echo -e "${C_YELLOW}========================================${C_RESET}"
    echo -e "  ⏱️  ${C_BOLD}TRIAL ACCOUNT${C_RESET}"
    echo -e "${C_YELLOW}========================================${C_RESET}"
    echo -e "  - 👤 Username:          ${C_YELLOW}$username${C_RESET}"
    echo -e "  - 🔑 Password:          ${C_YELLOW}$password${C_RESET}"
    echo -e "  - ⏱️ Duration:          ${C_CYAN}$duration_label${C_RESET}"
    echo -e "  - 🕐 Auto-expires at:   ${C_RED}$expiry_timestamp${C_RESET}"
    echo -e "  - 📶 Connection Limit:  ${C_YELLOW}$limit${C_RESET}"
    echo -e "  - 📦 Bandwidth Limit:   ${C_YELLOW}$bw_display${C_RESET}"
    echo -e "${C_YELLOW}========================================${C_RESET}"
    echo -e "\n${C_DIM}The account will be automatically deleted when the trial expires.${C_RESET}"
    
    # Auto-ask for config generation
    echo
    read -p "👉 Generate client config for this trial user? (y/n): " gen_conf
    if [[ "$gen_conf" == "y" || "$gen_conf" == "Y" ]]; then
        generate_client_config "$username" "$password"
    fi
    
    invalidate_banner_cache
    refresh_dynamic_banner_routing_if_enabled
}

view_user_bandwidth() {
    _select_user_interface "--- 📊 View User Bandwidth ---"
    local u=$SELECTED_USER
    if [[ "$u" == "NO_USERS" || -z "$u" ]]; then return; fi
    
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 📊 Bandwidth Details: ${C_YELLOW}$u${C_PURPLE} ---${C_RESET}\n"
    
    local line; line=$(grep "^$u:" "$DB_FILE")
    local _u _p _e _l bandwidth_gb
    IFS=: read -r _u _p _e _l bandwidth_gb _ <<< "$line"
    [[ -z "$bandwidth_gb" ]] && bandwidth_gb="0"
    
    local used_bytes=0
    if [[ -f "$BANDWIDTH_DIR/${u}.usage" ]]; then
        read -r used_bytes < "$BANDWIDTH_DIR/${u}.usage" 2>/dev/null || used_bytes=0
        [[ -z "$used_bytes" ]] && used_bytes=0
    fi
    
    local used_mb; used_mb=$(awk "BEGIN {printf \"%.2f\", $used_bytes / 1048576}")
    local used_gb; used_gb=$(awk "BEGIN {printf \"%.3f\", $used_bytes / 1073741824}")
    
    echo -e "  ${C_CYAN}Data Used:${C_RESET}        ${C_WHITE}${used_gb} GB${C_RESET} (${used_mb} MB)"
    
    if [[ "$bandwidth_gb" == "0" ]]; then
        echo -e "  ${C_CYAN}Bandwidth Limit:${C_RESET}  ${C_GREEN}Unlimited${C_RESET}"
        echo -e "  ${C_CYAN}Status:${C_RESET}           ${C_GREEN}No quota restrictions${C_RESET}"
    else
        local quota_bytes; quota_bytes=$(awk "BEGIN {printf \"%.0f\", $bandwidth_gb * 1073741824}")
        local percentage; percentage=$(awk "BEGIN {printf \"%.1f\", ($used_bytes / $quota_bytes) * 100}")
        local remaining_bytes; remaining_bytes=$((quota_bytes - used_bytes))
        if [[ "$remaining_bytes" -lt 0 ]]; then remaining_bytes=0; fi
        local remaining_gb; remaining_gb=$(awk "BEGIN {printf \"%.3f\", $remaining_bytes / 1073741824}")
        
        echo -e "  ${C_CYAN}Bandwidth Limit:${C_RESET}  ${C_YELLOW}${bandwidth_gb} GB${C_RESET}"
        echo -e "  ${C_CYAN}Remaining:${C_RESET}        ${C_WHITE}${remaining_gb} GB${C_RESET}"
        echo -e "  ${C_CYAN}Usage:${C_RESET}            ${C_WHITE}${percentage}%${C_RESET}"
        
        # Progress bar
        local bar_width=30
        local filled; filled=$(awk "BEGIN {printf \"%.0f\", ($percentage / 100) * $bar_width}")
        if [[ "$filled" -gt "$bar_width" ]]; then filled=$bar_width; fi
        local empty=$((bar_width - filled))
        local bar_color="$C_GREEN"
        if (( $(awk "BEGIN {print ($percentage > 80)}" ) )); then bar_color="$C_RED"
        elif (( $(awk "BEGIN {print ($percentage > 50)}" ) )); then bar_color="$C_YELLOW"
        fi
        printf "  ${C_CYAN}Progress:${C_RESET}         ${bar_color}["
        for ((i=0; i<filled; i++)); do printf "█"; done
        for ((i=0; i<empty; i++)); do printf "░"; done
        printf "]${C_RESET} ${percentage}%%\n"
        
        if [[ "$used_bytes" -ge "$quota_bytes" ]]; then
            echo -e "\n  ${C_RED}⚠️ USER HAS EXCEEDED BANDWIDTH QUOTA — ACCOUNT LOCKED${C_RESET}"
        fi
    fi
}

bulk_create_users() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 👥 Bulk Create Users ---${C_RESET}"
    
    read -p "👉 Enter username prefix (e.g., 'user'): " prefix
    if [[ -z "$prefix" ]]; then echo -e "\n${C_RED}❌ Prefix cannot be empty.${C_RESET}"; return; fi
    
    read -p "🔢 How many users to create? " count
    if ! [[ "$count" =~ ^[0-9]+$ ]] || [[ "$count" -lt 1 ]] || [[ "$count" -gt 100 ]]; then
        echo -e "\n${C_RED}❌ Invalid count (1-100).${C_RESET}"; return
    fi
    
    read -p "🗓️ Account duration (in days) [30]: " days
    days=${days:-30}
    if ! [[ "$days" =~ ^[0-9]+$ ]]; then echo -e "\n${C_RED}❌ Invalid number.${C_RESET}"; return; fi
    
    read -p "📶 Connection limit per user [1]: " limit
    limit=${limit:-1}
    if ! [[ "$limit" =~ ^[0-9]+$ ]]; then echo -e "\n${C_RED}❌ Invalid number.${C_RESET}"; return; fi
    
    read -p "📦 Bandwidth limit in GB per user (0 = unlimited) [0]: " bandwidth_gb
    bandwidth_gb=${bandwidth_gb:-0}
    if ! [[ "$bandwidth_gb" =~ ^[0-9]+\.?[0-9]*$ ]]; then echo -e "\n${C_RED}❌ Invalid number.${C_RESET}"; return; fi

    # App type for all bulk users
    local app="http"
    echo -e "\n${C_DIM}Select target application for all users:${C_RESET}"
    printf "  ${C_GREEN}[1]${C_RESET} %-15s ${C_DIM}(HTTP Custom)${C_RESET}\n" "HTTP Custom"
    printf "  ${C_GREEN}[2]${C_RESET} %-15s ${C_DIM}(ZiVPN)${C_RESET}\n" "ZiVPN"
    read -p "👉 App type [1]: " app_choice
    app_choice=${app_choice:-1}
    case "$app_choice" in
        2|z|Z|zivpn|ZiVPN) app="zivpn" ;;
        *) app="http" ;;
    esac

    local expire_date
    expire_date=$(date -d "+$days days" +%Y-%m-%d)
    local bw_display="Unlimited"; [[ "$bandwidth_gb" != "0" ]] && bw_display="${bandwidth_gb} GB"
    ensure_skylartech_system_group
    
    echo -e "\n${C_BLUE}⚙️ Creating $count users with prefix '${prefix}'...${C_RESET}\n"
    echo -e "${C_YELLOW}================================================================${C_RESET}"
    printf "${C_BOLD}${C_WHITE}%-20s | %-15s | %-12s${C_RESET}\n" "USERNAME" "PASSWORD" "EXPIRES"
    echo -e "${C_YELLOW}----------------------------------------------------------------${C_RESET}"
    
    local created=0
    for ((i=1; i<=count; i++)); do
        local username="${prefix}${i}"
        if id "$username" &>/dev/null || grep -q "^$username:" "$DB_FILE"; then
            echo -e "${C_RED}  ⚠️ Skipping '$username' — already exists${C_RESET}"
            continue
        fi
        local password=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 8)
        useradd -m -s /usr/sbin/nologin "$username"
        usermod -aG "$FF_USERS_GROUP" "$username" 2>/dev/null
        echo "$username:$password" | chpasswd
        chage -E "$expire_date" "$username"
        echo "$username:$password:$expire_date:$limit:$bandwidth_gb:::0:$app" >> "$DB_FILE"
        if [[ "$app" == "zivpn" ]]; then
            _ff_zivpn_add_pass "$password"
        fi
        printf "  ${C_GREEN}%-20s${C_RESET} | ${C_YELLOW}%-15s${C_RESET} | ${C_CYAN}%-12s${C_RESET}\n" "$username" "$password" "$expire_date"
        created=$((created + 1))
    done

    if [[ "$app" == "zivpn" ]]; then
        systemctl is-active --quiet zivpn 2>/dev/null && systemctl try-restart zivpn.service 2>/dev/null
    fi

    echo -e "${C_YELLOW}================================================================${C_RESET}"
    echo -e "\n${C_GREEN}✅ Created $created users. Conn Limit: ${limit} | BW: ${bw_display}${C_RESET}"
    echo -e "${C_DIM}ℹ️ Bulk users have no HWID lock (HWID is per-device). Assign per-user via Edit User → [6] if needed.${C_RESET}"
    
    invalidate_banner_cache
    refresh_dynamic_banner_routing_if_enabled
}

generate_client_config() {
    local user=$1
    local pass=$2
    
    local host_ip=$(curl -s -4 icanhazip.com)
    local host_domain
    host_domain=$(detect_preferred_host)
    [[ -z "$host_domain" ]] && host_domain="$host_ip"

    echo -e "\n${C_BOLD}${C_PURPLE}--- 📱 Client Connection Configuration ---${C_RESET}"
    echo -e "${C_CYAN}Copy the details below to your clipboard:${C_RESET}\n"

    echo -e "${C_YELLOW}========================================${C_RESET}"
    echo -e "👤 ${C_BOLD}User Details${C_RESET}"
    echo -e "   • Username: ${C_WHITE}$user${C_RESET}"
    echo -e "   • Password: ${C_WHITE}$pass${C_RESET}"
    echo -e "   • Host/IP : ${C_WHITE}$host_domain${C_RESET}"
    echo -e "${C_YELLOW}========================================${C_RESET}"
    
    # 1. SSH Direct
    echo -e "\n🔹 ${C_BOLD}SSH Direct${C_RESET}:"
    echo -e "   • Host: $host_domain"
    echo -e "   • Port: 22"
    echo -e "   • payload: (Standard SSH)"

    # 2. HAProxy edge stack
    if systemctl is-active --quiet haproxy; then
        echo -e "\n🔹 ${C_BOLD}HAProxy Edge Stack${C_RESET}:"
        echo -e "   • Host: $host_domain"
        echo -e "   • Port 80: HTTP payloads / raw SSH"
        echo -e "   • Port 443: TLS / SNI / SSL payloads"
        echo -e "   • Internal handoff: Nginx ${NGINX_INTERNAL_HTTP_PORT}/${NGINX_INTERNAL_TLS_PORT}"
        echo -e "   • SNI (BugHost): $host_domain (or your preferred SNI)"
    elif systemctl is-active --quiet nginx; then
        echo -e "\n🔹 ${C_BOLD}Internal Nginx Proxy${C_RESET}:"
        echo -e "   • Internal only: ${NGINX_INTERNAL_HTTP_PORT}/${NGINX_INTERNAL_TLS_PORT}"
        echo -e "   • Public clients should connect through HAProxy on ${EDGE_PUBLIC_HTTP_PORT}/${EDGE_PUBLIC_TLS_PORT}"
    fi

    # 3. UDP Custom
    if systemctl is-active --quiet udp-custom; then
        echo -e "\n🔹 ${C_BOLD}UDP Custom${C_RESET}:"
        echo -e "   • IP: $host_ip (Must use numeric IP)"
        echo -e "   • Port: 1-65535 (Exclude 53, 5300)"
        echo -e "   • Obfs: (None/Plain)"
    fi

    # 4. DNSTT
    if systemctl is-active --quiet dnstt; then
        if [ -f "$DNSTT_CONFIG_FILE" ]; then
            source "$DNSTT_CONFIG_FILE"
            echo -e "\n🔹 ${C_BOLD}DNSTT (SlowDNS)${C_RESET}:"
            echo -e "   • Nameserver: $TUNNEL_DOMAIN"
            echo -e "   • PubKey: $PUBLIC_KEY"
            echo -e "   • DNS IP: 1.1.1.1 / 8.8.8.8"
        fi
    fi
    
    # 5. ZiVPN
    if systemctl is-active --quiet zivpn; then
        echo -e "\n🔹 ${C_BOLD}ZiVPN${C_RESET}:"
        echo -e "   • UDP Port: 5667"
        echo -e "   • Forwarded Ports: 6000-19999"
    fi
    
    echo -e "${C_YELLOW}========================================${C_RESET}"

}

client_config_menu() {
    _select_user_interface "--- 📱 Generate Client Config ---"
    local u=$SELECTED_USER
    if [[ "$u" == "NO_USERS" || -z "$u" ]]; then return; fi
    
    # We need to find the password. It's in the DB.
    local pass=$(grep "^$u:" "$DB_FILE" | cut -d: -f2)
    generate_client_config "$u" "$pass"
}

format_rate_from_kbps() {
    local kbps=${1:-0}
    if (( kbps >= 1024 )); then
        printf "%d.%02d MB/s" $((kbps / 1024)) $((((kbps % 1024) * 100) / 1024))
    else
        printf "%d KB/s" "$kbps"
    fi
}

# Lightweight Bash Monitor (No vnStat required)
simple_live_monitor() {
    local iface=$1
    local rx_file="/sys/class/net/$iface/statistics/rx_bytes"
    local tx_file="/sys/class/net/$iface/statistics/tx_bytes"
    local interval=2
    local stop_monitor=0
    local rx1 tx1 rx2 tx2 rx_diff tx_diff rx_kbs tx_kbs rx_fmt tx_fmt

    if [[ -z "$iface" || ! -r "$rx_file" || ! -r "$tx_file" ]]; then
        echo -e "\n${C_RED}❌ Could not read interface statistics for '${iface:-unknown}'.${C_RESET}"
        return
    fi

    echo -e "\n${C_BLUE}⚡ Starting Lightweight Traffic Monitor for $iface...${C_RESET}"
    echo -e "${C_DIM}Press [Ctrl+C] to stop.${C_RESET}\n"

    read -r rx1 < "$rx_file"
    read -r tx1 < "$tx_file"

    printf "%-15s | %-15s\n" "⬇️ Download" "⬆️ Upload"
    echo "-----------------------------------"

    trap 'stop_monitor=1' INT TERM
    while (( ! stop_monitor )); do
        sleep "$interval"
        read -r rx2 < "$rx_file" || break
        read -r tx2 < "$tx_file" || break

        rx_diff=$((rx2 - rx1))
        tx_diff=$((tx2 - tx1))
        (( rx_diff < 0 )) && rx_diff=0
        (( tx_diff < 0 )) && tx_diff=0

        rx_kbs=$((rx_diff / 1024 / interval))
        tx_kbs=$((tx_diff / 1024 / interval))
        rx_fmt=$(format_rate_from_kbps "$rx_kbs")
        tx_fmt=$(format_rate_from_kbps "$tx_kbs")

        printf "\r%-15s | %-15s" "$rx_fmt" "$tx_fmt"

        rx1=$rx2
        tx1=$tx2
    done
    trap - INT TERM
    echo
}

traffic_monitor_menu() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 📈 Network Traffic Monitor ---${C_RESET}"
    
    # Find active interface
    local iface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
    
    echo -e "\nInterface: ${C_CYAN}${iface}${C_RESET}"
    
    echo -e "\n${C_BOLD}Select a monitoring option:${C_RESET}\n"
    printf "  ${C_CHOICE}[ 1]${C_RESET} %-40s\n" "⚡ Live Monitor ${C_DIM}(Lightweight, No Install)${C_RESET}"
    printf "  ${C_CHOICE}[ 2]${C_RESET} %-40s\n" "📊 View Total Traffic Since Boot"
    printf "  ${C_CHOICE}[ 3]${C_RESET} %-40s\n" "📅 Daily/Monthly Logs ${C_DIM}(Requires vnStat)${C_RESET}"
    
    echo -e "\n  ${C_WARN}[ 0]${C_RESET} ↩️ Return"
    echo
    read -p "👉 Enter choice: " t_choice
    case $t_choice in
        1) 
           simple_live_monitor "$iface"
           ;;
        2)
            local rx_total=$(cat /sys/class/net/$iface/statistics/rx_bytes)
            local tx_total=$(cat /sys/class/net/$iface/statistics/tx_bytes)
            local rx_mb=$((rx_total / 1024 / 1024))
            local tx_mb=$((tx_total / 1024 / 1024))
            echo -e "\n${C_BLUE}📊 Total Traffic (Since Boot):${C_RESET}"
            echo -e "   ⬇️ Download: ${C_WHITE}${rx_mb} MB${C_RESET}"
            echo -e "   ⬆️ Upload:   ${C_WHITE}${tx_mb} MB${C_RESET}"
            press_enter
            ;;
        3) 
           # vnStat Logic
           if ! command -v vnstat &> /dev/null; then
               echo -e "\n${C_YELLOW}⚠️ vnStat is not installed.${C_RESET}"
               echo -e "   This tool provides persistent history (Daily/Monthly reports)."
               echo -e "   It is lightweight but requires installation."
               read -p "👉 Install vnStat now? (y/n): " confirm
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                     echo -e "\n${C_BLUE}📦 Installing vnStat...${C_RESET}"
                     ff_pkg_install vnstat >/dev/null 2>&1 || {
                         echo -e "${C_RED}❌ Failed to install vnStat.${C_RESET}"
                         sleep 1
                         return
                     }
                     systemctl enable vnstat >/dev/null 2>&1
                     systemctl restart vnstat >/dev/null 2>&1
                    local default_iface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
                    vnstat --add -i "$default_iface" >/dev/null 2>&1
                    echo -e "${C_GREEN}✅ Installed.${C_RESET}"
                    sleep 1
               else
                    return
               fi
           fi
           echo
           vnstat -i "$iface"
           echo -e "\n${C_DIM}Run 'vnstat -d' or 'vnstat -m' manually for specific views.${C_RESET}"
           press_enter
           ;;
        *) return ;;
    esac
}

CONTENT_FILTER_CONF="$DB_DIR/domain_blocks.conf"

_filter_iptables_save() {
    ff_pkg_is_installed iptables-persistent &>/dev/null && netfilter-persistent save &>/dev/null
}

# ── Torrent blocking ──────────────────────────────────────────────────

_torrent_rules() {
    iptables -A FORWARD -m string --string "BitTorrent" --algo bm -j DROP
    iptables -A FORWARD -m string --string "BitTorrent protocol" --algo bm -j DROP
    iptables -A FORWARD -m string --string "peer_id=" --algo bm -j DROP
    iptables -A FORWARD -m string --string ".torrent" --algo bm -j DROP
    iptables -A FORWARD -m string --string "announce.php?passkey=" --algo bm -j DROP
    iptables -A FORWARD -m string --string "info_hash" --algo bm -j DROP
    iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
    iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
    iptables -A FORWARD -m string --string "magnet:?xt=urn:btih:" --algo bm -j DROP
    iptables -A FORWARD -m string --string "scrape.php" --algo bm -j DROP
    iptables -A FORWARD -m string --string "compact=1" --algo bm -j DROP
    iptables -A FORWARD -m string --string "no_peer_id=1" --algo bm -j DROP
    iptables -A FORWARD -m string --string "/announce" --algo bm -j DROP
}

_flush_torrent_rules() {
    for s in "BitTorrent" "BitTorrent protocol" "peer_id=" ".torrent" "announce.php?passkey=" \
             "torrent" "info_hash" "get_peers" "find_node" \
             "magnet:?xt=urn:btih:" "scrape.php" "compact=1" "no_peer_id=1" "/announce"; do
        iptables -D FORWARD -m string --string "$s" --algo bm -j DROP 2>/dev/null
        iptables -D OUTPUT   -m string --string "$s" --algo bm -j DROP 2>/dev/null
    done
}

# ── Adult-content blocking ────────────────────────────────────────────

_adult_domain_list() {
    cat <<'DOMAINS'
pornhub.com
xvideos.com
xhamster.com
xnxx.com
redtube.com
youporn.com
tube8.com
spankwire.com
brazzers.com
realitykings.com
bangbros.com
naughtyamerica.com
digitalplayground.com
chaturbate.com
stripchat.com
myfreecams.com
livejasmin.com
cam4.com
onlyfans.com
nhentai.net
hentaihaven.org
efukt.com
motherless.com
literotica.com
youjizz.com
xvideos2.com
xvideos3.com
hentaigasm.com
fakku.net
r18.com
javlibrary.com
javhd.com
txxx.com
porncom.com
porn300.com
beeg.com
xfree.com
eporner.com
porntrex.com
pornhd.com
hdsex.org
pornhubpremium.com
pornhub.net
pornhub.org
pornpics.com
sex.com
adult.com
xxx.com
slutload.com
extremetube.com
keezmovies.com
sunporno.com
pornoxo.com
pornktube.com
voyeurweb.com
CAM4.com
CAM4.es
strippoker.com
stripoker.com
adultwork.com
DOMAINS
}

_adult_rules() {
    # 1) Domain-level DPI rules (catches HTTP Host + HTTPS SNI)
    local domain
    while IFS= read -r domain; do
        [[ -z "$domain" || "$domain" == \#* || "$domain" == "DOMAINS" ]] && continue
        iptables -A FORWARD -m string --string "$domain" --algo bm -j DROP 2>/dev/null
    done < <(_adult_domain_list)

    # 2) Load user custom domains
    if [[ -f "$CONTENT_FILTER_CONF" ]]; then
        while IFS= read -r domain; do
            domain="${domain%%#*}"  # strip inline comments
            domain="${domain## }"    # trim leading space
            domain="${domain%% }"    # trim trailing space
            [[ -z "$domain" ]] && continue
            iptables -A FORWARD -m string --string "$domain" --algo bm -j DROP 2>/dev/null
        done < "$CONTENT_FILTER_CONF"
    fi

    # 3) URL-path keywords for HTTP plaintext
    for kw in "/porn" "/xxx" "/adult" "/hentai" "/nude" "/pornstar" "/erotic" \
              "/bdsm" "/fetish" "/sexo" "/incest" "/orgy" "/gangbang" "/blowjob" \
              "/cumshot" "/squirting" "/tranny" "/shemale" "/escort" "/pussy" \
              "/tits" "/boobs" "/milf" "/anal" "/dildo" "/vibrator" "/buttplug"; do
        iptables -A FORWARD -m string --string "$kw" --algo bm -j DROP 2>/dev/null
    done
}

_flush_adult_rules() {
    # Remove all adult domain rules
    local domain
    while IFS= read -r domain; do
        [[ -z "$domain" || "$domain" == \#* || "$domain" == "DOMAINS" ]] && continue
        iptables -D FORWARD -m string --string "$domain" --algo bm -j DROP 2>/dev/null
    done < <(_adult_domain_list)

    # Remove user custom domains
    if [[ -f "$CONTENT_FILTER_CONF" ]]; then
        while IFS= read -r domain; do
            domain="${domain%%#*}"
            domain="${domain## }"
            domain="${domain%% }"
            [[ -z "$domain" ]] && continue
            iptables -D FORWARD -m string --string "$domain" --algo bm -j DROP 2>/dev/null
        done < "$CONTENT_FILTER_CONF"
    fi

    # Remove URL-path keywords
    for kw in "/porn" "/xxx" "/adult" "/hentai" "/nude" "/pornstar" "/erotic" \
              "/bdsm" "/fetish" "/sexo" "/incest" "/orgy" "/gangbang" "/blowjob" \
              "/cumshot" "/squirting" "/tranny" "/shemale" "/escort" "/pussy" \
              "/tits" "/boobs" "/milf" "/anal" "/dildo" "/vibrator" "/buttplug"; do
        iptables -D FORWARD -m string --string "$kw" --algo bm -j DROP 2>/dev/null
    done
}

# ── Menu ──────────────────────────────────────────────────────────────

content_filter_menu() {
    while true; do
        clear; show_banner
        echo -e "${C_BOLD}${C_PURPLE}--- 🚫 Content Filtering ---${C_RESET}"

        local torrent_status="${C_STATUS_I}Disabled${C_RESET}"
        iptables -C FORWARD -m string --string "BitTorrent" --algo bm -j DROP 2>/dev/null && \
            torrent_status="${C_STATUS_A}Enabled${C_RESET}"

        local adult_status="${C_STATUS_I}Disabled${C_RESET}"
        iptables -C FORWARD -m string --string "pornhub.com" --algo bm -j DROP 2>/dev/null && \
            adult_status="${C_STATUS_A}Enabled${C_RESET}"

        local blocklist_count=0
        [[ -f "$CONTENT_FILTER_CONF" ]] && blocklist_count=$(grep -cvE '^\s*(#|$)' "$CONTENT_FILTER_CONF" 2>/dev/null || echo 0)

        echo -e "\n${C_WHITE}Torrent Blocking : ${torrent_status}"
        echo -e "Adult Blocking   : ${adult_status}${C_RESET}"
        echo -e "${C_DIM}Custom domains  : ${blocklist_count} entries in blocklist${C_RESET}"

        echo -e "\n${C_BOLD}Select an action:${C_RESET}\n"
        printf "  ${C_CHOICE}[ 1]${C_RESET} %-40s\n" "🔒 Enable Torrent Blocking"
        printf "  ${C_CHOICE}[ 2]${C_RESET} %-40s\n" "🔓 Disable Torrent Blocking"
        printf "  ${C_CHOICE}[ 3]${C_RESET} %-40s\n" "🔞 Enable Adult Content Block"
        printf "  ${C_CHOICE}[ 4]${C_RESET} %-40s\n" "🙈 Disable Adult Content Block"
        printf "  ${C_CHOICE}[ 5]${C_RESET} %-40s\n" "📝 Edit Custom Domain Blocklist"
        printf "  ${C_DANGER}[ 6]${C_RESET} %-40s\n" "🚫 Disable ALL Content Filters"
        echo -e "\n  ${C_WARN}[ 0]${C_RESET} ↩️ Return"
        echo
        read -p "👉 Enter choice: " f_choice

        case $f_choice in
            1)
                echo -e "\n${C_BLUE}🛡️ Enabling torrent blocking...${C_RESET}"
                _flush_torrent_rules
                _torrent_rules
                _filter_iptables_save
                echo -e "${C_GREEN}✅ Torrent Blocking Enabled.${C_RESET}"
                press_enter
                ;;
            2)
                echo -e "\n${C_BLUE}🔓 Disabling torrent blocking...${C_RESET}"
                _flush_torrent_rules
                _filter_iptables_save
                echo -e "${C_GREEN}✅ Torrent Blocking Disabled.${C_RESET}"
                press_enter
                ;;
            3)
                echo -e "\n${C_BLUE}🛡️ Enabling adult content blocking...${C_RESET}"
                _flush_adult_rules
                _adult_rules
                _filter_iptables_save
                echo -e "${C_GREEN}✅ Adult Content Blocking Enabled (${C_YELLOW}$(_adult_domain_list | grep -cvE '^(DOMAINS|#|$)' || true)${C_GREEN} domains + 23 URL keywords + custom blocklist).${C_RESET}"
                echo -e "${C_DIM}Note: HTTPS SNI matching catches most major adult sites; HTTP path matching adds coverage for plaintext connections.${C_RESET}"
                press_enter
                ;;
            4)
                echo -e "\n${C_BLUE}🙈 Disabling adult content blocking...${C_RESET}"
                _flush_adult_rules
                _filter_iptables_save
                echo -e "${C_GREEN}✅ Adult Content Blocking Disabled.${C_RESET}"
                press_enter
                ;;
            5)
                if [[ ! -f "$CONTENT_FILTER_CONF" ]]; then
                    cat > "$CONTENT_FILTER_CONF" <<-'CONF'
# Skylartech — Custom domain blocklist
# One domain or keyword per line.  Lines starting with # are ignored.
# These run alongside the built-in adult list.
# Examples:
# tiktok.com
# snapchat.com
# instagram.com
CONF
                fi
                ${EDITOR:-nano} "$CONTENT_FILTER_CONF"
                if iptables -C FORWARD -m string --string "pornhub.com" --algo bm -j DROP 2>/dev/null; then
                    echo -e "\n${C_BLUE}⚙️ Reloading adult block with updated blocklist...${C_RESET}"
                    _flush_adult_rules
                    _adult_rules
                    _filter_iptables_save
                    echo -e "${C_GREEN}✅ Blocklist reloaded.${C_RESET}"
                else
                    echo -e "\n${C_YELLOW}ℹ️ Adult blocking is off — changes apply when you enable it via option [3].${C_RESET}"
                fi
                press_enter
                ;;
            6)
                echo -e "\n${C_RED}⚠️ Disabling ALL content filters...${C_RESET}"
                _flush_torrent_rules
                _flush_adult_rules
                _filter_iptables_save
                echo -e "${C_GREEN}✅ All content filters disabled.${C_RESET}"
                press_enter
                ;;
            0) return ;;
            *) echo -e "\n${C_RED}❌ Invalid option.${C_RESET}" && sleep 1 ;;
        esac
    done
}

ssh_banner_menu() {
    while true; do
        show_banner
        local banner_mode
        local banner_status
        banner_mode=$(get_ssh_banner_mode)
        case "$banner_mode" in
            dynamic) banner_status="${C_STATUS_A}Dynamic${C_RESET}" ;;
            static) banner_status="${C_STATUS_A}Static${C_RESET}" ;;
            *) banner_status="${C_STATUS_I}Disabled${C_RESET}" ;;
        esac

        echo -e "\n   ${C_TITLE}═════════════════[ ${C_BOLD}🎨 SSH BANNER MODE: ${banner_status} ${C_RESET}${C_TITLE}]═════════════════${C_RESET}"
        echo -e "${C_DIM}Static mode uses 'Banner $SSH_BANNER_FILE'. Dynamic mode shows per-user account info.${C_RESET}"
        printf "     ${C_CHOICE}[ 1]${C_RESET} %-40s\n" "✨ Enable Dynamic Account Banner"
        printf "     ${C_CHOICE}[ 2]${C_RESET} %-40s\n" "📋 Paste or Replace Static Banner"
        printf "     ${C_CHOICE}[ 3]${C_RESET} %-40s\n" "👁️ View Current Static Banner"
        printf "     ${C_CHOICE}[ 4]${C_RESET} %-40s\n" "📝 Preview Dynamic Banner"
        printf "     ${C_DANGER}[ 5]${C_RESET} %-40s\n" "🗑️ Disable All SSH Banners"
        echo -e "   ${C_DIM}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${C_RESET}"
        echo -e "     ${C_WARN}[ 0]${C_RESET} ↩️ Return"
        echo
        if ! read -r -p "$(echo -e ${C_PROMPT}"👉 Select an option: "${C_RESET})" choice; then
            echo
            return
        fi
        case $choice in
            1)
                if setup_ssh_login_info; then
                    echo -e "\n${C_GREEN}✅ Dynamic account banner enabled.${C_RESET}"
                    echo -e "${C_DIM}Users will now see their account info banner instead of the static banner.${C_RESET}"
                fi
                press_enter
                ;;
            2) set_ssh_banner_paste ;;
            3) view_ssh_banner ;;
            4) preview_dynamic_ssh_banner ;;
            5) remove_ssh_banner ;;
            0) return ;;
            *) echo -e "\n${C_RED}❌ Invalid option.${C_RESET}" && sleep 1 ;;
        esac
    done
}

auto_reboot_menu() {
    clear; show_banner
    echo -e "${C_BOLD}${C_PURPLE}--- 🔄 Auto-Reboot Management ---${C_RESET}"
    
    # Check status
    local cron_check=$(crontab -l 2>/dev/null | grep "systemctl reboot")
    local status="${C_STATUS_I}Disabled${C_RESET}"
    if [[ -n "$cron_check" ]]; then
        status="${C_STATUS_A}Active (Midnight)${C_RESET}"
    fi
    
    echo -e "\n${C_WHITE}Current Status: ${status}${C_RESET}"
    
    echo -e "\n${C_BOLD}Select an action:${C_RESET}\n"
    printf "  ${C_CHOICE}[ 1]${C_RESET} %-40s\n" "🕐 Enable Daily Reboot (00:00 midnight)"
    printf "  ${C_CHOICE}[ 2]${C_RESET} %-40s\n" "❌ Disable Auto-Reboot"
    echo -e "\n  ${C_WARN}[ 0]${C_RESET} ↩️ Return"
    echo
    read -p "👉 Enter choice: " r_choice
    
    case $r_choice in
        1)
            # Remove existing to prevent duplicates
            (crontab -l 2>/dev/null | grep -v "systemctl reboot") | crontab -
            # Add new job
            (crontab -l 2>/dev/null; echo "0 0 * * * systemctl reboot") | crontab -
            echo -e "\n${C_GREEN}✅ Auto-reboot scheduled for every day at 00:00.${C_RESET}"
            press_enter
            ;;
        2)
            (crontab -l 2>/dev/null | grep -v "systemctl reboot") | crontab -
            echo -e "\n${C_GREEN}✅ Auto-reboot disabled.${C_RESET}"
            press_enter
            ;;
        *) return ;;
    esac
}


# ── NAT Port Forwarding ─────────────────────────────────────────────

NAT_RULES_CONF="$DB_DIR/nat_rules.conf"

_nat_default_rules() {
    cat <<'RULES'
# RETURN (TCP ports that bypass DNAT)
RETURN=22
RETURN=22741
RETURN=8888
RETURN=888
RETURN=80
RETURN=443
RETURN=887
RETURN=49222
# DNAT rules  (format: proto:port_or_range:target_port)
DNAT=tcp:1:65535:36712
DNAT=udp:6000:19999:5667
DNAT=udp:1:5999:36712
DNAT=udp:20000:65535:36712
RULES
}

_nat_load_rules() {
    if [[ ! -f "$NAT_RULES_CONF" ]]; then
        _nat_default_rules > "$NAT_RULES_CONF"
    fi
    mapfile -t NAT_RETURN < <(grep '^RETURN=' "$NAT_RULES_CONF" | cut -d= -f2)
    mapfile -t NAT_DNAT < <(grep '^DNAT=' "$NAT_RULES_CONF" | cut -d= -f2)
}

_nat_save_rules() {
    {
        for port in "${NAT_RETURN[@]}"; do echo "RETURN=$port"; done
        for rule in "${NAT_DNAT[@]}"; do echo "DNAT=$rule"; done
    } > "$NAT_RULES_CONF"
}

_nat_get_iface() {
    ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1
}

_nat_apply() {
    local iface
    iface=$(_nat_get_iface)
    [[ -z "$iface" ]] && iface="eth0"

    # Flush NAT PREROUTING chain
    iptables -t nat -F PREROUTING

    # Apply RETURN rules
    local port
    for port in "${NAT_RETURN[@]}"; do
        iptables -t nat -A PREROUTING -i "$iface" -p tcp --dport "$port" -j RETURN 2>/dev/null || true
    done

    # Apply DNAT rules
    local rule proto prange target
    for rule in "${NAT_DNAT[@]}"; do
        IFS=: read -r proto prange target <<< "$rule"
        iptables -t nat -A PREROUTING -i "$iface" -p "$proto" --dport "$prange" -j DNAT --to-destination ":${target}" 2>/dev/null || true
    done

    _filter_iptables_save
}

_nat_preview_commands() {
    local iface
    iface=$(_nat_get_iface)
    [[ -z "$iface" ]] && iface="eth0"

    echo -e "\n${C_YELLOW}  # Flush existing NAT PREROUTING${C_RESET}"
    echo "  iptables -t nat -F PREROUTING"
    echo
    if [[ ${#NAT_RETURN[@]} -gt 0 ]]; then
        echo -e "  ${C_YELLOW}# RETURN rules (ports bypassing DNAT)${C_RESET}"
        for port in "${NAT_RETURN[@]}"; do
            echo "  iptables -t nat -A PREROUTING -i $iface -p tcp --dport $port -j RETURN"
        done
        echo
    fi
    echo -e "  ${C_YELLOW}# DNAT rules${C_RESET}"
    local rule proto prange target
    for rule in "${NAT_DNAT[@]}"; do
        IFS=: read -r proto prange target <<< "$rule"
        echo "  iptables -t nat -A PREROUTING -i $iface -p $proto --dport $prange -j DNAT --to-destination :${target}"
    done
}

_nat_show_rules() {
    _nat_load_rules
    local i

    if [[ ${#NAT_RETURN[@]} -gt 0 ]]; then
        echo -e "\n  ${C_ACCENT}===== RETURN (skip DNAT — TCP only) =====${C_RESET}"
        for i in "${!NAT_RETURN[@]}"; do
            printf "  ${C_CHOICE}[R%2s]${C_RESET}  %-4s  %-17s  →  %s\n" "$((i+1))" "TCP" "${NAT_RETURN[$i]}" "RETURN"
        done
    fi

    if [[ ${#NAT_DNAT[@]} -gt 0 ]]; then
        echo -e "\n  ${C_ACCENT}===== DNAT (port forwarding) =====${C_RESET}"
        for i in "${!NAT_DNAT[@]}"; do
            local rule="${NAT_DNAT[$i]}"
            local proto prange target label
            IFS=: read -r proto prange target <<< "$rule"
            label=""
            [[ "$target" == "5667" ]] && label="  (ZiVPN)"
            printf "  ${C_CHOICE}[D%2s]${C_RESET}  %-4s  %-17s  →  %-5s%s\n" "$((i+1))" "${proto^^}" "$prange" "$target" "$label"
        done
    fi
}

apply_default_nat_rules() {
    echo -e "${C_BLUE}🔥 Applying default NAT port forwarding rules...${C_RESET}"
    _nat_default_rules > "$NAT_RULES_CONF"
    _nat_load_rules
    _nat_apply
    echo -e "${C_GREEN}✅ Default NAT rules applied (8 RETURN + 4 DNAT).${C_RESET}"
}

nat_forward_menu() {
    while true; do
        clear; show_banner
        echo -e "\n   ${C_TITLE}═════════════════[ ${C_BOLD}🔥 NAT PORT FORWARDING ${C_RESET}${C_TITLE}]═════════════════${C_RESET}"
        echo -e "   ${C_DIM}Manage iptables PREROUTING DNAT + RETURN rules${C_RESET}"
        _nat_show_rules

        echo
        echo -e "   ${C_BOLD}Actions:${C_RESET}\n"
        printf "     ${C_CHOICE}[ 1]${C_RESET} %-35s\n" "➕ Add RETURN port (TCP)"
        printf "     ${C_CHOICE}[ 2]${C_RESET} %-35s\n" "🗑️  Remove RETURN port"
        printf "     ${C_CHOICE}[ 3]${C_RESET} %-35s\n" "➕ Add DNAT rule"
        printf "     ${C_CHOICE}[ 4]${C_RESET} %-35s\n" "✏️  Edit DNAT rule"
        printf "     ${C_CHOICE}[ 5]${C_RESET} %-35s\n" "🗑️  Delete rule"
        printf "     ${C_CHOICE}[ 6]${C_RESET} %-35s\n" "🔄 Reset to defaults"
        printf "     ${C_CHOICE}[ 7]${C_RESET} %-35s\n" "👁️  Preview & Apply All"
        printf "     ${C_CHOICE}[ 8]${C_RESET} %-35s\n" "💾 Save (iptables-persistent)"
        echo -e "   ${C_DIM}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${C_RESET}"
        echo -e "     ${C_WARN}[ 0]${C_RESET} ↩️ Return"
        echo
        read -r -p "$(echo -e ${C_PROMPT}"👉 Select an option: "${C_RESET})" choice

        case $choice in
            1)
                _nat_load_rules
                read -p "👉 Enter TCP port to exclude from DNAT: " port
                if [[ -z "$port" || ! "$port" =~ ^[0-9]+$ ]]; then
                    echo -e "\n${C_RED}❌ Invalid port.${C_RESET}"; sleep 1; continue
                fi
                if printf '%s\n' "${NAT_RETURN[@]}" | grep -qx "$port"; then
                    echo -e "\n${C_YELLOW}⚠️ Port $port is already a RETURN exception.${C_RESET}"; sleep 1; continue
                fi
                NAT_RETURN+=("$port")
                # Sort numerically
                IFS=$'\n' NAT_RETURN=($(sort -n <<<"${NAT_RETURN[*]}")); unset IFS
                _nat_save_rules
                _nat_apply
                echo -e "\n${C_GREEN}✅ Port $port added as RETURN exception.${C_RESET}"
                press_enter
                ;;
            2)
                _nat_load_rules
                if [[ ${#NAT_RETURN[@]} -eq 0 ]]; then
                    echo -e "\n${C_YELLOW}⚠️ No RETURN rules to remove.${C_RESET}"; sleep 1; continue
                fi
                echo -e "\n${C_BOLD}Select RETURN port to remove:${C_RESET}\n"
                for i in "${!NAT_RETURN[@]}"; do
                    printf "  ${C_CHOICE}[%2s]${C_RESET}  TCP  %s\n" "$((i+1))" "${NAT_RETURN[$i]}"
                done
                echo -e "\n  ${C_WARN}[ 0]${C_RESET} Cancel"
                read -p "👉 Choice: " idx
                [[ "$idx" == "0" ]] && continue
                if [[ ! "$idx" =~ ^[0-9]+$ || "$idx" -lt 1 || "$idx" -gt "${#NAT_RETURN[@]}" ]]; then
                    echo -e "\n${C_RED}❌ Invalid.${C_RESET}"; sleep 1; continue
                fi
                local removed="${NAT_RETURN[$((idx-1))]}"
                unset "NAT_RETURN[$((idx-1))]"
                NAT_RETURN=("${NAT_RETURN[@]}")
                _nat_save_rules
                _nat_apply
                echo -e "\n${C_GREEN}✅ RETURN port $removed removed.${C_RESET}"
                press_enter
                ;;
            3)
                _nat_load_rules
                echo -e "\n${C_DIM}Add a new DNAT forwarding rule.${C_RESET}"
                read -p "👉 Protocol (tcp/udp) [tcp]: " proto
                proto=${proto:-tcp}
                [[ "$proto" != "tcp" && "$proto" != "udp" ]] && proto="tcp"
                read -p "👉 Port or range (e.g. 8080 or 8000:9000): " prange
                [[ -z "$prange" ]] && echo -e "\n${C_RED}❌ Required.${C_RESET}"; sleep 1; continue
                read -p "👉 Forward to port: " target
                [[ -z "$target" || ! "$target" =~ ^[0-9]+$ ]] && echo -e "\n${C_RED}❌ Invalid port.${C_RESET}"; sleep 1; continue
                NAT_DNAT+=("$proto:$prange:$target")
                _nat_save_rules
                _nat_apply
                echo -e "\n${C_GREEN}✅ DNAT rule added: $proto $prange → $target${C_RESET}"
                press_enter
                ;;
            4)
                _nat_load_rules
                if [[ ${#NAT_DNAT[@]} -eq 0 ]]; then
                    echo -e "\n${C_YELLOW}⚠️ No DNAT rules to edit.${C_RESET}"; sleep 1; continue
                fi
                echo -e "\n${C_BOLD}Select DNAT rule to edit:${C_RESET}\n"
                for i in "${!NAT_DNAT[@]}"; do
                    local rule="${NAT_DNAT[$i]}"
                    local p prot range tgt
                    IFS=: read -r prot range tgt <<< "$rule"
                    printf "  ${C_CHOICE}[%2s]${C_RESET}  %-4s  %-17s → %s\n" "$((i+1))" "${prot^^}" "$range" "$tgt"
                done
                echo -e "\n  ${C_WARN}[ 0]${C_RESET} Cancel"
                read -p "👉 Choice: " idx
                [[ "$idx" == "0" ]] && continue
                if [[ ! "$idx" =~ ^[0-9]+$ || "$idx" -lt 1 || "$idx" -gt "${#NAT_DNAT[@]}" ]]; then
                    echo -e "\n${C_RED}❌ Invalid.${C_RESET}"; sleep 1; continue
                fi
                local old="${NAT_DNAT[$((idx-1))]}"
                local oprot orange otarget
                IFS=: read -r oprot orange otarget <<< "$old"
                echo -e "\n${C_DIM}Editing: $oprot $orange → $otarget${C_RESET}"
                read -p "👉 Protocol (tcp/udp) [$oprot]: " nproto
                nproto=${nproto:-$oprot}
                read -p "👉 Port or range [$orange]: " nrange
                nrange=${nrange:-$orange}
                read -p "👉 Forward to port [$otarget]: " ntarget
                ntarget=${ntarget:-$otarget}
                NAT_DNAT[$((idx-1))]="$nproto:$nrange:$ntarget"
                _nat_save_rules
                _nat_apply
                echo -e "\n${C_GREEN}✅ DNAT rule updated.${C_RESET}"
                press_enter
                ;;
            5)
                _nat_load_rules
                local total=$(( ${#NAT_RETURN[@]} + ${#NAT_DNAT[@]} ))
                if [[ total -eq 0 ]]; then
                    echo -e "\n${C_YELLOW}⚠️ No rules to delete.${C_RESET}"; sleep 1; continue
                fi
                echo -e "\n${C_BOLD}Select rule to delete:${C_RESET}\n"
                local i idx
                for i in "${!NAT_RETURN[@]}"; do
                    printf "  ${C_CHOICE}[R%2s]${C_RESET}  RETURN  TCP  %s\n" "$((i+1))" "${NAT_RETURN[$i]}"
                done
                for i in "${!NAT_DNAT[@]}"; do
                    local rule="${NAT_DNAT[$i]}"
                    local prot range tgt
                    IFS=: read -r prot range tgt <<< "$rule"
                    printf "  ${C_CHOICE}[D%2s]${C_RESET}  DNAT    %-4s %s → %s\n" "$((i+1))" "${prot^^}" "$range" "$tgt"
                done
                echo -e "\n  ${C_WARN}[ 0]${C_RESET} Cancel"
                read -p "👉 Enter code (e.g. R1 or D3): " code
                [[ "$code" == "0" ]] && continue
                if [[ "$code" =~ ^[Rr]([0-9]+)$ ]]; then
                    idx="${BASH_REMATCH[1]}"
                    if [[ "$idx" -ge 1 && "$idx" -le "${#NAT_RETURN[@]}" ]]; then
                        local removed="${NAT_RETURN[$((idx-1))]}"
                        unset "NAT_RETURN[$((idx-1))]"
                        NAT_RETURN=("${NAT_RETURN[@]}")
                        _nat_save_rules; _nat_apply
                        echo -e "\n${C_GREEN}✅ RETURN $removed deleted.${C_RESET}"
                    else
                        echo -e "\n${C_RED}❌ Invalid index.${C_RESET}"; sleep 1; continue
                    fi
                elif [[ "$code" =~ ^[Dd]([0-9]+)$ ]]; then
                    idx="${BASH_REMATCH[1]}"
                    if [[ "$idx" -ge 1 && "$idx" -le "${#NAT_DNAT[@]}" ]]; then
                        local removed="${NAT_DNAT[$((idx-1))]}"
                        unset "NAT_DNAT[$((idx-1))]"
                        NAT_DNAT=("${NAT_DNAT[@]}")
                        _nat_save_rules; _nat_apply
                        echo -e "\n${C_GREEN}✅ DNAT $removed deleted.${C_RESET}"
                    else
                        echo -e "\n${C_RED}❌ Invalid index.${C_RESET}"; sleep 1; continue
                    fi
                else
                    echo -e "\n${C_RED}❌ Invalid format. Use R1 or D3.${C_RESET}"; sleep 1; continue
                fi
                press_enter
                ;;
            6)
                echo -e "\n${C_YELLOW}⚠️ This will reset to the 8 RETURN + 4 DNAT defaults and wipe custom rules.${C_RESET}"
                read -p "👉 Type 'yes' to confirm: " confirm
                if [[ "$confirm" != "yes" ]]; then
                    echo -e "\n${C_GREEN}Cancelled.${C_RESET}"; sleep 1; continue
                fi
                apply_default_nat_rules
                press_enter
                ;;
            7)
                _nat_load_rules
                echo -e "\n${C_BOLD}${C_PURPLE}--- 👁️  Preview: Commands to be applied ---${C_RESET}"
                _nat_preview_commands
                echo
                read -p "$(echo -e ${C_PROMPT}"👉 Press [Enter] to apply, or [0] to cancel: "${C_RESET})" confirm
                if [[ "$confirm" == "0" ]]; then
                    echo -e "\n${C_GREEN}Cancelled.${C_RESET}"; sleep 1; continue
                fi
                _nat_apply
                echo -e "\n${C_GREEN}✅ NAT rules applied live.${C_RESET}"
                press_enter
                ;;
            8)
                echo -e "\n${C_BLUE}💾 Saving iptables rules...${C_RESET}"
                _filter_iptables_save
                echo -e "\n${C_GREEN}✅ Saved (iptables-persistent).${C_RESET}"
                press_enter
                ;;
            0) return ;;
            *) echo -e "\n${C_RED}❌ Invalid option.${C_RESET}" && sleep 1 ;;
        esac
    done
}

press_enter() {
    echo -e "\nPress ${C_YELLOW}[Enter]${C_RESET} to return to the menu..." && read -r || true
}
invalid_option() {
    echo -e "\n${C_RED}❌ Invalid option.${C_RESET}" && sleep 1
}

main_menu() {
    while true; do
        export UNINSTALL_MODE="interactive"
        show_banner
        
        echo
        echo -e "   ${C_TITLE}─────────────────────────────────────────────────────${C_RESET}"
        echo -e "   ${C_TITLE}              👤 USER MANAGEMENT              ${C_RESET}"
        echo -e "   ${C_TITLE}─────────────────────────────────────────────────────${C_RESET}"
        printf "\033[6G${C_CHOICE}[%2s]${C_RESET}\033[11G%-26s\033[38G${C_CHOICE}[%2s]${C_RESET}\033[43G%-26s\033[K\n" "1" "🌟 Create New User" "7" "📋 List Users"
        printf "\033[6G${C_CHOICE}[%2s]${C_RESET}\033[11G%-26s\033[38G${C_CHOICE}[%2s]${C_RESET}\033[43G%-26s\033[K\n" "2" "🗑️ Delete User" "8" "📱 User Config"
        printf "\033[6G${C_CHOICE}[%2s]${C_RESET}\033[11G%-26s\033[38G${C_CHOICE}[%2s]${C_RESET}\033[43G%-26s\033[K\n" "3" "🔄 Renew User" "9" "⏱️ Trial Account"
        printf "\033[6G${C_CHOICE}[%2s]${C_RESET}\033[11G%-26s\033[38G${C_CHOICE}[%2s]${C_RESET}\033[43G%-26s\033[K\n" "4" "🔒 Lock User" "10" "👥 Bulk Users"
        printf "\033[6G${C_CHOICE}[%2s]${C_RESET}\033[11G%-26s\033[38G${C_CHOICE}[%2s]${C_RESET}\033[43G%-26s\033[K\n" "5" "🔓 Unlock User" "11" "👁️ User Details"
        printf "\033[6G${C_CHOICE}[%2s]${C_RESET}\033[11G%-26s\033[38G${C_ORANGE}[%2s]${C_RESET}\033[43G%-26s\033[K\n" "6" "📝 Edit User" "18" "💾 Backup Users"
        
        echo
        echo -e "   ${C_TITLE}─────────────────────────────────────────────────────${C_RESET}"
        echo -e "   ${C_TITLE}           🛠️ TOOLS & SETTINGS            ${C_RESET}"
        echo -e "   ${C_TITLE}─────────────────────────────────────────────────────${C_RESET}"
        printf "\033[6G${C_CHOICE}[%2s]${C_RESET}\033[11G%-26s\033[38G${C_CHOICE}[%2s]${C_RESET}\033[43G%-26s\033[K\n" "12" "🔌 Protocol Manager" "13" "📈 Traffic Monitor"
        printf "\033[6G${C_CHOICE}[%2s]${C_RESET}\033[11G%-26s\033[38G${C_CHOICE}[%2s]${C_RESET}\033[43G%-26s\033[K\n" "14" "🔞 Content Filter" "15" "🎨 SSH Banner"
        printf "\033[6G${C_CHOICE}[%2s]${C_RESET}\033[11G%-26s\033[38G${C_CHOICE}[%2s]${C_RESET}\033[43G%-26s\033[K\n" "16" "🔄 Auto-Reboot Task" "17" "🌐 Set Domain"
        printf "\033[6G${C_CHOICE}[%2s]${C_RESET}\033[11G%-26s\033[38G${C_CHOICE}[%2s]${C_RESET}\033[43G%-26s\033[K\n" "19" "📥 Restore Users" "20" "🧹 Cleanup Expired"
        printf "\033[6G${C_CHOICE}[%2s]${C_RESET}\033[11G%-26s\033[38G${C_CHOICE}[%2s]${C_RESET}\033[43G%-26s\033[K\n" "21" "🔥 NAT Forwarding" "" ""

        echo
        echo -e "   ${C_DANGER}─────────────────────────────────────────────────────${C_RESET}"
        echo -e "   ${C_DANGER}                🔥 DANGER ZONE                 ${C_RESET}"
        echo -e "   ${C_DANGER}─────────────────────────────────────────────────────${C_RESET}"
        echo -e "     ${C_DANGER}[99]${C_RESET} Uninstall Script             ${C_WARN}[ 0]${C_RESET} Exit"
        echo
        if ! read -r -p "$(echo -e ${C_PROMPT}"👉 Select an option: "${C_RESET})" choice; then
            echo
            exit 0
        fi
        case $choice in
            1) create_user; press_enter ;;
            2) delete_user; press_enter ;;
            3) renew_user; press_enter ;;
            4) lock_user; press_enter ;;
            5) unlock_user; press_enter ;;
            6) edit_user; press_enter ;;
            7) list_users; press_enter ;;
            8) client_config_menu; press_enter ;;
            9) create_trial_account; press_enter ;;
            10) bulk_create_users; press_enter ;;
            11) view_user_details ;;
            
            12) protocol_menu ;;
            13) traffic_monitor_menu ;;
            14) content_filter_menu ;;
            
            15) ssh_banner_menu ;;
            16) auto_reboot_menu ;;
            17) set_domain ;;
            18) backup_user_data; press_enter ;;
            19) restore_user_data; press_enter ;;
            20) cleanup_expired; press_enter ;;
            21) nat_forward_menu ;;
            
            99) uninstall_script ;;
            0) exit 0 ;;
            *) invalid_option ;;
        esac
    done
}

if [[ "$1" == "--install-setup" ]]; then
    initial_setup
    exit 0
fi

require_interactive_terminal
sync_runtime_components_if_needed
main_menu
