# 📁 Project Structure

```
streamy/
├── 📄 README.md                  # Main project documentation
├── 📄 CONTRIBUTING.md           # Contribution guidelines
├── 📄 LICENSE                   # MIT License
├── 📄 Makefile                  # Build automation and commands
├── 📄 package.json              # Project metadata and scripts
├── 📄 .gitignore               # Git ignore patterns
│
├── 📱 streamy_app/              # Flutter Mobile Application
│   ├── lib/
│   │   ├── core/               # Core business logic
│   │   │   ├── api/           # API interfaces and models
│   │   │   ├── extractors/    # Video link extraction
│   │   │   ├── providers/     # Content providers (anime, movies)
│   │   │   ├── plugins/       # Plugin management system
│   │   │   ├── discovery/     # Content discovery service
│   │   │   ├── downloads/     # Download manager
│   │   │   ├── subtitles/     # Subtitle service
│   │   │   └── sync/          # Data synchronization
│   │   ├── screens/           # UI screens
│   │   ├── services/          # Application services
│   │   ├── widgets/           # Reusable UI components
│   │   ├── themes/            # App theming
│   │   ├── models/            # Data models
│   │   ├── providers/         # State management
│   │   └── l10n/              # Internationalization
│   ├── test/                  # Unit and widget tests
│   ├── android/               # Android-specific configuration
│   ├── ios/                   # iOS-specific configuration
│   ├── pubspec.yaml           # Flutter dependencies
│   └── analysis_options.yaml  # Code analysis rules
│
├── 🐍 backend/                  # Python FastAPI Backend
│   ├── src/                    # Source code
│   │   └── main.py            # Main FastAPI application
│   ├── tests/                 # Backend tests
│   ├── requirements.txt       # Python dependencies
│   └── run.py                 # Development server runner
│
├── 📚 docs/                     # Documentation
│   └── README.md              # Documentation index
│
└── 🔧 development/             # Development Tools & Assets
    ├── README.md              # Development guide
    ├── tools/                 # Build and generation scripts
    │   ├── icon_generation/   # Icon generation utilities
    │   ├── icons/            # Icon tools
    │   └── promotional/      # Marketing asset tools
    ├── app_icons/            # Application icons
    │   ├── streamy_icon_1024.png
    │   ├── streamy_icon_4k.png
    │   └── android/          # Platform-specific icons
    └── promotional_assets/   # Marketing materials
        ├── app_store_screenshot_bg.png
        └── feature_graphic_1024x500.png
```

## 🎯 Key Organizational Principles

### ✅ Clean Structure
- **Separated concerns**: Frontend, backend, docs, and development tools
- **Clear hierarchy**: Logical nesting and organization
- **Professional layout**: Industry-standard project structure

### ✅ Developer Experience
- **Makefile**: Simple commands for common tasks
- **package.json**: Standard project metadata and scripts
- **Documentation**: Comprehensive guides and references
- **Contribution guidelines**: Clear process for contributors

### ✅ Maintainability
- **Gitignore**: Proper exclusion of build artifacts
- **License**: Clear MIT licensing
- **README**: Professional project presentation
- **Clean dependencies**: No unnecessary files or directories

### ✅ Scalability
- **Modular architecture**: Easy to extend and modify
- **Separation of concerns**: Clear boundaries between components
- **Standard conventions**: Following Flutter and Python best practices

## 🚀 Quick Start Commands

```bash
# Setup everything
make setup

# Run development servers
make run

# Run tests
make test

# Build for production
make build

# Clean build artifacts
make clean
```

This structure provides a professional, organized, and maintainable codebase that's easy to navigate and contribute to.
