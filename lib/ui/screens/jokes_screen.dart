import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/di/locator.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/favorites_service.dart';
import '../../data/models/favorite_entry.dart';
import '../../data/models/joke.dart';
import '../../data/repositories/jokes_repository.dart';
import '../widgets/common_views.dart';
import '../widgets/favorites.dart';

/// Раздел «Шутки»: фильтры, подгрузка, избранное.
class JokesScreen extends StatefulWidget {
  const JokesScreen({super.key});

  @override
  State<JokesScreen> createState() => _JokesScreenState();
}

class _JokesScreenState extends State<JokesScreen> {
  final JokesRepository _repository = getIt<JokesRepository>();
  final FavoritesService _favorites = getIt<FavoritesService>();

  final List<Joke> _jokes = <Joke>[];
  String _category = '';
  String _type = '';
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
      final fresh = await _repository.fetchJokes(category: _category, type: _type);
      if (!mounted) return;
      setState(() {
        if (append) {
          _jokes.addAll(fresh);
        } else {
          _jokes
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
      if (_jokes.isNotEmpty) {
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
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: DropdownButtonFormField<String>(
                  key: ValueKey<String>('category-$_category'),
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Категория'),
                  items: <DropdownMenuItem<String>>[
                    for (final category in JokesRepository.categories)
                      DropdownMenuItem<String>(
                        value: category,
                        child: Text(category.isEmpty ? 'Любая' : category),
                      ),
                  ],
                  onChanged: (String? value) {
                    setState(() => _category = value ?? '');
                    _load();
                  },
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: DropdownButtonFormField<String>(
                  key: ValueKey<String>('type-$_type'),
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Формат'),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(value: '', child: Text('Любой')),
                    DropdownMenuItem<String>(value: 'single', child: Text('Однострочные')),
                    DropdownMenuItem<String>(value: 'twopart', child: Text('Двухстрочные')),
                  ],
                  onChanged: (String? value) {
                    setState(() => _type = value ?? '');
                    _load();
                  },
                ),
              ),
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
    if (_loading && _jokes.isEmpty) return const LoadingView();
    if (_error != null && _jokes.isEmpty) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    if (_jokes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const <Widget>[
            SizedBox(height: 120),
            EmptyView(
              message: 'Шуток пока нет.\nНажмите «Ещё» или потяните вниз.',
              icon: Icons.sentiment_very_satisfied_outlined,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _jokes.length,
        itemBuilder: (BuildContext context, int index) {
          final joke = _jokes[index];
          final entry = FavoriteEntry(
            type: FavoriteEntry.jokeType,
            text: joke.text,
          );
          return Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(joke.text, style: Theme.of(context).textTheme.bodyLarge),
                  Row(
                    children: <Widget>[
                      TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: joke.text));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Шутка скопирована')),
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
