import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/core/widgets/confirm_remove_dialog.dart';
import 'package:vietnam_handbook/features/shopping/domain/entities/shopping_item.dart';
import 'package:vietnam_handbook/features/shopping/domain/shopping_text.dart';
import 'package:vietnam_handbook/features/shopping/presentation/cubit/shopping_cubit.dart';
import 'package:vietnam_handbook/injection.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ShoppingCubit>()..init(),
      child: const _ShoppingListView(),
    );
  }
}

class _ShoppingListView extends StatelessWidget {
  const _ShoppingListView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingCubit, ShoppingState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Shopping list'),
            actions: [
              IconButton(
                tooltip: state.isReordering
                    ? 'Done reordering'
                    : 'Reorder to-buy items',
                isSelected: state.isReordering,
                icon: Icon(
                  state.isReordering
                      ? LucideIcons.check
                      : LucideIcons.listOrdered,
                ),
                onPressed: state.isLoading
                    ? null
                    : () => context.read<ShoppingCubit>().toggleReorderMode(),
              ),
            ],
          ),
          floatingActionButton: state.isReordering
              ? null
              : FloatingActionButton(
                  onPressed: () => _showItemSheet(context),
                  child: const Icon(LucideIcons.plus),
                ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Check off items as you buy them. Notes can be added '
                          'on bought items.',
                          style: ShadTheme.of(context).textTheme.muted,
                        ),
                      ),
                    ),
                    _sectionHeader(context, 'To buy', state.toBuy.length),
                    if (state.toBuy.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            state.isReordering
                                ? 'Nothing to reorder.'
                                : 'Nothing to buy. Tap + to add an item.',
                            style: ShadTheme.of(context).textTheme.muted,
                          ),
                        ),
                      )
                    else if (state.isReordering)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        sliver: SliverReorderableList(
                          itemCount: state.toBuy.length,
                          onReorder: context.read<ShoppingCubit>().reorder,
                          itemBuilder: (context, index) {
                            final item = state.toBuy[index];
                            return Padding(
                              key: ValueKey(item.id),
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _ShoppingTile(
                                item: item,
                                index: index,
                                reordering: true,
                              ),
                            );
                          },
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        sliver: SliverList.separated(
                          itemCount: state.toBuy.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return _ShoppingTile(
                              item: state.toBuy[index],
                              index: index,
                            );
                          },
                        ),
                      ),
                    _sectionHeader(context, 'Bought', state.bought.length),
                    if (state.bought.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'Checked-off items show up here.',
                            style: ShadTheme.of(context).textTheme.muted,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                        sliver: SliverList.separated(
                          itemCount: state.bought.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return _ShoppingTile(
                              item: state.bought[index],
                              index: index,
                            );
                          },
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  Widget _sectionHeader(BuildContext context, String label, int count) {
    final theme = ShadTheme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Text(
          count == 0 ? label : '$label ($count)',
          style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ShoppingTile extends StatelessWidget {
  const _ShoppingTile({
    required this.item,
    required this.index,
    this.reordering = false,
  });

  final ShoppingItem item;
  final int index;
  final bool reordering;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final title = Text(
      item.title,
      style: theme.textTheme.p.copyWith(
        decoration: item.bought ? TextDecoration.lineThrough : null,
        color: item.bought
            ? theme.colorScheme.mutedForeground
            : theme.colorScheme.foreground,
      ),
    );

    return ShadCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              value: item.bought,
              checkboxPadding: EdgeInsets.zero,
              onChanged: (_) => context.read<ShoppingCubit>().toggle(item),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: item.bought
                    ? () => _showItemSheet(context, item: item)
                    : () => context.read<ShoppingCubit>().toggle(item),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    if (item.bought && item.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(item.note, style: theme.textTheme.muted),
                    ],
                  ],
                ),
              ),
            ),
            ShadIconButton.ghost(
              icon: const Icon(LucideIcons.pencil, size: 18),
              onPressed: () => _showItemSheet(context, item: item),
            ),
            ShadIconButton.ghost(
              icon: const Icon(LucideIcons.trash2, size: 18),
              onPressed: () => _confirmRemove(context, item),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _confirmRemove(BuildContext context, ShoppingItem item) async {
  final confirmed = await confirmRemove(
    context,
    description: '“${item.title}” will be deleted from your shopping list.',
  );
  if (confirmed && context.mounted) {
    await context.read<ShoppingCubit>().remove(item.id);
  }
}

Future<void> _showItemSheet(BuildContext context, {ShoppingItem? item}) async {
  final cubit = context.read<ShoppingCubit>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return _ItemSheet(item: item, cubit: cubit, toastContext: context);
    },
  );
}

class _ItemSheet extends StatefulWidget {
  const _ItemSheet({
    required this.item,
    required this.cubit,
    required this.toastContext,
  });

  final ShoppingItem? item;
  final ShoppingCubit cubit;
  final BuildContext toastContext;

  @override
  State<_ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends State<_ItemSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _noteCtrl;
  late final FocusNode _titleFocus;
  static const _titleFormatters = [_CapitalizeFirstWordFormatter()];

  bool get _isAdd => widget.item == null;
  bool get _isBought => widget.item?.bought ?? false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item?.title ?? '');
    _noteCtrl = TextEditingController(text: widget.item?.note ?? '');
    _titleFocus = FocusNode();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  void _showAddedToast(String title) {
    final toaster = ShadToaster.maybeOf(widget.toastContext);
    if (toaster == null) return;
    final theme = ShadTheme.of(widget.toastContext);
    toaster.show(
      ShadToast(
        alignment: Alignment.topCenter,
        backgroundColor: theme.colorScheme.primary,
        titleStyle: theme.textTheme.small.copyWith(
          color: theme.colorScheme.primaryForeground,
          fontWeight: FontWeight.w600,
        ),
        descriptionStyle: theme.textTheme.muted.copyWith(
          color: theme.colorScheme.primaryForeground.withValues(alpha: 0.9),
        ),
        title: const Text('Item added'),
        description: Text(title),
      ),
    );
  }

  Future<void> _submit() async {
    if (_isAdd) {
      final added = await widget.cubit.add(_titleCtrl.text);
      if (added == null || !mounted) return;
      _titleCtrl.clear();
      _titleFocus.requestFocus();
      _showAddedToast(added);
      return;
    }

    if (_isBought) {
      await widget.cubit.editBought(
        item: widget.item!,
        title: _titleCtrl.text,
        note: _noteCtrl.text,
      );
    } else {
      await widget.cubit.editTitle(widget.item!, _titleCtrl.text);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isAdd
                ? 'Add item'
                : _isBought
                ? 'Edit bought item'
                : 'Edit item',
            style: ShadTheme.of(context).textTheme.h4,
          ),
          const SizedBox(height: 12),
          ShadInput(
            controller: _titleCtrl,
            focusNode: _titleFocus,
            placeholder: const Text('What do you need?'),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: _isAdd
                ? TextInputAction.next
                : TextInputAction.done,
            inputFormatters: _titleFormatters,
            onSubmitted: (_) => _submit(),
          ),
          if (_isBought) ...[
            const SizedBox(height: 12),
            ShadTextarea(
              controller: _noteCtrl,
              placeholder: const Text('Note (price, stall, size…)'),
            ),
          ],
          const SizedBox(height: 12),
          ShadButton(onPressed: _submit, child: Text(_isAdd ? 'Add' : 'Save')),
        ],
      ),
    );
  }
}

class _CapitalizeFirstWordFormatter extends TextInputFormatter {
  const _CapitalizeFirstWordFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final capitalized = capitalizeFirstWord(newValue.text);
    if (capitalized == newValue.text) return newValue;
    return newValue.copyWith(text: capitalized);
  }
}
