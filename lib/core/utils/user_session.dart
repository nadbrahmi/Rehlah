// Simple in-memory session — stores user's onboarding choices
// for use across all screens in the same app session.
class UserSession {
  static final UserSession _instance = UserSession._();
  factory UserSession() => _instance;
  UserSession._();

  String name = 'there'; // default until onboarding sets it
  String cancerType = 'Breast cancer';
  String treatmentPhase = 'In chemotherapy';
  int whoIndex = 0; // 0=patient, 1=caregiver, 2=survivor

  // Greeting helper
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get displayName => name.isEmpty ? 'there' : name;
}
