# Darwin environment variables
$env.__NIX_DARWIN_SET_ENVIRONMENT_DONE = 1 

$env.PATH = [
    $"($env.HOME)/.nix-profile/bin"
    $"/etc/profiles/per-user/($env.USER)/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/usr/sbin"
    "/bin"
    "/sbin"
]
$env.EDITOR = "nvim"
$env.NIX_PATH = [
    $"darwin-config=($env.HOME)/.nixpkgs/darwin-configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
]
$env.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
$env.PAGER = "less -R"
$env.TERMINFO_DIRS = [
    $"($env.HOME)/.nix-profile/share/terminfo"
    $"/etc/profiles/per-user/($env.USER)/share/terminfo"
    "/run/current-system/sw/share/terminfo"
    "/nix/var/nix/profiles/default/share/terminfo"
    "/usr/share/terminfo"
]
$env.XDG_CONFIG_DIRS = [
    $"($env.HOME)/.nix-profile/etc/xdg"
    $"/etc/profiles/per-user/($env.USER)/etc/xdg"
    "/run/current-system/sw/etc/xdg"
    "/nix/var/nix/profiles/default/etc/xdg"
]
$env.XDG_DATA_DIRS = [
    $"($env.HOME)/.nix-profile/share"
    $"/etc/profiles/per-user/($env.USER)/share"
    "/run/current-system/sw/share"
    "/nix/var/nix/profiles/default/share"
]
$env.TERM = $env.TERM
$env.NIX_USER_PROFILE_DIR = $"/nix/var/nix/profiles/per-user/($env.USER)"
$env.NIX_PROFILES = [
    "/nix/var/nix/profiles/default"
    "/run/current-system/sw"
    $"/etc/profiles/per-user/($env.USER)"
    $"($env.HOME)/.nix-profile"
]

if ($"($env.HOME)/.nix-defexpr/channels" | path exists) {
    $env.NIX_PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/.nix-defexpr/channels")
}

if (false in (ls -l `/nix/var/nix`| where type == dir | where name == "/nix/var/nix/db" | get mode | str contains "w")) {
    $env.NIX_REMOTE = "daemon"
}

# Darwin END

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

# def create_left_prompt [] {
#     mut home = ""
#     try {
#         if $nu.os-info.name == "windows" {
#             $home = $env.USERPROFILE
#         } else {
#             $home = $env.HOME
#         }
#     }
#
#     let dir = ([
#         ($env.PWD | str substring 0..($home | str length) | str replace $home "~"),
#         ($env.PWD | str substring ($home | str length)..)
#     ] | str join)
#
#     let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
#     let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
#     let path_segment = $"($path_color)($dir)"
#
#     $path_segment | str replace --all (char path_sep) $"($separator_color)/($path_color)"
# }

def create_right_prompt [] {
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | date format '%Y/%m/%d %r')
    ] | str join | str replace --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

# Use nushell functions to define your right and left prompt
# $env.PROMPT_COMMAND = {|| create_left_prompt }
# $env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }
# The prompt indicators are environmental variables that represent
# the state of the prompt
# $env.PROMPT_INDICATOR = {|| " > " }
# $env.PROMPT_INDICATOR_VI_INSERT = {|| " : " }
# $env.PROMPT_INDICATOR_VI_NORMAL = {|| " > " }
# $env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    # ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    # ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]
#
# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
$env.PATH = ($env.PATH | split row (char esep) | prepend '.cargo/bin:.local/bin:')


# # Shell Variables
# Default programs:
load-env {
    EDITOR: 'nvim',
    TERMINAL: 'ghostty',
    TERMINAL_PROG: 'ghosstty',
    BROWSER: 'zen-browser'
}

# Change the default crypto/weather monitor sites.
load-env {
    CRYPTOURL: "rate.sx",
    WTTRURL: "wttr.in"
}

# ~/ Clean-up:
load-env {
    XDG_CONFIG_HOME: $"($env.HOME)/.config",
    XDG_DATA_HOME: $"($env.HOME)/.local/share"
    XDG_CACHE_HOME: $"($env.HOME)/.cache"
}

load-env {
    NOTMUCH_CONFIG: $"($env.XDG_CONFIG_HOME)/notmuch-config"
    GTK2_RC_FILES: $"($env.XDG_CONFIG_HOME)/gtk-2.0/gtkrc-2.0"
    WGETRC: $"($env.XDG_CONFIG_HOME)/wget/wgetrc"
    INPUTRC: $"($env.XDG_CONFIG_HOME)/shell/inputrc"
    ZDOTDIR: $"($env.XDG_CONFIG_HOME)/zsh"
    #GNUPGHOME="$XDG_DATA_HOME/gnupg"
    WINEPREFIX: $"($env.XDG_DATA_HOME)/wineprefixes/default"
    KODI_DATA: $"($env.XDG_DATA_HOME)/kodi"
    PASSWORD_STORE_DIR: $"($env.XDG_DATA_HOME)/password-store"
    ANDROID_SDK_HOME: $"($env.XDG_CONFIG_HOME)/android"
    CARGO_HOME: $"($env.XDG_DATA_HOME)/cargo"
    GOPATH: $"($env.XDG_DATA_HOME)/go"
    GOMODCACHE: $"($env.XDG_CACHE_HOME)/go/mod"
    ANSIBLE_CONFIG: $"($env.XDG_CONFIG_HOME)/ansible/ansible.cfg"
    UNISON: $"($env.XDG_DATA_HOME)/unison"
    HISTFILE: $"($env.XDG_DATA_HOME)/history"
    MBSYNCRC: $"($env.XDG_CONFIG_HOME)/mbsync/config"
    ELECTRUMDIR: $"($env.XDG_DATA_HOME)/electrum"
    PYTHONSTARTUP: $"($env.XDG_CONFIG_HOME)/python/pythonrc"
    SQLITE_HISTORY: $"($env.XDG_DATA_HOME)/sqlite_history"
}

# load-env {
#     AWS_ACCESS_KEY_ID: "admin"
#     AWS_SECRET_ACCESS_KEY: "password"
#     AWS_ENDPOINT: "http://localhost:9000"
#     AWS_DEFAULT_REGION: "us-east-1"
# }

# $env.http_proxy = "http://192.168.1.113:8080"
# $env.https_proxy = "http://192.168.1.113:8080"

$env.PATH = ($env.PATH | prepend $"($env.GOPATH)/bin" | prepend $"($env.CARGO_HOME)/bin")

# Other program settings:
# Starship
$env.STARSHIP_SHELL = "nu"
mkdir ~/.cache/starship

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = " > "
$env.PROMPT_INDICATOR_VI_INSERT = ": "
$env.PROMPT_INDICATOR_VI_NORMAL = "〉"
$env.PROMPT_MULTILINE_INDICATOR = "::: "

# Carapace completions
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
# fnm setup
if not (which fnm | is-empty) {
  ^fnm env --json | from json | load-env
  # Checking `Path` for Windows
  let path = if 'Path' in $env { $env.Path } else { $env.PATH }
  let node_path = if (sys host).name == 'Windows' {
    $"($env.FNM_MULTISHELL_PATH)"
  } else {
    $"($env.FNM_MULTISHELL_PATH)/bin"
  }
  $env.PATH = ($path | prepend [ $node_path ])
}

$env.PATH = ($env.PATH | prepend $"($env.HOME)/.surrealdb")
$env.GOBIN = $"($env.GOPATH)/bin"

$env.BUN_INSTALL = $"($env.HOME)/.bun" 
$env.PATH = ($env.PATH | prepend $"($env.BUN_INSTALL)/bin")

# Secrets
open $"($env.HOME)/secrets/.env" | from toml | load-env

# sccache
# $env.SCCACHE_DIRECT = true 
$env.SCCACHE_CACHE_SIZE = "12G"

$env.NODE_OPTIONS = "--max-old-space-size=8192"

# should be at the END
zoxide init nushell | save -f ($nu.default-config-dir | path join '.zoxide.nu')

