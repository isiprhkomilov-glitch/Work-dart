import 'package:flutter/material.dart';

import '../../core/di/locator.dart';
import '../../core/services/favorites_service.dart';
import '../../data/models/favorite_entry.dart';
import '../widgets/common_views.dart';

/// Экран «Избранное»: сохранённые шутки и цитаты.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _service = getIt<FavoritesService>();

  @override
  Widget build(BuildContext context) {
    final entries = _service.entries;

    if (entries.isEmpty) {
      return const EmptyView(
        message: 'Здесь пока пусто.\nОтмечайте шутки и цитаты звёздочкой.',
        icon: Icons.star_border_rounded,
      );
    }

    return ListenableBuilder(
      listenable: _service,
      builder: (BuildContext context, _) {
        final items = _service.entries;
        if (items.isEmpty) {
          return const EmptyView(
            message: 'Здесь пока пусто.\nОтмечайте шутки и цитаты звёздочкой.',
            icon: Icons.star_border_rounded,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            final entry = items[index];
            final isQuote = entry.type == FavoriteEntry.quoteType;

            return Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 4, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Chip(
                          avatar: Icon(
                            isQuote
                                ? Icons.format_quote_rounded
                                : Icons.sentiment_very_satisfied_rounded,
                            size: 16,
                          ),
                          label: Text(isQuote ? 'Цитата' : 'Шутка'),
                          visualDensity: VisualDensity.compact,
                        ),
                        if (entry.category.isNotEmpty) ...<Widget>[
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(entry.category),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                        const Spacer(),
                        IconButton(
                          tooltip: 'Удалить из избранного',
                          onPressed: () => _service.remove(entry.encode()),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isQuote ? '«${entry.text}»' : entry.text,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (entry.author.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          entry.author,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
