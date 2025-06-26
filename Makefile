.PHONY: help setup clean test build run docker

# Default target
help:
	@echo "Streamy Project Commands"
	@echo "======================="
	@echo "Setup Commands:"
	@echo "  setup           Install all dependencies (Flutter + Python)"
	@echo "  setup-flutter   Install Flutter dependencies only"
	@echo "  setup-backend   Install Python dependencies only"
	@echo ""
	@echo "Development Commands:"
	@echo "  run             Run both backend and frontend in development"
	@echo "  run-flutter     Run Flutter app only"
	@echo "  run-backend     Run Python backend only"
	@echo ""
	@echo "Testing Commands:"
	@echo "  test            Run all tests"
	@echo "  test-flutter    Run Flutter tests"
	@echo "  test-backend    Run Python tests"
	@echo ""
	@echo "Build Commands:"
	@echo "  build           Build release versions"
	@echo "  build-android   Build Android APK"
	@echo "  build-ios       Build iOS app"
	@echo ""
	@echo "Maintenance Commands:"
	@echo "  clean           Clean all build artifacts"
	@echo "  clean-flutter   Clean Flutter build artifacts"
	@echo "  clean-backend   Clean Python cache files"
	@echo "  format          Format all code"
	@echo ""
	@echo "Docker Commands:"
	@echo "  docker-build    Build Docker containers"
	@echo "  docker-run      Run with Docker Compose"
	@echo "  docker-stop     Stop Docker containers"

# Setup Commands
setup: setup-flutter setup-backend
	@echo "✅ All dependencies installed successfully!"

setup-flutter:
	@echo "📱 Installing Flutter dependencies..."
	cd streamy_app && flutter pub get
	@echo "✅ Flutter dependencies installed!"

setup-backend:
	@echo "🐍 Installing Python dependencies..."
	cd backend && pip install -r requirements.txt
	@echo "✅ Python dependencies installed!"

# Development Commands
run:
	@echo "🚀 Starting development servers..."
	@echo "Backend will start on http://localhost:8000"
	@echo "Flutter app will start on connected device/emulator"
	make run-backend & make run-flutter

run-flutter:
	@echo "📱 Starting Flutter app..."
	cd streamy_app && flutter run

run-backend:
	@echo "🐍 Starting Python backend..."
	cd backend && python run.py

# Testing Commands
test: test-flutter test-backend
	@echo "✅ All tests completed!"

test-flutter:
	@echo "🧪 Running Flutter tests..."
	cd streamy_app && flutter test

test-backend:
	@echo "🧪 Running Python tests..."
	cd backend && python -m pytest tests/ -v

# Build Commands
build: build-android
	@echo "✅ Build completed!"

build-android:
	@echo "📦 Building Android APK..."
	cd streamy_app && flutter build apk --release
	@echo "✅ Android APK built successfully!"
	@echo "📍 APK location: streamy_app/build/app/outputs/flutter-apk/app-release.apk"

build-ios:
	@echo "📦 Building iOS app..."
	cd streamy_app && flutter build ios --release
	@echo "✅ iOS app built successfully!"

# Maintenance Commands
clean: clean-flutter clean-backend
	@echo "✅ All build artifacts cleaned!"

clean-flutter:
	@echo "🧹 Cleaning Flutter build artifacts..."
	cd streamy_app && flutter clean

clean-backend:
	@echo "🧹 Cleaning Python cache files..."
	find backend -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find backend -type f -name "*.pyc" -delete 2>/dev/null || true

format:
	@echo "🎨 Formatting code..."
	cd streamy_app && dart format lib/ test/
	cd backend && black src/ tests/
	@echo "✅ Code formatted!"

# Docker Commands
docker-build:
	@echo "🐳 Building Docker containers..."
	docker-compose build

docker-run:
	@echo "🐳 Starting with Docker Compose..."
	docker-compose up -d
	@echo "✅ Services started!"
	@echo "Backend: http://localhost:8000"

docker-stop:
	@echo "🐳 Stopping Docker containers..."
	docker-compose down

# Analysis Commands
analyze:
	@echo "🔍 Analyzing Flutter code..."
	cd streamy_app && flutter analyze
	@echo "🔍 Analyzing Python code..."
	cd backend && flake8 src/ tests/

# Dependency Updates
update:
	@echo "⬆️ Updating dependencies..."
	cd streamy_app && flutter pub upgrade
	cd backend && pip install --upgrade -r requirements.txt
	@echo "✅ Dependencies updated!"

# Quick development workflow
dev-setup: clean setup
	@echo "🎯 Development environment ready!"

# Release preparation
prepare-release: clean test build
	@echo "🚀 Release preparation completed!"
