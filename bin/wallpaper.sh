#!/data/data/com.termux/files/usr/bin/bash

# Directory to store wallpapers
WALLPAPER_DIR="$HOME/storage/shared/Pictures"
# File to store the ID of the last processed post
LAST_POST_FILE="$HOME/.last_amoled_post"

# Ensure wallpaper directory exists
mkdir -p "$WALLPAPER_DIR"

# Fetch the newest post from r/amoledbackgrounds
URL="https://www.reddit.com/r/amoledbackgrounds/new.json?limit=1"
POST_DATA=$(curl -s -A "TermuxWallpaperScript/1.0" "$URL")

# Check if curl was successful
if [ $? -ne 0 ]; then
  echo "Failed to fetch data from Reddit"
  exit 1
fi

# Debug: Output the raw JSON and extracted data
echo "Raw JSON: $POST_DATA" > "$WALLPAPER_DIR/debug.json"
POST_ID=$(echo "$POST_DATA" | jq -r '.data.children[0].data.id')
IMAGE_URL=$(echo "$POST_DATA" | jq -r '.data.children[0].data.url')
echo "Post ID: $POST_ID" >> "$WALLPAPER_DIR/debug.txt"
echo "Image URL: $IMAGE_URL" >> "$WALLPAPER_DIR/debug.txt"

# Handle different types of URLs
if [[ "$IMAGE_URL" =~ \.(jpg|jpeg|png|webp|gif)$ ]]; then
  # Direct image link
  FILENAME="$WALLPAPER_DIR/amoled_wallpaper_$(date +%s).${IMAGE_URL##*.}"
  wget -q "$IMAGE_URL" -O "$FILENAME"
elif [[ "$IMAGE_URL" =~ imgur\.com ]]; then
  # Handle Imgur links
  IMGUR_ID=$(echo "$IMAGE_URL" | grep -oP 'imgur\.com/\K[^/]+')
  DIRECT_URL="https://i.imgur.com/$IMGUR_ID.jpg"
  FILENAME="$WALLPAPER_DIR/amoled_wallpaper_$(date +%s).jpg"
  wget -q "$DIRECT_URL" -O "$FILENAME"
elif [[ "$IMAGE_URL" =~ reddit\.com/gallery ]]; then
  # Handle Reddit gallery
  GALLERY_DATA=$(echo "$POST_DATA" | jq -r '.data.children[0].data.media_metadata')
  if [ "$GALLERY_DATA" == "null" ]; then
    echo "No valid image found in gallery. URL was: $IMAGE_URL"
    exit 1
  fi
  # Get the first image from the gallery
  FIRST_IMAGE_ID=$(echo "$GALLERY_DATA" | jq -r 'keys[0]')
  IMAGE_EXT=$(echo "$GALLERY_DATA" | jq -r ".[\"$FIRST_IMAGE_ID\"].m" | grep -oP 'image/\K[^/]+')
  if ! [[ "$IMAGE_EXT" =~ ^(jpg|jpeg|png|webp|gif)$ ]]; then
    echo "No supported image format in gallery. URL was: $IMAGE_URL"
    exit 1
  fi
  DIRECT_URL=$(echo "$GALLERY_DATA" | jq -r ".[\"$FIRST_IMAGE_ID\"].s.u" | sed 's/amp;//g')
  FILENAME="$WALLPAPER_DIR/amoled_wallpaper_$(date +%s).$IMAGE_EXT"
  wget -q "$DIRECT_URL" -O "$FILENAME"
else
  echo "No valid image found in the latest post. URL was: $IMAGE_URL"
  exit 1
fi

# Check if post is new by comparing with last processed post ID
if [ -f "$LAST_POST_FILE" ]; then
  LAST_POST_ID=$(cat "$LAST_POST_FILE")
  if [ "$POST_ID" == "$LAST_POST_ID" ]; then
    echo "No new wallpaper found"
    exit 0
  fi
fi

# Check if download was successful
if [ $? -ne 0 ]; then
  echo "Failed to download wallpaper from $DIRECT_URL"
  exit 1
fi

# Set wallpaper as both home and lock screen using termux-api
termux-wallpaper -f "$FILENAME"
termux-wallpaper -l -f "$FILENAME"

# Check if wallpaper was set successfully
if [ $? -eq 0 ]; then
  echo "Wallpaper set successfully: $FILENAME"
  # Update last post ID
  echo "$POST_ID" > "$LAST_POST_FILE"
else
  echo "Failed to set wallpaper"
  rm "$FILENAME"
  exit 1
fi

# Optional: Clean up old wallpapers (keep last 5)
find "$WALLPAPER_DIR" -name "amoled_wallpaper_*" -type f | sort -r | tail -n +6 | xargs -I {} rm {}
Test Change
