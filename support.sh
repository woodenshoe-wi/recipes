#!/bin/sh

#
# git2package sets the following environment variables.
#
# RECIPE_DIR is the path of the root of the recipe repo.
# SOURCE_DIR is the path of the git repo with the package source code.
# OUTPUT_DIR is the path to where finished packages should be saved.
#

# Sets compression method,
# gz and xz are the only methods currently supported.
EXT=xz

# package() $1=path/filename $2=PKGNAME $3=NAMEONLY $4=DESC $5=DEPS
package() {
  #split $1 path/filename into components...
  BASEPKG="$(basename $1)"
  DIRPKG="$(dirname $1)"
  [ "${DIRPKG}" = "/" ] && DIRPKG=""

  SIZEK="`du -s -k ${DIRPKG}/${BASEPKG} | cut -f 1`"

  . /etc/DISTRO_SPECS
  COMPAT=${DISTRO_BINARY_COMPAT}
  V=${DISTRO_COMPAT_VERSION}

  echo "$2|$3|${VER}||${CAT}|${SIZEK}K||${BASEPKG}.pet|$5|$4|${COMPAT}|${V}||" > \
    ${DIRPKG}/${BASEPKG}/pet.specs

  echo
  echo "Creating package..."
  tar -c -f ${DIRPKG}/${BASEPKG}.tar ${DIRPKG}/${BASEPKG}/
  sync
  case ${EXT} in
    xz)xz -z -9 -e ${DIRPKG}/${BASEPKG}.tar ;;
    gz)gzip --best ${DIRPKG}/${BASEPKG}.tar ;;
  esac
  TARBALL="${DIRPKG}/${BASEPKG}.tar.${EXT}"

  echo
  echo "File ${DIRPKG}/${BASEPKG}.tar.${EXT} created. Now converting to .pet..."
  FULLSIZE="`stat -c %s ${TARBALL}`"
  MD5SUM="`md5sum ${TARBALL} | cut -f 1 -d ' '`"
  echo -n "${MD5SUM}" >> ${TARBALL}
  sync
  mv -f ${TARBALL} ${OUTPUT_DIR}/${BASEPKG}.pet
  sync

  echo
  echo "${BASEPKG}.pet has been created. Finished."
  echo
}
