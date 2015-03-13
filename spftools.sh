
case $? in 0) :;; *) (exit "$?");; esac &&
prj_unset spf_host spf_base spf_btag spf_version spf_vtag &&

spf_parse() {
  sp_parse "${1?}" &&
  case ${sp_category?} in
    host/*/*/foreign/)
      prj_fail "spf_parse: unrecognized category for ${sp_path?}";;
    host/*/foreign/) :;;
    *) prj_fail "spf_parse: unrecognized category for ${sp_path?}";;
  esac &&
  case ${sp_base?} in
    ?*+spf+*)
      spf_base=`prj_sedarg1 's:+spf+.*$::' "${sp_base?}"` &&
      spf_btag='
:trim
s:^.[^+]*+:+:
/^+spf+/!btrim
' &&
      spf_btag=`prj_sedarg1 "${spf_btag?}" "${sp_base?}"`;;
    *) spf_base=${sp_base?} && spf_btag=;;
  esac &&
  spf_host='s:^host/\(.*\)/foreign/$:\1:' &&
  spf_host=`prj_sedarg1 "${spf_host?}" "${sp_category?}"` &&
  if test '' = "${sp_version?}"; then spf_version= && spf_vtag=
  else
    spf_version=`prj_sedarg1 's:^-::;s:+spf+.*$::' "${sp_version?}"` &&
    case ${sp_version?} in
      *+spf+*)
        spf_vtag='
:trim
s:^.[^+]*+:+:
/^+spf+/!btrim
' &&
        spf_vtag=`prj_sedarg1 "${spf_vtag?}" "${sp_version?}"`;;
      *) spf_vtag=
    esac
  fi &&
  spf_path_snippet=${sp_path?}/package/foreign_info &&
  prj_u2 prj_set spf_path_prefix  "${sp_path?}"/prefix &&
  prj_u2 prj_set spf_path_built   "${spf_path_prefix?}"/.built &&
  prj_u2 prj_set spf_path_cc      "${sp_path?}"/conf-compile &&
  prj_u2 prj_set spf_path_compile "${sp_path?}"/compile &&
  prj_u2 prj_set spf_path_conf    "${sp_path?}"/conf &&
  prj_x2 prj_set SPF_CONF         "${spf_path_conf?}" &&
  prj_u2 prj_set spf_path_data    "${SPF_CONF?}/${spf_base?}-data"/prefix &&
  prj_x2 prj_set_default SPF_LIBC glibc &&
  prj_u2 prj_set spf_path_libc    "${spf_path_conf?}/${SPF_LIBC?}"
} &&

prj_unset spf_info spf_info_external spf_info_downloaded &&
spf_info_downloaded='' &&
spf_load_info() {
  : "${sp_path?}" "${spf_version?}" &&
  if test external = "$1"
    then spf_info_external=y
    else spf_info_external=n
  fi &&
  if test n = "${spf_info_external?}" && test -f "${spf_path_snippet?}"; then
    spf_info=${spf_path_snippet?}
  else
    set x ${SP_TARDIR_FLAT+"${SP_TARDIR_FLAT?}/"} \
      ${SP_TARDIR+"${SP_TARDIR?}/${sp_category?}"} \
      "$SP_ROOT"/usr/local/src/package/"${sp_category?}" &&
    set x "$2".spf-scripts/ &&
    shift &&
    if test n = "${SPF_OFFLINE_SCRIPTS-n}" &&
       prj_not eval 'prj_anyeq "${sp_category?}${sp_base?}" '"${spf_info_downloaded?}"; then
      prj_qlist_unshift spf_info_downloaded "${sp_category?}${sp_base?}" &&
      prj_mkdir_p "$1"/."${spf_base?}" &&
      prj_download \
        http://"${spf_host?}"/slashpackage-foreign/"${spf_base?}".sh \
        "$1"/."${spf_base?}" "${spf_base?}".sh &&
      mv -f "$1"/."${spf_base?}"/"${spf_base?}".sh "$1"/ &&
      rmdir "$1"/."${spf_base?}"
    elif test -f "$1${spf_base?}".sh; then :
    else prj_fail "unable to find a local script for ${spf_base?} and SPF_OFFLINE_SCRIPTS is set"
    fi &&
    spf_info=$1${spf_base?}.sh
  fi &&
  spf_template__list= &&
  spf_url_home_= &&
  spf_url_watch_list_= &&
  spf_url_srcs_= &&
  spf_tested_versions= &&
  spf_own_entries= &&
  spf_cclist= &&
  spf_depend_list= &&
  spf_links= &&
  spf_link = command bin sbin usr/bin usr/sbin &&
  spf_link = include include usr/include &&
  spf_link = library lib usr/lib &&
  spf_link = man man share/man usr/man usr/share/man &&
  spf_link = info info share/info usr/info usr/share/info &&
  spf_data_list= &&
  spf_args_configure= &&
  spf_args_make= &&
  spf_args_cpp= &&
  spf_args_cxx= &&
  spf_args_cc= &&
  spf_args_ld= &&
  spf_args_rpath= &&
  spf_env_rpath=n &&
  spf_cmd_entries= &&
  spf_cmd_noop ldconfig &&
  spf_hack_lib_links_= &&
  spf_srcdir "${spf_base?}-${spf_version?}" &&
  . "${spf_info?}"
} &&

spf_set_version() {
  { test '' = "${sp_version?}" || return 0; } &&
  eval "set x ${spf_tested_versions?}" && shift &&
  case $1 in
    [0123456789]*) :;;
    *) prj_fail "bad versions: ${sp_path?}";;
  esac &&
  spf_parse "${sp_path?}-$1"
} &&

spf_set_vtag() {
  spf_set_version &&
  { test '' = "${spf_vtag?}" || return 0; } &&
  set x "${sp_path?}"+spf+[*] "${sp_path?}"+spf+* && shift &&
  if test "$1" = "${sp_path?}+spf+[*]" &&
     test "$2" = "${sp_path?}+spf+*"; then
    spf_parse "${sp_path?}+spf+0"
  else
    set 0 "$@" "${sp_path?}" &&
    while test "$#" != 2; do
      { spf_parse "$2" &&
        case ${spf_vtag?} in
          +spf+) :;;
          +spf+*[!0123456789]*) :;;
          *)
            spf_vtag=`prj_sedarg1 's/^+spf+//' "${spf_vtag?}"` &&
            if expr "$1" \> "${spf_vtag?}" > /dev/null; then :; else
              spf_vtag=`expr 1 + "${spf_vtag?}"` &&
              shift &&
              set "${spf_vtag?}" "$@"
            fi;;
        esac &&
        spf_vtag=$1 &&
        shift && shift &&
        set "${spf_vtag?}" "$@"
      } || return "$?"
    done &&
    spf_parse "$2+spf+$1"
  fi
} &&

prj_unset spf_srcdir_ &&
spf_srcdir() {
  spf_srcdir_=${1?} &&
  prj_u2 prj_set spf_path_src "${sp_path?}"/compile/src/"${spf_srcdir_?}"
} &&

prj_unset spf_url_home_ spf_url_watch_list_ spf_url_srcs_ spf_url_src_elt_ \
  spf_url_src_attr_dir_ spf_url_src_attr_fmt_ &&
spf_url() { : "${1?}" && spf_url_"$@"; } &&
spf_url_home()  { spf_url_home_=${1?}; } &&
spf_url_watch() { spf_url_watch_list_= && spf_url_watch_add "${1?}"; } &&
spf_url_watch_add() { prj_qlist_push spf_url_watch_list_ "${1?}"; } &&
spf_url_src_add() {
  spf_url_src_elt_= &&
  prj_qlist_push spf_url_src_elt_ "${1?}" &&
  shift &&
  spf_url_src_attr_dir_=. &&
  spf_url_src_attr_fmt_= &&
  while test "$#" != 0 && test args != "$1"; do
    { { prj_is_set spf_url_src_attr_"$1"_ ||
        prj_fail "unrecognized spf_url_src attribute: $1"; } &&
      prj_set spf_url_src_attr_"$1"_ "${2?}" &&
      shift &&
      shift
    } || return "$?"
  done &&
  prj_qlist_push spf_url_src_elt_ "${spf_url_src_attr_dir_?}" &&
  prj_qlist_push spf_url_src_elt_ "${spf_url_src_attr_fmt_?}" &&
  if test args = "$1"
    then shift
    else :
  fi &&
  while test "$#" != 0; do
    { prj_qlist_push spf_url_src_elt_ "${1?}" &&
      shift
    } || return "$?"
  done &&
  prj_qlist_push spf_url_srcs_ "${spf_url_src_elt_?}"
} &&
spf_url_src() {
  spf_url_srcs_= &&
  spf_url_src_add ${1+"$@"}
} &&
prj_set_default SPF_URL_SF easynews &&

prj_unset spf_tested_versions &&
spf_tested_version() { prj_qlist_push spf_tested_versions "${1?}"; } &&

prj_unset spf_own_entries spf_own_entry &&
spf_own() {
  spf_own_entry= &&
  prj_qlist_push spf_own_entry "$1" &&
  prj_qlist_push spf_own_entry "$2" &&
  prj_qlist_push spf_own_entry "$3" &&
  prj_qlist_push spf_own_entry "${4?}" &&
  prj_qlist_push spf_own_entry "$5" &&
  prj_qlist_push spf_own_entries "${spf_own_entry?}"
} &&

spf_revctl() { : "${1?}"; } &&
#spf_revctl() { : "${1?}" && spf_revctl_"$@"; } &&
spf_do_revctl_checkout() { prj_fail 'no spf_revctl mode has been set'; } &&
#spf_revctl_cvs() {
#  prj_u2 prj_set spf_revctl_cvs_root   "${1?}" &&
#  prj_u2 prj_set spf_revctl_cvs_module "${2?}" &&
#  spf_do_revctl_checkout() {
#    case ${1?} in
#      d) set x -D "${2?}${3+-$3}${4+-$4}${5+T$5}${6+:$6}${7+:$7}";;
#      t) set x -r "${2?}";;
#      r) set x -r "${2?}";;
#      b) set x -r "${2?}";;
#      *) prj_fail "unrecognized revision type: $1";;
#    esac &&
#    shift &&
#    if ; then 
#      ( 
#        cvs -z3 -d"${spf_revctl_cvs_root?}" checkout -d "${spf_base?}" "$@" \
#          "${spf_revctl_cvs_module?}"
#      )
#    else
#      ( 
#        cvs -z3 update "$@"
#      )
#    fi
#  }
#} &&
#spf_revctl_svn() {
#  prj_u2 prj_set spf_revctl_svn_url "${1?}" &&
#  spf_do_revctl_get() {
#    case ${1?} in
#      d) set x -r "{${2?}${3+-$3}${4+-$4}${5+T$5}${6+:$6}${7+:$7}}";;
#      t) set x -r "${2?}";;
#      r) set x -r "${2?}";;
#      *) prj_fail "unrecognized revision type: $1";;
#    esac &&
#    shift &&
#    if ; then 
#      ( 
#        svn checkout "$@" "${spf_revctl_svn_url?}" "${spf_base?}"
#      )
#    else
#      ( 
#        svn update "$@"
#      )
#    fi
#  }
#} &&

prj_u2 prj_capture spf_uname_s uname    &&
prj_u2 prj_capture spf_uname_r uname -r &&
prj_u2 prj_capture spf_uname_m uname -m &&

spf_is_token() {
  case ${1?} in
    ''|\
    [!ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz]*|\
    *[!ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789]*)
      return 100;;
    *) return 0;;
  esac
} &&
spf_need_token() {
  : "${1?}" &&
  { spf_is_token "$1" || prj_fail "not a token: $1"; }
} &&

spf_xesc() {
  prj_x2 prj_capture "$1" prj_quote_sed "$3" "${2?}"
} &&

prj_unset spf_links &&
spf_link() {
  spf_need_token "${2?}" &&
  { test + = "$1" || test = = "$1" || prj_fail "not '+' or '=': $1"; } &&
  prj_append spf_links "$2" ' ' &&
  { test + = "$1" || prj_set spf_links_"$2" ''; } &&
  eval '
    shift && shift &&
    while test "$#" != 0; do
      { { test "" != "$1" ||
          prj_fail "spf_link directories must not be empty"; } &&
        prj_qlist_push spf_links_'"$2"' "$1" &&
        shift
      } || return "$?"
    done'
} &&

spf_data() { : "${2?}" && spf_data_${1+"$@"}; } &&
spf_data_file()  { spf_data_ f "${1?}"; } &&
spf_data_dir()   { spf_data_ d "${1?}"; } &&
spf_data_other() { spf_data_ e "${1?}"; } &&
prj_unset spf_data_list &&
spf_data_() {
  : "${2?}" &&
  prj_qlist_push spf_data_list "$1" &&
  prj_qlist_push spf_data_list "$2"
} &&

prj_unset spf_args_configure &&
prj_unset spf_args_make &&
prj_unset spf_args_cpp &&
prj_unset spf_args_cxx &&
prj_unset spf_args_cc &&
prj_unset spf_args_ld &&
prj_unset spf_args_rpath &&
prj_unset spf_env_rpath &&
spf_args() { prj_qlist_push spf_args_"$1" "${2?}"; } &&

prj_unset spf_mklink_old_target &&
spf_mklink() {
  : "${3?}" &&
  if test -h "$1/$2" &&
     spf_mklink_old_target=`readlink "$1/$2"` &&
     test x"${spf_mklink_old_target?}" = x"$3"
    then return 0
    else :
  fi &&
  prj_mkdir_p "$1/$2{new}" &&
  rm -f "$1/$2{new}/$2" &&
  ln -s "$3" "$1/$2{new}/$2" &&
  mv -f "$1/$2{new}/$2" "$1/" &&
  rmdir "$1/$2{new}"
} &&

prj_unset spf_cclist spf_ccvar &&
spf_cc() {
  : "${3?}" &&
  spf_need_token "$1" &&
  spf_ccvar='' &&
  prj_qlist_push spf_ccvar "$1" &&
  prj_qlist_push spf_ccvar "$2" &&
  prj_qlist_push spf_ccvar "$3" &&
  prj_qlist_push spf_cclist "${spf_ccvar?}" &&
  prj_u2 prj_set spf_ccv_"$1" "$2" &&
  if test '' = "${spf_vtag?}"; then :
  elif test -f "${spf_path_cc?}/$1"; then
    prj_capture spf_ccv_"$1" sed q "${spf_path_cc?}/$1"
  elif test -f "${spf_path_cc?}/defaults/$1"; then
    prj_capture spf_ccv_"$1" sed q "${spf_path_cc?}/defaults/$1"
  else :
  fi
} &&

prj_unset spf_depend_base &&
spf_ccload() {
  set configure make &&
  while test "$#" != 0; do
    { eval '
        if test "" != "$spf_ccv_'"$1"'_args" &&
           test "" != "${spf_args_'"$1"'?}"
          then prj_set spf_args_"$1" "$spf_args_'"$1"' "
          else :
        fi &&
        prj_set spf_args_"$1" "$spf_args_'"$1"'$spf_ccv_'"$1"'_args"
      ' &&
      shift
    } || return "$?"
  done &&
  set cpp cxx cc ld &&
  while test "$#" != 0; do
    { eval '
        if test "" != "$spf_ccv_'"$1"'_args" &&
           test "" != "${spf_args_'"$1"'?}"
          then prj_set spf_args_"$1" " $spf_args_'"$1"'"
          else :
        fi &&
        prj_set spf_args_"$1" "$spf_ccv_'"$1"'_args$spf_args_'"$1"'"
      ' &&
      shift
    } || return "$?"
  done &&
  eval "set x ${spf_depend_list?}" && shift &&
  for spf_depend_tmp in ${1+"$@"}; do
    { eval "set x ${spf_depend_tmp?}" && shift &&
      eval 'spf_depend_tmp=${spf_ccv_depend_'"$1"'?}' &&
      if test "$3" = required && prj_not prj_exists "${spf_depend_tmp?}"
        then prj_fail "missing dependency: ${spf_depend_tmp?}"
        else :
      fi &&
      if test compiletime = "$6"
        then spf_ccvar=${spf_path_compile?}/conf
        else spf_ccvar=${spf_path_conf?}
      fi &&
      spf_depend_base=`prj_basename "$2"` &&
      spf_mklink "${spf_ccvar?}" "${spf_depend_base?}" "${spf_depend_tmp?}" &&
      spf_ccvar=${spf_ccvar?}/${spf_depend_base?} &&
      if test none = "$4"; then :; else
        spf_args cpp -I"${spf_ccvar?}"/include &&
        if test include = "$4"; then :; else
          spf_args ld -L"${spf_ccvar?}"/library &&
          if test lib = "$4"; then :; else
            spf_args rpath "${spf_ccvar?}"/library
          fi
        fi &&
        if test -d "${spf_ccvar?}"/library/pkgconfig; then
          prj_x2 prj_append PKG_CONFIG_PATH "${spf_ccvar?}"/library/pkgconfig
        else :
        fi &&
        if test -d "${spf_ccvar?}"/prefix/share/pkgconfig; then
          prj_x2 prj_append PKG_CONFIG_PATH \
            "${spf_ccvar?}"/prefix/share/pkgconfig
        else :
        fi
      fi
    } || exit "$?"
  done &&
  eval "set x ${spf_args_rpath?}" && shift &&
  if test y = "${spf_env_rpath?}"; then
    while test "$#" != 0; do
      { prj_x2 prj_append LD_RUN_PATH "$1" &&
        shift
      } || return "$?"
    done
  else
    while test "$#" != 0; do
      { spf_args ld -Xlinker && spf_args ld -R &&
        spf_args ld -Xlinker && spf_args ld "$1" &&
        shift
      } || return "$?"
    done
  fi
} &&

spf_cc_() { : "${1?}" && spf_cc_"$@"; } &&

spf_cc_cpp_args() {
  spf_cc cpp_args "$1" 'The arguments on the first line of this file are passed to the C preprocessor.'
} &&

spf_cc_cxx_args() {
  spf_cc cxx_args "$1" 'The arguments on the first line of this file are passed to the C++ compiler.'
} &&

spf_cc_cc_args() {
  spf_cc cc_args "$1" 'The arguments on the first line of this file are passed to the C compiler.'
} &&

spf_cc_ld_args() {
  spf_cc ld_args "$1" 'The arguments on the first line of this file are passed to the linker.'
} &&

spf_cc_nls() {
  spf_cc nls y \
    'This specifies whether to build the package with locale support.'
} &&

spf_cc_configure_args() {
  spf_cc configure_args "$1" 'The arguments on the first line of this file are passed to ./configure.'
} &&

spf_cc_make_args() {
  spf_cc make_args "$1" 'The arguments on the first line of this file are passed to make.'
} &&

prj_unset spf_set_default_pattern &&
spf_depend_validate() {
  set spf_depend_"$1" "${2?}" "$3" &&
  if prj_is_set "$1"; then
    eval 'prj_match "$2$3" "${'"$1"'}" ||
          prj_fail "invalid value for $1 (${'"$1"'}) for ${spf_depend_path?}"'
  else
    prj_set "$1" "$2"
  fi
} &&

prj_unset spf_depend_list spf_depend_path spf_depend_tmp &&
spf_depend() {
  spf_depend_path=$1 && shift &&
  case ${spf_depend_path?} in
    /*) :;;
    */*) prj_fail \
           "dependencies must be absolute or basenames: ${spf_depend_path?}";;
    *:*) spf_depend_path=/package/host/`
           prj_sedarg1 's=:=/foreign/=' "${spf_depend_path?}"`;;
    *) spf_depend_path=/package/host/${spf_host?}/foreign/${spf_depend_path?};;
  esac &&
  prj_unset spf_depend_degree spf_depend_flags spf_depend_versions \
    spf_depend_when spf_depend_version_sensitive &&
  while test "$#" != 0; do
    { case $1 in
        degree|when|flags|version_sensitive|versions)
          prj_set spf_depend_"$1" "${2?}";;
        *) prj_fail "unrecognized parameter: $1";;
      esac &&
      shift && shift
    } || return "$?"
  done &&
  spf_depend_validate degree   required '|optional'         &&
  spf_depend_validate flags    rlib     '|lib|include|none' &&
  spf_depend_validate versions '*'                          &&
  if test "${spf_depend_flags?}" = rlib; then
    spf_depend_validate when              runtime &&
    spf_depend_validate version_sensitive yes
  else
    spf_depend_validate when compiletime '|runtime' &&
    if test "${spf_depend_when?}" = compiletime
      then spf_depend_validate version_sensitive no
      else spf_depend_validate version_sensitive no '|yes'
    fi
  fi &&
  prj_capture spf_depend_tmp \
    prj_sedarg1 's:.*/::;s:[^a-zA-Z0-9]:_:g' "${spf_depend_path?}" &&
  set x "${spf_depend_tmp?}" && shift &&
  spf_cc depend_"$1" "${spf_depend_path?}" \
    "The first line of this file specifies where to find the
$1 package." &&
  spf_depend_tmp= &&
  prj_qlist_push spf_depend_tmp "$1" &&
  prj_qlist_push spf_depend_tmp "${spf_depend_path?}" &&
  prj_qlist_push spf_depend_tmp "${spf_depend_degree?}" &&
  prj_qlist_push spf_depend_tmp "${spf_depend_flags?}" &&
  prj_qlist_push spf_depend_tmp "${spf_depend_versions?}" &&
  prj_qlist_push spf_depend_tmp "${spf_depend_when?}" &&
  prj_qlist_push spf_depend_tmp "${spf_depend_version_sensitive?}" &&
  prj_qlist_push spf_depend_list "${spf_depend_tmp?}"
} &&

prj_unset spf_cmd_entries spf_cmd_entry &&
spf_cmd() {
  spf_cmd_entry= &&
  prj_qlist_push spf_cmd_entry "$1" &&
  prj_qlist_push spf_cmd_entry "${2?}" &&
  prj_qlist_push spf_cmd_entries "${spf_cmd_entry?}"
} &&
spf_cmd_hide() { spf_cmd "${1?}" 127; } &&
spf_cmd_noop() { spf_cmd "${1?}"   0; } &&

spf_trigger_conf_libc() { gcc -E -x c /dev/null > /dev/null; } &&

prj_u2 prj_set spf_c_nl '
' &&
prj_u2 prj_set spf_c_tab '	' &&
prj_u2 prj_set spf_c_ws   " ${spf_c_tab?}" &&
prj_u2 prj_set spf_c_cws  "[${spf_c_ws?}]" &&
prj_u2 prj_set spf_c_cwsp "${spf_c_cws?}${spf_c_cws?}*" &&

spf_edit() { spf_edit_${1+"$@"}; } &&
spf_edit_1c() {
  prj_sedfile "$1" "1c\\${spf_c_nl?}${2?}\\${spf_c_nl?}"
} &&
prj_unset spf_edit_make_define_ &&
spf_edit_make_define() {
  : "${3?}" &&
  spf_edit_make_define_=`prj_quote_regexp : "$2"` &&
  spf_edit_make_define_="
s:^\\(${spf_c_cws?}*${spf_edit_make_define_?}${spf_c_cws?}*=${spf_c_cws?}*\\).*$:\\1"`prj_quote_sed : "$3"`: &&
  eval "$1=\${$1?}\${spf_edit_make_define_?}"
} &&
prj_unset spf_edit_c_define_ &&
spf_edit_c_define() {
  : "${4?}" &&
  case $2 in
    string)  spf_edit_c_define_=`prj_quote_c "$4"`;;
    noquote) spf_edit_c_define_=$4;;
    *) prj_fail "unrecognized quoting type: $2";;
  esac &&
  spf_edit_c_define_=`prj_quote_sed : "${spf_edit_c_define_?}"` &&
  spf_edit_c_define_="
s:^\\(${spf_c_cws?}*#${spf_c_cws?}*define${spf_c_cwsp?}"`prj_quote_regexp : "$3"`"${spf_c_cwsp?}\\)[^${spf_c_ws?}].*$:\\1${spf_edit_c_define_?}:" &&
  eval "$1=\${$1?}\${spf_edit_c_define_?}"
} &&

spf_hack() { spf_hack_${1+"$@"}; } &&
spf_hack_errno() {
  prj_sedfile "$1" 's:^extern int errno;$:#include <errno.h>:'
} &&
spf_hack_ltconfig() {
  spf_trigger_conf_libc &&
  if test -d "${spf_path_libc?}"/.; then
    prj_u2 prj_capture spf_hack_ltconfig_ \
      prj_quote_sed : "${spf_path_libc?}" &&
    prj_sedfile "${1-.}/ltconfig" '
s: \(/lib/libc\): '"${spf_hack_ltconfig_?}"'\1:g
s:^\([a-z_]*_path_spec=\"\):\1'"${spf_hack_ltconfig_?}"'/lib :'
  else :
  fi
} &&
spf_hack_self_rpath() {
  spf_args rpath "${spf_path_prefix?}"/lib
} &&
prj_unset spf_hack_lib_links_ &&
spf_hack_lib_links() {
  prj_qlist_push spf_hack_lib_links_ "$1"
} &&

spf_once() { "$@"; } && 

spf_do_install() { make all install; } &&
spf_do_check() { make check; } &&
spf_no_check() { spf_do_check() { :; }; } &&

prj_unset spf_template__list spf_template__host spf_template__base \
  spf_template__downloaded &&
spf_template__downloaded='' &&
spf_template() {
  set x "${1?}" ${spf_template__host+"${spf_template__host?}"} && shift &&
  case $1 in
    *:*) spf_template__host=`prj_sedarg1 's/:.*$//'    "$1"` &&
         spf_template__base=`prj_sedarg1 's/^[^:]*://' "$1"`;;
    *) spf_template__host=${2-${spf_host?}} &&
       spf_template__base=$1;;
  esac &&
  prj_qlist_push spf_template__list \
    "${spf_template__host?}:${spf_template__base?}" &&
  if test n = "${spf_info_external?}" &&
     test -f "${sp_path?}/package/foreign_template_${spf_template__host?}:${spf_template__base?}"
    then .   "${sp_path?}/package/foreign_template_${spf_template__host?}:${spf_template__base?}"
  else
    set x ${SP_TARDIR_FLAT+"${SP_TARDIR_FLAT?}/"} \
      ${SP_TARDIR+"${SP_TARDIR?}/host/${spf_template__host?}/foreign/"} \
      "$SP_ROOT/usr/local/src/package/host/${spf_template__host?}/foreign/" &&
    shift &&
    set x "$1".spf-templates && shift &&
    if test n = "${SPF_OFFLINE_SCRIPTS-n}" &&
       prj_not eval 'prj_anyeq "${spf_template__host?}:${spf_template__base?}" '"${spf_template__downloaded?}"; then
      prj_qlist_unshift spf_template__downloaded  \
        "${spf_template__host?}:${spf_template__base?}" &&
      prj_mkdir_p "$1"/."${spf_template__base?}" &&
      prj_download \
        http://"${spf_template__host?}"/slashpackage-foreign/_templates/"${spf_template__base?}".sh \
        "$1"/."${spf_template__base?}" "${spf_template__base?}".sh &&
      mv -f "$1"/."${spf_template__base?}"/"${spf_template__base?}".sh "$1"/ &&
      rmdir "$1"/."${spf_template__base?}"
    elif test -f "$1/${spf_template__base?}".sh; then :
    else prj_fail "unable to find a local script for ${spf_template__base?} and SPF_OFFLINE_SCRIPTS is set"
    fi &&
    . "$1/${spf_template__base?}".sh
  fi &&
  if test "$#" = 1
    then prj_unset spf_template__host
    else spf_template__host=$2
  fi
} &&

spf_style() { : "${1?}" && spf_style_"$@"; } &&

spf_style_gnu() {
  spf_style_gnu_src_ext() {
    spf_url src "http://ftp.gnu.org/gnu/${spf_base?}/${spf_base?}-${spf_version?}.tar.${1?}"
  } &&
  spf_url home  "http://www.gnu.org/software/${spf_base?}/" &&
  spf_url watch "http://ftp.gnu.org/gnu/${spf_base?}/" &&
  spf_style_gnu_src_ext bz2 &&
  spf_cc_ cpp_args &&
  spf_cc_ cxx_args &&
  spf_cc_ cc_args &&
  spf_cc_ ld_args &&
  spf_cc_ configure_args &&
  spf_cc_ make_args &&
  prj_unset spf_style_gnu_dir_ &&
  spf_style_gnu_dir() { spf_style_gnu_dir_=${1?}; } &&
  spf_style_gnu_dir . &&
  spf_style_gnu_build_sep() {
    spf_srcdir build &&
    spf_style_gnu_dir ../"${spf_base?}-${spf_version?}"
  } &&
  spf_style_gnu_do_before_configure() { :; } &&
  spf_style_gnu_do_configure() {
    prj_u2 prj_getstatus spf_style_gnu_had_libc \
      test -d "${spf_path_libc?}"/. &&
    prj_u2 prj_getstatus spf_style_gnu_had_gcc \
      test -d "${spf_path_conf?}"/gcc/. &&
    set SPF_GCC_GCCLIB=y RANDOM="$$" "${spf_style_gnu_dir_?}"/configure &&
    eval 'env "$@" '"${spf_args_configure?}" &&
    { test "${spf_style_gnu_had_libc?}" = 0 || rm -f "${spf_path_libc?}"; } &&
    { test "${spf_style_gnu_had_gcc?}"  = 0 || rm -f "${spf_path_conf?}"/gcc
    } &&
    set "${spf_path_conf?}"/[*] "${spf_path_conf?}"/* &&
    if test "$1 $2" = "${spf_path_conf?}/[*] ${spf_path_conf?}/*" &&
       test -d "${spf_path_conf?}"/.
      then rmdir "${spf_path_conf?}"
      else :
    fi
  } &&
  spf_style_gnu_do_before_make()    { :;                             } &&
  spf_style_gnu_do_make()           { eval "make ${spf_args_make?}"; } &&
  spf_style_gnu_do_before_install() { :;                             } &&
  spf_style_gnu_do_install()        { make install;                  } &&
  spf_style_gnu_do_after_install()  { :;                             } &&
  spf_style_gnu_do_before_check()   { :;                             } &&
  spf_style_gnu_do_check()          { make check;                    } &&
  spf_style_gnu_do_after_check()    { :;                             } &&
  spf_args configure --prefix="${spf_path_prefix?}" &&
  spf_do_install() {
    if test n = "$spf_ccv_nls";  then spf_args configure --disable-nls
    elif prj_is_set spf_ccv_nls; then spf_args configure --enable-nls
    else :
    fi &&
    #if prj_is_set spf_ccv_depend_xorg &&
    #   test -d "${spf_ccv_depend_xorg?}"; then
    #  spf_args configure --x-includes="${spf_path_conf?}"/xorg/include &&
    #  spf_args configure --x-libraries="${spf_path_conf?}"/xorg/library
    #else :
    #fi &&
    prj_x2 prj_set CPPFLAGS "${spf_args_cpp?}" &&
    prj_x2 prj_set CXXFLAGS "${spf_args_cxx?}" &&
    prj_x2 prj_set CFLAGS   "${spf_args_cc?}" &&
    prj_x2 prj_set LDFLAGS  "${spf_args_ld?}" &&
    #prj_x2 prj_set CPP    'gcc -E' && 
    #prj_x2 prj_set CXXCPP 'g++ -E' && 
    spf_once spf_style_gnu_do_before_configure       &&
    spf_once spf_style_gnu_do_configure              &&
    spf_once spf_style_gnu_do_before_make            &&
    spf_once spf_style_gnu_do_make                   &&
    spf_once spf_style_gnu_do_before_install         &&
    spf_once spf_style_gnu_do_install                &&
    spf_once spf_style_gnu_do_after_install
  } &&
  spf_do_check() {
    spf_style_gnu_do_before_check &&
    spf_style_gnu_do_check        &&
    spf_style_gnu_do_after_check
  }
} &&

spf_style_xorg() {
  spf_style gnu &&
  spf_url home  'http://x.org/' &&
  spf_url watch 'http://ftp.x.org/pub/' &&
  prj_u2 prj_capture spf_style_xorg_version \
    prj_sedarg1 's/^\([^.]*\.[^.]*\)-.*$/\1/' "${spf_version?}" &&
  spf_style_xorg_base() {
    spf_url src "http://ftp.x.org/pub/X11R${spf_style_xorg_version?}/src/everything/${1?}-X11R${spf_version?}.tar.bz2" &&
    spf_srcdir "$1-X11R${spf_version?}"
  } &&
  spf_style xorg_base "${spf_base?}"
} &&

spf_style_djb() {
  spf_url home  "http://cr.yp.to/${spf_base?}.html" &&
  spf_url watch "http://cr.yp.to/${spf_base?}/install.html" &&
  spf_url src \
    "http://cr.yp.to/${spf_base?}/${spf_base?}-${spf_version?}.tar.gz" &&
  spf_cc_ cpp_args &&
  spf_cc_ cc_args -O2 &&
  spf_cc_ ld_args -s &&
  spf_cc_ make_args &&
  spf_style_djb_do_before_install() { :; } &&
  spf_style_djb_do_after_install()  { :; } &&
  spf_do_install() {
    spf_style_djb_do_before_install &&
    spf_edit_1c conf-home "${spf_path_prefix?}" &&
    spf_edit_1c conf-cc \
      "gcc ${spf_args_cpp?} ${spf_args_cc?}" &&
    spf_edit_1c conf-ld \
      "gcc ${spf_args_cpp?} ${spf_args_cc?} ${spf_args_ld?}" &&
    if test -f error.h; then spf_hack_errno error.h; else :; fi &&
    eval "make ${spf_args_make?}" &&
    make setup check &&
    spf_style_djb_do_after_install
  } &&
  spf_do_check() { :; }
} &&

spf_style_python() {
  spf_depend code.dogmap.org:python flags none when runtime &&
  prj_u2 prj_set spf_style_python_sitepath_list '' &&
  spf_style_python_sitepath() {
    prj_qlist_push spf_style_python_sitepath_list "${1?}"
  } &&
  spf_style_python_do_before_make() { :; } &&
  spf_style_python_do_make() {
    "$SPF_CONF"/python/command/python setup.py build
  } &&
  spf_style_python_do_before_install() { :; } &&
  spf_style_python_do_install() {
    "$SPF_CONF"/python/command/python setup.py install \
      --prefix="${spf_path_prefix?}"
  } &&
  spf_style_python_do_after_install() { :; } &&
  spf_do_install() {
    prj_u2 prj_capture spf_style_python_site_dir \
      "$SPF_CONF"/python/command/python -c '
import sys
from distutils.sysconfig import get_python_lib
print get_python_lib(0, 0, sys.argv[1])' "${spf_path_prefix?}" &&
    prj_u2 prj_capture spf_style_python_site_dir_q \
      prj_quote_python "${spf_style_python_site_dir?}" &&
    prj_capture spf_style_python_site_dir_q \
      prj_sedarg1 's/\\/\\\\/g' "${spf_style_python_site_dir_q?}" &&
    eval "set x ${spf_style_python_sitepath_list?}" && shift &&
    while test "$#" != 0; do
      { prj_sedfile "$1" "1a\\
import sys\\
sys.path.insert(0, ${spf_style_python_site_dir_q?})\\
" &&
        shift
      } || return "$?"
    done &&
    spf_style_python_do_before_make &&
    spf_style_python_do_make &&
    spf_style_python_do_before_install &&
    spf_style_python_do_install &&
    spf_style_python_do_after_install
  } &&
  spf_no_check
} &&

spf_style_perl() {
  spf_depend code.dogmap.org:perl flags none when runtime &&
  prj_u2 prj_set spf_args_makefile_pl '' &&
  spf_cc_ cpp_args &&
  spf_cc_ cc_args &&
  spf_cc_ ld_args &&
  spf_cc makefile_pl_args '' 'The arguments on the first line of this file are passed to Makefile.PL.' &&
  spf_style_perl_do_before_configure() { :; } &&
  spf_style_perl_do_configure() {
    eval "set x ${spf_args_makefile_pl?}" && shift &&
    "$SPF_CONF"/perl/command/perl Makefile.PL PREFIX="${spf_path_prefix?}" \
      CCFLAGS="${spf_args_cpp?} ${spf_args_cc?}" \
      LDFLAGS="${spf_args_cc?} ${spf_args_ld?}" ${1+"$@"}
  } &&
  spf_style_perl_do_before_make()    { :;            } &&
  spf_style_perl_do_make()           { make;         } &&
  spf_style_perl_do_before_install() { :;            } &&
  spf_style_perl_do_install()        { make install; } &&
  spf_style_perl_do_after_install()  { :;            } &&
  spf_do_install() {
    prj_set spf_args_makefile_pl \
      "${spf_args_makefile_pl?} ${spf_ccv_makefile_pl_args?}" &&
    spf_style_perl_do_before_configure &&
    spf_style_perl_do_configure &&
    spf_style_perl_do_before_make &&
    spf_style_perl_do_make &&
    spf_style_perl_do_before_install &&
    spf_style_perl_do_install &&
    spf_style_perl_do_after_install
  } &&
  spf_do_check() {
    prj_set spf_args_makefile_pl \
      "${spf_args_makefile_pl?} ${spf_ccv_makefile_pl_args?}" &&
    prj_x2 prj_prepend PERL5LIB "${spf_path_prefix?}"/lib/site_perl &&
    make test
  }
} &&

spf_is_static() {
  sp_path_=$1 &&
  for sp_dir in ${sp_path_}/command/ ${sp_path_}/library/ end; do
    { if test end = "${sp_dir?}"; then break; else :; fi &&
      set '' end &&
      for file in ${sp_dir?}/*; do 
        prj_u2 prj_getstatus tmp_var \
           ldd "${file?}" > /dev/null 2>&1 &&
        if test 0 = "${tmp_var}"; then 
          return 1;
        else :;
        fi 
      done 
    } || return 0
  done 
}  &&

spf_binary_index_fetch() {
  # put the index file in /package/host/$host/foreign/.indexes/
  prj_mkdir_p ${sp_dir?}/.index &&
  prj_download \
    http://"${spf_host?}"/slashpackage-foreign/dist/index-${spf_uname_m?}.txt \
    ${sp_dir?}/.index index-${spf_uname_m?}.txt
} &&
spf_binary_index_search() {
  pkg=""
  if  test -n "${spf_version}"; then
    search_str="${spf_base}-${spf_version}${spf_vtag}${spf_btag}"
    #echo "version=${spf_version}"
    #echo "str=${search_str}"
    pkg=$(grep ${search_str?} ${sp_dir?}/.index/index-${spf_uname_m?}.txt | tail -n1 )

    #echo "pkg=$pkg"
    if test -n "${pkg}"; then  
      echo "${pkg}"
    fi
  else
    #echo ${spf_version}
    search_str="${spf_base}"
    pkg=$(grep ${search_str?} ${sp_dir?}/.index/index-${spf_uname_m?}.txt | tail -n1 )
    if test ${pkg}; then
      echo "${pkg}"
    fi
  fi
} &&
spf_binary_dependencies() {
  prj_download \
    http://"${spf_host?}"/slashpackage-foreign/dist/${spf_uname_m?}/$1.depends.txt \
    ${sp_dir?}/.index/ $1.depends.txt
  if test -f ${sp_dir?}/.index/$1.depends.txt; then
    cat ${sp_dir?}/.index/$1.depends.txt
  else
    echo ""
  fi
}
#spf_warn() {
#  echo_ >&2 "${spf_program?}: warning: $*" &&
#  sleep 2 &&
#  echo_ >&2 "${spf_program?}: continuing"
#} &&
