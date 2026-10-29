import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/memory_provider.dart';
import '../../providers/routine_provider.dart';
import '../widgets/bento_card.dart';

class QuerySheet extends ConsumerStatefulWidget {
  const QuerySheet({super.key});

  @override
  ConsumerState<QuerySheet> createState() => _QuerySheetState();
}

class _QuerySheetState extends ConsumerState<QuerySheet> {
  final TextEditingController _queryController = TextEditingController();
  String _currentQuery = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memories = ref.watch(memoryProvider.notifier).query(_currentQuery);
    final routines = ref.watch(routineProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.violetMemory, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Synapse Query Vault',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            controller: _queryController,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Ask: "Where is my car?" or "Did I take morning pills?"',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              filled: true,
              fillColor: AppColors.surface,
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.violetMemory),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _currentQuery = val.trim();
              });
            },
          ),
          const SizedBox(height: 20),

          // Search Results
          Expanded(
            child: ListView(
              children: [
                if (_currentQuery.isNotEmpty &&
                    (_currentQuery.toLowerCase().contains('pill') ||
                     _currentQuery.toLowerCase().contains('medicine') ||
                     _currentQuery.toLowerCase().contains('take'))) ...[
                  const Text(
                    'MEDICATION ADHERENCE STATUS',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.emeraldMeds, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ...routines.map((r) {
                    final status = r.isCompletedToday ? '✅ Taken' : '⏳ Pending';
                    return BentoCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text(status, style: TextStyle(color: r.isCompletedToday ? AppColors.emeraldMeds : AppColors.amberReminders)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                const Text(
                  'SECOND BRAIN MEMORIES',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.violetMemory, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (memories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No memories match this query.', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  )
                else
                  ...memories.map((m) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: BentoCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.category.name.toUpperCase(),
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.violetMemory),
                            ),
                            const SizedBox(height: 6),
                            Text(m.content, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
