import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/core/widgets/day_pager.dart';
import 'package:vietnam_handbook/features/checklist/domain/entities/checklist_item.dart';
import 'package:vietnam_handbook/features/checklist/presentation/cubit/checklist_cubit.dart';
import 'package:vietnam_handbook/injection.dart';

class ChecklistPage extends StatelessWidget {
  const ChecklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChecklistCubit>()..init(),
      child: const _ChecklistView(),
    );
  }
}

class _ChecklistView extends StatelessWidget {
  const _ChecklistView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistCubit, ChecklistState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Daily checklist'),
            actions: [
              IconButton(
                tooltip: state.isReordering
                    ? 'Done reordering'
                    : 'Reorder items',
                isSelected: state.isReordering,
                icon: Icon(
                  state.isReordering
                      ? LucideIcons.check
                      : LucideIcons.listOrdered,
                ),
                onPressed: state.isLoading
                    ? null
                    : () => context.read<ChecklistCubit>().toggleReorderMode(),
              ),
            ],
          ),
          floatingActionButton: state.isReordering
              ? null
              : FloatingActionButton(
                  onPressed: () => _showEditSheet(context),
                  child: const Icon(LucideIcons.plus),
                ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : DayPager(
                  initialDay: state.currentDay,
                  pagePhysics: state.isReordering
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  onDayChanged: (day) =>
                      context.read<ChecklistCubit>().setDay(day),
                  builder: (context, day) {
                    final items =
                        state.items.where((e) => e.day == day).toList()
                          ..sort((a, b) => a.order.compareTo(b.order));
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          state.isReordering
                              ? 'Nothing to reorder on Day $day.'
                              : 'No items for Day $day.\nTap + to add one.',
                          textAlign: TextAlign.center,
                          style: ShadTheme.of(context).textTheme.muted,
                        ),
                      );
                    }
                    if (state.isReordering) {
                      return ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        buildDefaultDragHandles: false,
                        itemCount: items.length,
                        onReorder: (oldIndex, newIndex) => context
                            .read<ChecklistCubit>()
                            .reorder(oldIndex, newIndex),
                        proxyDecorator: (child, index, animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, _) {
                              return Material(
                                elevation: 2 * animation.value,
                                color: Colors.transparent,
                                child: child,
                              );
                            },
                          );
                        },
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Padding(
                            key: ValueKey(item.id),
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ChecklistTile(
                              item: item,
                              index: index,
                              reordering: true,
                            ),
                          );
                        },
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _ChecklistTile(item: item, index: index);
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.item,
    required this.index,
    this.reordering = false,
  });

  final ChecklistItem item;
  final int index;
  final bool reordering;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final title = Text(
      item.title,
      style: theme.textTheme.p.copyWith(
        decoration: item.done ? TextDecoration.lineThrough : null,
        color: item.done
            ? theme.colorScheme.mutedForeground
            : theme.colorScheme.foreground,
      ),
    );

    return ShadCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (reordering) ...[
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  LucideIcons.gripVertical,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            Expanded(child: title),
          ] else ...[
            ShadCheckbox(
              value: item.done,
              onChanged: (_) => context.read<ChecklistCubit>().toggle(item),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.read<ChecklistCubit>().toggle(item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: title,
                ),
              ),
            ),
            ShadIconButton.ghost(
              icon: const Icon(LucideIcons.pencil, size: 18),
              onPressed: () => _showEditSheet(context, item: item),
            ),
            ShadIconButton.ghost(
              icon: const Icon(LucideIcons.trash2, size: 18),
              onPressed: () => context.read<ChecklistCubit>().remove(item.id),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _showEditSheet(BuildContext context, {ChecklistItem? item}) async {
  final ctrl = TextEditingController(text: item?.title ?? '');
  final cubit = context.read<ChecklistCubit>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item == null ? 'Add checklist item' : 'Edit item',
              style: ShadTheme.of(ctx).textTheme.h4,
            ),
            const SizedBox(height: 12),
            ShadInput(
              controller: ctrl,
              placeholder: const Text('What do you need to do?'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            ShadButton(
              onPressed: () {
                if (item == null) {
                  cubit.add(ctrl.text);
                } else {
                  cubit.edit(item, ctrl.text);
                }
                Navigator.pop(ctx);
              },
              child: Text(item == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      );
    },
  );
  ctrl.dispose();
}
