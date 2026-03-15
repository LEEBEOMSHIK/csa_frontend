import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTopBar extends StatelessWidget {
  final String title;
  final bool showBack;
  final List<Widget> actions;

  static const Color _bg = Color(0xFFFE9EC7);
  static const Color _fg = Color(0xFF333333);

  const AppTopBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _bg,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: _bg,
            height: MediaQuery.of(context).padding.top,
          ),
          Container(
            color: _bg,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (showBack)
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Icon(Icons.chevron_left,
                        color: _fg, size: 24),
                  )
                else
                  const SizedBox(width: 24),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: _fg,
                  ),
                ),
                const Spacer(),
                if (actions.isNotEmpty)
                  actions.first
                else
                  const SizedBox(width: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
