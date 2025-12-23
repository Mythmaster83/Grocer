import 'package:flutter/material.dart';
import '../utils/text_style_helper.dart';

/// A widget that displays text with an expand/collapse feature
/// Only shows expand button if text actually overflows
class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;

  const ExpandableText({
    super.key,
    required this.text,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;
  bool _needsExpansion = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Create a TextPainter to measure if text overflows
        final textPainter = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: widget.style ?? TextStyleHelper.body(),
          ),
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);
        
        // Check if text overflows
        final doesOverflow = textPainter.didExceedMaxLines;
        
        // Update needsExpansion flag
        if (doesOverflow != _needsExpansion) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _needsExpansion = doesOverflow;
              });
            }
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.text,
                    style: widget.style ?? TextStyleHelper.body(),
                    maxLines: _isExpanded ? null : widget.maxLines,
                    overflow: _isExpanded ? TextOverflow.visible : widget.overflow,
                    textAlign: widget.textAlign,
                  ),
                ),
                if (_needsExpansion)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

