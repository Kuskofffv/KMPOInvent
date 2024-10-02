import 'dart:async';

import 'package:core/util/extension/extensions.dart';
import 'package:flutter/material.dart';

import '../../util/theme/colors.dart';

class CopyOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onCopy;
  final bool enabled;
  final String? text;
  final IconData? icon;
  final double? leftOffset;

  const CopyOverlay({
    required this.child,
    this.text,
    this.onCopy,
    super.key,
    this.enabled = true,
    this.icon,
    this.leftOffset,
  });

  @override
  State<CopyOverlay> createState() => _CopyOverlayState();
}

class _CopyOverlayState extends State<CopyOverlay> {
  final _overlayPortalController = OverlayPortalController();
  final _link = LayerLink();
  Timer? _changeVisibilityTimer;
  bool _isVisible = false;
  bool _isChildHovered = false;
  bool _isButtonHovered = false;

  @override
  void dispose() {
    _changeVisibilityTimer?.cancel();
    if (_overlayPortalController.isShowing) {
      _overlayPortalController.hide();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enabled == false) {
      return widget.child;
    }

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayPortalController,
        overlayChildBuilder: _buildOverlay,
        child: MouseRegion(
          onEnter: (event) {
            _isChildHovered = true;
            _checkOverlay();
          },
          onExit: (event) {
            _isChildHovered = false;
            _checkOverlay();
          },
          child: widget.child,
        ),
      ),
    );
  }

  void _checkOverlay() {
    _isVisible = _isButtonHovered || _isChildHovered;
    if (_isVisible) {
      _changeVisibilityTimer?.cancel();
      _changeVisibilityTimer = Timer(const Duration(milliseconds: 250), () {
        if (_isVisible) {
          _overlayPortalController.show();
        }
      });
    } else {
      _changeVisibilityTimer?.cancel();
      _changeVisibilityTimer = Timer(const Duration(milliseconds: 250), () {
        if (!_isVisible) {
          _overlayPortalController.hide();
        }
      });
    }
  }

  Widget _buildOverlay(BuildContext context) {
    const double topBottomPadding = 5;
    const double iconSize = 24;
    const double leftPadding = 8;
    return CompositedTransformFollower(
      link: _link,
      targetAnchor: Alignment.centerRight,
      child: Transform.translate(
        offset:
            Offset(widget.leftOffset ?? 0, -iconSize / 2 - topBottomPadding),
        child: Align(
          alignment: Alignment.topLeft,
          child: MouseRegion(
            onEnter: (event) {
              setState(() {
                _isButtonHovered = true;
              });
              _checkOverlay();
            },
            onExit: (event) {
              setState(() {
                _isButtonHovered = false;
              });
              _checkOverlay();
            },
            child: GestureDetector(
              onTap: widget.onCopy ??
                  () {
                    widget.text.copyToClipboard(notify: true);
                  },
              child: Container(
                  color: Colors.transparent,
                  width: leftPadding + iconSize,
                  height: iconSize + topBottomPadding * 2,
                  padding: const EdgeInsets.fromLTRB(
                      leftPadding, topBottomPadding, 0, topBottomPadding),
                  alignment: Alignment.topLeft,
                  child: Icon(
                    widget.icon ?? Icons.copy_outlined,
                    color: _isButtonHovered ? TColors.accent : TColors.grey70,
                    size: iconSize,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
