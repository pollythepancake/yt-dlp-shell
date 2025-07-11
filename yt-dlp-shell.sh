#!/usr/bin/env bash

# Written by Polly May
# GitHub: https://github.com/PollyThePancake
# Inspired by Mr. Mendelli
# GitHub: https://github.com/MrMendelli

error() {
	clear
	echo -e "An error has occured\n"
	case "$1" in
		"1") echo -e "Unknown platform, please download FFmpeg and yt-dlp for your respective platforms and install them, add them to your path, or place the binaries in the /bin folder" ;;
		"2") echo -e "Please install $2 for your respective platforms and install it, add it to your path, or place the binaries in the /bin folder" ;;
		"3") echo -e "Unable to give $2 executable permissions, please manually give the $2 binaries in /bin executable permissions" ;;
		"4") echo -e "Unable to download usable binaries for $2, please install $2 for your respective platforms and install it, add it to your path, or place the binaries in the /bin folder" ;;
		"5") echo -e "Unable to change current directory" ;;
		*) echo -e "Critical error, please report as an issue" ;;
	esac
	read -rp "Press enter to exit >>"
	exit_script
}

base_path="$(pwd)"
mkdir -p "./yt-dlp-shell/bin"
cd ./yt-dlp-shell || error "5"
mkdir -p "./video"
mkdir -p "./audio"
mkdir -p "./subs"

platform=""

ffmpeg="ffmpeg"
ytdlp="yt-dlp"


main() {
	check_platform
	check_ffmpeg
	check_ytdlp
	main_menu
}

exit_script() {
	cd "$base_path" || exit
	clear
	exit 1
}

check_platform(){
	case "$(uname)" in
		MINGW*|CYGWIN*|MSYS*)
			platform="Windows" ;;
		"Darwin")
			platform="MacOS" ;;
		"Linux")
			case "$(uname -m)" in
			"x86_64"|"aarch64"|"armv7l") platform="Linux_$(uname -m)";;
			*) error "1" ;;
			esac ;;
		*) error "1" ;;
	esac
}

check_ffmpeg() {
	if [ -f ./bin/ffmpeg ] && [ ! -x ./bin/ffmpeg ]; then
		chmod +x ./bin/ffmpeg
		if [ ! -x ./bin/ffmpeg ]; then
			error "3" "FFmpeg"
		fi
	fi
	if [ -x ./bin/ffmpeg ] && ./bin/ffmpeg -version 2>&1 | grep -q "ffmpeg version"; then
		ffmpeg="./bin/ffmpeg"
	elif [ -x ./bin/ffmpeg_"$platform" ] && ./bin/ffmpeg_"$platform" -version 2>&1 | grep -q "ffmpeg version"; then
		ffmpeg="./bin/ffmpeg_$platform"
	else
		while true; do
			if ! command -v ffmpeg >/dev/null 2>&1; then
				clear; read -rp "FFmpeg is missing. Do you want to download it automatically? (y/n) >> " answer
				case "$answer" in
					[Yy]*) download_ffmpeg; break;;
					[Nn]*) error "2" "FFmpeg";;
					*) read -rp "Invalid Choice >> ";;
				esac
			else break
			fi
		done
	fi
}

download_ffmpeg() {
	cd ./bin || error "5"
	echo "Downloading yt-dlp for $platform"
	case "$platform" in
	"Windows")
		curl --fail --location --progress-bar -Lo ./ffmpeg.zip "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
		unzip ./ffmpeg.zip
		mv "./$(unzip -Z1 ./ffmpeg.zip | head -1 | cut -d/ -f1)/bin/ffmpeg.exe" ./ffmpeg
		rm -r "./$(unzip -Z1 ./ffmpeg.zip | head -1 | cut -d/ -f1)"
		rm ./ffmpeg.zip ;;

	"MacOS")
		curl --fail --location --progress-bar -Lo ./ffmpeg.zip "https://evermeet.cx/ffmpeg/getrelease/zip"
		unzip ./ffmpeg.zip
		mv ./ffmpeg ./ffmpeg
		rm ./ffmpeg.zip
		chmod +x ./ffmpeg ;;

	"Linux"*)
		case "$(uname -m)" in
		"x86_64") architecture="amd64" ;;
		"aarch64") architecture="arm64" ;;
		"armv7l") architecture="armhf" ;;
		*) error ;;
		esac
		curl --fail --location --progress-bar -Lo ./ffmpeg.tar.xz "https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-$architecture-static.tar.xz"
		tar -xf ./ffmpeg.tar.xz
		mv "./$(tar -tf ./ffmpeg.tar.xz | head -1 | cut -d/ -f1)/ffmpeg" ./ffmpeg
		rm -r "./$(tar -tf ./ffmpeg.tar.xz | head -1 | cut -d/ -f1)"
		rm ./ffmpeg.tar.xz
		chmod +x ./ffmpeg ;;

	*) error ;;

	esac
	cd ../ || error "5"

	if [ ! -x ./bin/ffmpeg ]; then
		error "3" "FFmpeg"
	elif ! ./bin/ffmpeg -version 2>&1 | grep -q "ffmpeg version"; then
		error "4" "FFmpeg"
	fi

	mv ./bin/ffmpeg ./bin/ffmpeg_"$platform"
	ffmpeg="./bin/ffmpeg_$platform"
}

check_ytdlp(){
	if [ -f ./bin/yt-dlp ] && [ ! -x ./bin/yt-dlp ]; then
		chmod +x ./bin/yt-dlp
		if [ ! -x ./bin/yt-dlp ]; then
			error "3" "yt-dlp"
		fi
	fi
	if [ -x ./bin/yt-dlp ] && ./bin/yt-dlp --version 2>/dev/null | grep -qE '^[0-9]{4}\.[0-9]{2}\.[0-9]{2}$'; then
		ytdlp="./bin/yt-dlp"
	elif [ -x ./bin/yt-dlp_"$platform" ] && ./bin/yt-dlp_"$platform" --version 2>/dev/null | grep -qE '^[0-9]{4}\.[0-9]{2}\.[0-9]{2}$'; then
		ytdlp="./bin/yt-dlp_$platform"
	else
		while true; do
			if ! command -v yt-dlp >/dev/null 2>&1; then
				clear; read -rp "yt-dlp is missing. Do you want to download it automatically? (y/n) >> " answer
				case "$answer" in
					[Yy]*) download_ytdlp; break;;
					[Nn]*) error "2" "yt-dlp";;
					*) read -rp "Invalid Choice >> ";;
				esac
			else break
			fi
		done
	fi
}

download_ytdlp() {
	cd ./bin || error "5"
	echo "Downloading yt-dlp for $platform"
	case "$platform" in
	"Windows")
		curl --fail --location --progress-bar -Lo ./yt-dlp "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" ;;

	"MacOS")
		curl --fail --location --progress-bar -Lo ./yt-dlp "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos"
		chmod +x ./yt-dlp ;;

	"Linux"*)
		case "$(uname -m)" in
		"x86_64") architecture="" ;;
		"aarch64") architecture="_arm64" ;;
		"armv7l") architecture="_armhf" ;;
		*) error ;;
		esac
		curl --fail --location --progress-bar -Lo ./yt-dlp "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux$architecture"
		chmod +x ./yt-dlp ;;

	*) error ;;

	esac
	cd ../ || error "5"

	if [ ! -x ./bin/yt-dlp ]; then
		error "3" "yt-dlp"
	elif ! ./bin/yt-dlp --version 2>/dev/null | grep -qE '^[0-9]{4}\.[0-9]{2}\.[0-9]{2}$'; then
		error "4" "yt-dlp"
	fi

	mv ./bin/yt-dlp ./bin/yt-dlp_"$platform"
	ytdlp="./bin/yt-dlp_$platform"
}

main_menu() {
	while true; do
	clear;
	echo "Welcome to yt-dlp-shell"
	echo ""
	echo "Choose an option:"
	echo "1. Download"
	echo "2. Help (WIP)"
	echo "3. Update yt-dlp"
	echo "4. Exit"
	echo ""
	read -rp "Enter your choice >> " choice

	case $choice in
		1)
			check_url;;
		2)
			help_menu;;
		3)
			clear
			$ytdlp -U
			read -rp "Press enter to continue >> "
			main_menu ;;
		4)
			exit_script;;
		5)
			debug;;
		*)
			read -rp "Invalid Choice >> "
			main_menu ;;
	esac

	done
}

check_url() {
	clear
	read -rp "Please enter a video or playlist URL >> " url
	output=$($ytdlp --quiet --no-warnings --get-id --ies all,-generic "$url" 2>&1)

	if [[ -z "$output" || "$output" == ERROR* ]]; then
		echo "Invalid URL"
		read -rp "Press enter to continue >> "
	else
		download_menu
	fi
	main_menu
}

download_menu() {
	clear
		echo "Valid URL"
		read -rp "Press enter to continue >> "
}

help_menu() {
	clear
	echo "Work in progress"
	read -rp "Press enter to continue >> "
	main_menu
}

debug() {
	echo "$platform"
	echo "$ffmpeg"
	echo "$ytdlp"
	$ffmpeg -version | head -n 1 | awk '{print $3}'
	$ytdlp --version
	read -rp "Press enter to continue >> "
}

main
