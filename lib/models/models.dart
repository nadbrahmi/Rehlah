// User Journey Model
class UserJourney {
  final String id;
  String name;
  String cancerType;
  String stage;
  String treatmentPhase;
  DateTime? diagnosisDate;
  DateTime? treatmentStartDate;
  bool isPatient;
  String? caregiverName;

  UserJourney({
    required this.id,
    required this.name,
    required this.cancerType,
    required this.stage,
    required this.treatmentPhase,
    this.diagnosisDate,
    this.treatmentStartDate,
    this.isPatient = true,
    this.caregiverName,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'cancerType': cancerType,
        'stage': stage,
        'treatmentPhase': treatmentPhase,
        'diagnosisDate': diagnosisDate?.toIso8601String(),
        'treatmentStartDate': treatmentStartDate?.toIso8601String(),
        'isPatient': isPatient,
        'caregiverName': caregiverName,
      };

  factory UserJourney.fromMap(Map<String, dynamic> map) => UserJourney(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        cancerType: map['cancerType'] ?? '',
        stage: map['stage'] ?? '',
        treatmentPhase: map['treatmentPhase'] ?? '',
        diagnosisDate: map['diagnosisDate'] != null ? DateTime.parse(map['diagnosisDate']) : null,
        treatmentStartDate: map['treatmentStartDate'] != null ? DateTime.parse(map['treatmentStartDate']) : null,
        isPatient: map['isPatient'] ?? true,
        caregiverName: map['caregiverName'],
      );
}

// Daily Check-In Model
class CheckIn {
  final String id;
  final DateTime date;
  final int moodScore; // 1-5
  final int painScore; // 1-5
  final int fatigueScore; // 1-5
  final int nauseaScore; // 1-5
  final int appetiteScore; // 1-5
  final int sleepScore; // 1-5
  final bool medicationsTaken;
  final int waterGlasses;
  final String? notes;
  final String? foodNotes;
  final bool activitiesAble;
  final List<String> symptoms;

  CheckIn({
    required this.id,
    required this.date,
    required this.moodScore,
    required this.painScore,
    required this.fatigueScore,
    required this.nauseaScore,
    required this.appetiteScore,
    required this.sleepScore,
    required this.medicationsTaken,
    required this.waterGlasses,
    this.notes,
    this.foodNotes,
    required this.activitiesAble,
    required this.symptoms,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'moodScore': moodScore,
        'painScore': painScore,
        'fatigueScore': fatigueScore,
        'nauseaScore': nauseaScore,
        'appetiteScore': appetiteScore,
        'sleepScore': sleepScore,
        'medicationsTaken': medicationsTaken,
        'waterGlasses': waterGlasses,
        'notes': notes,
        'foodNotes': foodNotes,
        'activitiesAble': activitiesAble,
        'symptoms': symptoms,
      };

  factory CheckIn.fromMap(Map<String, dynamic> map) => CheckIn(
        id: map['id'] ?? '',
        date: DateTime.parse(map['date']),
        moodScore: map['moodScore'] ?? 3,
        painScore: map['painScore'] ?? 1,
        fatigueScore: map['fatigueScore'] ?? 2,
        nauseaScore: map['nauseaScore'] ?? 1,
        appetiteScore: map['appetiteScore'] ?? 3,
        sleepScore: map['sleepScore'] ?? 3,
        medicationsTaken: map['medicationsTaken'] ?? false,
        waterGlasses: map['waterGlasses'] ?? 0,
        notes: map['notes'],
        foodNotes: map['foodNotes'],
        activitiesAble: map['activitiesAble'] ?? true,
        symptoms: List<String>.from(map['symptoms'] ?? []),
      );
}

// Per-medication daily log (tracks each med individually per day)
class MedLog {
  final String medId;
  final DateTime date;
  final DateTime? takenAt; // null = not yet taken

  MedLog({required this.medId, required this.date, this.takenAt});

  bool get isTaken => takenAt != null;

  Map<String, dynamic> toMap() => {
        'medId': medId,
        'date': date.toIso8601String(),
        'takenAt': takenAt?.toIso8601String(),
      };

  factory MedLog.fromMap(Map<String, dynamic> map) => MedLog(
        medId: map['medId'] ?? '',
        date: DateTime.parse(map['date']),
        takenAt: map['takenAt'] != null ? DateTime.parse(map['takenAt']) : null,
      );
}

// Medication Model
class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String? notes;
  bool isActive;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.notes,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'notes': notes,
        'isActive': isActive,
      };

  factory Medication.fromMap(Map<String, dynamic> map) => Medication(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        dosage: map['dosage'] ?? '',
        frequency: map['frequency'] ?? '',
        notes: map['notes'],
        isActive: map['isActive'] ?? true,
      );
}

// Appointment Model
class Appointment {
  final String id;
  final String title;
  final String doctorName;
  final DateTime dateTime;
  final String? location;
  final String? notes;
  final String type; // oncologist, lab, imaging, etc.
  bool isCompleted;

  Appointment({
    required this.id,
    required this.title,
    required this.doctorName,
    required this.dateTime,
    this.location,
    this.notes,
    required this.type,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'doctorName': doctorName,
        'dateTime': dateTime.toIso8601String(),
        'location': location,
        'notes': notes,
        'type': type,
        'isCompleted': isCompleted,
      };

  factory Appointment.fromMap(Map<String, dynamic> map) => Appointment(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        doctorName: map['doctorName'] ?? '',
        dateTime: DateTime.parse(map['dateTime']),
        location: map['location'],
        notes: map['notes'],
        type: map['type'] ?? 'general',
        isCompleted: map['isCompleted'] ?? false,
      );
}

// Milestone Model
class Milestone {
  final String id;
  final String title;
  final String description;
  final DateTime? date;
  final String phase;
  bool isCompleted;
  bool isCurrent;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    this.date,
    required this.phase,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

// Cancer types
const List<String> cancerTypes = [
  'Breast Cancer',
  'Lung Cancer',
  'Colorectal Cancer',
  'Prostate Cancer',
  'Leukemia',
  'Lymphoma',
  'Ovarian Cancer',
  'Other',
];

// Cancer stages
const List<String> cancerStages = [
  'Stage I',
  'Stage II',
  'Stage III',
  'Stage IV',
  'Unknown / TBD',
];

// Treatment phases
const List<String> treatmentPhases = [
  'Pre-Treatment (Planning)',
  'Diagnosis & Planning',
  'Weekly Treatment (Chemo)',
  'Radiation Therapy',
  'Surgery',
  'Recovery',
  'Maintenance',
  'Survivorship',
];
