#!/bin/sh
ARCHIVES="archive"
SOURCES="source"
UNCRAWLABLES="uncrawlable"
DICTIONARIES="dictionaries"

mkdir -p "$ARCHIVES"
mkdir -p "$SOURCES"
mkdir -p "$DICTIONARIES"
mkdir -p "$UNCRAWLABLES"

#####################################################################
# METHODS ###########################################################
#####################################################################

#
# Unpack an archive.
#
# @param $1 - Name of archive.
# @param $2 - Page of source.
#
unpack() {
  ARCHIVE_PATH="$ARCHIVES/$1.zip"
  SOURCE_PATH="$SOURCES/$1"

  if [ ! -e "$SOURCE_PATH" ]; then
    unzip "$ARCHIVES/$1.zip" -d "$SOURCE_PATH"
  fi

  echo "$2" > "$SOURCE_PATH/SOURCE"
}

#
# Crawl and unpack an archive.
#
# @param $1 - Name of archive;
# @param $2 - Page of source.
# @param $3 - URL to archive.
#
crawl() {
  ARCHIVE_PATH="$ARCHIVES/$1.zip"

  if [ ! -e "$ARCHIVE_PATH" ]; then
    wget "$3" -O "$ARCHIVE_PATH"
  fi

  unpack "$1" "$2"
}

#
# Copy a local archive and unpack it.
#
# @param $1 - Name of archive.
# @param $2 - Page of source.
#
uncrawl() {
  ARCHIVE_PATH="$ARCHIVES/$1.zip"

  if [ ! -e "$ARCHIVE_PATH" ]; then
    cp "$UNCRAWLABLES/$1.zip" "$ARCHIVE_PATH"
  fi

  unpack "$1" "$2"

  echo "Warning: Loading local $1"
}

#
# Generate a package from a crawled directory (at $1) and
# the given settings.
#
# @param $1 - Name of source;
# @param $2 - Language / region code;
# @param $3 - SPDX license;
# @param $4 - Path to lincese file. Should be `-` when not
#   applicable;
# @param $5 - Path to `.aff` file;
# @param $6 - Path to `.dic` file;
# @param $7 - Encoding of `.aff` and `.dic` file.
#
generate() {
  SOURCE="$SOURCES/$1"
  dictionary="$DICTIONARIES/$2"

  mkdir -p "$dictionary"

  cp "$SOURCE/SOURCE" "$dictionary/SOURCE"

  echo "$3" > "$dictionary/SPDX"

  if [ -e "$SOURCE/$4" ]; then
    tr -d '\r' < "$SOURCE/$4" > "$dictionary/LICENSE"
  else
    echo "Warning: Missing LICENSE file for $2"
  fi

  (iconv -f "$7" -t "UTF-8" | sed "s/SET $8/SET UTF-8/" | tr -d '\r') < "$SOURCE/$5" > "$dictionary/index.dic"
  (iconv -f "$7" -t "UTF-8" | sed "s/SET $7/SET UTF-8/" | tr -d '\r') < "$SOURCE/$6" > "$dictionary/index.aff"
}

#####################################################################
# ARCHIVES ##########################################################
#####################################################################

#
# List of archives to crawl.
#


crawl "german" \
  "https://extensions.openoffice.org/project/dict-de_DE_frami" \
  "https://sourceforge.net/projects/aoo-extensions/files/1075/15/dict-de_de-frami_2017-01-12.oxt/download"


#####################################################################
# DICTIONARIES ######################################################
#####################################################################



#
# German (Germany).
#

generate "german" \
  "de_DE" \
  "(GPL-2.0 OR GPL-3.0)" \
  "de_DE_frami/de_DE_frami_README.txt" \
  "de_DE_frami/de_DE_frami.dic" \
  "de_DE_frami/de_DE_frami.aff" \
  "ISO8859-1"

