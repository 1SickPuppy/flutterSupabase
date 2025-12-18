#!/bin/bash

# DeveloperCat DK - Quick Run Script
# This script loads environment variables from .env and runs the Flutter app

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    echo "Please create a .env file with your API keys:"
    echo "GEMINI_API_KEY=your_key_here"
    echo "SUPABASE_URL=your_url_here"
    echo "SUPABASE_ANON_KEY=your_key_here"
    exit 1
fi

# Load environment variables from .env
export $(cat .env | grep -v '^#' | xargs)

# Default device is Chrome (web)
DEVICE="${1:-chrome}"

echo "🚀 Starting DeveloperCat DK on $DEVICE..."
echo "📦 Using Gemini API Key: ${GEMINI_API_KEY:0:10}..."

# Run Flutter with environment variables
flutter run -d "$DEVICE" \
  --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
