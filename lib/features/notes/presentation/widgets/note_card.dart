import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/features/notes/domain/entities/vietnam_note.dart';

enum _NoteTransitionKind { flip, slide }

class NoteCard extends StatefulWidget {
  const NoteCard({
    required this.note,
    required this.equivalent,
    super.key,
  });

  final VietnamNote note;
  final NoteEquivalent equivalent;

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 420);

  late final AnimationController _controller;
  var _index = 0;
  var _outgoingIndex = 0;
  var _direction = 1;
  _NoteTransitionKind _kind = _NoteTransitionKind.flip;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _shift(int delta) async {
    if (_controller.isAnimating || widget.note.variations.length < 2) {
      return;
    }

    final count = widget.note.variations.length;
    var nextIndex = (_index + delta) % count;
    if (nextIndex < 0) {
      nextIndex += count;
    }

    final from = widget.note.variations[_index];
    final to = widget.note.variations[nextIndex];
    final kind = from.series == to.series && from.side != to.side
        ? _NoteTransitionKind.flip
        : _NoteTransitionKind.slide;

    setState(() {
      _outgoingIndex = _index;
      _index = nextIndex;
      _direction = delta >= 0 ? 1 : -1;
      _kind = kind;
    });

    await _controller.forward(from: 0);
    if (!mounted) return;
    _controller.value = 0;
    setState(() {});
  }

  Widget _buildImage(NoteVariation variation, ShadThemeData theme) {
    return Image.asset(
      variation.imageUrl,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Could not load note image.',
              textAlign: TextAlign.center,
              style: theme.textTheme.muted,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedImage(Color background, ShadThemeData theme) {
    final variations = widget.note.variations;
    final incoming = variations[_index];

    if (!_controller.isAnimating && _controller.value == 0) {
      return ColoredBox(
        color: background,
        child: _buildImage(incoming, theme),
      );
    }

    final outgoing = variations[_outgoingIndex];
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_kind == _NoteTransitionKind.flip) {
          return _buildFlip(background, outgoing, incoming, theme);
        }
        return _buildSlide(background, outgoing, incoming, theme);
      },
    );
  }

  Widget _buildFlip(
    Color background,
    NoteVariation outgoing,
    NoteVariation incoming,
    ShadThemeData theme,
  ) {
    final t = Curves.easeInOut.transform(_controller.value);
    final angle = _direction * t * math.pi;
    final showOutgoing = t < 0.5;
    final displayAngle = showOutgoing ? angle : angle - (_direction * math.pi);

    return ColoredBox(
      color: background,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateY(displayAngle),
        child: _buildImage(showOutgoing ? outgoing : incoming, theme),
      ),
    );
  }

  Widget _buildSlide(
    Color background,
    NoteVariation outgoing,
    NoteVariation incoming,
    ShadThemeData theme,
  ) {
    final t = Curves.easeInOut.transform(_controller.value);

    return ColoredBox(
      color: background,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            FractionalTranslation(
              translation: Offset(-_direction * t, 0),
              child: _buildImage(outgoing, theme),
            ),
            FractionalTranslation(
              translation: Offset(_direction * (1 - t), 0),
              child: _buildImage(incoming, theme),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final variation = widget.note.variations[_index];
    final hasMultiple = widget.note.variations.length > 1;

    return ShadCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.note.title, style: theme.textTheme.h4),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 2.3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildAnimatedImage(theme.colorScheme.muted, theme),
            ),
          ),
          if (hasMultiple) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ShadIconButton.ghost(
                  icon: const Icon(LucideIcons.chevronLeft, size: 22),
                  onPressed: () => _shift(-1),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      variation.label,
                      key: ValueKey(variation.label),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.small,
                    ),
                  ),
                ),
                ShadIconButton.ghost(
                  icon: const Icon(LucideIcons.chevronRight, size: 22),
                  onPressed: () => _shift(1),
                ),
              ],
            ),
            Text(
              '${_index + 1} of ${widget.note.variations.length}',
              textAlign: TextAlign.center,
              style: theme.textTheme.muted,
            ),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              variation.label,
              textAlign: TextAlign.center,
              style: theme.textTheme.small,
            ),
          ],
          const SizedBox(height: 14),
          Text(widget.equivalent.usdText, style: theme.textTheme.h4),
          const SizedBox(height: 4),
          Text(widget.equivalent.nprText, style: theme.textTheme.h4),
          const SizedBox(height: 4),
          Text('from current FX rates', style: theme.textTheme.muted),
        ],
      ),
    );
  }
}
