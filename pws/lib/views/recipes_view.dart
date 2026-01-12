import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';

enum _SwipeDirection { left, right }

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen>
    with SingleTickerProviderStateMixin {
  final String apiBase = 'https://ffinder.nl';
  final String apiKey = dotenv.env['APP_KEY']!;
  Offset _panStart = Offset.zero;

  String get userId {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }
    return uid;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-app-key': apiKey,
      };

  // ================= STATE =================
  final List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = false;
  bool _isAnimating = false;

  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0.0;

  late AnimationController _animController;
  Animation<Offset>? _animOffset;
  Animation<double>? _animRotation;

  static const double _swipeThreshold = 120;
  static const double _rotationMultiplier = 0.003;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {
          _dragOffset = _animOffset?.value ?? _dragOffset;
          _dragRotation = _animRotation?.value ?? _dragRotation;
        });
      });

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isAnimating) {
        final dir =
            _dragOffset.dx > 0 ? _SwipeDirection.right : _SwipeDirection.left;
        _handleSwipeComplete(dir);
        _resetAnimation();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialRecipes();
    });
  }

  String? _loadError;

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _resetAnimation() {
    _isAnimating = false;
    _dragOffset = Offset.zero;
    _dragRotation = 0;
    _animController.reset();
  }

  Future<List<Map<String, dynamic>>> _searchRecipes(String query) async {
    // Deze functie blijft beschikbaar maar wordt niet meer gebruikt als fallback.
    try {
      final res = await http.get(
        Uri.parse(
          '$apiBase/recipes/search?query=${Uri.encodeComponent(query)}',
        ),
        headers: _headers,
      );
      debugPrint('SEARCH status=${res.statusCode} body=${res.body}');
      if (res.statusCode != 200) {
        throw Exception('Search failed: ${res.statusCode}');
      }

      final decoded = json.decode(res.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
      if (decoded is Map && decoded['recipes'] is List) {
        return List<Map<String, dynamic>>.from(decoded['recipes']);
      }
      if (decoded is Map &&
          decoded['foods'] is Map &&
          decoded['foods']['food'] is List) {
        return List<Map<String, dynamic>>.from(decoded['foods']['food']);
      }

      debugPrint('SEARCH unknown format: ${decoded.runtimeType}');
      return [];
    } catch (e, st) {
      debugPrint('SEARCH error: $e\n$st');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _getRecommendations() async {
    try {
      final res = await http.get(
        Uri.parse('$apiBase/recipes/recommendations/$userId?limit=6'),
        headers: _headers,
      );
      debugPrint('RECS status=${res.statusCode} body=${res.body}');
      if (res.statusCode != 200) return [];

      final decoded = json.decode(res.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
      if (decoded is Map && decoded['recipes'] is List) {
        return List<Map<String, dynamic>>.from(decoded['recipes']);
      }
      if (decoded is Map && decoded['results'] is List) {
        return List<Map<String, dynamic>>.from(decoded['results']);
      }
      debugPrint('RECS unknown format: ${decoded.runtimeType}');
      return [];
    } catch (e, st) {
      debugPrint('RECS error: $e\n$st');
      return [];
    }
  }

  Future<void> _loadInitialRecipes() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final recs = await _getRecommendations();
      if (recs.isNotEmpty) {
        _recipes.addAll(recs);
      } else {
        // Geen fallback meer: we gebruiken alleen recommendations
        setState(() {
          _loadError = 'Geen aanbevelingen gevonden';
        });
      }
    } catch (e, st) {
      debugPrint('Load recipes failed: $e\n$st');
      setState(() {
        _loadError = e.toString();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _getRecipeDetail(String id) async {
    final res = await http.get(
      Uri.parse('$apiBase/recipes/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) return null;
    return json.decode(res.body);
  }

  Future<void> _rateRecipe(String recipeId, int rating) async {
    await http.post(
      Uri.parse('$apiBase/recipes/rate'),
      headers: _headers,
      body: json.encode({
        'user_id': userId,
        'recipe_id': recipeId,
        'rating': rating,
      }),
    );
  }

  void _handleSwipeComplete(_SwipeDirection dir) async {
    if (_recipes.isEmpty) return;

    final recipe = _recipes.removeAt(0);
    setState(() {});

    final liked = dir == _SwipeDirection.right;
    await _rateRecipe(recipe['id'].toString(), liked ? 5 : 1);

    if (_recipes.length > 3) {
      setState(() {});
      return;
    }

    // Altijd recommendations ophalen (geen fallback meer)
    List<Map<String, dynamic>> newRecs = await _getRecommendations();

    for (final r in newRecs) {
      final id = r['id']?.toString();
      if (id != null && !_containsRecipe(id)) {
        _recipes.add(r);
      }
    }

    setState(() {});
  }

  bool _containsRecipe(String id) {
    return _recipes.any((r) => r['id'].toString() == id);
  }

  void _onPanEnd() {
    if (_isAnimating) return;

    if (_dragOffset.dx.abs() > _swipeThreshold) {
      final sign = _dragOffset.dx.sign;
      final width = MediaQuery.of(context).size.width;
      _isAnimating = true;
      _animOffset = Tween(
        begin: _dragOffset,
        end: Offset(sign * (width + 200), 0),
      ).animate(_animController);
      _animRotation = Tween(
        begin: _dragRotation,
        end: sign * 0.6,
      ).animate(_animController);
      _animController.forward(from: 0);
    } else {
      _animOffset = Tween(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(_animController);
      _animRotation = Tween(
        begin: _dragRotation,
        end: 0.0,
      ).animate(_animController);
      _animController.forward(from: 0);
    }
  }

  void _triggerSwipe(_SwipeDirection dir) {
    _dragOffset = Offset.zero;
    _dragRotation = 0.0;

    if (_isAnimating || _recipes.isEmpty) return;

    final sign = dir == _SwipeDirection.right ? 1 : -1;
    final width = MediaQuery.of(context).size.width;

    _isAnimating = true;

    _animOffset = Tween(
      begin: _dragOffset,
      end: Offset(sign * (width + 200), 0),
    ).animate(_animController);

    _animRotation = Tween(
      begin: _dragRotation,
      end: sign * 0.6,
    ).animate(_animController);

    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(child: Text('Load error: $_loadError'));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _recipes.isEmpty
                    ? Text(loc.recipesNoMore)
                    : LayoutBuilder(
                        builder: (context, c) {
                          final visible = math.min(3, _recipes.length);
                          return SizedBox(
                            width: math.min(480, c.maxWidth * 0.95),
                            height: math.min(640, c.maxHeight * 0.9),
                            child: Stack(
                              children: List.generate(visible, (i) {
                                final recipe = _recipes[i];
                                final isTop = i == 0;

                                Widget card = _recipeCard(recipe);

                                if (isTop) {
                                  card = GestureDetector(
                                    onPanStart: (d) {
                                      _panStart = _dragOffset;
                                    },
                                    onPanUpdate: (d) {
                                      setState(() {
                                        _dragOffset = _panStart + d.delta;
                                        _dragRotation =
                                            _dragOffset.dx *
                                            _rotationMultiplier;
                                      });
                                    },
                                    onPanEnd: (_) => _onPanEnd(),
                                    onTap: () => _showDetails(recipe),
                                    child: Transform.translate(
                                      offset: _dragOffset,
                                      child: Transform.rotate(
                                        angle: _dragRotation,
                                        child: card,
                                      ),
                                    ),
                                  );
                                }

                                return Positioned.fill(child: card);
                              }).reversed.toList(),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'dislike',
                  backgroundColor: Colors.red,
                  onPressed: () => _triggerSwipe(_SwipeDirection.left),
                  child: const Icon(Icons.close),
                ),
                FloatingActionButton(
                  heroTag: 'like',
                  backgroundColor: Colors.green,
                  onPressed: () => _triggerSwipe(_SwipeDirection.right),
                  child: const Icon(Icons.check),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _recipeCard(Map<String, dynamic> r) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              r['image_url'] ?? r['image'] ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
            ),
          ),
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
              child: Text(
                r['title'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(Map<String, dynamic> recipe) async {
    final detail = await _getRecipeDetail(recipe['id'].toString());
    if (!mounted || detail == null) return;

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(detail['title'] ?? ''),
      ),
    );
  }
}
