import 'package:core/util/extension/extensions.dart';
import 'package:core/util/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TDropSelectController<T> {
  _TDropSelectState<T>? _state;

  void showMenu() {
    _state?._overlayPortalController.show();
  }

  // ignore: use_setters_to_change_properties
  void _register(_TDropSelectState<T> state) {
    _state = state;
  }

  void _unregister(_TDropSelectState<T> state) {
    if (_state == state) {
      _state = null;
    }
  }
}

class TDropSelect<T> extends StatefulWidget {
  final String Function(T) textBuilder;
  final T? value;
  final String? hint;
  final void Function(T?) onSelected;
  final List<T> items;
  final TDropSelectController<T>? controller;
  final int? maxLines;

  const TDropSelect({
    required this.textBuilder,
    required this.value,
    required this.onSelected,
    required this.items,
    super.key,
    this.hint,
    this.controller,
    this.maxLines = 1,
  });

  @override
  State<TDropSelect<T>> createState() => _TDropSelectState<T>();
}

class _TDropSelectState<T> extends State<TDropSelect<T>> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<T> _results = [];
  final _overlayPortalController = OverlayPortalController();
  final _link = LayerLink();
  double? _controlWidth;

  @override
  void initState() {
    super.initState();
    _textEditingController.text =
        widget.value != null ? widget.textBuilder(widget.value as T) : "";
    _focusNode.addListener(_focusListener);
    widget.controller?._register(this);
  }

  @override
  void didUpdateWidget(covariant TDropSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller?._unregister(this);
    widget.controller?._register(this);
    _textEditingController.text =
        widget.value != null ? widget.textBuilder(widget.value as T) : "";
  }

  void _focusListener() {
    _controlWidth = context.size?.width;
    if (_focusNode.hasFocus) {
      _overlayPortalController.show();
    } else {
      _textEditingController.text =
          widget.value != null ? widget.textBuilder(widget.value as T) : "";
      _overlayPortalController.hide();
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    widget.controller?._unregister(this);
    super.dispose();
  }

  void _handleSearch(String input) {
    _controlWidth = context.size?.width;
    _results.clear();
    for (final item in widget.items) {
      if (widget.textBuilder(item).containsIgnoreCase(input)) {
        _results.add(item);
      }
    }
    setState(() {});
    if (_results.isEmpty) {
      _overlayPortalController.hide();
    } else {
      _overlayPortalController.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayPortalController,
        overlayChildBuilder: _buildOverlay,
        child: TextField(
            controller: _textEditingController,
            focusNode: _focusNode,
            onChanged: _handleSearch,
            maxLines: widget.maxLines,
            decoration: InputDecoration(
              hintText: widget.hint ?? '',
              suffixIcon: widget.value == null
                  ? const Icon(Icons.arrow_drop_down, color: Colors.black)
                  : IconButton(
                      onPressed: () {
                        widget.onSelected(null);
                      },
                      icon: const Icon(Icons.close_outlined,
                          color: TColors.grey80)),
            )),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final listItems =
        _textEditingController.text.trim().isEmpty ? widget.items : _results;

    final listContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: listItems
          .map((item) => OverlayListItem(
                onTap: () {
                  widget.onSelected(item);
                  _focusNode.unfocus();
                },
                title: widget.textBuilder(item),
              ))
          .toList(),
    );

    return CompositedTransformFollower(
      link: _link,
      targetAnchor: Alignment.bottomLeft,
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 400,
                minWidth: _controlWidth ?? 0,
                maxWidth: _controlWidth ?? 0,
              ),
              child: IntrinsicWidth(
                  child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        child: listContent,
                      ))),
            ),
          ),
        ),
      ),
    );
  }
}

class OverlayListItem extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  const OverlayListItem({required this.onTap, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      canRequestFocus: false,
      onTap: (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android)
          ? onTap
          : null,
      onTapDown: !(defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android)
          ? (_) => onTap()
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(title),
      ),
    );
  }
}
