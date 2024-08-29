#!/bin/bash

set -e 

owner="${1}"
repo="${2}"
ref="${3}"

is_binary_file() {
    # perplexity で生成した関数(少し調整してある)
    local filename="$1"
    local extension="${filename##*.}"

    # バイナリファイルと見なす拡張子のリスト
    local binary_extensions=("mp3" "wav" "ogg" "flac" "mp4" "avi" "mkv" "mov" "webm" "pdf" "doc" "docx" "xls" "xlsx" "ppt" "pptx" "exe" "dll" "so" "zip" "tar" "gz" "xz"  "ttf" "otf" "woff" "woff2")

    for ext in "${binary_extensions[@]}"; do
        if [[ "${extension,,}" == "$ext" ]]; then
            return 0  # バイナリファイルと判断された場合は0で終了
        fi
    done

    return 1  # バイナリファイルでないと判断された場合は1で終了
}

is_image_file() {
    # perplexity で生成した関数(少し調整してある)
    local filename="$1"
    local extension="${filename##*.}"

    # 画像ファイルと見なす拡張子のリスト
    local binary_extensions=("jpg" "jpeg" "png" "gif" "bmp" "webp" "ico" "avif")

    for ext in "${binary_extensions[@]}"; do
        if [[ "${extension,,}" == "$ext" ]]; then
            return 0  # バイナリファイルと判断された場合は0で終了
        fi
    done

    return 1  # バイナリファイルでないと判断された場合は1で終了
}

html_escape() {
    # GitHub Copilot で生成した関数(少し調整してある)
    sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g' -e "s/'/\&#39;/g"
}

raw_url() {
     echo -n "https://raw.githubusercontent.com/${1}/${2}/${3}" | html_escape
}

function content_fld {
    # if file "${1}" | grep -q -i text; then
    if is_image_file "${1}"; then
        echo "<img src=\"${2}\" />"
    elif is_binary_file "${1}"; then
        echo "<a href=\"${2}\">${2}</a>"
    else
        echo "<pre><code>"
        html_escape <"${1}"
        echo "</pre></code>"
    fi
}

TEMP_DIR=$(mktemp -d)
trap 'rm -r "${TEMP_DIR}"' EXIT
cd "${TEMP_DIR}"

echo "<html><head><title>$(echo -n "${owner}/${repo}/${ref}" | html_escape)</title></head><body>"
echo "<h1>$(echo -n "${owner}/${repo}/${ref}" | html_escape)</h1>"

# `.tar` を一旦展開するのは少しおもしろくない。できればパイプ的に扱いたいが今回は見送り。
curl -sL "https://github.com/${owner}/${repo}/archive/${ref}.tar.gz" | tar --strip 1 -zxf -
echo "<h2>Files</h2>"
find . -type f -print0 |  while IFS= read -r -d '' file; do
    # echo "{\"path\":$(echo -n "${file}" | jq -sR . ),$(content_fld "${PWD}/${file}")},"
    file="${file#./}"
    echo "<h3>$(echo -n "${file}" | html_escape)</h3>"
    echo "<p>"
    content_fld "${PWD}/${file}" "$(raw_url "${owner}" "${repo}" "${ref}/${file}")"
    echo "</p>"
done 

echo "</body></html>"