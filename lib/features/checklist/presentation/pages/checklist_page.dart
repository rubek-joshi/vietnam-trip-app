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
    return Scaffold(
      appBar: AppBar(title: const Text('Daily checklist')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditSheet(context),
        child: const Icon(LucideIcons.plus),
      ),
      body: BlocBuilder<ChecklistCubit, ChecklistState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return DayPager(
            initialDay: state.currentDay,
            onDayChanged: (day) => context.read<ChecklistCubit>().setDay(day),
            builder: (context, day) {
              final items = state.items
                  .where((e) => e.day == day)
                  .toList()
                ..sort((a, b) => a.order.compareTo(b.order));
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'No items for Day $day.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: ShadTheme.of(context).textTheme.muted,
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _ChecklistTile(item: item);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.item});

  final ChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ShadCheckbox(
            value: item.done,
            onChanged: (_) => context.read<ChecklistCubit>().toggle(item),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.title,
              style: theme.textTheme.p.copyWith(
                decoration: item.done ? TextDecoration.lineThrough : null,
                color: item.done
                    ? theme.colorScheme.mutedForeground
                    : theme.colorScheme.foreground,
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
