import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../core/zakat/zakat_calculator.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/app_surfaces.dart';

/// Zakat and fitra for Bangladesh: BDT, gold by karat in vori or gram,
/// mobile banking and savings certificates, prices entered by the user.
class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _Karat {
  final String id;
  final String label;
  const _Karat(this.id, this.label);
}

class _ZakatScreenState extends State<ZakatScreen> {
  static const _karats = [
    _Karat('22', '22 karat'),
    _Karat('21', '21 karat'),
    _Karat('18', '18 karat'),
    _Karat('trad', 'Traditional'),
  ];

  static const _assetFields = [
    ('cash', 'Cash in hand', Icons.payments_rounded),
    ('bank', 'Bank accounts', Icons.account_balance_rounded),
    ('mobile', 'bKash / Nagad / Rocket', Icons.phone_android_rounded),
    ('savings', 'DPS, FDR, Sanchayapatra', Icons.savings_rounded),
    ('shares', 'Shares & mutual funds (market value)', Icons.show_chart_rounded),
    ('foreign', 'Foreign currency (in taka)', Icons.currency_exchange_rounded),
    ('lent', 'Money lent you expect back', Icons.handshake_rounded),
  ];

  static const _businessFields = [
    ('stock', 'Business stock (sale value)', Icons.inventory_2_rounded),
    ('receivable', 'Business dues to collect', Icons.receipt_long_rounded),
  ];

  static const _liabilityFields = [
    ('debts', 'Loans and debts due now', Icons.credit_card_off_rounded),
    ('bills', 'Unpaid bills, rent, salaries', Icons.request_quote_rounded),
  ];

  static const _fitraItems = [
    ('wheat', 'Wheat / flour', '1.65 kg'),
    ('barley', 'Barley', '3.3 kg'),
    ('dates', 'Dates', '3.3 kg'),
    ('raisins', 'Raisins', '3.3 kg'),
    ('cheese', 'Cheese (panir)', '3.3 kg'),
  ];

  final _storage = Get.find<StorageService>();
  final Map<String, TextEditingController> _c = {};
  bool _useVori = true;
  bool _silverNisab = true;
  String _fitraItem = 'wheat';

  TextEditingController _ctl(String key) => _c.putIfAbsent(key, () => TextEditingController());

  @override
  void initState() {
    super.initState();
    final saved = _storage.getZakatInputs();
    for (final e in saved.entries) {
      if (e.key.startsWith('_')) continue;
      _ctl(e.key).text = e.value;
    }
    _useVori = saved['_unit'] != 'gram';
    _silverNisab = saved['_nisab'] != 'gold';
    _fitraItem = saved['_fitraItem'] ?? 'wheat';
    if (_ctl('people').text.isEmpty) _ctl('people').text = '1';
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _changed() {
    setState(() {});
    _storage.saveZakatInputs({
      for (final e in _c.entries)
        if (e.value.text.trim().isNotEmpty) e.key: e.value.text.trim(),
      '_unit': _useVori ? 'vori' : 'gram',
      '_nisab': _silverNisab ? 'silver' : 'gold',
      '_fitraItem': _fitraItem,
    });
  }

  double _v(String key) => double.tryParse(_ctl(key).text.replaceAll(',', '').trim()) ?? 0;

  double _vori(String key) => _useVori ? _v(key) : _v(key) / ZakatCalculator.gramsPerVori;

  static String money(double v) => '৳ ${LocaleText.digits(NumberFormat.decimalPattern('en_IN').format(v.round()))}';

  ({ZakatResult result, double goldValue, double cash, double business, double liabilities, double goldVori, double silverVori}) _compute() {
    var goldValue = 0.0;
    var goldVori = 0.0;
    for (final k in _karats) {
      final vori = _vori('gold_${k.id}');
      goldVori += vori;
      goldValue += vori * _v('price_${k.id}');
    }
    final silverVori = _vori('silver');
    final silverPricePerGram = _v('price_silver') / ZakatCalculator.gramsPerVori;
    final cash = _assetFields.fold(0.0, (s, f) => s + _v(f.$1));
    final business = _businessFields.fold(0.0, (s, f) => s + _v(f.$1));
    final liabilities = _liabilityFields.fold(0.0, (s, f) => s + _v(f.$1));
    final result = ZakatCalculator.calculate(ZakatInput(
      cashAndSavings: cash,
      goldValue: goldValue,
      goldPricePerGram: _v('price_22') / ZakatCalculator.gramsPerVori,
      silverGrams: silverVori * ZakatCalculator.gramsPerVori,
      silverPricePerGram: silverPricePerGram,
      tradeGoods: business,
      debtsYouOwe: liabilities,
      silverNisab: _silverNisab,
    ));
    return (
      result: result,
      goldValue: goldValue,
      cash: cash,
      business: business,
      liabilities: liabilities,
      goldVori: goldVori,
      silverVori: silverVori,
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final initialTab = args is Map && args['tab'] == 'fitra' ? 1 : 0;
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Zakat & Fitra'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.card,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.emerald,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.emerald,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800),
            tabs: [Tab(text: 'Zakat'.tr), Tab(text: 'Fitra'.tr)],
          ),
        ),
        body: TabBarView(children: [_zakatTab(), _fitraTab()]),
      ),
    );
  }

  Widget _zakatTab() {
    final c = _compute();
    final r = c.result;
    final missingPrice = r.nisab == 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        _resultHero(c, missingPrice),
        const SizedBox(height: 14),
        _Section(
          title: "Today's prices (per vori)".tr,
          subtitle: 'Enter the current BAJUS selling price. Nisab needs at least the silver or 22K gold price.'.tr,
          icon: Icons.sell_rounded,
          children: [
            for (final k in _karats) _MoneyField(controller: _ctl('price_${k.id}'), label: '${'Gold'.tr} ${k.label.tr}', onChanged: _changed),
            _MoneyField(controller: _ctl('price_silver'), label: 'Silver (22 karat)'.tr, onChanged: _changed),
          ],
        ),
        _Section(
          title: 'Gold & silver you own'.tr,
          subtitle: '1 vori = 16 ana = 11.664 g. Include jewellery you wear.'.tr,
          icon: Icons.diamond_rounded,
          trailing: SegmentedButton<bool>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
            segments: [
              ButtonSegment(value: true, label: Text('Vori'.tr)),
              ButtonSegment(value: false, label: Text('Gram'.tr)),
            ],
            selected: {_useVori},
            onSelectionChanged: (s) {
              _useVori = s.first;
              _changed();
            },
          ),
          children: [
            for (final k in _karats)
              _NumberField(
                controller: _ctl('gold_${k.id}'),
                label: '${'Gold'.tr} ${k.label.tr}',
                suffix: _useVori ? 'vori'.tr : 'g',
                onChanged: _changed,
              ),
            _NumberField(controller: _ctl('silver'), label: 'Silver'.tr, suffix: _useVori ? 'vori'.tr : 'g', onChanged: _changed),
          ],
        ),
        _Section(
          title: 'Cash, bank & savings'.tr,
          icon: Icons.account_balance_wallet_rounded,
          children: [for (final f in _assetFields) _MoneyField(controller: _ctl(f.$1), label: f.$2.tr, icon: f.$3, onChanged: _changed)],
        ),
        _Section(
          title: 'Business'.tr,
          icon: Icons.storefront_rounded,
          children: [for (final f in _businessFields) _MoneyField(controller: _ctl(f.$1), label: f.$2.tr, icon: f.$3, onChanged: _changed)],
        ),
        _Section(
          title: 'Liabilities'.tr,
          subtitle: 'Only debts and dues payable now. Not the full home loan.'.tr,
          icon: Icons.remove_circle_outline_rounded,
          children: [for (final f in _liabilityFields) _MoneyField(controller: _ctl(f.$1), label: f.$2.tr, icon: f.$3, onChanged: _changed)],
        ),
        _Section(
          title: 'Nisab standard'.tr,
          icon: Icons.balance_rounded,
          children: [
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: true, label: Text('Silver · 52.5 vori'.tr)),
                ButtonSegment(value: false, label: Text('Gold · 7.5 vori'.tr)),
              ],
              selected: {_silverNisab},
              onSelectionChanged: (s) {
                _silverNisab = s.first;
                _changed();
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Most scholars in Bangladesh advise the silver nisab when you hold cash or mixed assets, because it benefits the poor. If you own only gold and nothing else, the gold nisab applies.'.tr,
              style: TextStyle(fontSize: 11.5, height: 1.45, color: AppColors.textMid),
            ),
          ],
        ),
        _breakdown(c),
        const SizedBox(height: 12),
        _NoteCard(
          lines: [
            'Zakat is due when your net wealth stays above nisab for one lunar (Hijri) year.'.tr,
            'No zakat on your home, car, furniture or tools you use.'.tr,
            'Rate: 2.5% of net zakatable wealth.'.tr,
            'A study tool, not a fatwa. Ask a scholar for your own case.'.tr,
          ],
        ),
      ],
    );
  }

  Widget _resultHero(
    ({ZakatResult result, double goldValue, double cash, double business, double liabilities, double goldVori, double silverVori}) c,
    bool missingPrice,
  ) {
    final r = c.result;
    final status = missingPrice
        ? 'Enter the silver or gold price to find nisab'.tr
        : r.zakatDue
            ? 'Zakat is due on your wealth'.tr
            : 'Below nisab. Zakat is not due'.tr;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppSurfaces.hero(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('ZAKAT PAYABLE'.tr, style: const TextStyle(fontSize: 10.5, letterSpacing: 1.5, fontWeight: FontWeight.w800, color: AppPalette.goldLight)),
              const Spacer(),
              if (r.zakatDue)
                IconButton(
                  tooltip: 'Share'.tr,
                  onPressed: () => Share.share(_summary(c)),
                  icon: const Icon(Icons.ios_share_rounded, color: Colors.white, size: 20),
                ),
            ],
          ),
          Text(money(r.amount), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 4),
          Text(status, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xE6FFFFFF))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _HeroStat(label: 'Net wealth'.tr, value: money(r.netWealth))),
              Expanded(child: _HeroStat(label: 'Nisab'.tr, value: missingPrice ? '—' : money(r.nisab))),
            ],
          ),
          if (!missingPrice) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (r.netWealth / r.nisab).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: const Color(0x26FFFFFF),
                valueColor: const AlwaysStoppedAnimation(AppPalette.goldLight),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _breakdown(
    ({ZakatResult result, double goldValue, double cash, double business, double liabilities, double goldVori, double silverVori}) c,
  ) {
    final r = c.result;
    Widget row(String label, double value, {bool bold = false, bool minus = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, color: AppColors.textDark))),
              Text('${minus ? '− ' : ''}${money(value)}',
                  style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w900 : FontWeight.w700, color: minus ? Colors.redAccent : AppColors.textDark)),
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppSurfaces.card(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Breakdown'.tr, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 6),
          row('${'Gold'.tr} (${LocaleText.digits(c.goldVori.toStringAsFixed(2))} ${'vori'.tr})', c.goldValue),
          row('${'Silver'.tr} (${LocaleText.digits(c.silverVori.toStringAsFixed(2))} ${'vori'.tr})', r.silverValue),
          row('Cash, bank & savings'.tr, c.cash),
          row('Business'.tr, c.business),
          const Divider(),
          row('Total assets'.tr, r.grossWealth, bold: true),
          row('Liabilities'.tr, c.liabilities, minus: true),
          const Divider(),
          row('Net zakatable wealth'.tr, r.netWealth, bold: true),
          row('Zakat (2.5%)'.tr, r.amount, bold: true),
        ],
      ),
    );
  }

  String _summary(
    ({ZakatResult result, double goldValue, double cash, double business, double liabilities, double goldVori, double silverVori}) c,
  ) {
    final r = c.result;
    return [
      '${'Zakat'.tr} · Al-Noor',
      '${'Gold'.tr}: ${money(c.goldValue)}',
      '${'Silver'.tr}: ${money(r.silverValue)}',
      '${'Cash, bank & savings'.tr}: ${money(c.cash)}',
      '${'Business'.tr}: ${money(c.business)}',
      '${'Liabilities'.tr}: − ${money(c.liabilities)}',
      '${'Net zakatable wealth'.tr}: ${money(r.netWealth)}',
      '${'Nisab'.tr}: ${money(r.nisab)}',
      '${'Zakat (2.5%)'.tr}: ${money(r.amount)}',
    ].join('\n');
  }

  Widget _fitraTab() {
    final people = int.tryParse(_ctl('people').text.trim()) ?? 0;
    final rate = _v('fitra_$_fitraItem');
    final total = ZakatCalculator.fitra(people: people, ratePerPerson: rate);
    final item = _fitraItems.firstWhere((i) => i.$1 == _fitraItem);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppSurfaces.hero(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FITRA FOR YOUR FAMILY'.tr,
                  style: const TextStyle(fontSize: 10.5, letterSpacing: 1.5, fontWeight: FontWeight.w800, color: AppPalette.goldLight)),
              Text(money(total), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                '${LocaleText.digits(people)} ${'people'.tr} × ${money(rate)} · ${item.$2.tr} (${LocaleText.digits(item.$3)})',
                style: const TextStyle(fontSize: 12, color: Color(0xE6FFFFFF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Section(
          title: 'Family members'.tr,
          subtitle: 'Include yourself and everyone you support, including children.'.tr,
          icon: Icons.groups_rounded,
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: people <= 1
                      ? null
                      : () {
                          _ctl('people').text = '${people - 1}';
                          _changed();
                        },
                  icon: const Icon(Icons.remove_rounded),
                ),
                Expanded(
                  child: Text(LocaleText.digits(people),
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    _ctl('people').text = '${people + 1}';
                    _changed();
                  },
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ],
        ),
        _Section(
          title: 'Rate per person'.tr,
          subtitle: 'Islamic Foundation Bangladesh announces these rates every Ramadan. Enter this year\'s figures and choose the item you will pay by.'.tr,
          icon: Icons.rice_bowl_rounded,
          children: [
            for (final i in _fitraItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Radio<String>(
                      value: i.$1,
                      groupValue: _fitraItem,
                      activeColor: AppColors.emerald,
                      onChanged: (v) {
                        _fitraItem = v!;
                        _changed();
                      },
                    ),
                    Expanded(
                      child: _MoneyField(
                        controller: _ctl('fitra_${i.$1}'),
                        label: '${i.$2.tr} · ${LocaleText.digits(i.$3)}',
                        onChanged: _changed,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        _NoteCard(
          lines: [
            'Pay before the Eid prayer so the poor can celebrate too.'.tr,
            'Those who can afford it are encouraged to pay by the higher-value items.'.tr,
            'Fitra is due on every Muslim who has food beyond the needs of Eid day.'.tr,
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final List<Widget> children;

  const _Section({required this.title, this.subtitle, required this.icon, this.trailing, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: AppSurfaces.card(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.emerald),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark))),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: TextStyle(fontSize: 11.5, height: 1.4, color: AppColors.textLight)),
          ],
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final VoidCallback onChanged;
  final bool dense;

  const _MoneyField({required this.controller, required this.label, this.icon, required this.onChanged, this.dense = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: dense ? 0 : 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
        onChanged: (_) => onChanged(),
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          prefixText: '৳ ',
          prefixIcon: icon == null ? null : Icon(icon, size: 18, color: AppColors.textLight),
          filled: true,
          fillColor: AppColors.emeraldPale.withValues(alpha: 0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final VoidCallback onChanged;

  const _NumberField({required this.controller, required this.label, required this.suffix, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        onChanged: (_) => onChanged(),
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          suffixText: suffix,
          filled: true,
          fillColor: AppColors.emeraldPale.withValues(alpha: 0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xB3FFFFFF))),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  final List<String> lines;
  const _NoteCard({required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.info_outline_rounded, size: 14, color: AppPalette.gold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l, style: TextStyle(fontSize: 12, height: 1.45, color: AppColors.textMid))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
