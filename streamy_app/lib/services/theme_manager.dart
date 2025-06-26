import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Advanced Theme Manager with customization options
class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();
  
  // Theme preference keys
  static const String _themeTypeKey = 'theme_type';
  static const String _accentColorKey = 'accent_color';
  static const String _fontFamilyKey = 'font_family';
  static const String _fontSizeScaleKey = 'font_size_scale';
  static const String _playerThemeKey = 'player_theme';
  static const String _amoledModeKey = 'amoled_mode';
  
  // Current theme settings
  AppThemeType _currentThemeType = AppThemeType.dark;
  Color _accentColor = const Color(0xFF6200EA);
  String _fontFamily = 'Rubik';
  double _fontSizeScale = 1.0;
  PlayerTheme _playerTheme = PlayerTheme.dark;
  bool _amoledMode = false;
  
  // Getters
  AppThemeType get currentThemeType => _currentThemeType;
  Color get accentColor => _accentColor;
  String get fontFamily => _fontFamily;
  double get fontSizeScale => _fontSizeScale;
  PlayerTheme get playerTheme => _playerTheme;
  bool get amoledMode => _amoledMode;
  
  /// Initialize theme manager
  Future<void> initialize() async {
    await _loadThemePreferences();
  }
  
  /// Load theme preferences from storage
  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeTypeIndex = prefs.getInt(_themeTypeKey) ?? 1; // Default to dark
    _currentThemeType = AppThemeType.values[themeTypeIndex];
    
    final colorValue = prefs.getInt(_accentColorKey) ?? 0xFF6200EA;
    _accentColor = Color(colorValue);
    
    _fontFamily = prefs.getString(_fontFamilyKey) ?? 'Rubik';
    _fontSizeScale = prefs.getDouble(_fontSizeScaleKey) ?? 1.0;
    
    final playerThemeIndex = prefs.getInt(_playerThemeKey) ?? 1; // Default to dark
    _playerTheme = PlayerTheme.values[playerThemeIndex];
    
    _amoledMode = prefs.getBool(_amoledModeKey) ?? false;
    
    notifyListeners();
  }
  
  /// Save theme preferences to storage
  Future<void> _saveThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_themeTypeKey, _currentThemeType.index);
    await prefs.setInt(_accentColorKey, _accentColor.toARGB32());
    await prefs.setString(_fontFamilyKey, _fontFamily);
    await prefs.setDouble(_fontSizeScaleKey, _fontSizeScale);
    await prefs.setInt(_playerThemeKey, _playerTheme.index);
    await prefs.setBool(_amoledModeKey, _amoledMode);
  }
  
  /// Change theme type
  Future<void> setThemeType(AppThemeType themeType) async {
    if (_currentThemeType != themeType) {
      _currentThemeType = themeType;
      await _saveThemePreferences();
      notifyListeners();
    }
  }
  
  /// Change accent color
  Future<void> setAccentColor(Color color) async {
    if (_accentColor != color) {
      _accentColor = color;
      await _saveThemePreferences();
      notifyListeners();
    }
  }
  
  /// Change font family
  Future<void> setFontFamily(String fontFamily) async {
    if (_fontFamily != fontFamily) {
      _fontFamily = fontFamily;
      await _saveThemePreferences();
      notifyListeners();
    }
  }
  
  /// Change font size scale
  Future<void> setFontSizeScale(double scale) async {
    if (_fontSizeScale != scale) {
      _fontSizeScale = scale;
      await _saveThemePreferences();
      notifyListeners();
    }
  }
  
  /// Change player theme
  Future<void> setPlayerTheme(PlayerTheme theme) async {
    if (_playerTheme != theme) {
      _playerTheme = theme;
      await _saveThemePreferences();
      notifyListeners();
    }
  }
  
  /// Toggle AMOLED mode
  Future<void> setAmoledMode(bool enabled) async {
    if (_amoledMode != enabled) {
      _amoledMode = enabled;
      await _saveThemePreferences();
      notifyListeners();
    }
  }
  
  /// Get current theme data
  ThemeData getThemeData() {
    switch (_currentThemeType) {
      case AppThemeType.light:
        return _buildLightTheme();
      case AppThemeType.dark:
        return _buildDarkTheme();
      case AppThemeType.system:
        // This should be handled by the app to check system theme
        return _buildDarkTheme();
    }
  }
  
  /// Build light theme
  ThemeData _buildLightTheme() {
    final baseTheme = ThemeData.light();
    
    return baseTheme.copyWith(
      primaryColor: _accentColor,
      colorScheme: ColorScheme.light(
        primary: _accentColor,
        secondary: _accentColor.withValues(alpha: 0.8),
        surface: Colors.white,
        error: Colors.red,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      textTheme: _buildTextTheme(baseTheme.textTheme, Colors.black87),
      appBarTheme: _buildAppBarTheme(Colors.white, Colors.black87),
      cardTheme: _buildCardTheme(Colors.white),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      bottomNavigationBarTheme: _buildBottomNavTheme(Colors.white),
      dividerColor: Colors.grey[300],
    );
  }
  
  /// Build dark theme
  ThemeData _buildDarkTheme() {
    final backgroundColor = _amoledMode ? Colors.black : const Color(0xFF121212);
    final surfaceColor = _amoledMode ? Colors.black : const Color(0xFF1E1E1E);
    final baseTheme = ThemeData.dark();
    
    return baseTheme.copyWith(
      primaryColor: _accentColor,
      colorScheme: ColorScheme.dark(
        primary: _accentColor,
        secondary: _accentColor.withValues(alpha: 0.8),
        surface: surfaceColor,
        error: const Color(0xFFCF6679),
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: _buildTextTheme(baseTheme.textTheme, Colors.white),
      appBarTheme: _buildAppBarTheme(backgroundColor, Colors.white),
      cardTheme: _buildCardTheme(surfaceColor),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      bottomNavigationBarTheme: _buildBottomNavTheme(surfaceColor),
      dividerColor: Colors.white12,
    );
  }
  
  /// Build text theme with selected font and scale
  TextTheme _buildTextTheme(TextTheme baseTheme, Color textColor) {
    final googleFontsTextTheme = _getGoogleFontsTextTheme(baseTheme);
    
    return googleFontsTextTheme.copyWith(
      displayLarge: googleFontsTextTheme.displayLarge?.copyWith(
        color: textColor,
        fontSize: (googleFontsTextTheme.displayLarge?.fontSize ?? 57) * _fontSizeScale,
      ),
      displayMedium: googleFontsTextTheme.displayMedium?.copyWith(
        color: textColor,
        fontSize: (googleFontsTextTheme.displayMedium?.fontSize ?? 45) * _fontSizeScale,
      ),
      displaySmall: googleFontsTextTheme.displaySmall?.copyWith(
        color: textColor,
        fontSize: (googleFontsTextTheme.displaySmall?.fontSize ?? 36) * _fontSizeScale,
      ),
      headlineLarge: googleFontsTextTheme.headlineLarge?.copyWith(
        color: textColor,
        fontSize: (googleFontsTextTheme.headlineLarge?.fontSize ?? 32) * _fontSizeScale,
      ),
      headlineMedium: googleFontsTextTheme.headlineMedium?.copyWith(
        color: textColor,
        fontSize: (googleFontsTextTheme.headlineMedium?.fontSize ?? 28) * _fontSizeScale,
      ),
      headlineSmall: googleFontsTextTheme.headlineSmall?.copyWith(
        color: textColor,
        fontSize: (googleFontsTextTheme.headlineSmall?.fontSize ?? 24) * _fontSizeScale,
      ),
      titleLarge: googleFontsTextTheme.titleLarge?.copyWith(
        color: textColor,
        fontSize: (googleFontsTextTheme.titleLarge?.fontSize ?? 22) * _fontSizeScale,
      ),
      titleMedium: googleFontsTextTheme.titleMedium?.copyWith(
        color: textColor,
        fontSize: (googleFontsTextTheme.titleMedium?.fontSize ?? 16) * _fontSizeScale,
      ),
      titleSmall: googleFontsTextTheme.titleSmall?.copyWith(
        color: textColor,
        fontSize: (googleFontsTextTheme.titleSmall?.fontSize ?? 14) * _fontSizeScale,
      ),
      bodyLarge: googleFontsTextTheme.bodyLarge?.copyWith(
        color: textColor,
        fontSize: (googleFontsTextTheme.bodyLarge?.fontSize ?? 16) * _fontSizeScale,
      ),
      bodyMedium: googleFontsTextTheme.bodyMedium?.copyWith(
        color: textColor.withValues(alpha: 0.87),
        fontSize: (googleFontsTextTheme.bodyMedium?.fontSize ?? 14) * _fontSizeScale,
      ),
      bodySmall: googleFontsTextTheme.bodySmall?.copyWith(
        color: textColor.withValues(alpha: 0.6),
        fontSize: (googleFontsTextTheme.bodySmall?.fontSize ?? 12) * _fontSizeScale,
      ),
    );
  }
  
  /// Get Google Fonts text theme
  TextTheme _getGoogleFontsTextTheme(TextTheme baseTheme) {
    switch (_fontFamily) {
      case 'Rubik':
        return GoogleFonts.rubikTextTheme(baseTheme);
      case 'Inter':
        return GoogleFonts.interTextTheme(baseTheme);
      case 'Roboto':
        return GoogleFonts.robotoTextTheme(baseTheme);
      case 'Open Sans':
        return GoogleFonts.openSansTextTheme(baseTheme);
      case 'Nunito':
        return GoogleFonts.nunitoTextTheme(baseTheme);
      case 'Poppins':
        return GoogleFonts.poppinsTextTheme(baseTheme);
      case 'Montserrat':
        return GoogleFonts.montserratTextTheme(baseTheme);
      default:
        return GoogleFonts.rubikTextTheme(baseTheme);
    }
  }
  
  /// Build app bar theme
  AppBarTheme _buildAppBarTheme(Color backgroundColor, Color foregroundColor) {
    return AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: _getGoogleFontsStyle(
        fontSize: 20 * _fontSizeScale,
        fontWeight: FontWeight.bold,
        color: foregroundColor,
      ),
    );
  }
  
  /// Build card theme
  CardThemeData _buildCardTheme(Color color) {
    return CardThemeData(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    );
  }
  
  /// Build elevated button theme
  ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: _getGoogleFontsStyle(
          fontSize: 16 * _fontSizeScale,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  /// Build text button theme
  TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _accentColor,
        textStyle: _getGoogleFontsStyle(
          fontSize: 14 * _fontSizeScale,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  /// Build bottom navigation theme
  BottomNavigationBarThemeData _buildBottomNavTheme(Color backgroundColor) {
    return BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: _accentColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: _getGoogleFontsStyle(
        fontSize: 12 * _fontSizeScale,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: _getGoogleFontsStyle(
        fontSize: 12 * _fontSizeScale,
        fontWeight: FontWeight.normal,
      ),
    );
  }
  
  /// Get Google Fonts style
  TextStyle _getGoogleFontsStyle({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
  }) {
    switch (_fontFamily) {
      case 'Rubik':
        return GoogleFonts.rubik(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case 'Inter':
        return GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case 'Roboto':
        return GoogleFonts.roboto(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case 'Open Sans':
        return GoogleFonts.openSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case 'Nunito':
        return GoogleFonts.nunito(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case 'Poppins':
        return GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case 'Montserrat':
        return GoogleFonts.montserrat(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      default:
        return GoogleFonts.rubik(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
    }
  }
  
  /// Get player theme configuration
  PlayerThemeConfig getPlayerThemeConfig() {
    switch (_playerTheme) {
      case PlayerTheme.light:
        return PlayerThemeConfig(
          backgroundColor: Colors.white,
          controlsColor: Colors.black87,
          progressBarColor: _accentColor,
          overlayColor: Colors.black54,
        );
      case PlayerTheme.dark:
        return PlayerThemeConfig(
          backgroundColor: Colors.black,
          controlsColor: Colors.white,
          progressBarColor: _accentColor,
          overlayColor: Colors.black54,
        );
      case PlayerTheme.transparent:
        return PlayerThemeConfig(
          backgroundColor: Colors.transparent,
          controlsColor: Colors.white,
          progressBarColor: _accentColor,
          overlayColor: Colors.black38,
        );
    }
  }
  
  /// Get available font families
  static List<String> getAvailableFonts() {
    return [
      'Rubik',
      'Inter',
      'Roboto',
      'Open Sans',
      'Nunito',
      'Poppins',
      'Montserrat',
    ];
  }
  
  /// Get available accent colors
  static List<Color> getAvailableColors() {
    return [
      const Color(0xFF6200EA), // Purple
      const Color(0xFF2196F3), // Blue
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF4CAF50), // Green
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFFFEB3B), // Yellow
      const Color(0xFFFF9800), // Orange
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFFF44336), // Red
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF673AB7), // Deep Purple
    ];
  }
}

/// Theme type enum
enum AppThemeType {
  light,
  dark,
  system,
}

/// Player theme enum
enum PlayerTheme {
  light,
  dark,
  transparent,
}

/// Player theme configuration
class PlayerThemeConfig {
  final Color backgroundColor;
  final Color controlsColor;
  final Color progressBarColor;
  final Color overlayColor;
  
  PlayerThemeConfig({
    required this.backgroundColor,
    required this.controlsColor,
    required this.progressBarColor,
    required this.overlayColor,
  });
}
