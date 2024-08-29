#!/bin/bash

set -e 

owner="${1}"
repo="${2}"
ref="${3}"

is_binary_file() {
    # perplexity で生成した関数
    local filename="$1"
    local extension="${filename##*.}"

    # バイナリファイルと見なす拡張子のリスト
    local binary_extensions=("jpg" "jpeg" "png" "gif" "bmp" "ico" "avif" "mp3" "wav" "ogg" "flac" "mp4" "avi" "mkv" "mov" "webm" "pdf" "doc" "docx" "xls" "xlsx" "ppt" "pptx" "exe" "dll" "so" "zip" "tar" "gz" "xz" "ttf" "otf" "woff" "woff2")

    for ext in "${binary_extensions[@]}"; do
        if [[ "${extension,,}" == "$ext" ]]; then
            return 1  # バイナリファイルと判断された場合は1で終了
        fi
    done

    return 0  # バイナリファイルでないと判断された場合は0で終了
}

function content_fld {
    # if file "${1}" | grep -q -i text; then
    if is_binary_file "${1}"; then
        echo "\"content\":$(jq -sR . <"${1}")"
    else
        echo "\"contentBase64\":$(base64 "${1}" | jq -sR .)"
    fi
}

TEMP_DIR=$(mktemp -d)
trap 'rm -r "${TEMP_DIR}"' EXIT
cd "${TEMP_DIR}"

# `.tar` を一旦展開するのは少しおもしろくない。できればパイプ的に扱いたいが今回は見送り。
curl -sL "https://github.com/${owner}/${repo}/archive/${ref}.tar.gz" | tar --strip 1 -zxf -
echo "["
find . -type f -print0 |  while IFS= read -r -d '' file; do
    echo "{\"path\":$(echo -n "${file}" | jq -sR . ),$(content_fld "${PWD}/${file}")},"
done | sed '$s/,$//'
echo "]"