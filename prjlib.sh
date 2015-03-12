
case $? in 0) :;; *) (exit "$?");; esac &&
prj_set() {
  eval "$1=\${2?}"
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_set_default() {
  : "${2?}" &&
  eval "
  if test \"\${$1+x}\" = x; then :; else
    $1=\$2
  fi"
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_is_set() {
  eval "test \"\${${1?}+x}\" = x"
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_not() {
  if test "$#" = 0 || "$@"
    then return 100
    else return 0
  fi
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_match() {
  eval "
  case \${2?} in
    $1) :;;
    *) return 100;;
  esac"
}

case $? in 0) :;; *) (exit "$?");; esac &&
if { test -e .; } > /dev/null 2>&1; then
  prj_exists() {
    : "${1?}" &&
    { test -e "$1" || test -h "$1"; }
  }
else
  prj_exists() {
    : "${1?}" &&
    { test -f "$1" || test -d "$1" || test -h "$1" || test -b "$1" ||
      test -c "$1" || test -p "$1"
    }
  }
fi

case $? in 0) :;; *) (exit "$?");; esac &&
prj_echo() {
  case $* in
    -*|*\\*)
      # Avoid echo's nonportable behavior for switches and escapes.
      cat <<EOT
$*
EOT
      ;;
    *)
      # Use echo when we can get away with it, since it's typically a builtin.
      echo "$*";;
  esac
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_tmpdir_tmp_= &&
unset prj_tmpdir_tmp_ &&
prj_tmpdir() {
  { test "$#" = 1 || test "$#" = 2; } &&
  prj_tmpdir_tmp_=${2-$TMPDIR} &&
  case $prj_tmpdir_tmp_ in
    /*) :;;
    *)  prj_tmpdir_tmp_=/tmp;;
  esac &&
  set x "$1" "${prj_tmpdir_tmp_?}" && shift &&
  prj_tmpdir_tmp_=$2/${prj_program-prj_tmpdir}-XXXXXXXX &&
  if prj_tmpdir_tmp_=`{ mktemp -d "${prj_tmpdir_tmp_?}"; } 2> /dev/null`; then
    eval "$1=\${prj_tmpdir_tmp_?}"
  else
    prj_tmpdir_tmp_=$2/${prj_program-prj_tmpdir}-$$ &&
    prj_tmpdir_tmp_=${prj_tmpdir_tmp_?}`date +-%s 2> /dev/null || :` &&
    ( umask 077 && exec mkdir "${prj_tmpdir_tmp_?}" ) &&
    eval "$1=\${prj_tmpdir_tmp_?}"
  fi
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_capture() {
  eval "
  shift &&
  ${1?}"'=`${1+"$@"}`'
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_getstatus() {
  eval "shift && { \${1+\"\$@\"}; ${1?}=\$?; }"
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_id() {
  ( case $PATH: in
      /usr/xpg4/bin:*) :;;
      :) PATH=/usr/xpg4/bin;;
      *) PATH=/usr/xpg4/bin:${PATH?};;
    esac &&
    export PATH &&
    exec id ${1+"$@"}
  )
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_x2() {
  : "${2?}" &&
  "$@" &&
  export "$2"
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_u2() {
  : "${2?}" &&
  "$@" &&
  eval "
  set x \"\$$2\" &&
  $2= &&
  unset $2 &&
  $2=\$2"
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_warn() {
  : "${1?}" &&
  set x "$*" &&
  if test "${prj_program+x}" = x
    then set x "${prj_program?}: $2"
    else :
  fi &&
  case $2 in
    -*|*\\*) cat <<EOT
$2
EOT
      ;;
    *) echo "$2";;
  esac >&2
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_quote_sh() {
  case ${1?} in
    '') echo "''";;
    *[!%+,./0123456789:@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz-]*) sed "
s/'/'\\\\''/g
1s/^/'/
\$s/\$/'/
" <<EOT
$1
EOT
      ;;
    -*) cat <<EOT
$1
EOT
      ;;
    *) echo "$1";;
  esac
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_qlist_push() {
  : "${2?}" &&
  eval '
  if test "" = "${'"$1"'?}"
    then '"$1"'=`prj_quote_sh "$2"`
    else '"$1"'=$'"$1"'" "`prj_quote_sh "$2"`
  fi
'
} &&
prj_qlist_unshift() {
  : "${2?}" &&
  eval '
  if test "" = "${'"$1"'?}"
    then '"$1"'=`prj_quote_sh "$2"`
    else '"$1"'=`prj_quote_sh "$2"`" "$'"$1"'
  fi
'
} &&
prj_qlist_elt() {
  eval "set \"\${3?}\" $2 && shift \"\${1?}\" && shift && $1=\${1?}"
} &&
prj_qlist_map_= &&
unset prj_qlist_map_ &&
prj_qlist_map() {
  if test '' = "$1"; then :; else
    eval '
    shift &&
    for prj_qlist_map_ in '"${1?}"'; do
      ${1+"$@"} "${prj_qlist_map_?}" || return "$?"
    done
'
  fi
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_append_tmp0_= &&
prj_append_tmp1_= &&
unset prj_append_tmp0_ prj_append_tmp1_ &&
prj_append() {
  set x "$1" "${2?}" "${3-:}" && shift &&
  prj_append_tmp0_=$3$2$3 &&
  prj_append_tmp1_=$3$3 &&
  eval '
  case $3$'"$1"'$3 in
    *"${prj_append_tmp0_?}"*) :;;
    "${prj_append_tmp1_?}") '"$1"'=$2;;
    *) '"$1"'=$'"$1"'$3$2;;
  esac'
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_which_elt_= &&
prj_which_rest_= &&
unset prj_which_elt_ prj_which_rest_ &&
prj_which_get_elt() {
  sed '
1h
1!H
$!d
g
s%:.*$%%
/./s%$%/%
' <<EOT
${1?}
EOT
} &&
prj_which_get_rest() {
  sed '
1h
1!H
$!d
g
s%^[^:]*:%%
' <<EOT
${1?}
EOT
} &&
prj_which() {
  : "${2?}" &&
  prj_which_rest_= &&
  if test "${3+x}" = x;  then prj_which_rest_=${prj_which_rest_?}$3:;    else :
  fi &&
  if test x"$PATH" != x; then prj_which_rest_=${prj_which_rest_?}$PATH:; else :
  fi &&
  if test "${4+x}" = x;  then prj_which_rest_=${prj_which_rest_?}$4:;    else :
  fi &&
  while test "${prj_which_rest_?}" != ''; do
    { prj_which_elt_=`prj_which_get_elt "${prj_which_rest_?}"`$2 &&
      if test -x "${prj_which_elt_?}" && test -f "${prj_which_elt_?}"; then
        eval "$1=\${prj_which_elt_?}" &&
        return 0
      else :
      fi &&
      prj_which_rest_=`prj_which_get_rest "${prj_which_rest_?}"`
    } || return "$?"
  done &&
  { echo "unable to find $2 in \$PATH" >&2
    return 100
  }
}

case $? in 0) :;; *) (exit "$?");; esac &&
if (prj_which setuidgid_path setuidgid) 2> /dev/null; then
  :
elif (exec perl -e 'use POSIX qw(&setuid &setgid &getpwnam);') \
       > /dev/null 2>&1; then
  setuidgid() {
    perl -le '
use POSIX qw(&setuid &setgid &getpwnam);
my ($acct, @args)=@ARGV;
my @data=getpwnam($acct);
my ($uid, $gid)=@data[2, 3];
setgid($gid) or die("unable to set group id: ", $!, "\n");
$)=$gid." ".$gid;
$) eq $gid." ".$gid or die("unable to set groups\n");
setuid($uid) or die("unable to set user id: ", $!, "\n");
exec({ $args[0] } @args) or die("unable to exec ", $args[0], ": ", $!, "\n");
' ${1+"$@"}
  }
elif (exec python -c 'import pwd') > /dev/null 2>&1; then
  setuidgid() {
    python -c '
import sys, os, pwd
acct=sys.argv[1]
args=sys.argv[2:]
data=pwd.getpwnam(acct)
(uid, gid)=(data.pw_uid, data.pw_gid)
os.setgid(gid)
os.setgroups((gid,))
os.setuid(uid)
os.execvp(args[0], args)
' ${1+"$@"}
  }
elif (exec guile -c "(or (defined? 'setgroups) (exit 1))") \
       > /dev/null 2>&1; then
  setuidgid() {
    guile -c '
(define argv (program-arguments))
(define acct (cadr argv))
(define args (cddr argv))
(define data (getpwnam acct))
(define uid (vector-ref data 2))
(define gid (vector-ref data 3))
(setgid gid)
(setgroups (vector gid))
(setuid uid)
(apply execlp (car args) args)
' ${1+"$@"}
  }
else
  setuidgid() {
    echo "${prj_program-setuidgid}: unable to find a setuidgid program" >&2
    return 100
  }
fi

case $? in 0) :;; *) (exit "$?");; esac &&
if ( exec curl-config --version ) > /dev/null 2>&1; then
  prj_download() {
    : "${3?}" &&
    ( cd "$2" && rm -f "$3" && exec curl -LsSfo "$3" "$1" )
  }
elif ( exec wget -V ) > /dev/null 2>&1; then
  prj_download() {
    : "${3?}" &&
    ( cd "$2" && rm -f "$3" && exec wget -nv "$1" )
  }
elif ( exec wget -s http://www.google.com/ ) > /dev/null 2>&1; then
  prj_download() {
    : "${3?}" &&
    ( cd "$2" && rm -f "$3" && exec wget -q "$1" )
  }
elif ( exec fetch -o - file:///dev/null ) > /dev/null 2>&1; then
  prj_download() {
    : "${3?}" &&
    ( cd "$2" && rm -f "$3" && exec fetch -aqo "$3" "$1" )
  }
elif ( exec lftp --version ) > /dev/null 2>&1; then
  prj_download() {
    : "${3?}" &&
    ( cd "$2" && rm -f "$3" && exec lftp -c "get $1" )
  }
else
  prj_download() {
    echo "${prj_program-prj_download}: unable to find a download program" >&2
    return 100
  }
fi

case $? in 0) :;; *) (exit "$?");; esac &&
if (prj_which readlink_path readlink) 2> /dev/null; then
  :
elif (exec perl -e '') > /dev/null 2>&1; then
  readlink() { perl -le 'print(readlink($ARGV[0]) or die($!."\n"))' "${1?}"; }
elif (exec python -c '') > /dev/null 2>&1; then
  readlink() {
    python -c 'import sys, os; print os.readlink(sys.argv[1])' "${1?}"
  }
elif (exec guile -c '') > /dev/null 2>&1; then
  readlink() {
    guile -c '(format #t "~A\n" (readlink (cadr (program-arguments))))' "${1?}"
  }
else
  readlink() {
    echo "${prj_program-readlink}: unable to find a readlink program" >&2
    return 100
  }
fi

case $? in 0) :;; *) (exit "$?");; esac &&
prj_anyeq_tmp_= &&
unset prj_anyeq_tmp_ &&
prj_anyeq() {
  prj_anyeq_tmp_=${1?} &&
  shift &&
  while :; do
    if test "$#" = 0; then return 100
    else
      case $1 in
        "${prj_anyeq_tmp_?}") return 0;;
        *) shift;;
      esac
    fi || return "$?"
  done
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_let() {
  : "${3?}" &&
  eval '
  shift &&
  if test "${'"$1"'+x}" = x; then
    set x "${'"$1"'?}" "$@" && shift &&
    '"$1"'=$2 &&
    prj_let_ "$@" &&
    '"$1"'=$1
  else
    set x "$@" &&
    '"$1"'=$2 &&
    prj_let_ "$@" &&
    unset '"$1"'
  fi
'
} &&
prj_let_() {
  : "${3?}" &&
  shift && shift &&
  "$@"
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_dir_eq_1='' &&
prj_dir_eq_2='' &&
unset prj_dir_eq_1 prj_dir_eq_2 &&
prj_dir_eq_filter() {
  sed '
$!d
s/^.*[ 	][0-9][0-9]*[ 	][ 	]*[0-9][0-9]*[ 	][ 	]*[0-9][0-9]*[ 	][ 	]*[0-9][0-9]*%[ 	][ 	]*//
' <<EOT
$1
EOT
} &&
prj_dir_eq() {
  : "${2?}" &&
  test -d "$1"/. &&
  test -d "$2"/. &&
  if prj_dir_eq_1=`cd "$1" && pwd -P` 2> /dev/null; then
    prj_dir_eq_2=`cd "$2" && pwd -P` 2> /dev/null
  else
    prj_dir_eq_1=`cd "$1" && df .` &&
    prj_dir_eq_2=`cd "$2" && df .` &&
    prj_dir_eq_1=`prj_dir_eq_filter "${prj_dir_eq_1?}"` &&
    prj_dir_eq_2=`prj_dir_eq_filter "${prj_dir_eq_2?}"` &&
    prj_dir_eq_1=${prj_dir_eq_1?}:`cd "$1" && ls -ldi .` &&
    prj_dir_eq_2=${prj_dir_eq_2?}:`cd "$2" && ls -ldi .`
  fi &&
  test x"${prj_dir_eq_1?}" = x"${prj_dir_eq_2?}"
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_sedarg() {
  sed -e "$1" <<EOT
${2?}
EOT
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_unset() {
  while test "$#" != 0; do
    { eval "$1=" &&
      unset "$1" &&
      shift
    } || return "$?"
  done
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_fail() {
  : "${1?}" &&
  set x "$*" &&
  if test "${prj_program+x}" = x
    then set x "${prj_program?}: $2"
    else :
  fi &&
  case $2 in
    -*|*\\*) cat <<EOT
$2
EOT
      ;;
    *) echo "$2";;
  esac >&2
  return 100
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_sedarg1() {
  sed -e '
1h
1!H
$!d
g
'"$1" <<EOT
${2?}
EOT
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_dirname() {
  sed '
1h
1!H
$!d
g
s%[^/]*$%%
' <<EOT
${1?}
EOT
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_basename() {
  sed '
1h
1!H
g
s%^.*/%%
h
$!d
' <<EOT
${1?}
EOT
}

case $? in 0) :;; *) (exit "$?");; esac &&
prj_mkdir_p_tmp_= &&
unset prj_mkdir_p_tmp_ &&
prj_mkdir_p_sed_() {
  exec sed "$1" <<EOT
${2?}
EOT
} &&
prj_mkdir_p() {
  case ${1?} in
    '') echo >&2 'prj_mkdir_p: path must not be empty'; return 100;;
    *[!/]*) :;;
    *) return 0;;
  esac &&
  prj_mkdir_p_tmp_='
1h
1!H
$!d
g
/^\//!s%^%./%
s%/*$%%
' &&
  prj_mkdir_p_tmp_=`prj_mkdir_p_sed_ "${prj_mkdir_p_tmp_?}" "$1"` &&
  set "${prj_mkdir_p_tmp_?}" &&
  while :; do
    { if test -d "$1"/.; then shift && break; else :; fi &&
      prj_mkdir_p_tmp_='
1h
1!H
$!d
g
s%//*[^/]*$%%
' &&
      prj_mkdir_p_tmp_=`prj_mkdir_p_sed_ "${prj_mkdir_p_tmp_?}" "$1"` &&
      set "${prj_mkdir_p_tmp_?}" ${1+"$@"}
    } || return "$?"
  done &&
  for prj_mkdir_p_tmp_ in ${1+"$@"}; do
    mkdir "${prj_mkdir_p_tmp_?}" || return "$?"
  done
} &&
prj_cpdir() {
  # takes two arguments - src dest, result is dest/src
  case ${2?} in
    '') echo >&2 'prj_cpdir: dest must not be empty'; return 100;;
    *[!/]*) :;;
    *) return 0;;
  esac &&
  prj_mkdir_p ${2} &&
  cd ${1} && tar -c .  | tar -C ${2}/ -x
}
