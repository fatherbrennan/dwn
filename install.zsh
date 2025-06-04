#!/bin/zsh

# Add permissions to script files.
# chmod 755 ./bin/dwn

OS=macos # macos | linux | windows

FILE_ZSHRC="$HOME/.zshrc"

# Error codes.
ERROR_OS_UNKNOWN=001
ERROR_OS_UNSUPPORTED=002

# Error code messages.
typeset -A ERROR=()
ERROR[$ERROR_OS_UNKNOWN]="Unknown operating system: $OSTYPE"
ERROR[$ERROR_OS_UNSUPPORTED]="Unsupported operating system: $OS"

# Print error code and message, and exit with non-zero code.
# $1 ERROR code.
function error_exit() {
  echo "[ERROR:$1]: $ERROR[$1]" && exit 1
}

# Handle OS.
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS=macos
elif [[ "$OSTYPE" == "linux"* ]]; then
  OS=linux
elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  OS=windows
  error_exit $ERROR_OS_UNSUPPORTED
else
  error_exit $ERROR_OS_UNKNOWN
fi

# Add environment variables to zsh.
# Case handlers:
# - No ~/.zshrc file.
# - Env variables already exist.
function set_env_vars() {
  local ENV_VARIABLES_TEXT='\n# dwn\nexport DWN_INSTALL="$HOME/.dwn"\nexport PATH="$DWN_INSTALL/bin:$PATH"'

  # Check if the file exists.
  if [[ -f "$FILE_ZSHRC" ]]; then
    # Append text if not in file.
    if ! grep -qzo "$ENV_VARIABLES_TEXT" "$FILE_ZSHRC"; then
      echo "$ENV_VARIABLES_TEXT" >>"$FILE_ZSHRC"
    fi
  else
    # Create file with text.
    echo "$ENV_VARIABLES_TEXT" >"$FILE_ZSHRC"
  fi
}

set_env_vars
