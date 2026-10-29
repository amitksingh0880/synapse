import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synapse/core/constants/app_constants.dart';
import 'package:synapse/models/routine_item.dart';
import 'package:synapse/models/hydration_state.dart';
import 'package:synapse/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
  });

  group('StorageService Persistence Tests', () {
    test('Saves and loads routines reliably', () async {
      final routine = RoutineItem(
        id: 'r_01',
        title: 'Atorvastatin',
        dosage: '20mg - 1 tablet',
        sector: DaySector.evening,
        scheduledHour: 21,
        scheduledMinute: 0,
      );

      await storageService.saveRoutines([routine]);
      final loaded = await storageService.loadRoutines();

      expect(loaded.length, 1);
      expect(loaded.first.title, 'Atorvastatin');
      expect(loaded.first.sector, DaySector.evening);
    });

    test('Saves and retrieves hydration state', () async {
      final state = HydrationState(
        targetMl: 2500,
        consumedMl: 1500,
      );

      await storageService.saveHydrationState(state);
      final loaded = await storageService.loadHydrationState();

      expect(loaded.consumedMl, 1500);
      expect(loaded.targetMl, 2500);
    });
  });
}
