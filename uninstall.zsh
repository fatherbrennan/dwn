#!/bin/zsh

source ./common.zsh

INSTALLER_LOG=uninstall

if [[ ! -v "$DWN_INSTALL" ]]; then
  # make sure to make new variables available.
  # may not be available if user has same shell session open which was used to install.
  source "$FILE_ZSHRC" || log_error_exit $ERROR_ENV_VARS_SOURCE
fi

# remove dwn config directory.
function unset_config_dir() {
  INSTALLER_STEP=remove_config_dir

  # check if the directory exists.
  if [[ -d "$DWN_INSTALL" ]]; then
    # remove the entire directory.
    rm -rf "$DWN_INSTALL" && log "removed: $DWN_INSTALL" || log_error_exit $ERROR_CONFIG_DIR_REMOVE
  fi
}

# unset environment variables from zsh.
function unset_env_vars() {
  INSTALLER_STEP=unset_env_vars

  # check if the file exists.
  if [[ -f "$FILE_ZSHRC" ]]; then
    _tmp_f_env_vars=$(mktemp)
    _tmp_f_zshrc=$(mktemp)

    print_ln "$ENV_VARIABLES_TEXT" >"$_tmp_f_env_vars"

    # remove environment variables from file.
    grep -xvFf "$_tmp_f_env_vars" "$FILE_ZSHRC" >"$_tmp_f_zshrc" && mv "$_tmp_f_zshrc" "$FILE_ZSHRC"
  fi
  log "environment variables unset!"
}

unset_config_dir
unset_env_vars
