import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/features/phrases/domain/entities/phrase.dart';
import 'package:vietnam_handbook/features/phrases/presentation/cubit/phrases_cubit.dart';
import 'package:vietnam_handbook/injection.dart';

class PhrasesPage extends StatelessWidget {
  const PhrasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PhrasesCubit>(),
      child: const _PhrasesView(),
    );
  }
}

class _PhrasesView extends StatelessWidget {
  const _PhrasesView();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Quick translations')),
      body: BlocBuilder<PhrasesCubit, PhrasesState>(
        builder: (context, state) {
          final grouped = state.grouped;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ShadInput(
                  placeholder: const Text('Search English or Vietnamese…'),
                  leading: const Icon(LucideIcons.search, size: 18),
                  onChanged: context.read<PhrasesCubit>().setQuery,
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: state.category == null,
                        onSelected: (_) =>
                            context.read<PhrasesCubit>().setCategory(null),
                      ),
                    ),
                    ...phraseCategories.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(c),
                          selected: state.category == c,
                          onSelected: (_) =>
                              context.read<PhrasesCubit>().setCategory(c),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: grouped.isEmpty
                    ? Center(
                        child: Text(
                          'No phrases match.',
                          style: theme.textTheme.muted,
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        children: [
                          for (final entry in grouped.entries) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 12, bottom: 8),
                              child: Text(entry.key, style: theme.textTheme.h4),
                            ),
                            ...entry.value.map(
                              (p) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ShadCard(
                                  title: Text(p.english),
                                  description: Text(p.vietnamese),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      p.pronunciation,
                                      style: theme.textTheme.muted.copyWith(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
