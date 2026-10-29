import 'dart:async';
import '../core/utils/haptics_util.dart';
import '../models/movement_state.dart';

class MovementSensorService {
  Timer? _inactivityTimer;
  Function(MovementState)? onStateUpdated;
  Function()? onSedentaryAlert;

  MovementState _currentState = MovementState();
  MovementState get currentState => _currentState;

  /// Starts ambient inactivity tracking
  void startTracking({
    Function(MovementState)? onUpdate,
    Function()? onAlert,
  }) {
    onStateUpdated = onUpdate;
    onSedentaryAlert = onAlert;

    _inactivityTimer?.cancel();
    // Simulate background tick every minute
    _inactivityTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _tickInactivity();
    });
  }

  void stopTracking() {
    _inactivityTimer?.cancel();
  }

  /// Called every minute of detected sitting
  void _tickInactivity() {
    final updatedMinutes = _currentState.hourlySittingMinutes + 1;
    _currentState = MovementState(
      todaySteps: _currentState.todaySteps,
      hourlySittingMinutes: updatedMinutes,
      lastMovementTime: _currentState.lastMovementTime,
      stretchesCompleted: _currentState.stretchesCompleted,
      dailyMovementGoal: _currentState.dailyMovementGoal,
    );

    onStateUpdated?.call(_currentState);

    // If 50-minute threshold reached, trigger distinct double-pulse haptic tap
    if (updatedMinutes == 50) {
      HapticsUtil.doublePulseNudge();
      onSedentaryAlert?.call();
    }
  }

  /// Manually logs a completed micro-break or stretch
  void recordStretch() {
    _currentState = _currentState.recordStretch();
    HapticsUtil.mediumConfirm();
    onStateUpdated?.call(_currentState);
  }
}
