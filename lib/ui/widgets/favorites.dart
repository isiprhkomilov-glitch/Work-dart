import 'package:flutter/material.dart';

import '../../core/services/favorites_service.dart';
import '../../data/models/favorite_entry.dart';

/// Звезда «в избранном» для карточек.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.service,
    required this.entry,
  });

  final FavoritesService service;
  final FavoriteEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (BuildContext context, _) {
        final selected = service.contains(entry);
        return IconButton(
          tooltip: selected ? 'Убрать из избранного' : 'В избранное',
          onPressed: () => service.toggle(entry),
          icon: Icon(
            selected ? Icons.star_rounded : Icons.star_border_rounded,
            color: selected ? Colors.amber.shade700 : null,
          ),
        );
      },
    );
  }
}
