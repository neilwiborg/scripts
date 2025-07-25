#!/usr/bin/env zsh

# Directory containing the images
IMAGE_DIR="$1"

# Image types to look for
IMAGE_TYPES=(png jpg jpeg gif bmp tif tiff webp heic heif avif svg)

# Check if the directory is provided and exists
if [[ -z "$IMAGE_DIR" || ! -d "$IMAGE_DIR" ]]; then
	echo "Usage: $0 <image_directory>"
	exit 1
fi

# Check if the IMAGE_VIEWER environment variable is set
if [[ -z "$IMAGE_VIEWER" ]]; then
	echo "Please set the IMAGE_VIEWER environment variable to your preferred image viewer."
	exit 1
fi

# Function to read a keypress from the user
get_keypress() {
	local key
	read -rs -k1 key
	REPLY="$key"
}

# Function to display image
display_image() {
	clear
	$IMAGE_VIEWER "$1"
}

# Function to print options for an image
print_options() {
	img_name=${1:t}
	echo "Options for $img_name:"
	echo "Enter: Next image"
	echo "d: Delete this image (with confirmation)"
	echo "D: Delete this image (without confirmation)"
	echo "q: Quit the gallery"
}

# Function to delete image with confirmation
delete_image_with_confirmation() {
	rm -i "$1" || exit 1
}

# Function to delete image without confirmation
delete_image_without_confirmation() {
	rm -f "$1" || exit 1
}

# Check case-insensitively for file extensions, and don't return error if no results
setopt extended_glob
filetype_pattern="(${(j:|:)IMAGE_TYPES})"
images=(${~IMAGE_DIR}/*.(#i)${~filetype_pattern}(.N))

# Iterate over all images in the directory
for img in $images; do
	# Check if the file exists
	[[ -e "$img" ]] || continue

	# Display image and show options
	display_image "$img"
	print_options "$img"

	while true; do
		get_keypress
		key="$REPLY"
		case "$key" in
			$'\n') # Enter key to skip to the next image
				break
				;;
			d) # 'd' key to delete the image with confirmation
				delete_image_with_confirmation "$img"
				break
				;;
			D) # 'D' key to delete the image without confirmation
				delete_image_without_confirmation "$img"
				break
				;;
			q) # 'q' key to quit the gallery
				clear
				exit 0
				;;
			*) # Any other key, continue waiting for valid input
				;;
		esac
	done
done

clear
