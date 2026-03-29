import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/match_model.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = ref.watch(matchesProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mis Partidos'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 8,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: DataTable(
              columnSpacing: 24,
              horizontalMargin: 20,
              headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
              columns: const [
                DataColumn(label: Text('Día', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Hora', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Equipo Rival', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Lugar', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Sets', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('')), 
              ],
              rows: matches.map((match) {
                return DataRow(
                  cells: [
                    DataCell(_buildEditableCell(
                        text: match.day,
                        hint: 'Sáb 15',
                        width: 80,
                        onChanged: (val) => _updateMatch(match.copyWith(day: val)))),
                    DataCell(_buildEditableCell(
                        text: match.time,
                        hint: '18:00',
                        width: 80,
                        onChanged: (val) => _updateMatch(match.copyWith(time: val)))),
                    DataCell(_buildEditableCell(
                        text: match.opponent,
                        hint: 'Nombre Equipo',
                        width: 160,
                        onChanged: (val) => _updateMatch(match.copyWith(opponent: val)))),
                    DataCell(_buildEditableCell(
                        text: match.location,
                        hint: 'Local/Visitante',
                        width: 120,
                        onChanged: (val) => _updateMatch(match.copyWith(location: val)))),
                    DataCell(_buildEditableCell(
                        text: match.score,
                        hint: '3 - 1',
                        width: 80,
                        onChanged: (val) => _updateMatch(match.copyWith(score: val)))),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => _deleteMatch(match.id),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMatch,
        icon: const Icon(Icons.add),
        label: const Text('Añadir Partido'),
      ),
    );
  }

  Widget _buildEditableCell({required String text, required String hint, required double width, required Function(String) onChanged}) {
    return SizedBox(
      width: width,
      child: TextFormField(
        initialValue: text,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void _updateMatch(MatchModel updated) {
    final matches = ref.read(matchesProvider);
    final index = matches.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      final newList = List<MatchModel>.from(matches);
      newList[index] = updated;
      ref.read(matchesProvider.notifier).state = newList;
    }
  }

  void _deleteMatch(String id) {
    final matches = ref.read(matchesProvider);
    final newList = matches.where((m) => m.id != id).toList();
    ref.read(matchesProvider.notifier).state = newList;
  }

  void _addMatch() {
    final matches = ref.read(matchesProvider);
    final newMatch = MatchModel(id: DateTime.now().microsecondsSinceEpoch.toString());
    ref.read(matchesProvider.notifier).state = [...matches, newMatch];
  }
}
