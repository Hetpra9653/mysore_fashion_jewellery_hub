import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;

  const ExpandableText({
    Key? key,
    required this.text,
    required this.style,
    this.maxLines = 2,
  }) : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.text,
            style: widget.style,
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.justify,
          ),
          secondChild: Text(
            widget.text,
            style: widget.style,
            textAlign: TextAlign.justify,
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (_needsShowMore())
          GestureDetector(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _expanded ? 'Show less' : 'Show more',

                style: widget.style.copyWith(
                  color: AppColors.logoBlueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _needsShowMore() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width * 0.9);

    return textPainter.didExceedMaxLines;
  }
}
