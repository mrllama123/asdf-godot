#!/usr/bin/env bash

set -euo pipefail

# GH_REPO='https://github.com/godotengine/godot-builds'
GH_REPO_GODOT='https://github.com/godotengine/godot-builds'
GH_REPO_REDOT='https://github.com/Redot-Engine/redot-engine'
# TOOL_NAME='godot'
# TOOL_TEST="${TOOL_NAME} --help"

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

get_release_file_name() {
	local version="$1"

	platform=$(uname | tr '[:upper:]' '[:lower:]')
	if [ "${platform}" == 'darwin' ]; then
		echo "Godot_v${version}_macos.universal"
		exit 0
	fi

	arch=$(uname -m)

	echo "Godot_v${version}_${platform}.${arch}"
}

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_all_versions() {
	list_github_tags
}

download_release() {
	local tool_name repo version filename url
	tool_name="$1"
	repo="$2"
	version="$3"
	filename="$4"

	url="$repo/releases/download/${version}/$(get_release_file_name "${version}").zip"

	echo "* Downloading $tool_name release $version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local tool_name="$1"
	local install_type="$2"
	local version="$3"
	local install_path="${4%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$tool_name supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		local tool_cmd
		tool_cmd="$(echo "${tool_name} --help" | cut -d' ' -f1)"
		platform=$(uname | tr '[:upper:]' '[:lower:]')

		app_path=

		if [ "$tool_name" == "redot" ]; then
			app_path="${install_path}/Redot.app/Contents/MacOS/Redot"
		else
			app_path="${install_path}/Godot.app/Contents/MacOS/Godot"
		fi

		if [ "${platform}" == "darwin" ]; then
			ln -s "$app_path" "$install_path/${tool_cmd}"
		fi

		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $tool_name $version."
	)
}
