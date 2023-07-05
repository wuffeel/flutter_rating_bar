import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A widget to display rating as assigned using [rating] property.
///
/// This is a read only version of [RatingBar].
///
/// Use [RatingBar], if interactive version is required.
/// i.e. if user input is required.
class RatingBarIndicator extends StatefulWidget {
  const RatingBarIndicator({
    Key? key,
    required this.filledItem,
    required this.fillStroke,
    this.disabledStroke,
    this.clipFillStroke = false,
    this.textDirection,
    this.unratedColor,
    this.direction = Axis.horizontal,
    this.itemCount = 5,
    this.itemPadding = EdgeInsets.zero,
    this.itemSize = 40.0,
    this.physics = const NeverScrollableScrollPhysics(),
    this.rating = 0.0,
  }) : super(key: key);

  /// Filled svg item that for full number rating
  final SvgPicture filledItem;

  /// Filled svg item stroke to wrap [filledItem]
  final SvgPicture fillStroke;

  /// Stroke that shows unfilled rating. If not provided, [fillStroke] will be
  /// used
  final SvgPicture? disabledStroke;

  /// Whether filledItem with not full rating should be stroked with
  /// [fillStroke] or with clipped [disabledStroke]
  final bool clipFillStroke;

  /// {@macro flutterRatingBar.textDirection}
  final TextDirection? textDirection;

  /// {@macro flutterRatingBar.unratedColor}
  final Color? unratedColor;

  /// {@macro flutterRatingBar.direction}
  final Axis direction;

  /// {@macro flutterRatingBar.itemCount}
  final int itemCount;

  /// {@macro flutterRatingBar.itemPadding}
  final EdgeInsets itemPadding;

  /// {@macro flutterRatingBar.itemSize}
  final double itemSize;

  /// Controls the scrolling behaviour of rating bar.
  ///
  /// Default is [NeverScrollableScrollPhysics].
  final ScrollPhysics physics;

  /// Defines the rating value for indicator.
  ///
  /// Default is 0.0
  final double rating;

  @override
  State<RatingBarIndicator> createState() => _RatingBarIndicatorState();
}

class _RatingBarIndicatorState extends State<RatingBarIndicator> {
  late int _ratingNumber = widget.rating.truncate() + 1;
  late double _ratingFraction = widget.rating - _ratingNumber + 1;
  bool _isRTL = false;

  @override
  Widget build(BuildContext context) {
    final textDirection = widget.textDirection ?? Directionality.of(context);
    _isRTL = textDirection == TextDirection.rtl;
    _ratingNumber = widget.rating.truncate() + 1;
    _ratingFraction = widget.rating - _ratingNumber + 1;
    return SingleChildScrollView(
      scrollDirection: widget.direction,
      physics: widget.physics,
      child: widget.direction == Axis.horizontal
          ? Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: textDirection,
              children: _children,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              textDirection: textDirection,
              children: _children,
            ),
    );
  }

  List<Widget> get _children {
    return List.generate(
      widget.itemCount,
      (index) {
        if (widget.textDirection != null) {
          if (widget.textDirection == TextDirection.rtl &&
              Directionality.of(context) != TextDirection.rtl) {
            return Transform(
              transform: Matrix4.identity()..scale(-1.0, 1, 1),
              alignment: Alignment.center,
              transformHitTests: false,
              child: _buildItems(index),
            );
          }
        }
        return _buildItems(index);
      },
    );
  }

  Widget _buildItems(int index) {
    return Padding(
      padding: widget.itemPadding,
      child: SizedBox(
        width: widget.itemSize,
        height: widget.itemSize,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              child: index + 1 < _ratingNumber
                  ? widget.filledItem
                  : index + 1 != _ratingNumber || widget.clipFillStroke
                      ? widget.disabledStroke ?? widget.fillStroke
                      : null,
            ),
            if (index + 1 == _ratingNumber) ...[
              if (widget.clipFillStroke)
                FittedBox(
                  child: ClipRect(
                    clipper: _IndicatorClipper(
                      ratingFraction: _ratingFraction,
                      rtlMode: _isRTL,
                    ),
                    child: widget.disabledStroke ?? widget.fillStroke,
                  ),
                )
              else
                FittedBox(
                  child: widget.fillStroke,
                ),
              FittedBox(
                child: ClipRect(
                  clipper: _IndicatorClipper(
                    ratingFraction: _ratingFraction,
                    rtlMode: _isRTL,
                  ),
                  child: widget.filledItem,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _IndicatorClipper extends CustomClipper<Rect> {
  _IndicatorClipper({
    required this.ratingFraction,
    this.rtlMode = false,
  });

  final double ratingFraction;
  final bool rtlMode;

  @override
  Rect getClip(Size size) {
    return rtlMode
        ? Rect.fromLTRB(
            size.width - size.width * ratingFraction,
            0,
            size.width,
            size.height,
          )
        : Rect.fromLTRB(
            0,
            0,
            size.width * ratingFraction,
            size.height,
          );
  }

  @override
  bool shouldReclip(_IndicatorClipper oldClipper) {
    return ratingFraction != oldClipper.ratingFraction ||
        rtlMode != oldClipper.rtlMode;
  }
}
