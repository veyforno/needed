#!/usr/bin/env bash
LYRICS_DIR="$HOME/Music"

lrc="$LYRICS_DIR/${FILE%.*}.lrc"
[ -f "$lrc" ] && exit 0
mkdir -p "$(dirname "$lrc")"

curl -s -G "https://lrclib.net/api/get" \
  --data-urlencode "artist_name=$ARTIST" \
  --data-urlencode "track_name=$TITLE" |
  jq -r '.syncedLyrics // empty' >"$lrc.tmp"

if [ -s "$lrc.tmp" ]; then mv "$lrc.tmp" "$lrc"; else rm -f "$lrc.tmp"; fi
