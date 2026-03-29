import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/models/class_card_model.dart';
import '../providers/class_card_provider.dart';
import '../../../../shared/utils/date_utils.dart' as app_date_utils;

/// Main screen displaying the class attendance card.
class ClassCardScreen extends ConsumerStatefulWidget {
  const ClassCardScreen({super.key});

  @override
  ConsumerState<ClassCardScreen> createState() => _ClassCardScreenState();
}

class _ClassCardScreenState extends ConsumerState<ClassCardScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  // Color palette from PRD
  static const Color _gradientStart = Color(0xFFF5C842);
  static const Color _gradientMiddle = Color(0xFFE0608A);
  static const Color _gradientEnd = Color(0xFF9B4DB0);
  static const Color _slotMarkedText = Color(0xFF9B4DB0);
  static const Color _slotMarkedTime = Color(0xFFC06AB0);
  static const Color _fabColor = Color(0xFF9B4DB0);
  static const Color _background = Color(0xFFFAFAFA);
  static const Color _textPrimary = Color(0xFF212121);
  static const Color _textSecondary = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    final cardAsync = ref.watch(classCardProvider);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Mi Credencial'),
        centerTitle: true,
        backgroundColor: _gradientEnd,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: cardAsync.when(
        data: (card) => _buildContent(card),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(error),
      ),
      floatingActionButton: cardAsync.hasValue
          ? FloatingActionButton(
              onPressed: _isSharing ? null : _shareCard,
              backgroundColor: _fabColor,
              foregroundColor: Colors.white,
              child: _isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.share),
            )
          : null,
    );
  }

  Widget _buildContent(ClassCardModel card) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // The card widget
            Screenshot(
              controller: _screenshotController,
              child: _buildCard(card),
            ),
            const SizedBox(height: 24),
            // Legend / Instructions
            _buildLegend(),
            const SizedBox(height: 32), // Extra space for nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildCard(ClassCardModel card) {
    // Calculate minimum height based on total classes
    final gridRows = (card.totalClasses / 2).ceil();
    final minGridHeight = gridRows * 80.0 + 20; // slot height + spacing
    final minCardHeight =
        280.0 + minGridHeight; // header + name + pack + grid + footer

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_gradientStart, _gradientMiddle, _gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      constraints: BoxConstraints(minHeight: minCardHeight),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildCardHeader(card),
              const SizedBox(height: 20),
              // Student name
              _buildStudentName(card),
              const SizedBox(height: 16),
              // Pack selector
              _buildPackSelector(card),
              const SizedBox(height: 20),
              // Class slots grid
              _buildSlotsGrid(card),
              const SizedBox(height: 12),
              // Remaining classes
              _buildRemainingClasses(card),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(ClassCardModel card) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Evolución • Baila Más',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'TARJETA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentName(ClassCardModel card) {
    return GestureDetector(
      onTap: () => _showNameEditor(card),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.person, color: _textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                card.studentName.isEmpty
                    ? 'Toca para ingresar tu nombre'
                    : card.studentName,
                style: TextStyle(
                  color: card.studentName.isEmpty
                      ? _textSecondary
                      : _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.edit, color: _textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPackSelector(ClassCardModel card) {
    return GestureDetector(
      onTap: () => _showPackSelector(card),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.confirmation_number,
              color: _textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Pack de ${card.totalClasses} clases',
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.edit, color: _textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsGrid(ClassCardModel card) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: card.slots.length,
      itemBuilder: (context, index) {
        return _buildSlot(card.slots[index], index);
      },
    );
  }

  Widget _buildSlot(ClassSlot slot, int index) {
    return GestureDetector(
      onTap: () => _handleSlotTap(slot, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: slot.isUsed ? Colors.white : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: slot.isUsed
                ? _slotMarkedText
                : Colors.white.withOpacity(0.8),
            width: 2,
          ),
        ),
        child: slot.isUsed
            ? _buildMarkedSlotContent(slot)
            : _buildEmptySlotContent(),
      ),
    );
  }

  Widget _buildEmptySlotContent() {
    return const Center(child: Icon(Icons.add, color: Colors.white, size: 32));
  }

  Widget _buildMarkedSlotContent(ClassSlot slot) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            app_date_utils.DateUtils.formatDateWithDay(slot.date!),
            style: const TextStyle(
              color: _slotMarkedText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            app_date_utils.DateUtils.formatTime(slot.time!),
            style: const TextStyle(
              color: _slotMarkedTime,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingClasses(ClassCardModel card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${card.remainingCount} clases restantes',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cómo usar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildLegendItem(
            Icons.add_circle_outline,
            'Toca un círculo vacío para registrar una clase',
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            Icons.check_circle,
            'La fecha y horario quedan guardados',
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            Icons.touch_app,
            'Toca un círculo marcado para desmarcar',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: _textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los datos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.invalidate(classCardProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSlotTap(ClassSlot slot, int index) {
    if (slot.isUsed) {
      _showUnmarkConfirmation(slot, index);
    } else {
      _showDateSelector(index);
    }
  }

  void _showDateSelector(int slotIndex) async {
    // Default to today's date
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecciona la fecha de la clase',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (selectedDate != null && mounted) {
      _showTimeSelector(slotIndex, selectedDate);
    }
  }

  void _showTimeSelector(int slotIndex, DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Fecha: ${app_date_utils.DateUtils.formatDateShort(selectedDate)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona el horario',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                ...availableTimeSlots.map((time) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _markSlot(slotIndex, date: selectedDate, time: time);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gradientEnd,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          app_date_utils.DateUtils.formatTime(time),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _markSlot(
    int slotIndex, {
    required DateTime date,
    required TimeOfDay time,
  }) async {
    final notifier = ref.read(classCardProvider.notifier);
    final success = await notifier.markSlot(slotIndex, date: date, time: time);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar. Por favor, reintenta.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUnmarkConfirmation(ClassSlot slot, int slotIndex) {
    final dateStr = app_date_utils.DateUtils.formatDateWithDay(slot.date!);
    final timeStr = app_date_utils.DateUtils.formatTime(slot.time!);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Desmarcar clase'),
          content: Text(
            '¿Querés desmarcar la clase del $dateStr a las $timeStr?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _unmarkSlot(slotIndex);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Desmarcar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _unmarkSlot(int slotIndex) async {
    final notifier = ref.read(classCardProvider.notifier);
    final success = await notifier.unmarkSlot(slotIndex);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar. Por favor, reintenta.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showNameEditor(ClassCardModel card) {
    final controller = TextEditingController(text: card.studentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar nombre'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nombre y apellido',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateName(controller.text);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateName(String name) async {
    final notifier = ref.read(classCardProvider.notifier);
    final success = await notifier.updateName(name);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre no puede estar vacío'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPackSelector(ClassCardModel card) {
    final notifier = ref.read(classCardProvider.notifier);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Selecciona el pack',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                if (card.hasMarkedSlots) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Al cambiar el pack se resetearán las clases marcadas',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ...availablePacks.map((pack) {
                  final isSelected = pack == card.totalClasses;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          if (isSelected) return;

                          if (notifier.needsPackChangeConfirmation(pack)) {
                            _showPackChangeConfirmation(pack);
                          } else {
                            await _changePack(pack, confirmed: true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Colors.grey
                              : _gradientEnd,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '$pack clases',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPackChangeConfirmation(int newPack) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar pack'),
          content: const Text(
            '¿Estás seguro de cambiar el pack? Se perderán todas las clases marcadas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _changePack(newPack, confirmed: true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cambiar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePack(int newPack, {required bool confirmed}) async {
    final notifier = ref.read(classCardProvider.notifier);
    final success = await notifier.changePack(newPack, confirmed: confirmed);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar. Por favor, reintenta.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareCard() async {
    setState(() => _isSharing = true);

    try {
      // Capture the card as image
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 2.0,
        delay: const Duration(milliseconds: 10),
      );

      if (imageBytes == null) {
        _showShareError('Error al capturar la tarjeta');
        return;
      }

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final fileName =
          'tarjeta_clases_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      // Get student name for the share text
      final card = ref.read(classCardProvider).value;
      final studentName = card?.studentName ?? '';

      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        text: studentName.isNotEmpty
            ? '🎵 Tarjeta de clases de $studentName'
            : '🎵 Tarjeta de clases de baile',
      );
    } catch (e) {
      _showShareError('Error al compartir: $e');
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _showShareError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: _shareCard,
        ),
      ),
    );
  }
}
