import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepOrange,
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: Colors.orange,
        labelStyle: TextStyle(color: Colors.black),
        checkmarkColor: Colors.black,
        side: BorderSide(color: Colors.deepOrange),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.deepOrange;
          }
          return Colors.white;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
      ),
    ),
    home: const TakoyakiApp(),
  ),
);

class TakoyakiApp extends StatefulWidget {
  const TakoyakiApp({super.key});

  @override
  State<TakoyakiApp> createState() => _TakoyakiAppState();
}

class _TakoyakiAppState extends State<TakoyakiApp> {
  final foods = {
    '🐙 定番たこ焼き(6個)': 450,
    '🧀 チーズたこ焼き(6個)': 550,
    '🌶️ ピリ辛たこ焼き(6個)': 500,
  };

  late String food = foods.keys.first;
  String sauce = '定番ソース';
  final toppings = <String>{};
  bool chopsticks = false;
  bool napkin = false;
  int order = 0;
  String receipt = '';

  // ボタン内の文字の高さを揃え、フェードを防ぐ
  Widget chipLabel(String text) {
    return Text(
      text,
      overflow: TextOverflow.visible,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        height: 1.2,
      ),
      strutStyle: const StrutStyle(
        fontSize: 16,
        height: 1.2,
        forceStrutHeight: true,
      ),
    );
  }

  Widget choices(
    Iterable<String> items,
    String value,
    void Function(String) change,
  ) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final s in items)
          ChoiceChip(
            label: chipLabel(s),
            selected: value == s,
            onSelected: (_) => setState(() => change(s)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = foods[food]! + toppings.length * 100;
    final tax = subtotal ~/ 10;
    final total = subtotal + tax;

    final photo = const SizedBox(
      height: 145,
      child: Center(
        child: Text(
          '🐙',
          style: TextStyle(fontSize: 80),
        ),
      ),
    );

    final products = choices(
      foods.keys.map((s) => '$s ${foods[s]}円'),
      '$food ${foods[food]}円',
      (s) => food = s.substring(0, s.lastIndexOf(' ')),
    );

    final toppingChoices = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final s in ['🧀 追いチーズ', '🥓 ベーコン', '🥚 温玉'])
          FilterChip(
            label: chipLabel(s),
            selected: toppings.contains(s),
            onSelected: (v) => setState(() {
              if (v) {
                toppings.add(s);
              } else {
                toppings.remove(s);
              }
            }),
          ),
      ],
    );

    final sauces = choices(
      ['なし', '定番ソース', 'ポン酢', '辛口ソース'],
      sauce,
      (s) => sauce = s,
    );

    Widget supply(
      String label,
      bool value,
      void Function(bool) change,
    ) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => setState(() => change(v ?? false)),
          ),
          Text(label),
        ],
      );
    }

    final supplies = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        supply('🥢 お箸(無料)', chopsticks, (v) => chopsticks = v),
        supply('📄 紙ナプキン(無料)', napkin, (v) => napkin = v),
      ],
    );

    final bill = Column(
      children: [
        Text('税抜$subtotal 円 / 消費税(10%)$tax 円'),
        Text(
          '合計$total 円',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
      ],
    );

    // 注文ボタンを横幅いっぱい・高さ56にする
    final submit = SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => setState(() {
          order = Random().nextInt(999) + 1;

          receipt = '$food ${foods[food]}円\n'
              'トッピング：${toppings.isEmpty ? 'なし' : toppings.join(' ')}\n'
              'ソース：$sauce\n'
              'お箸：${chopsticks ? 'あり' : 'なし'}\n'
              '紙ナプキン：${napkin ? 'あり' : 'なし'}\n'
              '税抜$subtotal 円 / 消費税(10%)$tax 円\n'
              '合計$total 円';
        }),
        child: const Text('注文する'),
      ),
    );

    final ticket = order == 0
        ? const SizedBox.shrink()
        : Card(
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '注文番号$order',
                    style: const TextStyle(fontSize: 26),
                  ),
                  Text(receipt),
                  const SizedBox(height: 8),
                  const Text('ありがとうございました！🐙'),
                ],
              ),
            ),
          );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text('🐙 あつあつ！たこ焼き屋台'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              photo,
              const Text('🐙 焼きたてのたこ焼きをどうぞ！'),
              products,
              const SizedBox(height: 12),
              const Text('追加トッピング(1種類100円)'),
              toppingChoices,
              const SizedBox(height: 12),
              const Text('お好みのソース(無料)'),
              sauces,
              const SizedBox(height: 12),
              const Text('無料サービス'),
              supplies,
              const Divider(color: Colors.deepOrange),
              bill,
              const SizedBox(height: 12),
              submit,
              const SizedBox(height: 12),
              ticket,
            ],
          ),
        ),
      ),
    );
  }
}