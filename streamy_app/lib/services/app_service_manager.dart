import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'ad_blocking_engine.dart';
import 'web_scraping_service.dart';

/// Service manager for handling ad blocking configuration and web scraping
class AppServiceManager extends ChangeNotifier {
  static final AppServiceManager _instance = AppServiceManager._internal();
  factory AppServiceManager() => _instance;
  AppServiceManager._internal();

  AdBlockingConfig _adBlockingConfig = AdBlockingConfig();
  WebScrapingService? _webScrapingService;
  bool _isInitialized = false;

  AdBlockingConfig get adBlockingConfig => _adBlockingConfig;
  WebScrapingService get webScrapingService {
    _webScrapingService ??= WebScrapingService(adBlockingConfig: _adBlockingConfig);
    return _webScrapingService!;
  }

  bool get isInitialized => _isInitialized;

  /// Initialize the service manager
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadAdBlockingConfig();
    _initializeWebScrapingService();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load ad blocking configuration from storage
  Future<void> _loadAdBlockingConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('ad_blocking_config');
      
      if (configJson != null) {
        final Map<String, dynamic> json = jsonDecode(configJson);
        _adBlockingConfig = AdBlockingConfig.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error loading ad blocking config: $e');
      _adBlockingConfig = AdBlockingConfig();
    }
  }

  /// Save ad blocking configuration to storage
  Future<void> _saveAdBlockingConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = jsonEncode(_adBlockingConfig.toJson());
      await prefs.setString('ad_blocking_config', configJson);
    } catch (e) {
      debugPrint('Error saving ad blocking config: $e');
    }
  }

  /// Initialize or reinitialize the web scraping service
  void _initializeWebScrapingService() {
    _webScrapingService?.dispose();
    _webScrapingService = WebScrapingService(adBlockingConfig: _adBlockingConfig);
  }

  /// Update ad blocking configuration
  Future<void> updateAdBlockingConfig(AdBlockingConfig newConfig) async {
    _adBlockingConfig = newConfig;
    await _saveAdBlockingConfig();
    _initializeWebScrapingService();
    notifyListeners();
  }

  /// Get ad blocking statistics for a given HTML content and domain
  AdBlockingStats getAdBlockingStats(String html, String domain) {
    final engine = AdBlockingEngine(
      networkFilteringEnabled: _adBlockingConfig.networkFilteringEnabled,
      cosmeticFilteringEnabled: _adBlockingConfig.cosmeticFilteringEnabled,
      scriptBlockingEnabled: _adBlockingConfig.scriptBlockingEnabled,
      cookieNoticesBlocked: _adBlockingConfig.cookieNoticesBlocked,
      socialWidgetsBlocked: _adBlockingConfig.socialWidgetsBlocked,
      trackingBlocked: _adBlockingConfig.trackingBlocked,
      customPatterns: _adBlockingConfig.customPatterns,
      allowedDomains: _adBlockingConfig.allowedDomains,
    );
    
    return engine.getBlockingStats(html, domain);
  }

  /// Check if a URL should be blocked
  bool shouldBlockUrl(String url, String? referrer, String? requestType) {
    final engine = AdBlockingEngine(
      networkFilteringEnabled: _adBlockingConfig.networkFilteringEnabled,
      cosmeticFilteringEnabled: _adBlockingConfig.cosmeticFilteringEnabled,
      scriptBlockingEnabled: _adBlockingConfig.scriptBlockingEnabled,
      cookieNoticesBlocked: _adBlockingConfig.cookieNoticesBlocked,
      socialWidgetsBlocked: _adBlockingConfig.socialWidgetsBlocked,
      trackingBlocked: _adBlockingConfig.trackingBlocked,
      customPatterns: _adBlockingConfig.customPatterns,
      allowedDomains: _adBlockingConfig.allowedDomains,
    );
    
    return engine.shouldBlockRequest(url, referrer, requestType);
  }

  /// Generate CSS for hiding ad elements on a domain
  String generateAdBlockingCSS(String domain) {
    final engine = AdBlockingEngine(
      networkFilteringEnabled: _adBlockingConfig.networkFilteringEnabled,
      cosmeticFilteringEnabled: _adBlockingConfig.cosmeticFilteringEnabled,
      scriptBlockingEnabled: _adBlockingConfig.scriptBlockingEnabled,
      cookieNoticesBlocked: _adBlockingConfig.cookieNoticesBlocked,
      socialWidgetsBlocked: _adBlockingConfig.socialWidgetsBlocked,
      trackingBlocked: _adBlockingConfig.trackingBlocked,
      customPatterns: _adBlockingConfig.customPatterns,
      allowedDomains: _adBlockingConfig.allowedDomains,
    );
    
    return engine.generateBlockingCSS(domain);
  }

  /// Check if ad blocking is enabled
  bool get isAdBlockingEnabled => 
    _adBlockingConfig.networkFilteringEnabled || 
    _adBlockingConfig.cosmeticFilteringEnabled || 
    _adBlockingConfig.scriptBlockingEnabled;

  /// Reset ad blocking configuration to defaults
  Future<void> resetAdBlockingConfig() async {
    _adBlockingConfig = AdBlockingConfig();
    await _saveAdBlockingConfig();
    _initializeWebScrapingService();
    notifyListeners();
  }

  @override
  void dispose() {
    _webScrapingService?.dispose();
    super.dispose();
  }
}
