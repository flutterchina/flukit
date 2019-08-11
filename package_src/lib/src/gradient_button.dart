import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  GradientButton({
    Key key,
    this.colors,
    this.onPressed,
    this.padding,
    this.borderRadius,
    this.textColor,
    this.splashColor,
    this.disabledColor,
    this.disabledTextColor,
    this.onHighlightChanged,
    @required this.child,
  }):super(key:key);

  // 渐变色数组
  final List<Color> colors;
  final Color textColor;
  final Color splashColor;
  final Color disabledTextColor;
  final Color disabledColor;
  final EdgeInsetsGeometry padding;

  final Widget child;
  final BorderRadius borderRadius;

  final GestureTapCallback onPressed;
  final ValueChanged<bool> onHighlightChanged;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    //确保colors数组不空
    List<Color> _colors = colors ??
        [theme.primaryColor, theme.primaryColorDark ?? theme.primaryColor];
    var radius = borderRadius ?? BorderRadius.circular(2);
    bool disabled = onPressed == null;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: disabled ? null : LinearGradient(colors: _colors),
        color: disabled
            ? disabledColor ?? disabledColor ?? theme.disabledColor
            : null,
        borderRadius: radius,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
          child: InkWell(
            splashColor: splashColor ?? _colors.last,
            highlightColor: Colors.transparent,
            borderRadius: borderRadius ?? BorderRadius.circular(5),
            onHighlightChanged: onHighlightChanged,
            onTap: onPressed,
            child: Padding(
              padding: padding ?? theme.buttonTheme.padding,
              child: DefaultTextStyle(
                style: TextStyle(fontWeight: FontWeight.bold),
                child: Center(
                  child: DefaultTextStyle(
                    style: theme.textTheme.button.copyWith(
                        color: disabled
                            ? disabledTextColor ?? Colors.black38
                            : textColor ?? Colors.white),
                    child: child,
                  ),
                  widthFactor: 1,
                  heightFactor: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RaisedGradientButton extends StatefulWidget {
  RaisedGradientButton({
    Key key,
    this.colors,
    this.onPressed,
    this.padding,
    this.borderRadius,
    this.textColor,
    this.splashColor,
    this.disabledColor,
    this.disabledTextColor,
    this.onHighlightChanged,
    this.shadowColor,
    @required this.child,
  }):super(key:key);

  // 渐变色数组
  final List<Color> colors;
  final Color textColor;
  final Color splashColor;
  final Color disabledTextColor;
  final Color disabledColor;
  final Color shadowColor;
  final EdgeInsetsGeometry padding;

  final Widget child;
  final BorderRadius borderRadius;

  final GestureTapCallback onPressed;
  final ValueChanged<bool> onHighlightChanged;

  @override
  _RaisedGradientButtonState createState() => _RaisedGradientButtonState();
}

class _RaisedGradientButtonState extends State<RaisedGradientButton> {
  bool _tapDown = false;

  @override
  Widget build(BuildContext context) {
    bool disabled = widget.onPressed == null;
    return AnimatedContainer(
      duration: Duration(milliseconds: 100),
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(2),
        boxShadow: disabled
            ? null
            : [
                _tapDown
                    ? BoxShadow(
                        offset: Offset(2, 6),
                        spreadRadius: -2,
                        blurRadius: 9,
                        color: widget.shadowColor ?? Colors.black54,
                      )
                    : BoxShadow(
                        offset: Offset(0, 2),
                        spreadRadius: -2,
                        blurRadius: 3,
                        color: widget.shadowColor ?? Colors.black87,
                      )
              ],
      ),
      child: GradientButton(
        colors: widget.colors,
        onPressed: widget.onPressed,
        padding: widget.padding,
        borderRadius: widget.borderRadius,
        textColor: widget.textColor,
        splashColor: widget.splashColor,
        disabledColor: widget.disabledColor,
        disabledTextColor: widget.disabledTextColor,
        child: widget.child,
        onHighlightChanged: (v) {
          setState(() {
            _tapDown = v;
          });
          if (widget.onHighlightChanged != null) {
            widget.onHighlightChanged(v);
          }
        },
      ),
    );
  }
}
