import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteService {
  static SQLiteService? _instance;
  static Database? _database;

  SQLiteService._();

  static SQLiteService get instance {
    _instance ??= SQLiteService._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/vaxguard.db';

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vaccine_records (
        id TEXT PRIMARY KEY,
        vaccine_name TEXT NOT NULL,
        vaccine_type TEXT,
        dose_number TEXT,
        dose_count INTEGER DEFAULT 1,
        vaccination_date TEXT NOT NULL,
        next_dose_date TEXT,
        lot_number TEXT,
        location TEXT,
        provider TEXT,
        is_completed INTEGER DEFAULT 0,
        notes TEXT,
        side_effects TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        type TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE health_tips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        image_url TEXT,
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE symptoms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        severity TEXT NOT NULL,
        possible_causes TEXT,
        recommendations TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE first_aid_guides (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        emergency_level TEXT NOT NULL,
        steps TEXT NOT NULL,
        warnings TEXT,
        Created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE medicine_reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicine_name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        time TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        notes TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE triage_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symptoms TEXT NOT NULL,
        risk_level TEXT NOT NULL,
        risk_score INTEGER NOT NULL,
        recommendations TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        date_of_birth TEXT,
        blood_type TEXT,
        allergies TEXT,
        medical_conditions TEXT,
        emergency_contact_name TEXT,
        emergency_contact_phone TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE assessment_history (
        id TEXT PRIMARY KEY,
        assessment_type TEXT NOT NULL,
        title TEXT NOT NULL,
        summary TEXT NOT NULL,
        status TEXT NOT NULL,
        risk_level TEXT,
        risk_score INTEGER,
        details TEXT,
        metadata_json TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await _insertDefaultData(db);
    debugPrint('SQLite database created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE vaccine_records ADD COLUMN lot_number TEXT',
      );

      await db.execute('''
        CREATE TABLE assessment_history (
          id TEXT PRIMARY KEY,
          assessment_type TEXT NOT NULL,
          title TEXT NOT NULL,
          summary TEXT NOT NULL,
          status TEXT NOT NULL,
          risk_level TEXT,
          risk_score INTEGER,
          details TEXT,
          metadata_json TEXT,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().toIso8601String();

    final healthTips = [
      {'title': 'Stay Hydrated', 'content': 'Drink at least 8 glasses of water daily to maintain optimal health and help your body fight infections.', 'category': 'General'},
      {'title': 'Get Enough Sleep', 'content': 'Adults need 7-9 hours of sleep per night for proper immune function.', 'category': 'Sleep'},
      {'title': 'Exercise Regularly', 'content': 'At least 150 minutes of moderate exercise per week boosts your immune system.', 'category': 'Exercise'},
      {'title': 'Eat Fruits & Vegetables', 'content': 'Include a variety of colorful fruits and vegetables for essential vitamins and antioxidants.', 'category': 'Nutrition'},
      {'title': 'Wash Your Hands', 'content': 'Wash hands frequently with soap for at least 20 seconds to prevent disease spread.', 'category': 'Hygiene'},
      {'title': 'Vaccination Facts', 'content': 'Vaccines are safe and effective. They protect you and those around you from serious diseases.', 'category': 'Vaccination'},
      {'title': 'Manage Stress', 'content': 'Chronic stress weakens your immune system. Practice stress management techniques daily.', 'category': 'Mental Health'},
      {'title': 'Regular Check-ups', 'content': 'Schedule regular health check-ups to catch potential issues early.', 'category': 'Prevention'},
    ];

    for (final tip in healthTips) {
      await db.insert('health_tips', {
        ...tip,
        'is_favorite': 0,
        'created_at': now,
      });
    }

    final symptoms = [
      {'name': 'Fever', 'description': 'Body temperature above 38°C (100.4°F)', 'category': 'General', 'severity': 'medium', 'possible_causes': 'Infection, Inflammation, Vaccine reaction', 'recommendations': 'Rest, fluids, acetaminophen if needed. Seek care if > 39.5°C or lasts > 3 days'},
      {'name': 'Headache', 'description': 'Pain in the head, scalp, or neck area', 'category': 'Neurological', 'severity': 'low', 'possible_causes': 'Stress, Dehydration, Tension, Sinus infection', 'recommendations': 'Rest, hydration, over-the-counter pain reliever'},
      {'name': 'Fatigue', 'description': 'Persistent tiredness and lack of energy', 'category': 'General', 'severity': 'medium', 'possible_causes': 'Lack of sleep, Anemia, Depression, Vaccine reaction', 'recommendations': 'Rest, proper nutrition, light exercise. Consult doctor if persistent'},
      {'name': 'Cough', 'description': 'Persistent cough, dry or with mucus', 'category': 'Respiratory', 'severity': 'medium', 'possible_causes': 'Cold, Flu, Allergies, COVID-19', 'recommendations': 'Stay hydrated, rest, honey for dry cough. Seek care if breathing difficulty'},
      {'name': 'Nausea', 'description': 'Feeling of wanting to vomit', 'category': 'Digestive', 'severity': 'low', 'possible_causes': 'Food poisoning, Motion sickness, Pregnancy, Vaccine reaction', 'recommendations': 'Ginger tea, small frequent meals, rest. Seek care if severe or bloody'},
      {'name': 'Dizziness', 'description': 'Feeling of lightheadedness or unsteadiness', 'category': 'Neurological', 'severity': 'medium', 'possible_causes': 'Dehydration, Low blood sugar, Inner ear issue, Vaccine reaction', 'recommendations': 'Sit down, hydrate, Eat something. Seek care if fainting or chest pain'},
      {'name': 'Injection Site Pain', 'description': 'Pain, swelling, or redness at injection site', 'category': 'Local', 'severity': 'low', 'possible_causes': 'Normal vaccine reaction, Immune response', 'recommendations': 'Cold compress, gentle movement. Normal side effect of vaccination'},
      {'name': 'Muscle Aches', 'description': 'Generalized muscle pain and soreness', 'category': 'General', 'severity': 'low', 'possible_causes': 'Flu, Exercise, Vaccine reaction', 'recommendations': 'Rest, gentle stretching, warm bath. Consult if severe or persistent'},
    ];

    for (final symptom in symptoms) {
      await db.insert('symptoms', {
        ...symptom,
        'created_at': now,
      });
    }

    final firstAidGuides = [
      {'title': 'CPR', 'content': 'Cardiopulmonary resuscitation for cardiac emergencies', 'category': 'Emergency', 'emergency_level': 'critical', 'steps': '1. Check responsiveness\n2. Call 911\n3. Place hands on center chest\n4. Push hard and fast (100-120/min)\n5. Give 2 rescue breaths\n6. Continue until help arrives', 'warnings': 'Only perform if person is unresponsive and not breathing normally'},
      {'title': 'Choking', 'content': 'Emergency response for airway obstruction', 'category': 'Emergency', 'emergency_level': 'critical', 'steps': '1. Ask "Are you choking?"\n2. Call 911 if severe\n3. Perform Heimlich maneuver\n4. Stand behind person\n5. Make fist above navel\n6. Thrust upward firmly', 'warnings': 'Do not attempt if person can cough or speak'},
      {'title': 'Bleeding', 'content': 'How to control bleeding wounds', 'category': 'First Aid', 'emergency_level': 'high', 'steps': '1. Apply direct pressure\n2. Use clean cloth/gauze\n3. Elevate the wound\n4. Apply bandage\n5. Seek medical help', 'warnings': 'Do not remove embedded objects'},
      {'title': 'Burns', 'content': 'Treatment for thermal burns', 'category': 'First Aid', 'emergency_level': 'medium', 'steps': '1. Cool with running water\n2. Do not use ice\n3. Cover with sterile dressing\n4. Take pain relievers\n5. Seek medical care for severe burns', 'warnings': 'Do not pop blisters'},
      {'title': 'Snake Bite', 'content': 'Emergency response for snake bites', 'category': 'Emergency', 'emergency_level': 'critical', 'steps': '1. Call 911 immediately\n2. Keep calm and still\n3. Keep bite below heart level\n4. Remove constrictive items\n5. Do not suck or cut wound', 'warnings': 'Do not use tourniquet or ice'},
      {'title': 'Animal Bite', 'content': 'First aid for animal bites', 'category': 'First Aid', 'emergency_level': 'high', 'steps': '1. Wash wound thoroughly\n2. Apply antiseptic\n3. Stop bleeding with pressure\n4. Apply bandage\n5. Get rabies vaccination if needed', 'warnings': 'All animal bites need medical evaluation'},
      {'title': 'Allergic Reaction', 'content': 'Managing severe allergic reactions', 'category': 'Emergency', 'emergency_level': 'critical', 'steps': '1. Use EpiPen if available\n2. Call 911\n3. Keep person lying down\n4. Elevate legs if no breathing issues\n5. Perform CPR if needed', 'warnings': 'Anaphylaxis is life-threatening'},
      {'title': 'Heat Exhaustion', 'content': 'Treatment for heat-related illness', 'category': 'First Aid', 'emergency_level': 'medium', 'steps': '1. Move to cool area\n2. Loosen clothing\n3. Apply cool cloths\n4. Sip water\n5. Seek medical care if severe', 'warnings': 'Do not give fluids if unconscious'},
    ];

    for (final guide in firstAidGuides) {
      await db.insert('first_aid_guides', {
        ...guide,
        'created_at': now,
      });
    }

    debugPrint('Default data inserted successfully');
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<int> update(String table, Map<String, dynamic> data, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
