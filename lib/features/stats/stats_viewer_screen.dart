import 'package:a2f_sdk/a2f_sdk.dart';
import 'package:flext_core/flext_core.dart';
import 'package:flutter/material.dart';

import '../../data/service_repository.dart';
import '../../model/model.dart';

class StatsViewerScreen extends StatefulWidget {
  const StatsViewerScreen({super.key});

  @override
  State<StatsViewerScreen> createState() => _StatsViewerScreenState();
}

class _StatsViewerScreenState extends State<StatsViewerScreen> {
  List<AwsServiceQnaHelper> _helpers = [];
  bool _isAscending = true;
  int _sortColumnIndex = 0;
  bool _showReversedStats = false;

  /// 0 = all, 1 = enabled, 2 = disabled
  int _showEnabledVsDisabled = 0;

  @override
  void initState() {
    super.initState();
    _setHelpers();
  }

  void _setHelpers() {
    _helpers = _showEnabledVsDisabled == 0
        ? ServiceRepository.I.items
        : _showEnabledVsDisabled == 1
            ? ServiceRepository.I.enabledItems
            : ServiceRepository.I.disabledItems;
    _sort();
  }

  Widget _label(
    String text, {
    bool bold = false,
    bool isEnabled = false,
  }) =>
      Text(
        text.replaceAll(' ', '\n'),
        style: TextStyle(
          fontSize: 11,
          fontWeight: bold ? FontWeight.bold : null,
          decoration: isEnabled ? TextDecoration.lineThrough : null,
          color: isEnabled ? Colors.grey[600] : null,
        ),
      );

  void _sort([int? columnIndex, bool? ascending]) {
    columnIndex ??= _sortColumnIndex;
    ascending ??= _isAscending;
    late final Comparable<dynamic> Function(AwsServiceQnaHelper a) getField;
    switch (columnIndex) {
      case 0:
        getField = (helper) => helper.service.name;
      case 1:
        getField = (helper) => helper.stats.correctCount;
      case 2:
        getField =
            (helper) => helper.stats.questionCount - helper.stats.correctCount;
      case 3:
        getField = (helper) => helper.stats.questionCount;
      default:
        throw Exception('Invalid column index');
    }
    if (ascending) {
      _helpers.sort(
        (a, b) {
          final result = getField(a).compareTo(getField(b));
          if (result == 0) {
            return a.service.name.compareTo(b.service.name);
          }
          return result;
        },
      );
    } else {
      _helpers.sort((a, b) {
        final result = getField(b).compareTo(getField(a));
        if (result == 0) {
          return a.service.name.compareTo(b.service.name);
        }
        return result;
      });
    }
    _sortColumnIndex = columnIndex;
    _isAscending = ascending;
  }

  void _onSort(
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      _sort(columnIndex, ascending);
    });
  }

  void _onLongPress(AwsServiceQnaHelper helper, BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(helper.service.name),
        content: Text(helper.service.description),
        actions: [
          TextButton(
            onPressed: () {
              ServiceRepository.I.toggle(
                helper.service,
                isEnabled: !helper.isEnabled,
              );
              _refresh();
              ctx.nav.pop();
            },
            child: Text(
              helper.isEnabled ? 'Disable' : 'Enable',
              style: TextStyle(
                color: helper.isEnabled ? Colors.red : Colors.green,
              ),
            ),
          ),
          TextButton(
            onPressed: () => ctx.nav.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _refresh() {
    setState(() {
      _setHelpers();
      _sort();
    });
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required void Function(bool selected) onSelected,
  }) {
    return ChoiceChip(
      visualDensity: const VisualDensity(
        horizontal: -4,
        vertical: -4,
      ),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      showCheckmark: false,
      selected: selected,
      onSelected: onSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('Stats'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refresh,
            ),
          ],
        ),
        SliverPadding(
          padding: $style.insets.screenH.asPaddingH,
          sliver: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              _buildChip(
                label: 'Toggle reversed',
                selected: !_showReversedStats,
                onSelected: (selected) {
                  setState(() {
                    _showReversedStats = !selected;
                    _sort();
                  });
                },
              ),
              _buildChip(
                label: 'Only enabled',
                selected: _showEnabledVsDisabled == 1,
                onSelected: (selected) {
                  setState(() {
                    _showEnabledVsDisabled = selected ? 1 : 0;
                    _setHelpers();
                  });
                },
              ),
              _buildChip(
                label: 'Only disabled',
                selected: _showEnabledVsDisabled == 2,
                onSelected: (selected) {
                  setState(() {
                    _showEnabledVsDisabled = selected ? 2 : 0;
                    _setHelpers();
                  });
                },
              ),
            ],
          ).asSliver,
        ),
        SliverToBoxAdapter(
          child: DataTable(
            showCheckboxColumn: false,
            dataRowMinHeight: 0,
            horizontalMargin: 12,
            columnSpacing: 30,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _isAscending,
            columns: [
              DataColumn(
                label: _label('Service'),
                onSort: _onSort,
              ),
              DataColumn(
                label: _label('Correct'),
                onSort: _onSort,
                numeric: true,
              ),
              DataColumn(
                label: _label('Wrong'),
                onSort: _onSort,
                numeric: true,
              ),
              DataColumn(
                label: _label('Total'),
                onSort: _onSort,
                numeric: true,
              ),
            ],
            rows: _helpers.map(
              (helper) {
                final stats =
                    _showReversedStats ? helper.reverseStats : helper.stats;
                return DataRow(
                  color: WidgetStateProperty.all(
                    (!helper.isEnabled
                            ? Colors.black
                            : stats.correctCount / stats.questionCount > 0.72 ||
                                    stats.questionCount == 0
                                ? Colors.green
                                : Colors.pink)
                        .withValues(alpha: 0.2),
                  ),
                  onSelectChanged: (_) => _onLongPress(helper, context),
                  cells: [
                    DataCell(
                      _label(
                        helper.service.name,
                        bold: true,
                        isEnabled: !helper.isEnabled,
                      ),
                    ),
                    DataCell(
                      _label(
                        stats.let((s) => '${s.correctCount}'),
                        isEnabled: !helper.isEnabled,
                      ),
                    ),
                    DataCell(
                      _label(
                        stats.let(
                          (s) => '${s.questionCount - s.correctCount}',
                        ),
                        isEnabled: !helper.isEnabled,
                      ),
                    ),
                    DataCell(
                      _label(
                        '${stats.questionCount}',
                        isEnabled: !helper.isEnabled,
                      ),
                    ),
                  ],
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }
}
