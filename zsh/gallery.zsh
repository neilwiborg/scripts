#!/usr/bin/env zsh

# Image types to look for
typeset -g -a _GALLERY_IMAGE_TYPES=(png jpg jpeg gif bmp tif tiff webp heic heif avif svg)

# Function to read a keypress from the user
_gallery_get_keypress() {
	local key
	read -rs -k1 key
	REPLY="$key"
}

# Function to display image
_gallery_display_image() {
	clear
	$IMAGE_VIEWER "$1"
}

# Function to print options for an image
_gallery_print_options() {
	local img_name
	img_name=${1:t}
	echo "Options for $img_name:"
	echo "Enter: Next image"
	echo "d: Delete this image (with confirmation)"
	echo "D: Delete this image (without confirmation)"
	echo "q: Quit the gallery"
}

# Function to delete image with confirmation
_gallery_delete_image_with_confirmation() {
	rm -i "$1" || return 1
}

# Function to delete image without confirmation
_gallery_delete_image_without_confirmation() {
	rm -f "$1" || return 1
}

gallery() {
	local image_dir="$1"

	# Check if the directory is provided and exists
	if [[ -z "$image_dir" || ! -d "$image_dir" ]]; then
		echo "Usage: $0 <image_directory>"
		return 1
	fi

	# Check if the IMAGE_VIEWER environment variable is set
	if [[ -z "$IMAGE_VIEWER" ]]; then
		echo "Please set the IMAGE_VIEWER environment variable to your preferred image viewer."
		return 1
	fi

	if ! [[ -o extended_glob ]]; then
		echo "Please enable extended_glob and retry."
		return 1
	fi

	local filetype_pattern images img key
	filetype_pattern="(${(j:|:)_GALLERY_IMAGE_TYPES})"
	images=(${~image_dir}/*.(#i)${~filetype_pattern}(.N))

	# Iterate over all images in the directory
	for img in $images; do
		# Check if the file exists
		[[ -e "$img" ]] || continue

	# Display image and show options
	_gallery_display_image "$img"
	_gallery_print_options "$img"

		while true; do
			_gallery_get_keypress
			key="$REPLY"
			case "$key" in
				$'\n') # Enter key to skip to the next image
					break
					;;
				d) # 'd' key to delete the image with confirmation
					_gallery_delete_image_with_confirmation "$img"
					break
					;;
				D) # 'D' key to delete the image without confirmation
					_gallery_delete_image_without_confirmation "$img"
					break
					;;
				q) # 'q' key to quit the gallery
					clear
					return 0
					;;
				*) # Any other key, continue waiting for valid input
					;;
			esac
		done
	done

	clear
	return 0
}
