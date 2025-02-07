import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class ConfirmationSlider extends StatefulWidget {
  /// Height of the slider. Defaults to 70.
  final double height;

  /// Width of the slider. Defaults to 300.
  final double width;

  /// The color of the background of the slider. Defaults to Colors.white.
  final Color backgroundColor;

  /// The color of the background of the slider when it has been slide to the end. By giving a value here, the background color
  /// will gradually change from backgroundColor to backgroundColorEnd when the user slides. Is not used by default.
  final Color? backgroundColorEnd;

  /// The color of the moving element of the slider. Defaults to Colors.blueAccent.
  final Color foregroundColor;

  /// The color of the icon on the moving element if icon is IconData. Defaults to Colors.white.
  final Color iconColor;

  /// The button widget used on the moving element of the slider. Defaults to Icon(Icons.chevron_right).
  final Widget sliderButtonContent;

  /// The shadow below the slider. Defaults to BoxShadow(color: Colors.black38, offset: Offset(0, 2),blurRadius: 2,spreadRadius: 0,).
  final BoxShadow? shadow;

  /// The text showed below the foreground. Used to specify the functionality to the user. Defaults to "Slide to confirm".
  final String text;

  /// The style of the text. Defaults to TextStyle(color: Colors.black26, fontWeight: FontWeight.bold,).
  final TextStyle? textStyle;

  /// The callback when slider is completed. This is the only required field.
  final VoidCallback onConfirmation;

  /// The callback when slider is pressed.
  final VoidCallback? onTapDown;

  /// The callback when slider is release.
  final VoidCallback? onTapUp;

  /// The callback when slide is moving.
  final VoidCallback? onPanUpdate;

  /// The shape of the moving element of the slider. Defaults to a circular border radius
  final BorderRadius? foregroundShape;

  /// The shape of the background of the slider. Defaults to a circular border radius
  final BorderRadius? backgroundShape;

  /// Stick the slider to the end
  final bool stickToEnd;

  /// Widget to show in the background of the slider text area 
  final Widget? bgText;

  /// Flag to indicate if has to show a background animation (two arrows moving from left to right)
  final bool showBgAnimation;

  /// Color of the background animation (if showed)
  final Color? bgAnimationColor;

  const ConfirmationSlider({
    Key? key,
    this.height = 70,
    this.width = 300,
    this.backgroundColor = Colors.white,
    this.backgroundColorEnd,
    this.foregroundColor = Colors.blueAccent,
    this.iconColor = Colors.white,
    this.shadow,
    this.sliderButtonContent = const Icon(
      Icons.chevron_right,
      color: Colors.white,
      size: 35,
    ),
    this.text = "Slide to confirm",
    this.textStyle,
    required this.onConfirmation,
    this.onTapDown,
    this.onTapUp,
    this.onPanUpdate,
    this.foregroundShape,
    this.backgroundShape,
    this.stickToEnd = false,
    this.bgText,
    this.showBgAnimation = false,
    this.bgAnimationColor,
  }) : assert(height >= 25 && width >= 250);

  @override
  State<StatefulWidget> createState() {
    return ConfirmationSliderState();
  }
}

class ConfirmationSliderState extends State<ConfirmationSlider> {
  double _position = 0;
  int _duration = 0;

  double getPosition() {
    if (_position < 0) {
      return 0;
    } else if (_position > widget.width - widget.height) {
      return widget.width - widget.height;
    } else {
      return _position;
    }
  }

  void updatePosition(details) {
    if (details is DragEndDetails) {
      setState(() {
        _duration = 600;
        if (widget.stickToEnd && _position > widget.width - widget.height) {
          _position = widget.width - widget.height;
        } else {
          _position = 0;
        }
      });
    } else if (details is DragUpdateDetails) {
      setState(() {
        _duration = 0;
        _position = details.localPosition.dx - (widget.height / 2);
      });
    }
  }

  void sliderReleased(details) {
    if (_position > widget.width - widget.height) {
      widget.onConfirmation();
    }
    updatePosition(details);
  }

  Color calculateBackground() {
    if (widget.backgroundColorEnd != null) {
      double percent;

      // calculates the percentage of the position of the slider
      if (_position > widget.width - widget.height) {
        percent = 1.0;
      } else if (_position / (widget.width - widget.height) > 0) {
        percent = _position / (widget.width - widget.height);
      } else {
        percent = 0.0;
      }

      int red = widget.backgroundColorEnd!.red;
      int green = widget.backgroundColorEnd!.green;
      int blue = widget.backgroundColorEnd!.blue;

      return Color.alphaBlend(
          Color.fromRGBO(red, green, blue, percent), widget.backgroundColor);
    } else {
      return widget.backgroundColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    BoxShadow shadow;
    if (widget.shadow == null) {
      shadow = BoxShadow(
        color: Colors.black38,
        offset: Offset(0, 2),
        blurRadius: 2,
        spreadRadius: 0,
      );
    } else {
      shadow = widget.shadow!;
    }

    TextStyle style;
    if (widget.textStyle == null) {
      style = TextStyle(
        color: Colors.black26,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = widget.textStyle!;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: _duration),
      curve: Curves.ease,
      height: widget.height,
      width: widget.width,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: widget.backgroundShape ??
            BorderRadius.all(Radius.circular(widget.height)),
        color: widget.backgroundColorEnd != null
            ? this.calculateBackground()
            : widget.backgroundColor,
        boxShadow: <BoxShadow>[shadow],
      ),
      child: Stack(
        children: <Widget>[
          if (widget.bgText != null)
            Center(child: widget.bgText!),

          if (widget.showBgAnimation)
            _bgAnimation(context),

          Positioned(
            left: widget.height - 10, // 10 is the padding of the container
            height: widget.height - 10,
            width: widget.width - widget.height - 10,
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  widget.text,
                  style: style,
                  textAlign: TextAlign.center,
                )),
          ),
          
          Positioned(
            left: widget.height / 2,
            child: AnimatedContainer(
              height: widget.height - 10,
              width: getPosition(),
              duration: Duration(milliseconds: _duration),
              curve: Curves.ease,
              decoration: BoxDecoration(
                borderRadius: widget.backgroundShape ??
                    BorderRadius.all(Radius.circular(widget.height)),
                color: widget.backgroundColorEnd != null
                    ? this.calculateBackground()
                    : widget.backgroundColor,
              ),
            ),
          ),

          AnimatedPositioned(
            duration: Duration(milliseconds: _duration),
            curve: Curves.bounceOut,
            left: getPosition(),
            top: 0,
            child: GestureDetector(
              onTapDown: (_) =>
                  widget.onTapDown != null ? widget.onTapDown!() : null,
              onTapUp: (_) => widget.onTapUp != null ? widget.onTapUp!() : null,
              onPanUpdate: (details) {
                if (widget.onPanUpdate != null) {
                  widget.onPanUpdate!();
                }
                updatePosition(details);
              },
              onPanEnd: (details) {
                if (widget.onTapUp != null) widget.onTapUp!();
                sliderReleased(details);
              },
              child: Container(
                height: widget.height - 10,
                width: widget.height - 10,
                decoration: BoxDecoration(
                  borderRadius: widget.foregroundShape ??
                      BorderRadius.all(Radius.circular(widget.height / 2)),
                  color: widget.foregroundColor,
                ),
                child: widget.sliderButtonContent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bgAnimation(BuildContext context) => Stack(children: [
    _activateBg(MediaQuery.of(context).size, 0), //First arrow
    _activateBg(MediaQuery.of(context).size, 16) //Second arrow
  ]);

  Widget _activateBg(Size size, double padding) {
    var bgSize = widget.width - 72;
    return LoopAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 12 + padding, 
        end: bgSize + padding
      ),
      curve: Curves.easeInOut,
      duration: const Duration(seconds: 3, milliseconds: 200),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 60,
            color: widget.bgAnimationColor ?? Color(0xddfdc33b),
          )
        );
      }
    );
  }
}
