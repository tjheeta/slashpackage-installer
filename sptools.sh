
case $? in 0) :;; *) (exit "$?");; esac &&
prj_unset sp_path sp_relpath sp_dir sp_root sp_category sp_base sp_version \
  sp_dashdigit sp_skip sp_tardir sp_ext sp_tar sp_tar_base sp_id \
  sp_hook_status sp_tmp_ &&
sp_process_non_directory() { :; } &&
sp_process_package_current() { :; } &&
sp_process_package_version() { :; } &&
sp_dashdigit='-[0123456789]' &&

sp_parse() {
  sp_path=${1?} &&
  sp_dir=` prj_dirname  "${sp_path?}"` &&
  sp_base=`prj_basename "${sp_path?}"` &&
  sp_version='
/'${sp_dashdigit?}'/!d
:trim
s%^.[^-]*--*%-%
/^'${sp_dashdigit?}'/!btrim
' &&
  sp_version=`prj_sedarg1 "${sp_version?}" "${sp_base?}"` &&
  sp_base=`prj_sedarg1 "s%\(.\)${sp_dashdigit?}.*$%\1%" "${sp_base?}"` &&
  case ${sp_dir?} in
    "$SP_ROOT"/package/*) sp_root=$SP_ROOT;;
    /package/*) sp_root=;;
    *) prj_unset sp_category sp_root && return 0;;
  esac &&
  sp_category='s,\([][%\\.*^$]\),\\\1,g' &&
  sp_category=`prj_sedarg1 "${sp_category?}" "${sp_root?}"` &&
  sp_relpath=` prj_sedarg1 "s%^${sp_category?}%%"          "${sp_path?}"` &&
  sp_category=`prj_sedarg1 "s%^${sp_category?}/package/%%" "${sp_dir?}"`
} &&

sp_find_tar() {
  for sp_tardir in ${SP_TARDIR_FLAT+"${SP_TARDIR_FLAT?}/"} \
                   ${SP_TARDIR+"${SP_TARDIR?}/${sp_category?}"} \
                   "$SP_ROOT"/usr/local/src/package/"${sp_category?}" \
                   /usr/local/src/package/"${sp_category?}" end; do
    { if test end = "${sp_tardir?}"; then break; else :; fi &&
      set '' end &&
      { prj_is_set sp_tar_base || set .gz .bz2 .Z "$@"; } &&
      for sp_ext in "$@"; do
        { sp_tar=${sp_tardir?}${sp_tar_base-${sp_base?}${sp_version?}.tar${sp_ext?}} &&
          if test end != "${sp_ext?}" &&
             test -f  "${sp_tar?}"
            then return 0
            else :
          fi
        } || return "$?"
      done
    } || return "$?"
  done &&
  sp_tar=not_found
} &&

sp_for_each_package() {
  if test 0 = "$#"; then set "$SP_ROOT"/package; else :; fi &&
  while test 0 != "$#"; do
    { sp_path=`prj_sedarg1 's%/*$%%' "$1"` &&
      shift &&
      if test -k "${sp_path?}"/.; then
        # this is a category; push its subdirectories on the stack
        set x "${sp_path?}"/[*] "${sp_path?}"/* ${1+"$@"} && shift &&
        if test x"$1" = x"${sp_path?}/[*]" && test x"$2" = x"${sp_path?}/*"
          then shift
          else :
        fi &&
        shift &&
        continue
      else :
      fi &&
      # this is a package
      sp_parse "${sp_path?}" &&
      if test -d "${sp_path?}"/.; then :; else
        sp_skip=y &&
        sp_process_non_directory &&
        if test y = "${sp_skip?}"; then continue; else :; fi
      fi &&
      if test '' = "${sp_version?}"
        then sp_process_package_current
        else sp_process_package_version
      fi
    } || return "$?"
  done
} &&

sp_validate_root() {
  case $SP_ROOT in
    [!/]*) prj_fail '$SP_ROOT must specify an absolute path';;
    *) :;;
  esac
} &&

sp_download() { prj_download ${1+"$@"}; } && # deprecated

sp_hook() {
  : "${1?}" &&
  sp_hook_status=0 &&
  if prj_is_set SP_HOOK; then
    ( prj_x2 prj_set SP_PATH "${sp_path?}" &&
      prj_x2 prj_set SP_DIR "${sp_dir?}" &&
      if prj_is_set sp_root
        then prj_x2 prj_set SP_PATH_ROOT "${sp_root?}"
        else prj_unset SP_PATH_ROOT
      fi &&
      if prj_is_set sp_category
        then prj_x2 prj_set SP_CATEGORY "${sp_category?}"
        else prj_unset SP_CATEGORY
      fi &&
      prj_x2 prj_set SP_BASE "${sp_base?}" &&
      prj_x2 prj_set SP_VERSION "${sp_version?}" &&
      exec "${SP_HOOK?}" "$1"
    )
    sp_hook_status=$? &&
    if test "${sp_hook_status?}" = 99
      then return 0
      else return "${sp_hook_status?}"
    fi
  else :
  fi
} &&

sp_mkdir() {
  set "${sp_path?}" &&
  while :; do
    { sp_tmp_=`prj_sedarg1 's%//*[^/]*$%%' "$1"` &&
      { test "${sp_root?}"/package != "${sp_tmp_?}" || break; } &&
      set "${sp_tmp_?}" "$@"
    } || return "$?"
  done &&
  while test "$#" != 1; do
    { { test -d "$1"/. || mkdir    "$1"; } &&
      { test -k "$1"/. || chmod +t "$1"; } &&
      shift
    } || return "$?"
  done &&
  { test -d "$1"/. || mkdir "$1"; }
} &&

sp_unpack() {
  if prj_is_set SP_COMPILE_USER; then
    sp_mkdir &&
    sp_id=`prj_id -u "${SP_COMPILE_USER?}"` &&
    chown -R "${sp_id?}" "${sp_path?}"/. &&
    ( cd "${sp_root?}"/package &&
      setuidgid "${SP_COMPILE_USER?}" tar -xpf - \
        "${sp_category?}${sp_base?}${sp_version?}"
    ) < "${sp_tar?}" &&
    sp_id=`prj_id -u` &&
    sp_id=${sp_id?}:`prj_id -g` &&
    chown -R "${sp_id?}" "${sp_path?}"/.
  else
    ( cd "${sp_root?}"/package && exec tar -xpf - ) < "${sp_tar?}"
  fi
}
