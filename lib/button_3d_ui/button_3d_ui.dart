import 'package:flutter/material.dart';

class Btn3D extends StatefulWidget {
  const Btn3D({super.key});

  @override
  State<Btn3D> createState() => _Btn3DState();
}

class _Btn3DState extends State<Btn3D> {
  final double kHeightBtn = 60;
  final double kElevationBtn = 8;

  final textStyle = const TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  final shadow = BoxShadow(
    color: Colors.grey.withOpacity(0.5),
    spreadRadius: 2,
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PushableBtn(
              height: kHeightBtn,
              elevation: kElevationBtn,
              hslColor: const HSLColor.fromAHSL(1.0, 356, 1.0, 0.43),
              shadow: shadow,
              onPressed: () => print('''I'm a primary Button'''),
              child: Text('Button 1', style: textStyle),
            ),
            const SizedBox(
              height: 16,
            ),
            _PushableBtn(
              height: kHeightBtn,
              elevation: kElevationBtn,
              hslColor: const HSLColor.fromAHSL(1.0, 120, 1.0, 0.37),
              shadow: shadow,
              onPressed: () => print('''I'm a second Button'''),
              child: Text('Button 2', style: textStyle),
            ),
            const SizedBox(
              height: 16,
            ),
            _PushableBtn(
              height: kHeightBtn,
              elevation: kElevationBtn,
              hslColor: const HSLColor.fromAHSL(1.0, 195, 1.0, 0.43),
              shadow: shadow,
              onPressed: () => print('''I'm a third Button'''),
              child: Text('Button 3', style: textStyle),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget to show a "3D" pushable button
class _PushableBtn extends StatefulWidget {
  const _PushableBtn({
    super.key,
    this.child,
    required this.hslColor,
    required this.height,
    this.elevation = 8.0,
    this.shadow,
    this.onPressed,
  }) : assert(height > 0);

  /// child widget (normally a Text or Icon)
  final Widget? child;

  /// Color of the top layer
  /// The color of the bottom layer is derived by decreasing the luminosity by 0.15
  final HSLColor hslColor;

  /// height of the top layer
  final double height;

  /// elevation or "gap" between the top and bottom layer
  final double elevation;

  /// An optional shadow to make the button look better
  /// This is added to the bottom layer only
  final BoxShadow? shadow;

  /// button pressed callback
  final VoidCallback? onPressed;

  @override
  State<_PushableBtn> createState() => _PushableButtonState();
}

class _PushableButtonState extends State<_PushableBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  static const animationDuration = Duration(milliseconds: 50);

  bool _isDragInProgress = false;
  Offset _gestureLocation = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: animationDuration);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _gestureLocation = details.localPosition;
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    // Small delay to ensure the forward animation completes before reversing
    Future.delayed(animationDuration, () {
      _animationController.reverse();
    });
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_isDragInProgress && mounted) {
        _animationController.reverse();
      }
    });
  }

  void _handleDragStart(DragStartDetails details) {
    _gestureLocation = details.localPosition;
    _isDragInProgress = true;
    _animationController.forward();
  }

  void _handleDragEnd(Size buttonSize) {
    if (_isDragInProgress) {
      _isDragInProgress = false;
      _animationController.reverse();
    }
    if (_gestureLocation.dx >= 0 &&
        _gestureLocation.dx < buttonSize.width &&
        _gestureLocation.dy >= 0 &&
        _gestureLocation.dy < buttonSize.height) {
      widget.onPressed?.call();
    }
  }

  void _handleDragCancel() {
    if (_isDragInProgress) {
      _isDragInProgress = false;
      _animationController.reverse();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _gestureLocation = details.localPosition;
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = widget.height + widget.elevation;
    return SizedBox(
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonSize = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onHorizontalDragStart: _handleDragStart,
            onHorizontalDragEnd: (_) => _handleDragEnd(buttonSize),
            onHorizontalDragCancel: _handleDragCancel,
            onHorizontalDragUpdate: _handleDragUpdate,
            onVerticalDragStart: _handleDragStart,
            onVerticalDragEnd: (_) => _handleDragEnd(buttonSize),
            onVerticalDragCancel: _handleDragCancel,
            onVerticalDragUpdate: _handleDragUpdate,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final top = _animationController.value * widget.elevation;
                final hslColor = widget.hslColor;
                final bottomHslColor =
                    hslColor.withLightness(hslColor.lightness - 0.15);
                return Stack(
                  children: [
                    // Bottom layer
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _BtnInside(
                        height: totalHeight - top,
                        hslColor: bottomHslColor,
                        shadow: widget.shadow,
                      ),
                    ),
                    // Top layer
                    Positioned(
                      left: 0,
                      right: 0,
                      top: top,
                      child: _BtnInside(
                        height: widget.height,
                        hslColor: hslColor,
                        child: Center(
                          child: widget.child,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _BtnInside extends StatelessWidget {
  const _BtnInside({
    super.key,
    this.child,
    required this.hslColor,
    required this.height,
    this.shadow,
  });

  /// Color of the top layer
  /// The color of the bottom layer is derived by decreasing the luminosity by 0.15
  final HSLColor hslColor;

  /// height of the top layer
  final double height;

  /// An optional shadow to make the button look better
  /// This is added to the bottom layer only
  final BoxShadow? shadow;

  /// child widget (normally a Text or Icon)
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: hslColor.toColor(),
          boxShadow: shadow != null ? [shadow!] : [],
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: child,
      ),
    );
  }
}
