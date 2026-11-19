import 'package:flutter/material.dart';

import '../../core/di/locator.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/animal_fact.dart';
import '../../data/repositories/animals_repository.dart';
import '../widgets/common_views.dart';

/// Раздел «Животные»: поиск по названию и карточки с характеристиками.
class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  static const List<String> _suggestions = <String>[
    'cat',
    'dog',
    'lion',
    'tiger',
    'dolphin',
    'eagle',
    'fox',
  ];

  final AnimalsRepository _repository = getIt<AnimalsRepository>();
  final TextEditingController _controller = TextEditingController(text: 'cat');

  final List<AnimalFact> _results = <AnimalFact>[];
  String _query = 'cat';
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search('cat');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _error = 'Введите название животного';
        _results.clear();
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _query = trimmed;
    });
    try {
      final items = await _repository.fetchAnimals(name: trimmed);
      if (!mounted) return;
      setState(() {
        _results
          ..clear()
          ..addAll(items);
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Животное (латинское или английское название)',
              hintText: 'Например: cat, dolphin, panthera leo',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                tooltip: 'Найти',
                onPressed: _loading ? null : () => _search(_controller.text),
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ),
            onSubmitted: _search,
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: <Widget>[
              for (final name in _suggestions)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(name),
                    onPressed: _loading ? null : () => _search(name),
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView();
    if (_error != null && _results.isEmpty) {
      return ErrorView(message: _error!, onRetry: () => _search(_query));
    }
    if (_results.isEmpty) {
      return const EmptyView(
        message: 'По запросу ничего не найдено.\nПопробуйте другое название.',
        icon: Icons.pets_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _search(_query),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _results.length,
        itemBuilder: (BuildContext context, int index) =>
            _AnimalCard(fact: _results[index]),
      ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({required this.fact});

  final AnimalFact fact;

  static const Map<String, String> _taxonomyLabels = <String, String>{
    'class': 'Класс',
    'order': 'Отряд',
    'family': 'Семейство',
    'genus': 'Род',
    'scientific_name': 'Латинское название',
    'kingdom': 'Царство',
    'phylum': 'Тип',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taxonomy = <Widget>[];
    fact.taxonomy.forEach((String key, String value) {
      taxonomy.add(
        Text(
          '${_taxonomyLabels[key] ?? key}: $value',
          style: theme.textTheme.bodySmall,
        ),
      );
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(fact.name, style: theme.textTheme.titleMedium),
            if (taxonomy.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              ...taxonomy,
            ],
            if (fact.locations.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  for (final location in fact.locations)
                    Chip(
                      avatar: const Icon(Icons.place_rounded, size: 16),
                      label: Text(location),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            if (fact.characteristics.isNotEmpty)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Характеристики (${fact.characteristics.length})',
                  style: theme.textTheme.bodyMedium,
                ),
                children: <Widget>[
                  for (final entry in fact.characteristics.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.key,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(flex: 3, child: Text(entry.value)),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
