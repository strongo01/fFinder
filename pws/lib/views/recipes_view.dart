import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum _SwipeDirection { left, right } // Veegrichting

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen>
    with SingleTickerProviderStateMixin {
  // voor animaties
  final List<Map<String, dynamic>> _recipes = [
    // voorbeeld recepten
    {
      'id': 'r1',
      'title': 'Thaise kokos-curry',
      'preparation_time': 25,
      'total_time': 40,
      'kcal': 520,
      'fat': 20,
      'saturated_fat': 10,
      'carbs': 60,
      'protein': 25,
      'fibers': 8,
      'salt': 1.2,
      'prepreparation': 'Snijd groenten en bereid curry pasta voor',
      'persons': 2,
      'difficulty': 'Easy',
      'kitchens': ['Thai', 'Asian'],
      'courses': ['Dinner', 'Lunch'],
      'requirements': ['Pan', 'Knife'],
      'ingredients': ['Kokosmelk', 'Currypasta', 'Groenten'],
      'steps': ['Stap 1', 'Stap 2', 'Stap 3'],
      'tags': ['Vegan', 'Spicy'],
      'image_link':
          'https://via.placeholder.com/600x350.png?text=Thaise+kokos+curry',
    },
    {
      'id': 'r2',
      'title': 'Panzanella (broodsalade)',
      'preparation_time': 15,
      'total_time': 20,
      'kcal': 320,
      'fat': 5,
      'saturated_fat': 1,
      'carbs': 50,
      'protein': 10,
      'fibers': 5,
      'salt': 0.8,
      'prepreparation': 'Snijd brood en groenten',
      'persons': 2,
      'difficulty': 'Easy',
      'kitchens': ['Italian'],
      'courses': ['Lunch'],
      'requirements': ['Bowl', 'Knife'],
      'ingredients': ['Brood', 'Tomaat', 'Komkommer', 'Basilicum'],
      'steps': ['Stap 1', 'Stap 2'],
      'tags': ['Vegetarian', 'Quick'],
      'image_link': 'https://via.placeholder.com/600x350.png?text=Panzanella',
    },
  ];

  Offset _dragOffset =
      Offset.zero; // huidige sleep offset. offset betekent verplaatsing
  double _dragRotation = 0.0; // huidige rotatie tijdens slepen
  late AnimationController _animController;
  Animation<Offset>? _animOffset; // animatie voor offset
  Animation<double>? _animRotation;
  bool _isAnimating = false;

  static const double _swipeThreshold = 120.0; // drempel voor vegen
  static const double _rotationMultiplier =
      0.003; // rotatie factor tijdens slepen

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..addListener(() {
          // bij elke frame
          setState(() {
            _dragOffset = _animOffset?.value ?? _dragOffset;
            _dragRotation = _animRotation?.value ?? _dragRotation;
          });
        });

    _animController.addStatusListener((status) {
      // bij status verandering
      if (status == AnimationStatus.completed) {
        if (_isAnimating) {
          final dir = _dragOffset.dx > 0
              ? _SwipeDirection.right
              : _SwipeDirection.left;
          _handleSwipeComplete(dir);
        }
        _isAnimating = false;
        _dragOffset = Offset.zero;
        _dragRotation = 0.0;
        _animOffset = null;
        _animRotation = null;
        _animController.reset();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool get _hasCards => _recipes.isNotEmpty; // of er nog kaarten zijn

  void _animateCardTo(Offset targetOffset, double targetRotation) {
    // animatie naar doelpositie
    _isAnimating = true;
    _animOffset = Tween<Offset>(begin: _dragOffset, end: targetOffset).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    ); // animatie voor offset
    _animRotation = Tween<double>(begin: _dragRotation, end: targetRotation)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOut),
        ); // animatie voor rotatie
    _animController.forward(from: 0.0);
  }

  void _onPanEnd() {
    // bij loslaten na slepen
    if (_dragOffset.dx.abs() > _swipeThreshold) {
      final sign = _dragOffset.dx.sign;
      final screenWidth = MediaQuery.of(context).size.width;
      final target = Offset(sign * (screenWidth + 200), _dragOffset.dy);
      final targetRotation = _dragRotation + sign * 0.5;
      _animateCardTo(target, targetRotation);
    } else {
      _animOffset = Tween<Offset>(begin: _dragOffset, end: Offset.zero).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut),
      );
      _animRotation = Tween<double>(begin: _dragRotation, end: 0.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut),
      );
      _animController.forward(from: 0.0);
    }
  }

  void _handleSwipeComplete(_SwipeDirection direction) {
    // na voltooien vegen
    if (!_hasCards) return;
    final top = _recipes.first;
    final title = top['title'] ?? '';
    final liked = direction == _SwipeDirection.right;

    final loc = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          liked
              ? '${loc.recipesSavedPrefix}$title'
              : '${loc.recipesSkippedPrefix}$title',
        ),
        duration: const Duration(milliseconds: 700),
      ),
    );

    setState(() {
      if (_recipes.isNotEmpty) _recipes.removeAt(0);
    });
  }

  void _swipeProgrammatically(_SwipeDirection direction) {
    // veeg kaart programatisch
    if (!_hasCards || _isAnimating) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final target = Offset(
      (direction == _SwipeDirection.right ? 1 : -1) * (screenWidth + 200),
      0,
    );
    final targetRotation = (direction == _SwipeDirection.right
        ? 0.6
        : -0.6); // rotatie bij vegen
    _animateCardTo(target, targetRotation);
  }

  Widget _buildCard(Map<String, dynamic> recipe, int positionFromTop) {
    // bouw kaart met schaal en vertaling
    final scale = 1.0 - positionFromTop * 0.04;
    final translateY = positionFromTop * 12.0;
    return Transform.translate(
      offset: Offset(0, translateY),
      child: Transform.scale(scale: scale, child: _recipeCard(recipe)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                loc.recipesSwipeInstruction,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: _hasCards
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          final visibleCount = math.min(
                            3,
                            _recipes.length,
                          ); // max 3 kaarten zichtbaar
                          final cards = <Widget>[];

                          for (int i = visibleCount - 1; i >= 0; i--) {
                            // van onder naar boven
                            final recipeIndex = i;
                            final recipe = _recipes[recipeIndex];

                            if (i == 0) {
                              // bovenste kaart
                              Widget topCard = GestureDetector(
                                // bovenste kaart
                                onPanStart: (_) {},
                                onPanUpdate: (details) {
                                  if (_isAnimating) return;
                                  setState(() {
                                    _dragOffset +=
                                        details.delta; // update offset
                                    _dragRotation =
                                        _dragOffset.dx *
                                        _rotationMultiplier; // update rotatie
                                  });
                                },
                                onPanEnd: (_) {
                                  if (_isAnimating) return;
                                  _onPanEnd();
                                },
                                onTap: () => _showRecipeDetails(
                                  recipe,
                                ), // toon details bij tikken
                                child: Transform.translate(
                                  // verplaats kaart
                                  offset: _dragOffset,
                                  child: Transform.rotate(
                                    angle: _dragRotation,
                                    child: _recipeCard(recipe),
                                  ),
                                ),
                              );
                              cards.add(
                                Positioned.fill(child: topCard),
                              ); // vul de beschikbare ruimte
                            } else {
                              final lower = Positioned.fill(
                                child: Center(
                                  child: _buildCard(
                                    _recipes[i],
                                    i,
                                  ), // bouw lagere kaart
                                ),
                              );
                              cards.add(lower);
                            }
                          }

                          return SizedBox(
                            width: math.min(
                              480,
                              constraints.maxWidth * 0.95,
                            ), // max breedte
                            height: math.min(
                              640,
                              constraints.maxHeight * 0.9,
                            ), // max hoogte
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: cards,
                            ),
                          );
                        },
                      )
                    : Center(child: Text(loc.recipesNoMore)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _actionButton(
                    Icons.clear,
                    Colors.red,
                    () => _swipeProgrammatically(_SwipeDirection.left),
                  ),
                  const SizedBox(width: 24),
                  _actionButton(
                    Icons.favorite,
                    Colors.green,
                    () => _swipeProgrammatically(_SwipeDirection.right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    // actie knop
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 32),
        ),
      ),
    );
  }

  Widget _recipeCard(Map<String, dynamic> recipe) {
    // bouw recept kaart
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Afbeelding
          Positioned.fill(
            child: Image.network(
              recipe['image_link'] ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 48),
              ),
            ),
          ),
          // Overlay voor leesbaarheid
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipe['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: (recipe['tags'] ?? []).map<Widget>((tag) {
                      return Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.green.shade400.withOpacity(0.8),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // ondertitel met tijd, personen, kcal
                    '⏱ ${recipe['preparation_time'] ?? '?'} min | 🍽 ${recipe['persons'] ?? '?'} | 🔥 ${recipe['kcal'] ?? '?'} kcal',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(Map<String, dynamic> recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            final loc = AppLocalizations.of(context)!;
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      recipe['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Image.network(
                      recipe['image_link'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 48),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: (recipe['tags'] ?? []).map<Widget>((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.green.shade200,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(loc.recipesDetailId, recipe['id']),
                    _buildDetailRow(
                      loc.recipesDetailPreparationTime,
                      '${recipe['preparation_time']} min',
                    ),
                    _buildDetailRow(
                      loc.recipesDetailTotalTime,
                      '${recipe['total_time']} min',
                    ),
                    _buildDetailRow(
                      loc.recipesDetailKcal,
                      recipe['kcal']?.toString(),
                    ),
                    _buildDetailRow(loc.recipesDetailFat, '${recipe['fat']} g'),
                    _buildDetailRow(
                      loc.recipesDetailSaturatedFat,
                      '${recipe['saturated_fat']} g',
                    ),
                    _buildDetailRow(
                      loc.recipesDetailCarbs,
                      '${recipe['carbs']} g',
                    ),
                    _buildDetailRow(
                      loc.recipesDetailProtein,
                      '${recipe['protein']} g',
                    ),
                    _buildDetailRow(
                      loc.recipesDetailFibers,
                      '${recipe['fibers']} g',
                    ),
                    _buildDetailRow(
                      loc.recipesDetailSalt,
                      '${recipe['salt']} g',
                    ),
                    _buildDetailRow(
                      loc.recipesDetailPersons,
                      recipe['persons'].toString(),
                    ),
                    _buildDetailRow(
                      loc.recipesDetailDifficulty,
                      recipe['difficulty'],
                    ),
                    if (recipe['prepreparation'] != null)
                      _buildDetailSection(
                        loc.recipesPrepreparation,
                        recipe['prepreparation'],
                      ),
                    if (recipe['ingredients'] != null)
                      _buildListSection(
                        loc.recipesIngredients,
                        recipe['ingredients'],
                      ),
                    if (recipe['steps'] != null)
                      _buildListSection(loc.recipesSteps, recipe['steps']),
                    if (recipe['kitchens'] != null)
                      _buildListSection(
                        loc.recipesKitchens,
                        recipe['kitchens'],
                      ),
                    if (recipe['courses'] != null)
                      _buildListSection(loc.recipesCourses, recipe['courses']),
                    if (recipe['requirements'] != null)
                      _buildListSection(
                        loc.recipesRequirements,
                        recipe['requirements'],
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)), // titel
          Expanded(
            child: Text(
              value ?? '',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), // sectietitel
          const SizedBox(height: 4),
          Text(content), // inhoud
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...items.map((i) => Text('- $i')).toList(),
        ],
      ),
    );
  }
}

class UnderConstructionScreen extends StatelessWidget {
  const UnderConstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(height: 24),
            Text(
              loc.recipesTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(seconds: 2),
              child: Text(
                loc.recipesSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
