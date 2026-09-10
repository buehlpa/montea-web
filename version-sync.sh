#!/usr/bin/env bash
# Holt die aktuelle Ausgabe von Montea-2 (privat) und traegt sie in index.html
# ein - Versionsband, Update-Mailadresse und Fusszeile in einem Zug.
#
#   ./version-sync.sh            Version holen und eintragen
#   ./version-sync.sh --pruefen  nur melden, ob index.html hinterherhinkt
#   ./version-sync.sh 2.2.0      Version von Hand setzen
#
# Quelle, in dieser Reihenfolge:
#   1. GitHub-API, wenn GH_TOKEN oder GITHUB_TOKEN gesetzt ist (echter Release)
#   2. der lokale Klon unter MONTEA_REPO (neuester Tag)
set -euo pipefail

REPO=${MONTEA_REPO:-$HOME/repos/Montea-2}
NWERK=buehlpa/Montea-2
SEITE=$(dirname "$0")/index.html

api() {
  curl -fsSL -H "Authorization: Bearer ${GH_TOKEN:-${GITHUB_TOKEN:-}}" \
       -H "Accept: application/vnd.github+json" \
       "https://api.github.com/repos/$NWERK/$1" 2>/dev/null || true
}

ausgabe_holen() {
  local token=${GH_TOKEN:-${GITHUB_TOKEN:-}}
  if [ -n "$token" ]; then
    local marke
    # Erst der veroeffentlichte Release. Gibt es keinen - nur Tags -, dann der
    # neueste Tag; die API listet sie in der Reihenfolge des Repos.
    marke=$(api "releases/latest" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1)
    [ -n "$marke" ] || marke=$(api "tags?per_page=1" | sed -n 's/.*"name": *"\([^"]*\)".*/\1/p' | head -1)
    echo "$marke"
    return
  fi
  if [ -d "$REPO/.git" ]; then
    git -C "$REPO" fetch --tags --quiet 2>/dev/null || true
    git -C "$REPO" tag --sort=-v:refname | head -1
    return
  fi
  echo "Keine Quelle: weder GH_TOKEN gesetzt noch Klon unter $REPO." >&2
  exit 1
}

neu=${1:-}
case "$neu" in --pruefen|"") neu=$(ausgabe_holen) ;; esac
neu=${neu#v}
[ -n "$neu" ] || { echo "Keine Ausgabe gefunden." >&2; exit 1; }

alt=$(sed -n 's/.*<span class="ausgabe">\([^<]*\)<\/span>.*/\1/p' "$SEITE" | head -1)

if [ "${1:-}" = "--pruefen" ]; then
  [ "$alt" = "$neu" ] && { echo "aktuell: $alt"; exit 0; }
  echo "Seite steht auf $alt, Montea-2 liefert $neu."; exit 1
fi

[ "$alt" = "$neu" ] && { echo "Bereits auf $neu - nichts zu tun."; exit 0; }

sed -i -E \
  -e "s|(<span class=\"ausgabe\">)[0-9]+\.[0-9]+\.[0-9]+(</span>)|\1$neu\2|" \
  -e "s|(subject=Montea%20)[0-9]+\.[0-9]+\.[0-9]+(%20)|\1$neu\2|" \
  -e "s|(<b>Montea )[0-9]+\.[0-9]+\.[0-9]+(</b>)|\1$neu\2|" \
  "$SEITE"

echo "index.html: $alt -> $neu"
grep -nE "ausgabe\">|subject=Montea%20|<b>Montea " "$SEITE"
