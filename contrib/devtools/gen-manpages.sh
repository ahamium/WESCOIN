#!/usr/bin/env bash

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

WESCOIND=${WESCOIND:-$BINDIR/wescoind}
WESCOINCLI=${WESCOINCLI:-$BINDIR/wescoin-cli}
WESCOINTX=${WESCOINTX:-$BINDIR/wescoin-tx}
WESCOINQT=${WESCOINQT:-$BINDIR/qt/wescoin-qt}

[ ! -x $WESCOIND ] && echo "$WESCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
WESCVER=($($WESCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for wescoind if --version-string is not set,
# but has different outcomes for wescoin-qt and wescoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$WESCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $WESCOIND $WESCOINCLI $WESCOINTX $WESCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${WESCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${WESCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
