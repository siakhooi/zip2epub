#!/bin/bash

set -e

# If no args, process all zip/html files in /data
if [ $# -eq 0 ]; then
    FILES=$(ls /data/*.{zip,html} 2>/dev/null || true)
    if [ -z "$FILES" ]; then
        echo "❌ No .zip or .html files found in /data"
        exit 1
    fi
else
    FILES=("$@")
fi

pick_cover() {
    local DIR="$1"
    local COVER_IMG=""
    # Prefer cover.jpg / cover.png (case-insensitive)
    COVER_IMG=$(find "$DIR" -maxdepth 1 -type f \
        \( -iname "cover.jpg" -o -iname "cover.png" \) | head -n 1)

    if [ -z "$COVER_IMG" ]; then
        # Fallback: first image in directory
        COVER_IMG=$(find "$DIR" -maxdepth 1 -type f \
            \( -iname "*.jpg" -o -iname "*.png" \) | head -n 1)
    fi

    echo "$COVER_IMG"
}

get_title_from_file() {
    local FILE="$1"
    local NAME
    NAME=$(basename "$FILE")
    echo "${NAME%.*}"   # strip extension
}

for INPUT in "${FILES[@]}"; do
    echo "----------------------------------------"
    echo "📦 Processing: $INPUT"

    OPTIONS=()
    # If ZIP file
    if [[ "$INPUT" == *.zip ]]; then
        WORKDIR=$(mktemp -d)
        unzip -q "$INPUT" -d "$WORKDIR"

        ROOT_HTML=$(find "$WORKDIR" -maxdepth 1 -type f -name "*.html" | head -n 1)
        if [ -z "$ROOT_HTML" ]; then
            echo "❌ No HTML file found in $INPUT"
            continue
        fi

        TITLE=$(get_title_from_file "$ROOT_HTML")
        OPTIONS+=(--title="$TITLE")
        echo "📖 Book title set to: $TITLE"

        ROOT_IMG=$(pick_cover "$WORKDIR")
        if [ -n "$ROOT_IMG" ]; then
            echo "🖼 Using cover image: $ROOT_IMG"
            OPTIONS+=(--cover="$ROOT_IMG")
        fi

        BASE="${INPUT%.zip}"
        EPUB_OUT="${BASE}.epub"
        KEPUB_OUT="${BASE}.kepub.epub"

        echo "📖 Converting $ROOT_HTML → $EPUB_OUT"
        ebook-convert "$ROOT_HTML" "$EPUB_OUT" "${OPTIONS[@]}"
        echo "📖 Converting $EPUB_OUT → $KEPUB_OUT"
        ebook-convert "$EPUB_OUT" "$KEPUB_OUT" "${OPTIONS[@]}"

        echo "✅ EPUB created: $EPUB_OUT"
        echo "✅ Kepub created: $KEPUB_OUT"

    # If HTML file
    elif [[ "$INPUT" == *.html ]]; then
        TITLE=$(get_title_from_file "$INPUT")
        OPTIONS+=(--title="$TITLE")
        echo "📖 Book title set to: $TITLE"

        BASE_DIR=$(dirname "$INPUT")
        ROOT_IMG=$(pick_cover "$BASE_DIR")
        if [ -n "$ROOT_IMG" ]; then
            echo "🖼 Using cover image: $ROOT_IMG"
            OPTIONS+=(--cover="$ROOT_IMG")
        fi

        BASE="${INPUT%.html}"
        EPUB_OUT="${BASE}.epub"
        KEPUB_OUT="${BASE}.kepub.epub"

        echo "📖 Converting $INPUT → $EPUB_OUT"
        ebook-convert "$INPUT" "$EPUB_OUT" "${OPTIONS[@]}"
        echo "📖 Converting $EPUB_OUT → $KEPUB_OUT"
        ebook-convert "$EPUB_OUT" "$KEPUB_OUT" "${OPTIONS[@]}"

        echo "✅ EPUB  created: $EPUB_OUT"
        echo "✅ Kepub created: $KEPUB_OUT"

    else
        echo "⚠️ Skipping unsupported file: $INPUT"
    fi
done

echo "----------------------------------------"
echo "🎉 All conversions done!"
