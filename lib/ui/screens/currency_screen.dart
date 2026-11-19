import 'package:flutter/material.dart';

import '../../core/di/locator.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/currency_rate.dart';
import '../../data/repositories/currency_repository.dart';
import '../widgets/common_views.dart';

/// Раздел «Курсы валют»: базовая валюта, сумма, список конвертаций.
class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  /// Коды валют с названиями (поддерживаемые бесплатным тарифом API Ninjas).
  static const Map<String, String> currencies = <String, String>{
    'USD': 'Доллар США',
    'EUR': 'Евро',
    'RUB': 'Российский рубль',
    'CNY': 'Юань',
    'GBP': 'Фунт стерлингов',
    'JPY': 'Японская иена',
    'TRY': 'Турецкая лира',
    'KZT': 'Казахстанский тенге',
    'BYN': 'Белорусский рубль',
    'UAH': 'Украинская гривна',
    'CHF': 'Швейцарский франк',
    'CAD': 'Канадский доллар',
    'AUD': 'Австралийский доллар',
    'AED': 'Дирхам ОАЭ',
    'INR': 'Индийская рупия',
    'HKD': 'Гонконгский доллар',
    'KRW': 'Южнокорейская вона',
    'BRL': 'Бразильский реал',
  };

  /// Порядок, в котором валюты показываются в списке.
  static const List<String> preferredTargets = <String>[
    'USD',
    'EUR',
    'RUB',
    'CNY',
    'GBP',
    'JPY',
    'TRY',
    'KZT',
    'BYN',
    'UAH',
    'CHF',
    'AED',
    'INR',
    'HKD',
    'KRW',
    'BRL',
    'CAD',
    'AUD',
  ];

  final CurrencyRepository _repository = getIt<CurrencyRepository>();
  final TextEditingController _amountController =
      TextEditingController(text: '100');

  String _base = 'USD';
  double _amount = 100;
  List<CurrencyRate> _rates = <CurrencyRate>[];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  List<String> get _targets => preferredTargets
      .where((String code) => code != _base && currencies.containsKey(code))
      .take(9)
      .toList();

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rates = await _repository.fetchRates(base: _base, targets: _targets);
      if (!mounted) return;
      setState(() {
        _rates = rates;
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

  Future<void> _submitAmount() async {
    final parsed = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );
    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректную сумму')),
      );
      return;
    }
    setState(() => _amount = parsed);
  }

  void _swapBase(String code) {
    setState(() {
      _base = code;
      _rates = <CurrencyRate>[];
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey<String>('base-$_base'),
                  initialValue: _base,
                  decoration: const InputDecoration(labelText: 'Базовая валюта'),
                  items: <DropdownMenuItem<String>>[
                    for (final code in preferredTargets)
                      if (currencies.containsKey(code))
                        DropdownMenuItem<String>(
                          value: code,
                          child: Text('$code — ${currencies[code]}'),
                        ),
                  ],
                  onChanged: (String? value) {
                    if (value == null || value == _base) return;
                    _swapBase(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Сумма'),
                  onSubmitted: (_) => _submitAmount(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: <Widget>[
              Text('1 $_base = …', style: theme.textTheme.bodySmall),
              const Spacer(),
              TextButton.icon(
                onPressed: _loading ? null : _submitAmount,
                icon: const Icon(Icons.calculate_rounded, size: 18),
                label: const Text('Пересчитать'),
              ),
              const SizedBox(width: 4),
              IconButton.outlined(
                tooltip: 'Обновить курсы',
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        if (_rates.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Курсы обновляются раз в сутки (бесплатный тариф). '
              'Нажатие на стрелку меняет базовую валюту.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 4),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading && _rates.isEmpty) return const LoadingView();
    if (_error != null && _rates.isEmpty) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    if (_rates.isEmpty) {
      return const EmptyView(
        message: 'Курсы пока не загружены',
        icon: Icons.currency_exchange_outlined,
      );
    }

    final appliedAt = _rates.first.appliedAt;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _rates.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Обновлено: ${_formatDate(appliedAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }

          final rate = _rates[index - 1];
          final converted = rate.rate * _amount;

          return Card(
            child: ListTile(
              title: Text('${rate.target} — ${currencies[rate.target] ?? ''}'),
              subtitle: Text(
                '1 ${rate.base} = ${rate.rate.toStringAsFixed(4)} ${rate.target}\n'
                '$_amount ${rate.base} = ${converted.toStringAsFixed(2)} ${rate.target}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                tooltip: 'Сделать базовой валютой',
                onPressed: _loading ? null : () => _swapBase(rate.target),
                icon: const Icon(Icons.swap_horiz_rounded),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)}.${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
