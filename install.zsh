#!/bin/zsh

source ./common.zsh

INSTALLER_LOG=install

is_fresh_install=0

# set permissions of script files in bin directory.
# important because cp will preserve permissions later.
function set_bin_dir_permissions() {
  INSTALLER_STEP=permissions

  chmod 755 ./bin/dwn || log_error_exit $ERROR_PERMISSIONS_BIN_DIR
  log "dwn permissions set!"
}

# add environment variables to zsh.
# case handlers:
# - oo ~/.zshrc file.
# - env variables already exist.
function set_env_vars() {
  INSTALLER_STEP=env_vars
  local env_vars_text="\n$ENV_VARIABLES_TEXT"

  # check if the file exists.
  if [[ -f "$FILE_ZSHRC" ]]; then
    # append text if not in file.
    if ! grep -qzo "$ENV_VARIABLES_TEXT" "$FILE_ZSHRC"; then
      print_ln "$env_vars_text" >>"$FILE_ZSHRC" || log_error_exit $ERROR_ENV_VARS_APPEND
    else
      log "environment variables already exist!"
    fi
  else
    # create file with text.
    print_ln "$env_vars_text" >"$FILE_ZSHRC" || log_error_exit $ERROR_ENV_VARS_WRITE
    log "environment variables added!"
  fi

  # make sure to make new variables available.
  source "$FILE_ZSHRC" || log_error_exit $ERROR_ENV_VARS_SOURCE
}

# create dwn config directory.
function set_config_dir() {
  INSTALLER_STEP=config_dir

  if [[ ! -d "$DWN_INSTALL" ]]; then
    is_fresh_install=1
  fi

  # check if the directory exists.
  if bool $is_fresh_install; then
    DWN_VERSION=$INSTALLER_DWN_VERSION
    mkdir -p -m 755 $DWN_INSTALL
    cp -Rp ./bin $DWN_INSTALL
    log "created: $DWN_INSTALL"
  else
    # print_ln "Directory exists"
    # # check version file.
    # if [[ -f $version_file ]]; then
    # local version_file="$DWN_INSTALL/$FILE_DWN_VERSION"
    # local version_pattern="^[0-9]+\.[0-9]+\.[0-9]+$"
    # local version=""
    #   print_ln "Version file exists"
    #   version=$(head -n 1 "$version_file")
    #   if [[ "$version" =~ $version_pattern ]]; then
    #     print_ln "Version file is valid"
    #     if [[ "$version" != "$INSTALLER_DWN_VERSION" ]]; then
    #       print_ln "Different version"
    #     fi
    #   else
    #     # do something if not valid version
    #   fi
    # else
    #   print_ln "Version file does not exist"
    # fi
    # log 'unsupported operation for now' && exit 0
  fi
}

set_os
set_bin_dir_permissions
set_env_vars
set_config_dir

print_ln
print_ln "installed dwn"
print_ln "=> v$DWN_VERSION"
print_ln "to check if the installation was successful, use"
print_ln
print_ln "    dwn -v"
print_ln
