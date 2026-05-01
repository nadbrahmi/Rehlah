import 'package:flutter/foundation.dart';

/// Stores the caregiver's linked state.
/// When a caregiver enters a code, this gets populated with the patient's name
/// and the caregiver mode is activated.
class CaregiverSession extends ChangeNotifier {
  static final CaregiverSession _instance = CaregiverSession._internal();
  factory CaregiverSession() => _instance;
  CaregiverSession._internal();

  bool _isCaregiver = false;
  String _patientName = '';
  String _patientPhase = '';
  String _linkedCode = '';

  bool get isCaregiver => _isCaregiver;
  String get patientName => _patientName;
  String get patientPhase => _patientPhase;
  String get linkedCode => _linkedCode;

  void linkAsCaregiver({
    required String patientName,
    required String patientPhase,
    required String code,
  }) {
    _isCaregiver = true;
    _patientName = patientName;
    _patientPhase = patientPhase;
    _linkedCode = code;
    notifyListeners();
  }

  void reset() {
    _isCaregiver = false;
    _patientName = '';
    _patientPhase = '';
    _linkedCode = '';
    notifyListeners();
  }
}
