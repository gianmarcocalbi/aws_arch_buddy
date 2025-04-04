import 'package:a2f_sdk/a2f_sdk.dart';
import 'package:flext_core/flext_core.dart';
import 'package:flutter/material.dart';

import '../../data/service/service_repository.dart';
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
  var _showEnabled = true;
  var _showDisabled = false;
  var _hideNotFlagged = false;
  late TextEditingController _searchBarController;

  @override
  void initState() {
    super.initState();
    _searchBarController = TextEditingController();
    _setHelpers();
  }

  void _setHelpers() {
    _helpers = ServiceRepository.I.items.where((helper) {
      final isEnabledFilter = _showEnabled || !helper.isEnabled;
      final isDisabledFilter = _showDisabled || helper.isEnabled;
      final isFlaggedFilter = !_hideNotFlagged || helper.isFlagged;
      final searchFilter = _searchBarController.text.isEmpty ||
          helper.service.name
              .toLowerCase()
              .contains(_searchBarController.text.toLowerCase());
      return isEnabledFilter &&
          isDisabledFilter &&
          isFlaggedFilter &&
          searchFilter;
    }).toList();
    _sort();
  }

  void _refresh() {
    setState(() {
      _setHelpers();
      _sort();
    });
  }

  Widget _label(
    String text, {
    bool bold = false,
    bool isEnabled = false,
  }) =>
      Text(
        text,
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
        getField = (helper) => helper.mergedStats.correctCount;
      case 2:
        getField = (helper) =>
            helper.mergedStats.questionCount - helper.mergedStats.correctCount;
      case 3:
        getField = (helper) => helper.mergedStats.questionCount;
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
        content: SingleChildScrollView(
          child: Text(helper.service.description),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            color: helper.isFlagged ? Colors.pink : null,
            onPressed: () {
              ServiceRepository.I.flag(
                helper.service,
                isFlagged: !helper.isFlagged,
              );
              _refresh();
              ctx.nav.pop();
            },
          ),
          IconButton(
            onPressed: () {
              ServiceRepository.I.toggle(
                helper.service,
                isEnabled: !helper.isEnabled,
              );
              _refresh();
              ctx.nav.pop();
            },
            color: helper.isEnabled ? Colors.green : Colors.pink,
            icon: Icon(
              helper.isEnabled ? Icons.visibility : Icons.visibility_off,
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

  Widget _buildToggleButtons(BuildContext context) {
    final children = [
      (
        label: 'Enabled',
        onTap: (bool selected) => setState(() => _showEnabled = selected),
        isSelected: () => _showEnabled,
      ),
      (
        label: 'Disabled',
        onTap: (bool selected) => setState(() => _showDisabled = selected),
        isSelected: () => _showDisabled,
      ),
      (
        label: 'Only Flagged',
        onTap: (bool selected) => setState(() => _hideNotFlagged = selected),
        isSelected: () => _hideNotFlagged,
      ),
    ];
    return Center(
      child: ToggleButtons(
        isSelected: children.map((e) => e.isSelected()).toList(),
        onPressed: (index) {
          children[index].onTap(!children[index].isSelected());
          _refresh();
        },
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        selectedBorderColor: context.col.primary,
        constraints: BoxConstraints(
          minHeight: 22.0,
          minWidth: (context.widthPx - $style.insets.screenH * 2) / 4 - 2,
        ),
        children: children
            .map(
              (e) => Text(
                e.label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: TextFormField(
              onTapOutside: (_) {
                final currentScope = FocusScope.of(context);
                if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
              autofocus: false,
              controller: _searchBarController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                contentPadding: EdgeInsets.zero,
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchBarController.clear();
                    final currentScope = FocusScope.of(context);
                    if (!currentScope.hasPrimaryFocus &&
                        currentScope.hasFocus) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                    _refresh();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
              onChanged: (value) {
                _refresh();
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refresh,
              ),
            ],
          ),
          SliverPadding(
            padding: $style.insets.screenH.asPaddingH,
            sliver: _buildToggleButtons(context).asSliver,
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
                  final stats = helper.mergedStats;
                  return DataRow(
                    color: WidgetStateProperty.all(
                      (!helper.isEnabled
                              ? Colors.black
                              : stats.correctCount / stats.questionCount >
                                          0.72 ||
                                      stats.questionCount == 0
                                  ? Colors.green
                                  : Colors.pink)
                          .withValues(alpha: 0.2),
                    ),
                    onSelectChanged: (_) => _onLongPress(helper, context),
                    cells: [
                      DataCell(
                        _label(
                          '${helper.isFlagged ? '🚩' : ''}'
                          '${helper.service.name}',
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
      ),
    );
  }
}
