# Contributing to Streamy

Thank you for your interest in contributing to Streamy! This document provides guidelines for contributing to the project.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Python 3.8+
- Android Studio or VS Code with Flutter extensions
- Git

### Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/streamy.git
   cd streamy
   ```

2. **Frontend Setup:**
   ```bash
   cd streamy_app
   flutter pub get
   flutter run
   ```

3. **Backend Setup:**
   ```bash
   cd backend
   pip install -r requirements.txt
   python run.py
   ```

## 📁 Project Structure

```
streamy/
├── README.md                 # Main project documentation
├── CONTRIBUTING.md          # This file
├── LICENSE                  # Project license
├── streamy_app/            # Flutter mobile application
│   ├── lib/
│   │   ├── core/           # Core business logic
│   │   ├── screens/        # UI screens
│   │   ├── services/       # Application services
│   │   ├── widgets/        # Reusable UI components
│   │   └── themes/         # App theming
│   └── test/               # Unit and widget tests
├── backend/                # Python FastAPI backend
│   ├── src/               # Backend source code
│   ├── tests/             # Backend tests
│   └── requirements.txt   # Python dependencies
├── docs/                  # Documentation
└── development/           # Development tools and assets
    ├── tools/             # Build and generation scripts
    ├── app_icons/         # Application icons
    └── promotional_assets/ # Marketing materials
```

## 🔧 Development Guidelines

### Code Style

#### Flutter/Dart
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` before committing
- Maintain 80-character line limit
- Use meaningful variable and function names

#### Python
- Follow [PEP 8](https://pep8.org/)
- Use type hints
- Use `black` for code formatting
- Maintain comprehensive docstrings

### Git Workflow

1. **Fork the repository**
2. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes with clear, descriptive commits**
4. **Test your changes thoroughly**
5. **Submit a pull request**

### Commit Messages

Use conventional commit format:
```
type(scope): description

feat(player): add subtitle customization options
fix(api): resolve search result parsing error
docs(readme): update installation instructions
refactor(core): reorganize provider architecture
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## 🧪 Testing

### Flutter Tests
```bash
cd streamy_app
flutter test
```

### Python Tests
```bash
cd backend
python -m pytest tests/
```

### Integration Tests
```bash
cd streamy_app
flutter drive --target=test_driver/app.dart
```

## 📋 Pull Request Guidelines

1. **Ensure all tests pass**
2. **Update documentation if needed**
3. **Add tests for new features**
4. **Keep PRs focused and atomic**
5. **Provide clear description of changes**
6. **Reference related issues**

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if UI changes)
[Add screenshots here]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## 🐛 Bug Reports

When reporting bugs, please include:
1. **Clear description** of the issue
2. **Steps to reproduce** the problem
3. **Expected vs actual behavior**
4. **Environment details** (OS, Flutter version, etc.)
5. **Screenshots or logs** if applicable

## 💡 Feature Requests

For new features:
1. **Check existing issues** first
2. **Provide clear use case** and motivation
3. **Describe proposed solution**
4. **Consider implementation complexity**
5. **Be open to discussion** and alternatives

## 📖 Documentation

- Keep documentation up to date
- Use clear, concise language
- Include code examples where helpful
- Update README for significant changes

## 🎯 Areas for Contribution

### High Priority
- Plugin system improvements
- Performance optimizations
- UI/UX enhancements
- Test coverage expansion
- Documentation improvements

### Medium Priority
- Additional video format support
- New content providers
- Accessibility features
- Internationalization

### Low Priority
- Code refactoring
- Development tooling
- Build optimizations

## 📞 Support

- **Issues**: GitHub Issues for bugs and features
- **Discussions**: GitHub Discussions for questions
- **Documentation**: Check `/docs` directory

## 📄 License

By contributing to Streamy, you agree that your contributions will be licensed under the same license as the project.

Thank you for contributing to Streamy! 🎉
