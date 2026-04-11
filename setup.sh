#!/bin/bash
# IoTani Setup Script
# Quick setup for development

echo "🌱 IoTani Setup Script"
echo "====================="

# Step 1: Install dependencies
echo ""
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Step 2: Generate Riverpod code (if needed)
echo ""
echo "⚙️  Generating Riverpod code..."
# flutter pub run build_runner build --delete-conflicting-outputs

# Step 3: Clean cache
echo ""
echo "🧹 Cleaning build cache..."
flutter clean

# Step 4: Get dependencies again
flutter pub get

echo ""
echo "✅ Setup complete!"
echo ""
echo "📱 Next steps:"
echo "1. Configure Firebase (see README.md)"
echo "2. Run: flutter run -d android  (or -d ios for iOS)"
echo ""
echo "📚 Documentation:"
echo "  - README.md - Quick start guide"
echo "  - ARCHITECTURE.md - Detailed architecture and setup"
echo ""
