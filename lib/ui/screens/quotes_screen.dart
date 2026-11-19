import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/di/locator.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/favorites_service.dart';
import '../../data/models/favorite_entry.dart';
import '../../data/models/quote.dart';
import '../../data/repositories/quotes_repository.dart';
import '../widgets/common_views.dart';
import '../widgets/favorites.dart';

/// Раздел «Цитаты»: случайные цитаты, подгрузка, избранное.
class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final QuotesRepository _repository = getIt<QuotesRepository>();
  final FavoritesService _favorites = getIt<FavoritesService>();

  final List<Quote> _quotes = <Quote>[];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool append = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fresh = await _repository.fetchQuotes();
      if (!mounted) return;
      setState(() {
        if (append) {
          _quotes.addAll(fresh);
        } else {
          _quotes
            ..clear()
            ..addAll(fresh);
        }
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
      if (_quotes.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Неизвестная ошибка: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        HintCard(
          child: Row(
            children: <Widget>[
              const Icon(Icons.format_quote_rounded),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Случайные цитаты. Новая партия — по кнопке «Ещё».'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _loading ? null : () => _load(append: true),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ещё'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading && _quotes.isEmpty) return const LoadingView();
    if (_error != null && _quotes.isEmpty) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    if (_quotes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const <Widget>[
            SizedBox(height: 120),
            EmptyView(
              message: 'Цитат пока нет.\nНажмите «Ещё» или потяните вниз.',
              icon: Icons.format_quote_outlined,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _quotes.length,
        itemBuilder: (BuildContext context, int index) {
          final quote = _quotes[index];
          final entry = FavoriteEntry(
            type: FavoriteEntry.quoteType,
            text: quote.text,
            author: quote.author,
            category: quote.category,
          );
          return Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 4, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '«${quote.text}»',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          quote.author.isEmpty ? 'Автор не указан' : quote.author,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ),
                      if (quote.category.isNotEmpty)
                        Chip(
                          label: Text(quote.category),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: '${quote.text} — ${quote.author}'),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Цитата скопирована')),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Копировать'),
                      ),
                      const Spacer(),
                      FavoriteButton(service: _favorites, entry: entry),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
