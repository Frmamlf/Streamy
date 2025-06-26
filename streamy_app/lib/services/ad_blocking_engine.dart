import 'package:html/parser.dart' as html_parser;

/// Advanced Ad Blocking Engine inspired by uBlock Origin
class AdBlockingEngine {
  static const List<String> _commonNetworkPatterns = [
    // Network request blocking patterns
    r'||googletagmanager.com^',
    r'||google-analytics.com^',
    r'||googlesyndication.com^',
    r'||doubleclick.net^',
    r'||amazon-adsystem.com^',
    r'||facebook.com/tr^',
    r'||scorecardresearch.com^',
    r'||outbrain.com^',
    r'||taboola.com^',
    r'||adsystem.com^',
    r'||googletag^',
    r'||adnxs.com^',
    r'||adsafeprotected.com^',
    r'||amazon-adsystem.com^',
    r'||casalemedia.com^',
    r'||addthis.com^',
    r'||quantserve.com^',
    r'||hotjar.com^',
    r'||mixpanel.com^',
    r'||intercom.io^',
    r'||zendesk.com^',
    r'||livechatinc.com^',
    r'||zopim.com^',
    r'||freshworks.com^',
    r'||pusher.com^',
    r'||segment.com^',
    r'||amplitude.com^',
    r'||fullstory.com^',
    r'||logrocket.com^',
    r'||bugsnag.com^',
    r'||sentry.io^',
    r'||newrelic.com^',
    
    // Generic ad patterns
    r'/ads/*',
    r'/advertisement/*',
    r'/banners/*',
    r'/sponsors/*',
    r'/popup/*',
    r'/popunder/*',
    r'/overlay/*',
    r'/interstitial/*',
    r'/preroll/*',
    r'/midroll/*',
    r'/postroll/*',
    r'*/ads.js',
    r'*/adsystem.js',
    r'*/advertising.js',
    r'*/analytics.js',
    r'*/tracking.js',
    r'*/metrics.js',
    r'*/telemetry.js',
    
    // Video ad patterns  
    r'*/vast/*',
    r'*/vmap/*',
    r'*/ima/*',
    r'*/dfp/*',
    r'*/gpt/*',
    r'*/prebid/*',
    r'*/adsense/*',
    
    // Social tracking
    r'||facebook.com/tr*',
    r'||twitter.com/i/adsct*',
    r'||linkedin.com/li/track*',
    r'||pinterest.com/ct/*',
    r'||snapchat.com/tr*',
    r'||tiktok.com/i18n/pixel*',
  ];

  static const List<String> _commonCosmeticSelectors = [
    // Generic element hiding
    '.ad',
    '.ads',
    '.advertisement',
    '.advertising',
    '.banner',
    '.sponsor',
    '.sponsored',
    '.promotion',
    '.popup',
    '.popover',
    '.overlay',
    '.modal.ad',
    '.interstitial',
    '.preroll',
    '.midroll',
    '.postroll',
    
    // ID-based selectors
    '#ad',
    '#ads',
    '#advertisement',
    '#advertising',
    '#banner',
    '#popup',
    '#overlay',
    
    // Common ad networks
    '[class*="google-ad"]',
    '[id*="google-ad"]',
    '[class*="adsense"]',
    '[id*="adsense"]',
    '[class*="doubleclick"]',
    '[id*="doubleclick"]',
    '[class*="amazon-ad"]',
    '[id*="amazon-ad"]',
    
    // Social widgets
    '[class*="facebook-widget"]',
    '[class*="twitter-widget"]',
    '[class*="linkedin-widget"]',
    '[class*="pinterest-widget"]',
    '[class*="social-share"]',
    
    // Video ads
    '[class*="video-ad"]',
    '[id*="video-ad"]',
    '[class*="vast"]',
    '[id*="vast"]',
    '[class*="ima"]',
    '[id*="ima"]',
    
    // Tracking pixels
    'img[width="1"][height="1"]',
    'img[src*="tracking"]',
    'img[src*="analytics"]',
    'img[src*="pixel"]',
    
    // Newsletter signups
    '[class*="newsletter"]',
    '[id*="newsletter"]',
    '[class*="subscribe"]',
    '[id*="subscribe"]',
    
    // Cookie notices (configurable)
    '[class*="cookie-notice"]',
    '[id*="cookie-notice"]',
    '[class*="gdpr"]',
    '[id*="gdpr"]',
  ];

  static const List<String> _scriptBlockingPatterns = [
    // Analytics scripts
    r'google-analytics\.com/analytics\.js',
    r'googletagmanager\.com/gtag/js',
    r'googlesyndication\.com/pagead/js',
    r'doubleclick\.net/instream/ad_status\.js',
    r'facebook\.com/tr',
    r'connect\.facebook\.net/en_US/fbevents\.js',
    r'platform\.twitter\.com/widgets\.js',
    r'platform\.linkedin\.com/in\.js',
    r'assets\.pinterest\.com/js/pinit\.js',
    r'snap\.licdn\.com/li\.lms-analytics',
    
    // Video ad scripts
    r'imasdk\.googleapis\.com/js/sdkloader/ima3\.js',
    r'securepubads\.g\.doubleclick\.net/tag/js/gpt\.js',
    r'pagead2\.googlesyndication\.com/pagead/js',
    r'prebid\.org/download/current/prebid\.js',
    
    // Tracking scripts
    r'hotjar\.com/c/hotjar-',
    r'mixpanel\.com/site_media/js',
    r'segment\.com/analytics\.js',
    r'amplitude\.com/libs/amplitude-',
    r'fullstory\.com/s/fs\.js',
    r'logrocket\.com/dist/logrocket\.min\.js',
    r'bugsnag\.com/js/',
    r'browser\.sentry-cdn\.com/',
    r'js-agent\.newrelic\.com/nr-',
  ];

  final bool _networkFilteringEnabled;
  final bool _cosmeticFilteringEnabled;
  final bool _scriptBlockingEnabled;
  final bool _cookieNoticesBlocked;
  final bool _socialWidgetsBlocked;
  final bool _trackingBlocked;
  final List<String> _customPatterns;
  final List<String> _allowedDomains;

  AdBlockingEngine({
    bool networkFilteringEnabled = true,
    bool cosmeticFilteringEnabled = true,
    bool scriptBlockingEnabled = true,
    bool cookieNoticesBlocked = true,
    bool socialWidgetsBlocked = true,
    bool trackingBlocked = true,
    List<String> customPatterns = const [],
    List<String> allowedDomains = const [],
  }) : _networkFilteringEnabled = networkFilteringEnabled,
       _cosmeticFilteringEnabled = cosmeticFilteringEnabled,
       _scriptBlockingEnabled = scriptBlockingEnabled,
       _cookieNoticesBlocked = cookieNoticesBlocked,
       _socialWidgetsBlocked = socialWidgetsBlocked,
       _trackingBlocked = trackingBlocked,
       _customPatterns = customPatterns,
       _allowedDomains = allowedDomains;

  /// Check if a network request should be blocked
  bool shouldBlockRequest(String url, String? referrer, String? requestType) {
    if (!_networkFilteringEnabled) return false;
    
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    
    // Check if domain is explicitly allowed
    if (_allowedDomains.any((domain) => uri.host.contains(domain))) {
      return false;
    }
    
    // Check against network patterns
    for (final pattern in _commonNetworkPatterns) {
      if (_matchesPattern(url, pattern)) {
        return true;
      }
    }
    
    // Check custom patterns
    for (final pattern in _customPatterns) {
      if (_matchesPattern(url, pattern)) {
        return true;
      }
    }
    
    // Check script blocking patterns
    if (_scriptBlockingEnabled && requestType == 'script') {
      for (final pattern in _scriptBlockingPatterns) {
        if (RegExp(pattern, caseSensitive: false).hasMatch(url)) {
          return true;
        }
      }
    }
    
    // Block tracking requests
    if (_trackingBlocked && _isTrackingRequest(url, requestType)) {
      return true;
    }
    
    return false;
  }

  /// Get CSS selectors to hide elements
  List<String> getCosmeticFilters(String domain) {
    if (!_cosmeticFilteringEnabled) return [];
    
    // Check if domain is explicitly allowed
    if (_allowedDomains.any((allowedDomain) => domain.contains(allowedDomain))) {
      return [];
    }
    
    List<String> selectors = [];
    
    // Add base cosmetic filters
    selectors.addAll(_commonCosmeticSelectors);
    
    // Add conditional filters
    if (!_cookieNoticesBlocked) {
      selectors.removeWhere((selector) => 
        selector.contains('cookie') || selector.contains('gdpr'));
    }
    
    if (!_socialWidgetsBlocked) {
      selectors.removeWhere((selector) => 
        selector.contains('facebook') || 
        selector.contains('twitter') || 
        selector.contains('social'));
    }
    
    return selectors;
  }

  /// Apply ad blocking to HTML content
  String applyAdBlocking(String html, String domain) {
    if (!_cosmeticFilteringEnabled && !_scriptBlockingEnabled) {
      return html;
    }
    
    String processedHtml = html;
    
    // Remove blocked scripts
    if (_scriptBlockingEnabled) {
      processedHtml = _removeBlockedScriptsString(processedHtml);
    }
    
    // Apply cosmetic filtering
    if (_cosmeticFilteringEnabled) {
      processedHtml = _applyCosmeticFiltering(processedHtml, domain);
    }
    
    return processedHtml;
  }

  /// Generate CSS to inject for hiding elements
  String generateBlockingCSS(String domain) {
    final selectors = getCosmeticFilters(domain);
    if (selectors.isEmpty) return '';
    
    // Group selectors for efficiency
    const hiddenStyle = '{ display: none !important; visibility: hidden !important; }';
    return '${selectors.join(', ')} $hiddenStyle';
  }

  /// Create a comprehensive blocking summary
  AdBlockingStats getBlockingStats(String html, String domain) {
    int blockedRequests = 0;
    int blockedElements = 0;
    int blockedScripts = 0;
    List<String> blockedTypes = [];
    
    // Count potential network blocks (simplified)
    for (final pattern in _commonNetworkPatterns) {
      if (html.contains(pattern.replaceAll(RegExp(r'[\|\^\*]'), ''))) {
        blockedRequests++;
      }
    }
    
    // Count cosmetic blocks
    final selectors = getCosmeticFilters(domain);
    blockedElements = selectors.length;
    
    // Count script blocks
    if (_scriptBlockingEnabled) {
      for (final pattern in _scriptBlockingPatterns) {
        if (RegExp(pattern, caseSensitive: false).hasMatch(html)) {
          blockedScripts++;
        }
      }
    }
    
    // Determine blocked types
    if (blockedRequests > 0) blockedTypes.add('Network Requests');
    if (blockedElements > 0) blockedTypes.add('Page Elements');
    if (blockedScripts > 0) blockedTypes.add('Scripts');
    if (_trackingBlocked) blockedTypes.add('Tracking');
    if (_cookieNoticesBlocked) blockedTypes.add('Cookie Notices');
    if (_socialWidgetsBlocked) blockedTypes.add('Social Widgets');
    
    return AdBlockingStats(
      blockedRequests: blockedRequests,
      blockedElements: blockedElements,
      blockedScripts: blockedScripts,
      blockedTypes: blockedTypes,
      domain: domain,
    );
  }

  /// Process HTML content and remove blocked elements
  String processHtml(String html, Uri pageUrl) {
    if (!_cosmeticFilteringEnabled) return html;
    
    try {
      final document = html_parser.parse(html);
      
      // Remove elements based on cosmetic filters
      _removeCosmeticElements(document, pageUrl.host);
      
      // Remove script elements if script blocking is enabled
      if (_scriptBlockingEnabled) {
        _removeBlockedScripts(document, pageUrl);
      }
      
      return document.outerHtml;
    } catch (e) {
      // Return original HTML if processing fails
      return html;
    }
  }

  /// Remove cosmetic elements from document
  void _removeCosmeticElements(dynamic document, String domain) {
    // Remove elements matching cosmetic patterns
    for (final pattern in _commonCosmeticSelectors) {
      try {
        final elements = document.querySelectorAll(pattern);
        for (final element in elements) {
          element.remove();
        }
      } catch (e) {
        // Continue with other patterns if one fails
      }
    }
    
    // Apply custom patterns
    for (final pattern in _customPatterns) {
      if (pattern.startsWith('##')) {
        // Cosmetic filter
        try {
          final selector = pattern.substring(2);
          final elements = document.querySelectorAll(selector);
          for (final element in elements) {
            element.remove();
          }
        } catch (e) {
          // Continue with other patterns
        }
      }
    }
  }
  
  /// Remove blocked script elements
  void _removeBlockedScripts(dynamic document, Uri pageUrl) {
    final scripts = document.querySelectorAll('script');
    final scriptsToRemove = <dynamic>[];
    
    for (final script in scripts) {
      final src = script.attributes['src'];
      if (src != null) {
        final scriptUrl = _resolveUrl(src, pageUrl.toString());
        if (shouldBlockRequest(scriptUrl, pageUrl.toString(), 'script')) {
          scriptsToRemove.add(script);
        }
      } else {
        // Inline script - check content for tracking patterns
        final content = script.text.toLowerCase();
        if (_containsTrackingCode(content)) {
          scriptsToRemove.add(script);
        }
      }
    }
    
    for (final script in scriptsToRemove) {
      script.remove();
    }
  }
  
  /// Check if script content contains tracking code
  bool _containsTrackingCode(String content) {
    final trackingPatterns = [
      'google-analytics',
      'googletagmanager',
      'gtag(',
      'ga(',
      '_gaq',
      'fbq(',
      'facebook.com/tr',
      'doubleclick',
      'adsystem',
      'googlesyndication',
    ];
    
    return trackingPatterns.any((pattern) => content.contains(pattern));
  }
  
  /// Resolve relative URL to absolute URL
  String _resolveUrl(String url, String baseUrl) {
    if (url.startsWith('http')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) {
      final uri = Uri.parse(baseUrl);
      return '${uri.scheme}://${uri.host}$url';
    }
    return '$baseUrl/$url';
  }

  // Private helper methods
  bool _matchesPattern(String url, String pattern) {
    // Implement uBlock-style pattern matching
    String regexPattern = pattern
        .replaceAll('||', r'https?://([^/]+\.)?')
        .replaceAll('^', r'[/?]')
        .replaceAll('*', '.*')
        .replaceAll('|', r'\|');
    
    try {
      return RegExp(regexPattern, caseSensitive: false).hasMatch(url);
    } catch (e) {
      // Fallback to simple contains check
      return url.toLowerCase().contains(
        pattern.toLowerCase()
          .replaceAll('||', '')
          .replaceAll('^', '')
          .replaceAll('*', '')
          .replaceAll('|', '')
      );
    }
  }

  bool _isTrackingRequest(String url, String? requestType) {
    const trackingKeywords = [
      'tracking', 'analytics', 'telemetry', 'metrics', 
      'beacon', 'pixel', 'impression', 'click'
    ];
    
    return trackingKeywords.any((keyword) => 
      url.toLowerCase().contains(keyword));
  }

  String _removeBlockedScriptsString(String html) {
    String processedHtml = html;
    
    for (final pattern in _scriptBlockingPatterns) {
      final regex = RegExp(
        '<script[^>]*src=["\'][^"\']*$pattern[^"\']*["\'][^>]*>.*?</script>',
        caseSensitive: false,
        dotAll: true,
      );
      processedHtml = processedHtml.replaceAll(regex, '');
    }
    
    return processedHtml;
  }

  String _applyCosmeticFiltering(String html, String domain) {
    final document = html_parser.parse(html);
    final selectors = getCosmeticFilters(domain);
    
    // Remove elements matching cosmetic filters
    for (final selector in selectors) {
      try {
        final elements = document.querySelectorAll(selector);
        for (final element in elements) {
          element.remove();
        }
      } catch (e) {
        // Skip invalid selectors
        continue;
      }
    }
    
    return document.outerHtml;
  }
}

/// Statistics about ad blocking activity
class AdBlockingStats {
  final int blockedRequests;
  final int blockedElements;
  final int blockedScripts;
  final List<String> blockedTypes;
  final String domain;

  AdBlockingStats({
    required this.blockedRequests,
    required this.blockedElements,
    required this.blockedScripts,
    required this.blockedTypes,
    required this.domain,
  });

  int get totalBlocked => blockedRequests + blockedElements + blockedScripts;

  Map<String, dynamic> toJson() {
    return {
      'blockedRequests': blockedRequests,
      'blockedElements': blockedElements,
      'blockedScripts': blockedScripts,
      'blockedTypes': blockedTypes,
      'domain': domain,
      'totalBlocked': totalBlocked,
    };
  }
}

/// Configuration for ad blocking settings
class AdBlockingConfig {
  final bool networkFilteringEnabled;
  final bool cosmeticFilteringEnabled;
  final bool scriptBlockingEnabled;
  final bool cookieNoticesBlocked;
  final bool socialWidgetsBlocked;
  final bool trackingBlocked;
  final List<String> customPatterns;
  final List<String> allowedDomains;

  AdBlockingConfig({
    this.networkFilteringEnabled = true,
    this.cosmeticFilteringEnabled = true,
    this.scriptBlockingEnabled = true,
    this.cookieNoticesBlocked = true,
    this.socialWidgetsBlocked = true,
    this.trackingBlocked = true,
    this.customPatterns = const [],
    this.allowedDomains = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'networkFilteringEnabled': networkFilteringEnabled,
      'cosmeticFilteringEnabled': cosmeticFilteringEnabled,
      'scriptBlockingEnabled': scriptBlockingEnabled,
      'cookieNoticesBlocked': cookieNoticesBlocked,
      'socialWidgetsBlocked': socialWidgetsBlocked,
      'trackingBlocked': trackingBlocked,
      'customPatterns': customPatterns,
      'allowedDomains': allowedDomains,
    };
  }

  factory AdBlockingConfig.fromJson(Map<String, dynamic> json) {
    return AdBlockingConfig(
      networkFilteringEnabled: json['networkFilteringEnabled'] ?? true,
      cosmeticFilteringEnabled: json['cosmeticFilteringEnabled'] ?? true,
      scriptBlockingEnabled: json['scriptBlockingEnabled'] ?? true,
      cookieNoticesBlocked: json['cookieNoticesBlocked'] ?? true,
      socialWidgetsBlocked: json['socialWidgetsBlocked'] ?? true,
      trackingBlocked: json['trackingBlocked'] ?? true,
      customPatterns: List<String>.from(json['customPatterns'] ?? []),
      allowedDomains: List<String>.from(json['allowedDomains'] ?? []),
    );
  }

  AdBlockingConfig copyWith({
    bool? networkFilteringEnabled,
    bool? cosmeticFilteringEnabled,
    bool? scriptBlockingEnabled,
    bool? cookieNoticesBlocked,
    bool? socialWidgetsBlocked,
    bool? trackingBlocked,
    List<String>? customPatterns,
    List<String>? allowedDomains,
  }) {
    return AdBlockingConfig(
      networkFilteringEnabled: networkFilteringEnabled ?? this.networkFilteringEnabled,
      cosmeticFilteringEnabled: cosmeticFilteringEnabled ?? this.cosmeticFilteringEnabled,
      scriptBlockingEnabled: scriptBlockingEnabled ?? this.scriptBlockingEnabled,
      cookieNoticesBlocked: cookieNoticesBlocked ?? this.cookieNoticesBlocked,
      socialWidgetsBlocked: socialWidgetsBlocked ?? this.socialWidgetsBlocked,
      trackingBlocked: trackingBlocked ?? this.trackingBlocked,
      customPatterns: customPatterns ?? this.customPatterns,
      allowedDomains: allowedDomains ?? this.allowedDomains,
    );
  }
}
