import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/user_session.dart';
import '../utils/protocols.dart';

class SupabaseService {
  static const _kPatientCache   = 'rehlah_patient_data';
  static const _kMedsCache      = 'rehlah_meds_data';
  static const _kAptsCache      = 'rehlah_apts_data';
  static const _kLabsCache      = 'rehlah_labs_data';
  static const _kCheckinsCache  = 'rehlah_checkins';

  static bool get isAvailable {
    try {
      Supabase.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  static SupabaseClient get _client => Supabase.instance.client;

  // ── Invite code ─────────────────────────────────────────────────────────────

  /// Looks up a patient by invite code.
  /// Returns null if not found, expired, already used, or Supabase unavailable.
  static Future<Map<String, dynamic>?> validateInviteCode(String code) async {
    if (!isAvailable) return null;
    try {
      final response = await _client
          .from('patients')
          .select()
          .eq('invite_code', code.trim().toUpperCase())
          .eq('invite_status', 'pending')
          .gt('invite_expires_at', DateTime.now().toIso8601String())
          .maybeSingle();
      return response;
    } catch (_) {
      return null;
    }
  }

  static Future<void> activatePatient(String patientId) async {
    if (!isAvailable) return;
    try {
      await _client
          .from('patients')
          .update({'invite_status': 'active'}).eq('id', patientId);
    } catch (_) {}
  }

  // ── Fetch by ID ──────────────────────────────────────────────────────────────

  /// Fetches a patient row by primary key — used for session recovery on restart.
  static Future<Map<String, dynamic>?> getPatientById(String patientId) async {
    if (!isAvailable) return null;
    try {
      return await _client
          .from('patients')
          .select()
          .eq('id', patientId)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }

  // ── Clinical data fetchers ───────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getMedications(
      String patientId) async {
    if (!isAvailable) return [];
    try {
      final response = await _client
          .from('medications')
          .select()
          .eq('patient_id', patientId)
          .eq('active', true);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAppointments(
      String patientId) async {
    if (!isAvailable) return [];
    try {
      final response = await _client
          .from('appointments')
          .select()
          .eq('patient_id', patientId)
          .order('date_time');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (_) {
      return [];
    }
  }

  /// Fetches all lab panels with their metrics in a single join query.
  static Future<List<Map<String, dynamic>>> getLabs(
      String patientId) async {
    if (!isAvailable) return [];
    try {
      final response = await _client
          .from('labs')
          .select('*, lab_metrics(*)')
          .eq('patient_id', patientId)
          .order('date', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getCheckinHistory(
      String patientId) async {
    if (!isAvailable) return [];
    try {
      final response = await _client
          .from('checkins')
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false)
          .limit(14);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCheckin(
      String patientId, Map<String, dynamic> data) async {
    if (!isAvailable) return;
    try {
      await _client.from('checkins').insert({
        'patient_id': patientId,
        ...data,
      });
    } catch (_) {}
  }

  // ── Session population ───────────────────────────────────────────────────────

  /// Fetches all patient data from Supabase, populates UserSession, and
  /// writes a local cache so the session can be restored offline next launch.
  static Future<void> applyPatientToSession(
      Map<String, dynamic> data) async {
    final patientId = data['id'] as String;
    final meds     = await getMedications(patientId);
    final apts     = await getAppointments(patientId);
    final labs     = await getLabs(patientId);
    final checkins = await getCheckinHistory(patientId);

    _populateSession(data, meds, apts, labs);
    UserSession().initCheckinHistoryFromData(checkins);

    // Cache for offline recovery — fire-and-forget, never blocks
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPatientCache,  jsonEncode(data));
      await prefs.setString(_kMedsCache,     jsonEncode(meds));
      await prefs.setString(_kAptsCache,     jsonEncode(apts));
      await prefs.setString(_kLabsCache,     jsonEncode(labs));
      await prefs.setString(_kCheckinsCache, jsonEncode(checkins));
    } catch (_) {}
  }

  /// Restores UserSession from the local cache written by [applyPatientToSession].
  /// Returns true if cache was present and applied, false if nothing was cached.
  static Future<bool> applyPatientFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientJson = prefs.getString(_kPatientCache);
      if (patientJson == null) return false;

      final data     = jsonDecode(patientJson) as Map<String, dynamic>;
      final meds     = _decodeList(prefs.getString(_kMedsCache));
      final apts     = _decodeList(prefs.getString(_kAptsCache));
      final labs     = _decodeList(prefs.getString(_kLabsCache));
      final checkins = _decodeList(prefs.getString(_kCheckinsCache));

      _populateSession(data, meds, apts, labs);
      UserSession().initCheckinHistoryFromData(checkins);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  /// Pure session mutation — no network calls. Used by both the live path
  /// (applyPatientToSession) and the offline path (applyPatientFromCache).
  static void _populateSession(
    Map<String, dynamic> data,
    List<Map<String, dynamic>> meds,
    List<Map<String, dynamic>> apts,
    List<Map<String, dynamic>> labs,
  ) {
    final session = UserSession();
    session.name          = (data['name'] as String?) ?? '';
    session.cancerType    = (data['diagnosis'] as String?) ?? 'Breast cancer';
    session.treatmentPhase = 'In chemotherapy';
    session.protocol       = _protocolFromId((data['protocol_id'] as String?) ?? '');
    session.currentCycle   = (data['cycle_number'] as int?) ?? 1;
    session.totalCycles    = (data['total_cycles'] as int?) ?? 8;
    session.cycleDaySetByUser = true;
    session.supabasePatientId = data['id'] as String?;

    final cycleStartStr = data['cycle_start_date'] as String?;
    if (cycleStartStr != null) {
      final cycleStart = DateTime.tryParse(cycleStartStr);
      if (cycleStart != null) {
        session.cycleStartDate = cycleStart;
        final cycleLen = session.protocol == BreastProtocol.cmf ? 28 : 21;
        final daysSince = DateTime.now().difference(cycleStart).inDays;
        session.dayInCycle = (daysSince + 1).clamp(1, cycleLen);
      }
    }

    if (meds.isNotEmpty) {
      session.initMedicationsFromData(meds);
    } else {
      session.initDefaultMedications();
    }
    if (apts.isNotEmpty) {
      session.initAppointmentsFromData(apts);
    } else {
      session.initDefaultAppointments();
    }
    if (labs.isNotEmpty) {
      session.initLabsFromData(labs);
    } else {
      session.initDefaultLabs();
    }
  }

  static List<Map<String, dynamic>> _decodeList(String? json) {
    if (json == null) return [];
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(json) as List);
    } catch (_) {
      return [];
    }
  }

  static BreastProtocol _protocolFromId(String id) {
    switch (id.toUpperCase()) {
      case 'AC-T': return BreastProtocol.act;
      case 'TC':   return BreastProtocol.tc;
      case 'CMF':  return BreastProtocol.cmf;
      default:     return BreastProtocol.act;
    }
  }
}
