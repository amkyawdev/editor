import 'package:hive/hive.dart';

class LocalStorage {
  static const String _projectsBox = 'projects';
  static const String _settingsBox = 'settings';
  static const String _draftsBox = 'drafts';

  static Future<void> init() async {
    await Hive.openBox(_projectsBox);
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_draftsBox);
  }

  // Projects
  static Box get projectsBox => Hive.box(_projectsBox);
  static Box get settingsBox => Hive.box(_settingsBox);
  static Box get draftsBox => Hive.box(_draftsBox);

  static Future<void> saveProject(String id, Map<String, dynamic> data) async {
    await projectsBox.put(id, data);
  }

  static Map<String, dynamic>? getProject(String id) {
    final data = projectsBox.get(id);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static List<Map<String, dynamic>> getAllProjects() {
    return projectsBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> deleteProject(String id) async {
    await projectsBox.delete(id);
  }

  // Settings
  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  // Drafts
  static Future<void> saveDraft(String id, Map<String, dynamic> data) async {
    await draftsBox.put(id, data);
  }

  static Map<String, dynamic>? getDraft(String id) {
    final data = draftsBox.get(id);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<void> deleteDraft(String id) async {
    await draftsBox.delete(id);
  }

  static List<Map<String, dynamic>> getAllDrafts() {
    return draftsBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}