import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/storage_service.dart';
import '../../domain/models/class_card_model.dart';

part 'class_card_provider.g.dart';

/// Provider for SharedPreferences instance.
/// Must be overridden in main.dart with the actual instance.
@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
}

/// Provider for StorageService.
@riverpod
StorageService storageService(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
}

/// Available time slots for classes.
const List<TimeOfDay> availableTimeSlots = [
  TimeOfDay(hour: 17, minute: 0),
  TimeOfDay(hour: 19, minute: 30),
  TimeOfDay(hour: 20, minute: 30),
];

/// Available class pack options.
const List<int> availablePacks = [4, 8, 16];

/// Notifier for managing the class card state.
///
/// Handles all CRUD operations for the card with automatic persistence.
@riverpod
class ClassCardNotifier extends _$ClassCardNotifier {
  @override
  Future<ClassCardModel> build() async {
    final storage = ref.watch(storageServiceProvider);
    return await storage.loadCard();
  }

  /// Updates the student name.
  ///
  /// Validates that the name is not empty or just whitespace.
  /// Returns true if successful, false if validation fails.
  Future<bool> updateName(String name) async {
    final trimmedName = name.trim();

    // Validation: name cannot be empty or just spaces
    if (trimmedName.isEmpty) {
      return false;
    }

    final currentState = state.value;
    if (currentState == null) return false;

    final newCard = currentState.copyWith(studentName: trimmedName);
    return await _saveAndUpdate(newCard);
  }

  /// Marks a class slot with the given date and time.
  ///
  /// [slotIndex] - The index of the slot to mark.
  /// [date] - The date of the class (defaults to today).
  /// [time] - The time slot chosen.
  Future<bool> markSlot(
    int slotIndex, {
    required DateTime date,
    required TimeOfDay time,
  }) async {
    final currentState = state.value;
    if (currentState == null) return false;

    if (slotIndex < 0 || slotIndex >= currentState.slots.length) {
      return false;
    }

    final newSlot = ClassSlot.marked(date: date, time: time);

    final newSlots = List<ClassSlot>.from(currentState.slots);
    newSlots[slotIndex] = newSlot;

    final newCard = currentState.copyWith(slots: newSlots);
    return await _saveAndUpdate(newCard);
  }

  /// Unmarks a class slot (clears it).
  ///
  /// [slotIndex] - The index of the slot to unmark.
  Future<bool> unmarkSlot(int slotIndex) async {
    final currentState = state.value;
    if (currentState == null) return false;

    if (slotIndex < 0 || slotIndex >= currentState.slots.length) {
      return false;
    }

    final newSlots = List<ClassSlot>.from(currentState.slots);
    newSlots[slotIndex] = const ClassSlot.empty();

    final newCard = currentState.copyWith(slots: newSlots);
    return await _saveAndUpdate(newCard);
  }

  /// Changes the class pack.
  ///
  /// [newPack] - The new total classes (4, 8, or 16).
  /// If there are marked slots and [confirmed] is false, returns false
  /// to indicate confirmation is needed.
  Future<bool> changePack(int newPack, {bool confirmed = false}) async {
    final currentState = state.value;
    if (currentState == null) return false;

    // Validate pack size
    if (!availablePacks.contains(newPack)) {
      return false;
    }

    // Check if we need confirmation (only if there are marked slots)
    if (!confirmed &&
        currentState.hasMarkedSlots &&
        newPack != currentState.totalClasses) {
      return false;
    }

    // Create new card with the new pack (resets all slots)
    final newCard = ClassCardModel.withPack(
      newPack,
    ).copyWith(studentName: currentState.studentName);

    return await _saveAndUpdate(newCard);
  }

  /// Checks if pack change needs confirmation.
  ///
  /// Returns true if there are marked slots and the new pack is different.
  bool needsPackChangeConfirmation(int newPack) {
    final currentState = state.value;
    if (currentState == null) return false;

    return currentState.hasMarkedSlots && newPack != currentState.totalClasses;
  }

  /// Saves the card and updates state.
  ///
  /// Returns true if successful, false if storage fails.
  Future<bool> _saveAndUpdate(ClassCardModel card) async {
    final storage = ref.read(storageServiceProvider);

    // Optimistic update - update state first
    state = AsyncData(card);

    // Then persist
    final success = await storage.saveCard(card);

    if (!success) {
      // Reload from storage if save failed
      final savedCard = await storage.loadCard();
      state = AsyncData(savedCard);
      return false;
    }

    return true;
  }
}
