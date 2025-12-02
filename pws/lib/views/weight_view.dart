import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fFinder/views/feedback_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WeightView extends StatefulWidget {
  const WeightView({super.key});

  @override
  State<WeightView> createState() => _WeightViewState();
}

class _WeightViewState extends State<WeightView> {
  bool _loading = true;
  bool _saving = false;

  double _weight = 72;
  double _height = 180;
  double? _bmi;

  List<WeightEntry> _entries = [];

  String _viewMode = 'table';

  int _currentMonthIndex = 0;

  static const double _bmiMin = 10.0;
  static const double _bmiVeryLowEnd = 16.0;
  static const double _bmiLowEnd = 18.5;
  static const double _bmiGoodEnd = 25.0;
  static const double _bmiHighEnd = 30.0;
  static const double _bmiMax = 40.0;

  double _clampBmi(double bmi) {
    return bmi.clamp(_bmiMin, _bmiMax);
  }

  final TextEditingController _weightController = TextEditingController();
  final FocusNode _weightFocusNode = FocusNode(); // FocusNode voor het gewicht invoerveld

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};

      _weight = _parseDouble(data['weight']) ?? _weight;
      _height = _parseDouble(data['height']) ?? _height;

      final weightsRaw = data['weights'] as List<dynamic>? ?? [];
      _entries =
          weightsRaw 
              .map((e) => WeightEntry.fromMap(e as Map<String, dynamic>)) 
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      _currentMonthIndex = 0;
      _weightController.text = _weight.toStringAsFixed(1);
      _recalculateBMI();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kon gewicht niet laden: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double? _parseDouble(dynamic value) { // Hulpmethode om double te parsen. parsen betekent omzetten van tekst naar een getal
    if (value == null) return null; 
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.'));
    }
    return null;
  }

  void _recalculateBMI() {
    if (_height <= 0 || _weight <= 0) {
      setState(() => _bmi = null);
      return;
    }
    final hMeters = _height / 100;
    final bmi = _weight / (hMeters * hMeters);
    setState(() => _bmi = bmi);
  }

  Future<void> _saveWeight() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _weightFocusNode.unfocus();

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final newEntry = WeightEntry(
        date: DateTime(now.year, now.month, now.day),
        weight: _weight,
      );

      _entries.removeWhere((e) => _isSameDay(e.date, newEntry.date));
      _entries.add(newEntry);
      _entries.sort((a, b) => a.date.compareTo(b.date));

      _currentMonthIndex = 0;

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final doc = await docRef.get();
      final data = doc.data() ?? {};

      final String gender = (data['gender'] as String?) ?? 'Man';
      final String? birthDateStr = data['birthDate'] as String?;
      DateTime? birthDate;
      if (birthDateStr != null && birthDateStr.isNotEmpty) {
        birthDate = DateTime.tryParse(birthDateStr);
      }

      final String activityLevel =
          (data['activityLevel'] as String?) ?? 'Weinig actief';
      final String goal = (data['goal'] as String?) ?? 'Op gewicht blijven';
      final double height = (data['height'] as num?)?.toDouble() ?? _height;
      final double targetWeight =
          (data['targetWeight'] as num?)?.toDouble() ?? _weight;

      double? bmi;
      double? calorieGoal;
      double? proteinGoal;
      double? fatGoal;
      double? carbGoal;

      if (height > 0 && _weight > 0 && birthDate != null) { // Berekeningen
        final heightCm = height;
        final weightKg = _weight;

        final heightM = heightCm / 100;
        bmi = weightKg / (heightM * heightM);

        final age = DateTime.now().year - birthDate.year;
        double bmr;
        if (gender == 'Vrouw') {
          bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
        } else {
          bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
        }

        final activity = activityLevel.split(':')[0].trim();
        double activityFactor;
        switch (activity) {
          case 'Weinig actief':
            activityFactor = 1.2;
            break;
          case 'Licht actief':
            activityFactor = 1.375;
            break;
          case 'Gemiddeld actief':
            activityFactor = 1.55;
            break;
          case 'Zeer actief':
            activityFactor = 1.725;
            break;
          case 'Extreem actief':
            activityFactor = 1.9;
            break;
          default:
            activityFactor = 1.2;
        }

        double calories = bmr * activityFactor;

        switch (goal) {
          case 'Afvallen':
            calories -= 500;
            break;
          case 'Aankomen (spiermassa)':
          case 'Aankomen (algemeen)':
            calories += 300;
            break;
          case 'Op gewicht blijven':
          default:
            break;
        }
        calorieGoal = calories;

        proteinGoal = weightKg;
        final fatCalories = calorieGoal * 0.30;
        fatGoal = fatCalories / 9;
        final proteinCalories = proteinGoal * 4;
        final carbCalories = calorieGoal - fatCalories - proteinCalories;
        carbGoal = carbGoal = carbCalories / 4;
      }

      await docRef.set({
        'weight': _weight,
        'targetWeight': targetWeight,
        'height': height,
        'bmi': bmi,
        'calorieGoal': calorieGoal,
        'proteinGoal': proteinGoal,
        'fatGoal': fatGoal,
        'carbGoal': carbGoal,
        'activityLevel': activityLevel,
        'goal': goal,
        'weights': _entries.map((e) => e.toMap()).toList(),
      }, SetOptions(merge: true));

      setState(() {
        _bmi = bmi;
        _height = height;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gewicht + doelen opgeslagen')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Opslaan mislukt: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    _weightFocusNode.unfocus(); // Verberg het toetsenbord na het opslaan
  }

  List<_MonthGroup> _groupEntriesByMonth() { // groepeer entries per maand
    if (_entries.isEmpty) return [];

    final Map<String, List<WeightEntry>> byMonth = {};
    for (final e in _entries) {
      final key = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}';
      byMonth.putIfAbsent(key, () => []).add(e);
    }

    final groups = <_MonthGroup>[]; // lijst van maandgroepen
    byMonth.forEach((key, list) {
      list.sort((a, b) => a.date.compareTo(b.date));
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      groups.add(_MonthGroup(year: year, month: month, entries: list));
    });

    // sorteer op maand (oudste eerst), dan omdraaien zodat index 0 = nieuwste maand
    groups.sort((a, b) {
      final da = DateTime(a.year, a.month);
      final db = DateTime(b.year, b.month);
      return da.compareTo(db);
    });
    return groups.reversed.toList();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _bmiCategory(double bmi) {
    if (bmi < 16) return 'Veel te laag';
    if (bmi < 18.5) return 'Laag';
    if (bmi < 25) return 'Goed';
    if (bmi < 30) return 'Te hoog';
    return 'Veel te hoog';
  }

  Color _bmiCategoryColor(double bmi, bool isDark) {
    if (bmi < 16) return Colors.redAccent;
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey[300] : Colors.grey[700];
    final cardColor = theme.cardColor;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        backgroundColor: isDark ? Colors.black : Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () {
                if (_weightFocusNode.hasFocus) {
                  _weightFocusNode.unfocus();
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Je gewicht',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pas je gewicht aan en bekijk je BMI.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: isDark ? 0 : 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextField(
                                controller: _weightController,
                                focusNode: _weightFocusNode,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: primaryTextColor,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Gewicht (kg)',
                                  labelStyle: TextStyle(
                                    color: secondaryTextColor,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.monitor_weight,
                                    color: secondaryTextColor,
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  final v = double.tryParse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (v != null && v > 0) {
                                    setState(() => _weight = v);
                                    _recalculateBMI();
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gewicht slider',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: colorScheme.primary,
                                      inactiveTrackColor: colorScheme.primary
                                          .withOpacity(0.3),
                                      thumbColor: colorScheme.primary,
                                      overlayColor: colorScheme.primary
                                          .withOpacity(0.2),
                                    ),
                                    child: Slider(
                                      value: _weight.clamp(30, 200),
                                      min: 30,
                                      max: 200,
                                      divisions: 170,
                                      label: _weight.toStringAsFixed(1),
                                      onChanged: (v) {
                                        setState(() {
                                          _weight = v;
                                          _weightController.text = _weight
                                              .toStringAsFixed(1);
                                        });
                                        _recalculateBMI();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? Colors.black
                                        : colorScheme.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: _saving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.save),
                                  label: Text(
                                    _saving ? 'Opslaan...' : 'Gewicht opslaan',
                                  ),
                                  onPressed: _saving ? null : _saveWeight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: isDark ? 0 : 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'BMI',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_bmi == null)
                                Text(
                                  'Onvoldoende gegevens om BMI te berekenen. Vul je lengte en gewicht in.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: secondaryTextColor,
                                  ),
                                )
                              else ...[
                                Text(
                                  'Jouw BMI: ${_bmi!.toStringAsFixed(1)} (${_bmiCategory(_bmi!)})',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: _bmiCategoryColor(_bmi!, isDark),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildBmiBar(theme, isDark),
                                const SizedBox(height: 12),
                                _buildBmiLegend(theme, isDark),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text('Tabel'),
                            selected: _viewMode == 'table',
                            onSelected: (_) {
                              setState(() => _viewMode = 'table');
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Grafiek (per maand)'),
                            selected: _viewMode == 'chart',
                            onSelected: (_) {
                              setState(() => _viewMode = 'chart');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_entries.isEmpty)
                        Text(
                          'Nog geen metingen opgeslagen.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryTextColor,
                          ),
                        )
                      else if (_viewMode == 'table')
                        _buildTableView(
                          theme,
                          primaryTextColor,
                          secondaryTextColor,
                        )
                      else
                        _buildChartView(
                          theme,
                          primaryTextColor,
                          secondaryTextColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 80.0,
        ), 
        child: const FeedbackButton(),
      ),
    );
  }

  Widget _buildBmiBar(ThemeData theme, bool isDark) { //  BMI-balk bouwen
    if (_bmi == null) return const SizedBox.shrink();
    final bmi = _clampBmi(_bmi!); // clamp de BMI binnen het bereik

    const totalRange = _bmiMax - _bmiMin;
    final veryLowWidth = _bmiVeryLowEnd - _bmiMin; // 10–16
    final lowWidth = _bmiLowEnd - _bmiVeryLowEnd; // 16–18.5
    final goodWidth = _bmiGoodEnd - _bmiLowEnd; // 18.5–25
    final highWidth = _bmiHighEnd - _bmiGoodEnd; // 25–30
    final veryHighWidth = _bmiMax - _bmiHighEnd; // 30–40

    final veryLowFlex = veryLowWidth / totalRange;
    final lowFlex = lowWidth / totalRange;
    final goodFlex = goodWidth / totalRange;
    final highFlex = highWidth / totalRange;
    final veryHighFlex = veryHighWidth / totalRange;

    return SizedBox(
      height: 32,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final bmiPos =
              ((bmi - _bmiMin) / totalRange).clamp(0.0, 1.0) * totalWidth;

          return Stack(
            children: [
              Row(
                children: [
                  _bmiSegment(
                    flex: (veryLowFlex * 1000).round(),
                    color: Colors.redAccent.withOpacity(0.6),
                  ),
                  _bmiSegment(
                    flex: (lowFlex * 1000).round(),
                    color: Colors.orange.withOpacity(0.7),
                  ),
                  _bmiSegment(
                    flex: (goodFlex * 1000).round(),
                    color: Colors.green.withOpacity(0.7),
                  ),
                  _bmiSegment(
                    flex: (highFlex * 1000).round(),
                    color: Colors.orange.withOpacity(0.7),
                  ),
                  _bmiSegment(
                    flex: (veryHighFlex * 1000).round(),
                    color: Colors.redAccent.withOpacity(0.6),
                  ),
                ],
              ),
              Positioned(
                left: bmiPos,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bmiSegment({required int flex, required Color color}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0.5),
        color: color,
      ),
    );
  }

  Widget _buildBmiLegend(ThemeData theme, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;

    Widget item(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: textColor),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        item(Colors.redAccent.withOpacity(0.6), 'Veel te laag'),
        item(Colors.orange.withOpacity(0.7), 'Laag'),
        item(Colors.green.withOpacity(0.7), 'Goed'),
        item(Colors.orange.withOpacity(0.7), 'Te hoog'),
        item(Colors.redAccent.withOpacity(0.6), 'Veel te hoog'),
      ],
    );
  }

  Widget _buildTableView(
    ThemeData theme,
    Color primaryTextColor,
    Color? secondaryTextColor,
  ) {
    final reversed = _entries.reversed.toList();

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Tabel metingen',
              style: TextStyle(color: primaryTextColor),
            ),
          ),
          const Divider(height: 1),
          ...reversed.map(
            (e) => ListTile(
              dense: true,
              title: Text(
                _formatDate(e.date),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: primaryTextColor,
                ),
              ),
              trailing: Text(
                '${e.weight.toStringAsFixed(1)} kg',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: primaryTextColor,
                ),
              ),
              subtitle: Text(
                _formatShortMonth(e.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartView(
    ThemeData theme,
    Color primaryTextColor,
    Color? secondaryTextColor,
  ) {
    final monthGroups = _groupEntriesByMonth();
    if (monthGroups.isEmpty) {
      return Text(
        'Nog geen metingen voor een grafiek.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
      );
    }

    // zorg dat index binnen bereik blijft
    if (_currentMonthIndex >= monthGroups.length) {
      _currentMonthIndex = 0;
    }

    final current = monthGroups[_currentMonthIndex];
    final monthEntries = current.entries;

    final canGoPrev = _currentMonthIndex < monthGroups.length - 1;
    final canGoNext = _currentMonthIndex > 0;

    final displayedDate = DateTime(current.year, current.month, 1);

    double? minWeight;
    double? maxWeight;
    if (monthEntries.length >= 2) {
      minWeight = monthEntries
          .map((e) => e.weight)
          .reduce((a, b) => a < b ? a : b);
      maxWeight = monthEntries
          .map((e) => e.weight)
          .reduce((a, b) => a > b ? a : b);
    }

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // titel + pijltjes, altijd tonen
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: canGoPrev
                      ? () {
                          setState(() {
                            _currentMonthIndex++;
                          });
                        }
                      : null,
                ),
                Text(
                  'Grafiek – ${_formatMonthYear(displayedDate)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primaryTextColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: canGoNext
                      ? () {
                          setState(() {
                            _currentMonthIndex--;
                          });
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (monthEntries.length < 2) ...[
              // te weinig metingen: geen grafiek, wél navigatie
              Text(
                'Nog te weinig metingen in deze maand voor een grafiek.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryTextColor,
                ),
              ),
            ] else ...[
              SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: _WeightChartPainter(
                    entries: monthEntries,
                    minWeight: minWeight!,
                    maxWeight: maxWeight!,
                    lineColor: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'X-as: dagen van de maand, Y-as: gewicht (kg)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryTextColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  String _formatShortMonth(DateTime date) {
    const months = [
      'jan',
      'feb',
      'mrt',
      'apr',
      'mei',
      'jun',
      'jul',
      'aug',
      'sep',
      'okt',
      'nov',
      'dec',
    ];
    return months[date.month - 1];
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'januari',
      'februari',
      'maart',
      'april',
      'mei',
      'juni',
      'juli',
      'augustus',
      'september',
      'oktober',
      'november',
      'december',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class WeightEntry {
  final DateTime date;
  final double weight;

  WeightEntry({required this.date, required this.weight});

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    final dateStr = map['date'] as String? ?? '';
    DateTime date;
    try {
      date = DateTime.parse(dateStr);
    } catch (_) {
      date = DateTime.now();
    }

    final dynamic rawWeight = map['weight'];
    double weight;

    if (rawWeight is num) {
      weight = rawWeight.toDouble();
    } else if (rawWeight is String) {
      weight = double.tryParse(rawWeight.replaceAll(',', '.')) ?? 0.0;
    } else {
      weight = 0.0;
    }

    return WeightEntry(date: date, weight: weight);
  }

  Map<String, dynamic> toMap() {
    final d = date;
    final onlyDate = DateTime(d.year, d.month, d.day);
    return {'date': onlyDate.toIso8601String(), 'weight': weight};
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;
  final double minWeight;
  final double maxWeight;
  final Color lineColor;

  _WeightChartPainter({
    required this.entries,
    required this.minWeight,
    required this.maxWeight,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    const double leftPad = 32;
    const double rightPad = 8;
    const double topPad = 8;
    const double bottomPad = 32;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;

    final first = entries.first.date;
    final last = entries.last.date;
    final startDay = first.day.toDouble();
    final endDay = last.day.toDouble();
    final dayRange = (endDay - startDay).clamp(1, 31);

    final wRange = (maxWeight - minWeight).abs().clamp(1, 100);

    final paintAxis = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintPoint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final path = Path();

    final List<Offset> points = [];

    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final dayPos = (e.date.day - startDay) / dayRange;
      final weightPos = (e.weight - minWeight) / wRange;

      final dx = leftPad + dayPos * chartWidth;
      final dy = topPad + (1 - weightPos) * chartHeight;

      points.add(Offset(dx, dy));

      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    final origin = Offset(leftPad, topPad + chartHeight);
    final xEnd = Offset(leftPad + chartWidth, topPad + chartHeight);
    final yEnd = Offset(leftPad, topPad);

    canvas.drawLine(origin, xEnd, paintAxis);
    canvas.drawLine(origin, yEnd, paintAxis);

    canvas.drawPath(path, paintLine);

    const double pointRadius = 4;
    for (final p in points) {
      canvas.drawCircle(p, pointRadius + 1.5, paintAxis);
      canvas.drawCircle(p, pointRadius, paintPoint);
    }

    final textStyle = TextStyle(color: Colors.grey.shade700, fontSize: 10);
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final p = points[i];

      final label = e.date.day.toString();
      textPainter.text = TextSpan(text: label, style: textStyle);
      textPainter.layout();

      final offset = Offset(p.dx - textPainter.width / 2, origin.dy + 2);
      textPainter.paint(canvas, offset);
    }

    final Set<String> usedWeightLabels = {};
    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final p = points[i];

      final label = e.weight.toStringAsFixed(1);
      if (usedWeightLabels.contains(label)) continue;
      usedWeightLabels.add(label);

      textPainter.text = TextSpan(text: label, style: textStyle);
      textPainter.layout();

      final offset = Offset(
        leftPad - textPainter.width - 4,
        p.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.minWeight != minWeight ||
        oldDelegate.maxWeight != maxWeight ||
        oldDelegate.lineColor != lineColor;
  }
}

class _MonthGroup {
  final int year;
  final int month;
  final List<WeightEntry> entries;

  _MonthGroup({required this.year, required this.month, required this.entries});
}
