#!/bin/zsh

OS=macos # macos | linux | windows
DWN_VERSION=
INSTALLER_LOG=install
INSTALLER_STEP=step

FILE_ZSHRC="$HOME/.zshrc"
FILE_DWN_VERSION="bin/version"

INSTALLER_DWN_VERSION=$(head -n 1 "./$FILE_DWN_VERSION") # Format: 0.0.0

# Error codes.
ERROR_OS_UNKNOWN=001
ERROR_OS_UNSUPPORTED=002
ERROR_PERMISSIONS_BIN_DIR=010
ERROR_ENV_VARS_APPEND=020
ERROR_ENV_VARS_WRITE=021

# Error code messages.
typeset -A ERROR=()
ERROR[$ERROR_OS_UNKNOWN]="unknown operating system: $OSTYPE"
ERROR[$ERROR_OS_UNSUPPORTED]="unsupported operating system: $OS"
ERROR[$ERROR_ENV_VARS_APPEND]="cannot append environment variables to ~/.zshrc"
ERROR[$ERROR_ENV_VARS_WRITE]="cannot write environment variables to ~/.zshrc"
ERROR[$ERROR_PERMISSIONS_BIN_DIR]="error setting permissions of bin directory"

# Print error code and message, and exit with non-zero code.
# $1 ERROR code.
function log_error_exit() {
  echo "[$INSTALLER_LOG] $INSTALLER_STEP [ERROR:$1]:\t$ERROR[$1]" && exit 1
}

# Print warning log message.
# $1 warning message.
function log_warn() {
  echo "[$INSTALLER_LOG] $INSTALLER_STEP [WARN]:\t$1"
}

# Print log message.
# $1 log message.
function log() {
  echo "[$INSTALLER_LOG] $INSTALLER_STEP\t$1"
}

# Set the operating system.
# Error if not supported.
function set_os() {
  INSTALLER_STEP=os_check

  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS=macos
  elif [[ "$OSTYPE" == "linux"* ]]; then
    OS=linux
  elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    OS=windows
    log_error_exit $ERROR_OS_UNSUPPORTED
  else
    log_error_exit $ERROR_OS_UNKNOWN
  fi
  log "$OS"
}

# Set permissions of script files in bin directory.
# Important because cp will preserve permissions later.
function set_bin_dir_permissions() {
  INSTALLER_STEP=permissions

  chmod 755 ./bin/dwn || log_error_exit $ERROR_PERMISSIONS_BIN_DIR
  log "dwn permissions set!"
}

# Add environment variables to zsh.
# Case handlers:
# - No ~/.zshrc file.
# - Env variables already exist.
function set_env_vars() {
  INSTALLER_STEP=env_vars
  local ENV_VARIABLES_TEXT='\n# dwn\nexport DWN_INSTALL="$HOME/.dwn"\nexport PATH="$DWN_INSTALL/bin:$PATH"'

  # Check if the file exists.
  if [[ -f "$FILE_ZSHRC" ]]; then
    # Append text if not in file.
    if ! grep -qzo "$ENV_VARIABLES_TEXT" "$FILE_ZSHRC"; then
      echo "$ENV_VARIABLES_TEXT" >>"$FILE_ZSHRC" || log_error_exit $ERROR_ENV_VARS_APPEND
    else
      log "environment variables already exist!"
    fi
  else
    # Create file with text.
    echo "$ENV_VARIABLES_TEXT" >"$FILE_ZSHRC" || log_error_exit $ERROR_ENV_VARS_WRITE
    log "environment variables added!"
  fi
}

function set_config_dir() {
  INSTALLER_STEP=config_dir
  local version_file="$DWN_INSTALL/$FILE_DWN_VERSION"
  local version_pattern="^[0-9]+\.[0-9]+\.[0-9]+$"
  local version=""

  # Check if the directory exists.
  if [[ -d "$DWN_INSTALL" ]]; then
    # echo "Directory exists"
    # # Check version file.
    # if [[ -f $version_file ]]; then
    #   echo "Version file exists"
    #   version=$(head -n 1 "$version_file")
    #   if [[ "$version" =~ $version_pattern ]]; then
    #     echo "Version file is valid"
    #     if [[ "$version" != "$INSTALLER_DWN_VERSION" ]]; then
    #       echo "Different version"
    #     fi
    #   else
    #     # do something if not valid version
    #   fi
    # else
    #   echo "Version file does not exist"
    # fi
    log 'unsupported operation for now' && exit 0
  else
    # Fresh install.
    DWN_VERSION=$INSTALLER_DWN_VERSION
    mkdir -p -m 755 $DWN_INSTALL
    cp -Rp ./bin $DWN_INSTALL
    log "created at $DWN_INSTALL"
  fi
}

set_os
set_bin_dir_permissions
set_env_vars
set_config_dir

echo
echo "installed dwn"
echo "=> v$DWN_VERSION"
echo "to check if the installation was successful, use"
echo
echo "    dwn -v"
echo
