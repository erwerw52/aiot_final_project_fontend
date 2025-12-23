import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration characterDelay; // 每個字符出現的間隔時間

  const WaveText({
    super.key,
    required this.text,
    this.style,
    this.characterDelay = const Duration(milliseconds: 200), // 預設 0.2 秒
  });

  @override
  State<WaveText> createState() => _WaveTextState();
}

class _WaveTextState extends State<WaveText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 總動畫時長 = 字符數量 × 每個字符的延遲 + 額外的彈跳時間
    final totalDuration = widget.characterDelay * widget.text.length + 
                          const Duration(milliseconds: 100);
    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            widget.text.length,
            (index) {
              final char = widget.text[index];
              
              // 計算每個字符的出場時間（0-1之間）
              final charAppearTime = index / widget.text.length;
              final progress = _controller.value;
              
              // 如果還沒到這個字符的出場時間，隱藏它
              if (progress < charAppearTime) {
                return Opacity(
                  opacity: 0,
                  child: Text(char, style: widget.style),
                );
              }
              
              // 計算彈跳動畫（出場後的0.2秒內彈跳）
              final bounceProgress = ((progress - charAppearTime) * widget.text.length).clamp(0.0, 1.0);
              final bounce = bounceProgress < 1.0
                  ? math.sin(bounceProgress * math.pi).abs() * 6 // 彈跳高度6像素
                  : 0.0; // 彈跳完成後保持穩定
              
              return Transform.translate(
                offset: Offset(0, -bounce),
                child: Opacity(
                  opacity: bounceProgress > 0 ? 1.0 : 0.0,
                  child: Text(
                    char,
                    style: widget.style,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
