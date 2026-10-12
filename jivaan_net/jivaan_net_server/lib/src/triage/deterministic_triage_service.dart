/// Deterministic triage service for emergency incident classification.
///
/// NOTE: This is a rule-based deterministic classifier using emergency signals
/// and validated keywords. This is NOT a trained artificial intelligence (AI)
/// or large language model (LLM).
///
/// The service never infers severity from coordinates, hardware IDs, or relay counts.
/// If description or emergency indicators are missing, it defaults to a conservative
/// 'medium' priority.
class DeterministicTriageService {
  /// Default conservative priority when emergency details are insufficient.
  static const String defaultPriority = 'medium';

  /// Critical severity keywords: immediate life threats, entrapment, collapse, unconsciousness.
  static const Set<String> _criticalKeywords = {
    'collapse',
    'collapsed',
    'trapped',
    'buried',
    'drowning',
    'cardiac',
    'unconscious',
    'severe bleeding',
    'suffocation',
    'explosion',
    'mass casualty',
    'crush',
    'crushed',
    'choking',
  };

  /// High severity keywords: injuries, rising flood waters, active fire, hazardous conditions.
  static const Set<String> _highKeywords = {
    'injured',
    'injury',
    'fracture',
    'broken bone',
    'bleeding',
    'fire',
    'smoke',
    'flood',
    'flooding',
    'landslide',
    'hazard',
    'gas leak',
    'electric shock',
    'hypothermia',
    'burn',
    'burned',
    'urgent',
  };

  /// Low severity keywords: property-only issues, supply requests without immediate life danger.
  static const Set<String> _lowKeywords = {
    'supplies',
    'food needed',
    'water needed',
    'blanket',
    'minor',
    'safe',
    'information',
    'query',
    'status check',
  };

  /// Classifies the initial priority/severity of an SOS incident.
  ///
  /// Returns one of: 'critical', 'high', 'medium', or 'low'.
  static String classify({String? description}) {
    if (description == null || description.trim().isEmpty) {
      return defaultPriority;
    }

    final lower = description.toLowerCase();

    // Check critical keywords first
    for (final keyword in _criticalKeywords) {
      if (lower.contains(keyword)) {
        return 'critical';
      }
    }

    // Check high keywords
    for (final keyword in _highKeywords) {
      if (lower.contains(keyword)) {
        return 'high';
      }
    }

    // Check low keywords (only if neither critical nor high matched)
    for (final keyword in _lowKeywords) {
      if (lower.contains(keyword)) {
        return 'low';
      }
    }

    // Default conservative priority when no keyword matches
    return defaultPriority;
  }
}
