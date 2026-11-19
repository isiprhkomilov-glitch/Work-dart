import 'package:flutter/material.dart';

import '../../core/di/locator.dart';
import '../../core/storage/app_storage.dart';
import 'animals_screen.dart';
import 'currency_screen.dart';
import 'favorites_screen.dart';
import 'jokes_screen.dart';
import 'quotes_screen.dart';
import 'settings_screen.dart';
import 'weather_screen.dart';

/// Главный экран: боковое меню и разделы приложения.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const List<_Destination> _destinations = <_Destination>[
    _Destination('Шутки', Icons.sentiment_very_satisfied_rounded, JokesScreen()),
    _Destination('Цитаты', Icons.format_quote_rounded, QuotesScreen()),
    _Destination('Животные', Icons.pets_rounded, AnimalsScreen()),
    _Destination('Курсы валют', Icons.currency_exchange_rounded, CurrencyScreen()),
    _Destination('Погода', Icons.wb_sunny_rounded, WeatherScreen()),
    _Destination('Избранное', Icons.star_rounded, FavoritesScreen()),
    _Destination('Настройки', Icons.settings_rounded, null),
  ];

  @override
  Widget build(BuildContext context) {
    final storage = getIt<AppStorage>();
    final current = _destinations[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text(current.title),
        centerTitle: false,
      ),
      drawer: NavigationDrawer(
        selectedIndex: _index,
        onDestinationSelected: (int value) => setState(() => _index = value),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.api_rounded, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Работа с сетью',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'API Ninjas · Dio · get_it\nТокен: ${storage.maskedToken}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(indent: 28, endIndent: 28),
          for (var i = 0; i < _destinations.length; i++)
            NavigationDrawerDestination(
              icon: Icon(_destinations[i].icon),
              label: Text(_destinations[i].title),
            ),
          const SizedBox(height: 12),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          for (var i = 0; i < _destinations.length; i++)
            i == _destinations.length - 1
                ? SettingsScreen(onTokenSaved: () => setState(() {}))
                : _destinations[i].screen!,
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination(this.title, this.icon, this.screen);

  final String title;
  final IconData icon;
  final Widget? screen;
}
