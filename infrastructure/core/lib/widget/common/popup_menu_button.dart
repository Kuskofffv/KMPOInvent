import 'package:flutter/material.dart';

import 'drop_select.dart';

class TPopupMenuButton<T> extends StatefulWidget {
  final String Function(T) textBuilder;
  final T? value;
  final String? hint;
  final void Function(T) onSelected;
  final List<T> items;
  final double? width;
  final String? tooltip;

  const TPopupMenuButton({
    required this.textBuilder,
    required this.value,
    required this.onSelected,
    required this.items,
    this.width,
    super.key,
    this.hint,
    this.tooltip,
  });

  @override
  State<TPopupMenuButton<T>> createState() => _TPopupMenuButtonState<T>();
}

class _TPopupMenuButtonState<T> extends State<TPopupMenuButton<T>> {
  final _overlayPortalController = OverlayPortalController();
  final _link = LayerLink();
  double? _controlWidth;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _focusListener() {
    _controlWidth = context.size?.width;
    if (_focusNode.hasFocus) {
      _overlayPortalController.show();
    } else {
      _overlayPortalController.hide();
    }
    setState(() {});
  }

  void _showPopup() {
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    Widget field = InputDecorator(
      isFocused: _focusNode.hasFocus,
      decoration: InputDecoration(
        hintText: widget.hint,
        suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        constraints: BoxConstraints(
            maxWidth: widget.width ?? MediaQuery.of(context).size.width),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              widget.value == null
                  ? (widget.hint ?? '')
                  : widget.textBuilder(widget.value as T),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: widget.value == null
                  ? Theme.of(context).inputDecorationTheme.hintStyle
                  : const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );

    field = Focus(
      focusNode: _focusNode,
      child: field,
    );

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayPortalController,
        overlayChildBuilder: _buildOverlay,
        child: InkWell(
          canRequestFocus: false,
          onTap: _showPopup,
          focusColor: Colors.transparent,
          child: field,
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final listItems = widget.items;

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
                maxHeight: 200,
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
