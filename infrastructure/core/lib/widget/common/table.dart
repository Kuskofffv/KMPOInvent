import 'dart:async';

import 'package:core/util/exception/exception_parser.dart';
import 'package:core/util/extension/extensions.dart';
import 'package:core/util/globals.dart';
import 'package:core/util/simple.dart';
import 'package:core/util/theme/colors.dart';
import 'package:core/util/widget/adaptation.dart';
import 'package:core/widget/common/button.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:worker_manager/worker_manager.dart';

import '../../core_dependencies.dart';
import 'overlay.dart';
import 'page.dart';

double get _titleFontSize => 15;

double get _fontSize => 15;

class TTableMobileConfig {
  final int? idCellIndex;
  final double? idCellWidth;
  final List<int> titleCellIndexes;
  final double titleSpaceSize;
  final List<int> valueCellIndexes;
  final double valueSpaceSize;
  final double spaceSize;
  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;
  final double? maxScreenWidth;

  const TTableMobileConfig(
      {this.idCellIndex,
      this.idCellWidth,
      this.titleSpaceSize = 8,
      this.valueSpaceSize = 8,
      this.spaceSize = 8,
      this.maxScreenWidth,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.padding = const EdgeInsets.fromLTRB(0, 12, 0, 12),
      this.titleCellIndexes = const [],
      this.valueCellIndexes = const []});
}

class TTableRow extends StatelessWidget {
  final Map<int, TableColumnWidth>? columnWidths;
  final double minRowHeight;
  final double? verticalRowPadding;
  final List<TTableCell> cells;
  final int? textMaxLines;
  final void Function()? onRowTap;
  final TTableMobileConfig? mobileConfig;

  const TTableRow({
    required this.cells,
    super.key,
    this.columnWidths,
    this.textMaxLines = 2,
    this.onRowTap,
    this.minRowHeight = 50,
    this.verticalRowPadding,
    this.mobileConfig,
  });

  @override
  Widget build(BuildContext context) {
    final adaptation = TAdaptation.of(context);

    if (adaptation.isMobile ||
        (mobileConfig?.maxScreenWidth ?? 0) >= adaptation.screenWidth) {
      return _buildMobileRow(context);
    }

    return Table(
      columnWidths: columnWidths,
      children: [
        _buildTableRow(context),
      ],
    );
  }

  Widget _buildMobileRow(BuildContext context) {
    final mobileConfigLocal = mobileConfig ??
        const TTableMobileConfig(
            idCellIndex: 0, titleCellIndexes: [1], valueCellIndexes: [2]);

    Widget content = Row(
      crossAxisAlignment: mobileConfigLocal.crossAxisAlignment,
      children: [
        if (mobileConfigLocal.idCellIndex != null) ...[
          SizedBox(
            width: mobileConfigLocal.idCellWidth,
            child: cells
                .getOrNull(mobileConfigLocal.idCellIndex!)
                ?.widget(context, textMaxLines),
          ),
          SizedBox(
            width: mobileConfigLocal.spaceSize,
          )
        ],
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...mobileConfigLocal.titleCellIndexes.map((index) {
                  return cells
                          .getOrNull(index)
                          ?.widget(context, textMaxLines) ??
                      emptyWidget;
                }).expandIndexed((element, index) => [
                      if (index != 0)
                        SizedBox(
                          height: mobileConfigLocal.titleSpaceSize,
                        ),
                      element
                    ]),
              ]),
        ),
        if (mobileConfigLocal.valueCellIndexes.isNotEmpty) ...[
          SizedBox(
            width: mobileConfigLocal.spaceSize,
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            ...mobileConfigLocal.valueCellIndexes.map((index) {
              return cells.getOrNull(index)?.widget(context, textMaxLines) ??
                  emptyWidget;
            }).expandIndexed((element, index) => [
                  if (index != 0)
                    SizedBox(
                      height: mobileConfigLocal.valueSpaceSize,
                    ),
                  element
                ]),
          ]),
        ],
      ],
    );

    content = Padding(padding: mobileConfigLocal.padding, child: content);

    if (onRowTap != null) {
      content = InkWell(
        canRequestFocus: false,
        onTap: onRowTap,
        child: content,
      );
    }

    return content;
  }

  TableRow _buildTableRow(BuildContext context) {
    double verticalRowPaddingLocal;
    if (verticalRowPadding == null) {
      verticalRowPaddingLocal =
          cells.containsWhere((element) => element.child != null) ? 16 : 20;
    } else {
      verticalRowPaddingLocal = verticalRowPadding!;
    }

    return TableRow(
        children: cells.map((cell) {
      EdgeInsets padding;
      if (cell.paddings != null) {
        padding = cell.paddings!;
      } else {
        padding = EdgeInsets.fromLTRB(
            8, verticalRowPaddingLocal, 8, verticalRowPaddingLocal);
      }
      return _TTableCell(
          cell: cell,
          minHeight: minRowHeight,
          padding: padding,
          textMaxLines: textMaxLines,
          onRowTap: onRowTap != null ? () => onRowTap!() : null);
    }).toList());
  }
}

class TTable extends StatelessWidget {
  final List<String> headerTitles;
  final Map<int, TableColumnWidth>? columnWidths;
  final double minRowHeight;
  final double? verticalRowPadding;
  final List<List<TTableCell>> cells;
  final int? textMaxLines;
  final void Function(int index)? onRowTap;
  final TTableMobileConfig? mobileConfig;

  const TTable(
      {required this.headerTitles,
      required this.cells,
      required this.mobileConfig,
      super.key,
      this.columnWidths,
      this.textMaxLines,
      this.onRowTap,
      this.minRowHeight = 50,
      this.verticalRowPadding});

  @override
  Widget build(BuildContext context) {
    final headerStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: _titleFontSize);
    final adaptation = TAdaptation.of(context);

    if (adaptation.isMobile ||
        (mobileConfig?.maxScreenWidth ?? 0) >= adaptation.screenWidth) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...cells.mapIndexed((cells, index) {
            return TTableRow(
                    columnWidths: columnWidths,
                    mobileConfig: mobileConfig,
                    minRowHeight: minRowHeight,
                    verticalRowPadding: verticalRowPadding,
                    textMaxLines: textMaxLines,
                    onRowTap: onRowTap != null ? () => onRowTap!(index) : null,
                    cells: cells)
                ._buildMobileRow(context);
          })
        ],
      );
    }

    return Table(
      columnWidths: columnWidths,
      children: [
        TableRow(
          decoration: const BoxDecoration(color: TColors.grey20),
          children: headerTitles
              .map((e) => _buildHeaderCell(
                  context,
                  Text(
                    e,
                    style: headerStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )))
              .toList(),
        ),
        ...cells.mapIndexed((cells, index) {
          return TTableRow(
                  cells: cells,
                  columnWidths: columnWidths,
                  textMaxLines: textMaxLines,
                  minRowHeight: minRowHeight,
                  verticalRowPadding: verticalRowPadding,
                  onRowTap: onRowTap != null ? () => onRowTap!(index) : null)
              ._buildTableRow(context);
        }).toList(),
      ],
    );
  }

  static Widget _buildHeaderCell(BuildContext context, Widget child) {
    return TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 14), child: child));
  }
}

class TTableCell {
  final String? text;
  final Widget? child;
  final VoidCallback? onTap;
  final EdgeInsets? paddings;
  final Alignment alignment;
  final IconData? copyIcon;
  final bool canCopy;
  final VoidCallback? onCopy;

  const TTableCell(
      {this.text,
      this.child,
      this.onTap,
      this.paddings,
      this.copyIcon,
      this.canCopy = false,
      this.onCopy,
      this.alignment = Alignment.centerLeft});
}

class _TTableCell extends StatelessWidget {
  final TTableCell cell;
  final double minHeight;
  final EdgeInsets padding;
  final int? textMaxLines;
  final VoidCallback? onRowTap;

  const _TTableCell(
      {required this.cell,
      required this.minHeight,
      required this.padding,
      required this.textMaxLines,
      required this.onRowTap});

  @override
  Widget build(BuildContext context) {
    Widget cellContent = Padding(
      padding: padding,
      child: cell.child ??
          Text(
            cell.text!,
            maxLines: textMaxLines,
            textWidthBasis: TextWidthBasis.longestLine,
          ),
    );

    cellContent = CopyOverlay(
      enabled: cell.canCopy,
      text: cell.text,
      icon: cell.copyIcon,
      onCopy: cell.onCopy,
      leftOffset: -padding.right,
      child: cellContent,
    );

    cellContent = DefaultTextStyle(
      style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontSize: _fontSize) ??
          TextStyle(fontSize: _fontSize),
      child: cellContent,
    );

    cellContent = ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Align(alignment: cell.alignment, child: cellContent));

    if (cell.onTap != null) {
      cellContent = TableCell(
        verticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
        child: InkWell(
          canRequestFocus: false,
          onTap: cell.onTap,
          child: cellContent,
        ),
      );
    } else if (onRowTap != null) {
      cellContent = TableCell(
        verticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
        child: TableRowInkWell(
          onTap: onRowTap,
          child: cellContent,
        ),
      );
    } else {
      cellContent = TableCell(
        verticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
        child: cellContent,
      );
    }

    return cellContent;
  }
}

extension on TTableCell {
  Widget widget(BuildContext context, int? textMaxLines) {
    return DefaultTextStyle(
      style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontSize: _fontSize) ??
          TextStyle(fontSize: _fontSize),
      child: child ??
          Text(
            text!,
            maxLines: textMaxLines,
          ),
    );
  }
}

class TTableSliver extends TTableSliverBuilder {
  TTableSliver(
      {required super.headerTitles,
      required List<List<TTableCell>> cells,
      required super.mobileConfig,
      super.columnWidths,
      super.textMaxLines,
      super.onRowTap,
      super.minRowHeight,
      super.verticalRowPadding})
      : super(
            itemCount: cells.length, builder: (context, index) => cells[index]);
}

class TTableSliverBuilder extends StatelessWidget {
  final List<String> headerTitles;
  final Map<int, TableColumnWidth>? columnWidths;
  final double minRowHeight;
  final double? verticalRowPadding;
  final List<TTableCell> Function(BuildContext context, int index) builder;
  final int itemCount;
  final int? textMaxLines;
  final void Function(int index)? onRowTap;
  final Widget? footer;
  final TTableMobileConfig? mobileConfig;

  const TTableSliverBuilder(
      {required this.headerTitles,
      required this.builder,
      required this.itemCount,
      required this.mobileConfig,
      this.columnWidths,
      this.textMaxLines,
      this.onRowTap,
      this.minRowHeight = 50,
      this.verticalRowPadding,
      this.footer});

  @override
  Widget build(BuildContext context) {
    final adaptation = TAdaptation.of(context);

    final listSliver = SliverList.builder(
        itemBuilder: (context, index) {
          if (footer != null && index == itemCount) {
            return footer!;
          }
          return TTableRow(
              columnWidths: columnWidths,
              mobileConfig: mobileConfig,
              onRowTap: () {
                onRowTap?.call(index);
              },
              cells: builder(context, index));
        },
        itemCount: itemCount + (footer != null ? 1 : 0));

    return MultiSliver(children: [
      if (!adaptation.isMobile &&
          (mobileConfig?.maxScreenWidth ?? 0) < adaptation.screenWidth)
        SliverToBoxAdapter(
          child: TTableHeader(
            headerTitles: headerTitles,
            columnWidths: columnWidths,
          ),
        ),
      listSliver
    ]);
  }
}

class TTableHeader extends StatelessWidget {
  const TTableHeader({
    required this.headerTitles,
    this.columnWidths,
    super.key,
  });

  final List<String> headerTitles;
  final Map<int, TableColumnWidth>? columnWidths;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: columnWidths,
      children: [
        TableRow(
          decoration: const BoxDecoration(color: TColors.grey20),
          children: headerTitles
              .map((e) => TTable._buildHeaderCell(
                  context,
                  Text(
                    e,
                    style: TextStyle(fontSize: _titleFontSize),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )))
              .toList(),
        ),
      ],
    );
  }
}

class TTablePaginatedSliverItemSnapshot<T extends Object> {
  final List<T> list;
  final T data;
  final int index;

  const TTablePaginatedSliverItemSnapshot(
      {required this.list, required this.data, required this.index});
}

class OperationSnapshot<T extends Object> {
  final List<T> list;
  final bool hasMore;

  const OperationSnapshot({required this.list, required this.hasMore});
}

class TTablePaginatedSliverController<T extends Object> {
  _TTablePaginatedSliverState<T>? _state;

  Future update({int Function(T item)? idGetter}) async {
    void Function(List<T> items, List<T> newItems) mergeFunc;

    if (idGetter == null) {
      mergeFunc = (items, newItems) {
        items
          ..clear()
          ..addAll(newItems);
      };
    } else {
      mergeFunc = (items, newItems) {
        if (items.isNotEmpty && newItems.isNotEmpty) {
          final firstId = idGetter(newItems.last);
          final indexOfFirst =
              items.indexWhere((element) => idGetter(element) == firstId);
          if (indexOfFirst == -1) {
            items
              ..clear()
              ..addAll(newItems);
          } else {
            items
              ..removeRange(0, indexOfFirst + 1)
              ..insertAll(0, newItems);
          }
        } else {
          items.addAll(newItems);
        }
      };
    }
    await _state!._queue.add(() => _state!._loadData(
        operation: () => _state!.widget.operation(0), mergeFunc: mergeFunc));
  }

  void dispose() {
    _state = null;
  }
}

class TTablePaginatedSliver<T extends Object> extends StatefulWidget {
  final List<String> headerTitles;
  final Map<int, TableColumnWidth>? columnWidths;
  final double minRowHeight;
  final double? verticalRowPadding;
  final List<TTableCell> Function(
          BuildContext context, TTablePaginatedSliverItemSnapshot<T> snapshot)
      builder;
  final int? textMaxLines;
  final void Function(TTablePaginatedSliverItemSnapshot<T> snapshot)? onRowTap;
  final Future<OperationSnapshot<T>> Function(int offser) operation;
  final bool autoLoadMore;
  final bool Function(T)? filter;
  final TTableMobileConfig? mobileConfig;
  final TTablePaginatedSliverController<T>? controller;
  final Key? filterKey;
  final ScrollController? scrollController;
  final String emptyPageTitle;

  const TTablePaginatedSliver(
      {required Key key,
      required this.headerTitles,
      required this.builder,
      required this.operation,
      required this.mobileConfig,
      required this.emptyPageTitle,
      this.columnWidths,
      this.textMaxLines,
      this.onRowTap,
      this.minRowHeight = 50,
      this.verticalRowPadding,
      this.autoLoadMore = true,
      this.filter,
      this.filterKey,
      this.controller,
      this.scrollController})
      : super(key: key);

  @override
  State<TTablePaginatedSliver<T>> createState() =>
      _TTablePaginatedSliverState<T>();
}

class _TTablePaginatedSliverState<T extends Object>
    extends State<TTablePaginatedSliver<T>> {
  final _queue = FuturesQueue();
  final List<T> _items = [];
  List<T>? _filteredItems;
  bool _hasMore = true;

  late bool _autoLoadMore = widget.autoLoadMore;
  Object? _firstLoadException;

  Key? _filterKey;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _filterKey = widget.filterKey;
    _queue.add(() => _loadMore(0));
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) {
      widget.controller?._state = null;
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(TTablePaginatedSliver<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller?._state = null;
    widget.controller?._state = this;
    if (_filterKey != widget.filterKey) {
      _filterKey = widget.filterKey;
      _queue.add(() => _loadData(
          operation: () async => OperationSnapshot<T>(
                list: [],
                hasMore: _hasMore,
              ),
          mergeFunc: (items, newItems) {}));
    }
  }

  Future<void> _loadMore(int offset) async {
    if (offset != _items.length) {
      return;
    }
    await _loadData(
      operation: () => widget.operation(offset),
      mergeFunc: (items, newItems) {
        items.addAll(newItems);
      },
    );
  }

  Future<void> _loadData(
      {required Future<OperationSnapshot<T>> Function() operation,
      required void Function(List<T> items, List<T> newItems)
          mergeFunc}) async {
    try {
      final value = await operation();
      mergeFunc(_items, value.list);
      if (widget.filter != null) {
        _filteredItems =
            await WorkerManager.smartAsyncOperation((controller) async {
          final _filteredItems = <T>[];
          for (final item in _items) {
            if (widget.filter!(item)) {
              _filteredItems.add(item);
            }
            await controller.checkMaybeWait();
          }
          return _filteredItems;
        });
      } else {
        _filteredItems = null;
      }

      if (mounted) {
        setState(() {
          _firstLoadException = null;
          _hasMore = value.hasMore;
        });
      }
    } catch (e, s) {
      logger.e(e.toString(), error: e, stackTrace: s);
      if (mounted) {
        if (_items.isEmpty) {
          setState(() {
            _firstLoadException = e;
          });
        } else {
          setState(() {
            _autoLoadMore = false;
          });
          Simple.toast(ExceptionParser.parseException(e));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems ?? _items;

    if (_firstLoadException != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: TExceptionPageWidget(
          exception: _firstLoadException!,
          onRetry: () {
            setState(() {
              _firstLoadException = null;
            });
            _queue.add(() => _loadMore(0));
          },
        ),
      );
    } else if (_items.isEmpty && _queue.inProcess) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: TProgressPageWidget(),
      );
    } else if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TTableHeader(
            headerTitles: widget.headerTitles,
            columnWidths: widget.columnWidths,
          ),
          const SizedBox(height: 48),
          TEmptyPageWidget(emptyPageTitle: widget.emptyPageTitle)
        ],
      );
    }

    Widget footer;

    if (_autoLoadMore && _hasMore && _items.isNotEmpty) {
      footer = Builder(builder: (context) {
        _queue.add(() => _loadMore(_items.length));
        return const Center(
          child: CircularProgressIndicator(),
        );
      });
    } else if (_hasMore && _items.isNotEmpty && !_queue.inProcess) {
      footer = Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: MediumTextButton(
              child: const Text("Загрузить еще"),
              onPressed: () {
                setState(() {
                  _queue.add(() => _loadMore(_items.length));
                });
              }),
        ),
      );
    } else if (_hasMore && _items.isNotEmpty && _queue.inProcess) {
      footer = const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      footer = emptyWidget;
    }

    final listSliver = TTableSliverBuilder(
        headerTitles: widget.headerTitles,
        builder: (context, index) {
          final snapshot = TTablePaginatedSliverItemSnapshot<T>(
              list: items, data: items[index], index: index);
          return widget.builder(context, snapshot);
        },
        columnWidths: widget.columnWidths,
        textMaxLines: widget.textMaxLines,
        minRowHeight: widget.minRowHeight,
        verticalRowPadding: widget.verticalRowPadding,
        footer: footer,
        onRowTap: widget.onRowTap != null
            ? (index) {
                widget.onRowTap!.call(TTablePaginatedSliverItemSnapshot<T>(
                  list: items,
                  data: items[index],
                  index: index,
                ));
              }
            : null,
        mobileConfig: widget.mobileConfig,
        itemCount: items.length);

    return listSliver;
  }
}
