#!/bin/zsh

SYSTEM_OS=macos # macos | linux | windows
DWN_VERSION=
INSTALLER_LOG=
INSTALLER_STEP=start
ENV_VARIABLES_TEXT='\n# dwn\nexport DWN_INSTALL="$HOME/.dwn"\nexport PATH="$DWN_INSTALL/bin:$PATH"'

DIR_TEMP="$(mktemp -d)"

FILE_ZSHRC="$HOME/.zshrc"
FILE_DWN_VERSION="bin/version"

INSTALLER_DWN_VERSION=$(head -n 1 "./$FILE_DWN_VERSION") # Format: 0.0.0

# error codes.
ERROR_SYSTEM_OS_UNKNOWN=001
ERROR_SYSTEM_OS_UNSUPPORTED=002
ERROR_PERMISSIONS_BIN_DIR=010
ERROR_ENV_VARS_APPEND=020
ERROR_ENV_VARS_WRITE=021
ERROR_ENV_VARS_REMOVE=022
ERROR_REMOVE_CONFIG_DIR=030

# error code messages.
typeset -A ERROR=()
ERROR[$ERROR_SYSTEM_OS_UNKNOWN]="unknown operating system: $OSTYPE"
ERROR[$ERROR_SYSTEM_OS_UNSUPPORTED]="unsupported operating system: $SYSTEM_OS"
ERROR[$ERROR_ENV_VARS_APPEND]="cannot append environment variables to ~/.zshrc"
ERROR[$ERROR_ENV_VARS_WRITE]="cannot write environment variables to ~/.zshrc"
ERROR[$ERROR_ENV_VARS_REMOVE]="error removing environment variables from ~/.zshrc"
ERROR[$ERROR_PERMISSIONS_BIN_DIR]="error setting permissions of bin directory"
ERROR[$ERROR_REMOVE_CONFIG_DIR]="error removing dwn config directory"

# print error code and message, and exit with non-zero code.
# $1 ERROR code.
function log_error_exit() {
  echo "[$INSTALLER_LOG] $INSTALLER_STEP [ERROR:$1]:\t$ERROR[$1]" && exit 1
}

# print warning log message.
# $1 warning message.
function log_warn() {
  echo "[$INSTALLER_LOG] $INSTALLER_STEP [WARN]:\t$1"
}

# print log message.
# $1 log message.
function log() {
  echo "[$INSTALLER_LOG] $INSTALLER_STEP\t$1"
}

# set the operating system.
# error if not supported.
function set_os() {
  INSTALLER_STEP=os_check

  if [[ "$OSTYPE" == "darwin"* ]]; then
    SYSTEM_OS=macos
  elif [[ "$OSTYPE" == "linux"* ]]; then
    SYSTEM_OS=linux
  elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    SYSTEM_OS=windows
    log_error_exit $ERROR_SYSTEM_OS_UNSUPPORTED
  else
    log_error_exit $ERROR_SYSTEM_OS_UNKNOWN
  fi
  log "$SYSTEM_OS"
}

# remove temp directory on exit.
trap 'rm -rf -- "$DIR_TEMP"' EXIT
