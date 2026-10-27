import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state.dart';
import '../theme.dart';

bool _isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

// ------------------------------------------------------------- Background

/// Gradient background with soft colored glows, sits behind the whole app.
class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [withA(color, 0.55), withA(color, 0)]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF0B1030), Color(0xFF1B1146), Color(0xFF0A2540)]
              : const [Color(0xFFE6EEFF), Color(0xFFF1E6FF), Color(0xFFDFF3FF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -90, left: -70, child: _blob(280, kViolet)),
          Positioned(bottom: 140, right: -100, child: _blob(320, kCyan)),
          Positioned(top: 260, right: -60, child: _blob(200, kPink)),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

// -------------------------------------------------------- Press animation

/// Gives any child a subtle press-scale animation and light haptic feedback.
class PressableScale extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool haptic;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.haptic = true,
  });

  @override
  ConsumerState<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends ConsumerState<PressableScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null && widget.onLongPress == null) return widget.child;
    final reduce = ref.watch(settingsProvider.select((s) => s.reduceAnim));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        if (widget.haptic) HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: (_down && !reduce) ? 0.96 : 1.0,
        duration: Duration(milliseconds: reduce ? 0 : 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// -------------------------------------------------------------- GlassCard

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<Color>? colors;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.onTap,
    this.onLongPress,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final r = BorderRadius.circular(radius);
    final card = Container(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: withA(Colors.black, dark ? 0.25 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors ??
                    (dark
                        ? [withA(Colors.white, 0.14), withA(Colors.white, 0.05)]
                        : [withA(Colors.white, 0.70), withA(Colors.white, 0.35)]),
              ),
              border: Border.all(
                color: withA(Colors.white, dark ? 0.22 : 0.85),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
    if (onTap == null && onLongPress == null) return card;
    return PressableScale(onTap: onTap, onLongPress: onLongPress, child: card);
  }
}

// ------------------------------------------------------------ GlassButton

class GlassButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool filled;
  final bool loading;
  final bool expand;

  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.filled = true,
    this.loading = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final fg = filled ? Colors.white : null;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else if (icon != null)
          Icon(icon, size: 20, color: fg),
        if (loading || icon != null) const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w700, color: fg),
          ),
        ),
      ],
    );

    final Widget body = filled
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(colors: [kViolet, kCyan]),
              boxShadow: [
                BoxShadow(
                  color: withA(kViolet, 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: content,
          )
        : GlassCard(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: content,
          );

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: PressableScale(onTap: enabled ? onPressed : null, child: body),
    );
  }
}

// --------------------------------------------------------- GlassTextField

class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int minLines;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.minLines = 1,
    this.onSubmitted,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: withA(Colors.white, dark ? 0.08 : 0.55),
        border: Border.all(color: withA(Colors.white, dark ? 0.2 : 0.8)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: minLines,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: withA(dark ? Colors.white : Colors.black, 0.45)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------- GlassBottomBar

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

class GlassBottomBar extends ConsumerWidget {
  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onTap;

  const GlassBottomBar({
    super.key,
    required this.items,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = _isDark(context);
    final reduce = ref.watch(settingsProvider.select((s) => s.reduceAnim));
    final dur = Duration(milliseconds: reduce ? 0 : 250);
    final r = BorderRadius.circular(28);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: r,
            boxShadow: [
              BoxShadow(
                color: withA(Colors.black, dark ? 0.35 : 0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: r,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: r,
                  color: withA(dark ? Colors.white : Colors.white, dark ? 0.10 : 0.6),
                  border: Border.all(
                    color: withA(Colors.white, dark ? 0.22 : 0.85),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: PressableScale(
                          onTap: () => onTap(i),
                          child: AnimatedContainer(
                            duration: dur,
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.all(6),
                            decoration: i == index
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    gradient: LinearGradient(
                                      colors: [withA(kViolet, 0.95), withA(kCyan, 0.85)],
                                    ),
                                  )
                                : const BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  items[i].icon,
                                  size: 22,
                                  color: i == index
                                      ? Colors.white
                                      : withA(dark ? Colors.white : Colors.black, 0.65),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  items[i].label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: i == index
                                        ? Colors.white
                                        : withA(dark ? Colors.white : Colors.black, 0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ Small helpers

/// Fades and slides a child in; used to stagger list items.
class FadeSlideIn extends ConsumerWidget {
  final int index;
  final Widget child;
  const FadeSlideIn({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduce = ref.watch(settingsProvider.select((s) => s.reduceAnim));
    if (reduce) return child;
    final ms = 320 + (index > 8 ? 8 : index) * 70;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 18), child: c),
      ),
      child: child,
    );
  }
}

class PageHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  const PageHeader({super.key, required this.title, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        ...actions,
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
}

/// Chip-like selectable pill.
class GlassChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const GlassChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: selected
              ? const LinearGradient(colors: [kViolet, kCyan])
              : null,
          color: selected ? null : withA(Colors.white, dark ? 0.08 : 0.55),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : withA(Colors.white, dark ? 0.2 : 0.8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}
