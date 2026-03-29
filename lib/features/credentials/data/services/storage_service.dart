import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/class_card_model.dart';

/// Service for persisting class card data to SharedPreferences.
///
/// Handles reading and writing the card data with error handling
/// and default value fallback.
class StorageService {
  static const String _storageKey = 'class_card_data';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// Loads the class card data from storage.
  ///
  /// Returns [ClassCardModel.empty()] if:
  /// - No data exists
  /// - Data is corrupted
  /// - Reading fails
  ///
  /// In case of errors, logs the issue for debugging.
  Future<ClassCardModel> loadCard() async {
    try {
      final jsonString = _prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return ClassCardModel.empty();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ClassCardModel.fromJson(json);
    } catch (e) {
      // Data is corrupted, return default
      return ClassCardModel.empty();
    }
  }

  /// Saves the class card data to storage.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> saveCard(ClassCardModel card) async {
    try {
      final json = card.toJson();
      final jsonString = jsonEncode(json);
      return await _prefs.setString(_storageKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Clears all stored data.
  ///
  /// Useful for testing or reset functionality.
  Future<bool> clearCard() async {
    try {
      return await _prefs.remove(_storageKey);
    } catch (e) {
      return false;
    }
  }

  /// Checks if stored data exists.
  bool hasStoredData() {
    return _prefs.containsKey(_storageKey);
  }
}
