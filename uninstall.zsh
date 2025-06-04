#!/bin/zsh

source ./common.zsh

INSTALLER_LOG=uninstall

# remove dwn config directory.
function unset_config_dir() {
  INSTALLER_STEP=remove_config_dir

  # check if the directory exists.
  if [[ -d "$DWN_INSTALL" ]]; then
    # remove the entire directory.
    rm -rf "$DWN_INSTALL" && log "removed $DWN_INSTALL" || log_error_exit $ERROR_REMOVE_CONFIG_DIR
  fi
}

# unset environment variables from zsh.
function unset_env_vars() {
  INSTALLER_STEP=unset_env_vars
  local env_vars_no_leading_newline="${ENV_VARIABLES_TEXT:2}" # Remove leading newline character `\n`.

  # check if the file exists.
  if [[ -f "$FILE_ZSHRC" ]]; then
    _tmp_f_env_vars=$(mktemp)
    _tmp_f_zshrc=$(mktemp)

    echo "$env_vars_no_leading_newline" >"$_tmp_f_env_vars"

    # remove environment variables from file.
    grep -xvFf "$_tmp_f_env_vars" "$FILE_ZSHRC" >"$_tmp_f_zshrc" && mv "$_tmp_f_zshrc" "$FILE_ZSHRC"
  fi
  log "environment variables unset!"
}

unset_config_dir
unset_env_vars
