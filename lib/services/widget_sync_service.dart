import 'package:home_widget/home_widget.dart';
import '../models/routine_item.dart';
import '../models/hydration_state.dart';
import '../models/movement_state.dart';

class WidgetSyncService {
  static const String appGroupId = 'group.com.synapse.ambient';
  static const String androidWidgetName = 'SynapseGlanceWidget';
  static const String iOSWidgetKind = 'SynapseLockScreenWidget';

  WidgetSyncService._();

  /// Synchronizes current active state to native widget storage
  static Future<void> syncWidgetPayload({
    required List<RoutineItem> routines,
    required HydrationState hydration,
    required MovementState movement,
  }) async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);

      final nextRoutine = routines.firstWhere(
        (r) => !r.isCompletedToday,
        orElse: () => routines.isNotEmpty
            ? routines.first
            : RoutineItem(
                id: 'none',
                title: 'All Doses Complete',
                dosage: 'Done for today',
                sector: routines.isNotEmpty ? routines.first.sector : null!,
                scheduledHour: 0,
                scheduledMinute: 0,
              ),
      );

      // Save key-values for native WidgetKit / Glance
      await HomeWidget.saveWidgetData<String>('next_med_title', nextRoutine.title);
      await HomeWidget.saveWidgetData<String>('next_med_dosage', nextRoutine.dosage);
      await HomeWidget.saveWidgetData<String>(
        'next_med_time',
        '${nextRoutine.scheduledHour.toString().padLeft(2, '0')}:${nextRoutine.scheduledMinute.toString().padLeft(2, '0')}',
      );
      await HomeWidget.saveWidgetData<int>('hydration_consumed_ml', hydration.consumedMl);
      await HomeWidget.saveWidgetData<int>('hydration_target_ml', hydration.targetMl);
      await HomeWidget.saveWidgetData<int>('sitting_minutes', movement.hourlySittingMinutes);
      await HomeWidget.saveWidgetData<bool>('sedentary_alert', movement.isSedentaryAlertDue);

      // Trigger native widget refresh
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iOSWidgetKind,
      );
    } catch (_) {
      // In simulator/desktop environments where native widget provider is missing, fail silently
    }
  }
}
