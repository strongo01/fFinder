import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';

enum _SwipeDirection { left, right }

class RecipeFilters {
  List<String> kitchens = [];
  List<String> courses = [];
  List<String> tags = [];
  List<String> difficulties = [];
  int? maxKcal;
  int? maxPrepTime;

  bool get isEmpty =>
      kitchens.isEmpty &&
      courses.isEmpty &&
      tags.isEmpty &&
      difficulties.isEmpty &&
      maxKcal == null &&
      maxPrepTime == null;

  void reset() {
    kitchens.clear();
    courses.clear();
    tags.clear();
    difficulties.clear();
    maxKcal = null;
    maxPrepTime = null;
  }
}

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen>
    with SingleTickerProviderStateMixin {
  final String apiBase = 'https://ffinder.nl';
  final String apiKey = dotenv.env['APP_KEY']!;

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

  final List<Map<String, dynamic>> _recipes = [];
  final Set<String> _shownIds = {};
  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _isAnimating = false;
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();
  final RecipeFilters _currentFilters = RecipeFilters();
  Map<String, dynamic>? _filterOptions;

  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0.0;

  late AnimationController _animController;
  Animation<Offset>? _animOffset;
  Animation<double>? _animRotation;

  static const double _swipeThreshold = 100;
  static const double _rotationMultiplier = 0.003;

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(
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
        final dir = _dragOffset.dx > 0
            ? _SwipeDirection.right
            : _SwipeDirection.left;
        _handleSwipeComplete(dir);
        _resetAnimation();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialRecipes();
      _fetchFilterOptions();
    });
  }

  Future<void> _fetchFilterOptions() async {
    try {
      final res = await http.get(
        Uri.parse('$apiBase/recipes/filters'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            _filterOptions = json.decode(res.body);
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch filters: $e');
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final loc = AppLocalizations.of(context)!;
            final isDark = Theme.of(context).brightness == Brightness.dark;

            if (_filterOptions == null) {
              return Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Filters laden...'),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        _fetchFilterOptions().then((_) {
                          if (mounted) setSheetState(() {});
                        });
                      },
                      child: const Text('Opnieuw proberen'),
                    ),
                  ],
                ),
              );
            }

            final Map<String, String> cats = {
              'kitchens': loc.recipesKitchens,
              'courses': loc.recipesCourses,
              'tags': 'Tags',
              'difficulties': loc.recipesDetailDifficulty,
              'kcal': loc.recipesDetailKcal,
              'prepTime': loc.recipesDetailPreparationTime,
            };

            Widget buildMultiSelect(
              String categoryKey,
              List<String> currentValues,
              List<dynamic>? options,
              Function(String) onToggle,
            ) {
              if (options == null || options.isEmpty) return const SizedBox.shrink();
              return Wrap(
                spacing: 8,
                runSpacing: 4,
                children: options.map((opt) {
                  final val = opt.toString();
                  final isSelected = currentValues.contains(val);
                  return FilterChip(
                    label: Text(val),
                    selected: isSelected,
                    onSelected: (_) => onToggle(val),
                    selectedColor: Colors.orange.withOpacity(0.3),
                    checkmarkColor: Colors.orange,
                  );
                }).toList(),
              );
            }

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Filter op categorie(ën):',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: cats.entries.map((entry) {
                      bool isActive = false;
                      if (entry.key == 'kitchens') isActive = _currentFilters.kitchens.isNotEmpty;
                      if (entry.key == 'courses') isActive = _currentFilters.courses.isNotEmpty;
                      if (entry.key == 'tags') isActive = _currentFilters.tags.isNotEmpty;
                      if (entry.key == 'difficulties') isActive = _currentFilters.difficulties.isNotEmpty;
                      if (entry.key == 'kcal') isActive = _currentFilters.maxKcal != null;
                      if (entry.key == 'prepTime') isActive = _currentFilters.maxPrepTime != null;

                      return ChoiceChip(
                        label: Text(entry.value),
                        selected: isActive,
                        onSelected: (val) {
                          setSheetState(() {
                            if (!val) {
                              if (entry.key == 'kitchens') _currentFilters.kitchens.clear();
                              if (entry.key == 'courses') _currentFilters.courses.clear();
                              if (entry.key == 'tags') _currentFilters.tags.clear();
                              if (entry.key == 'difficulties') _currentFilters.difficulties.clear();
                              if (entry.key == 'kcal') _currentFilters.maxKcal = null;
                              if (entry.key == 'prepTime') _currentFilters.maxPrepTime = null;
                                } else {
                              if (entry.key == 'kcal') _currentFilters.maxKcal = _filterOptions!['max_kcal'] ?? 1500;
                              if (entry.key == 'prepTime') _currentFilters.maxPrepTime = _filterOptions!['max_prep_time'] ?? 120;
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const Divider(height: 32),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_currentFilters.kitchens.isNotEmpty || cats.keys.first == 'kitchens' && _currentFilters.kitchens.isEmpty && false) 
                          ...[
                             if (_currentFilters.kitchens.isNotEmpty || _currentFilters.isEmpty && false) Container(), 
                          ],
                          
                          if (_currentFilters.kitchens.isNotEmpty || _currentFilters.kitchens.isEmpty && false)
                          ...[],

                          if (_currentFilters.kitchens.isNotEmpty || cats.keys.toList().indexWhere((k)=>k=='kitchens') != -1 ) 
                             _buildFilterSection(loc.recipesKitchens, _currentFilters.kitchens.isNotEmpty, 
                             buildMultiSelect('kitchens', _currentFilters.kitchens, _filterOptions!['kitchens'], (v){
                               setSheetState((){
                                 if(_currentFilters.kitchens.contains(v)) _currentFilters.kitchens.remove(v);
                                 else _currentFilters.kitchens.add(v);
                               });
                             })),
                          
                          _buildFilterSection(loc.recipesCourses, _currentFilters.courses.isNotEmpty, 
                             buildMultiSelect('courses', _currentFilters.courses, _filterOptions!['courses'], (v){
                               setSheetState((){
                                 if(_currentFilters.courses.contains(v)) _currentFilters.courses.remove(v);
                                 else _currentFilters.courses.add(v);
                               });
                             })),

                          _buildFilterSection('Tags', _currentFilters.tags.isNotEmpty, 
                             buildMultiSelect('tags', _currentFilters.tags, _filterOptions!['tags'], (v){
                               setSheetState((){
                                 if(_currentFilters.tags.contains(v)) _currentFilters.tags.remove(v);
                                 else _currentFilters.tags.add(v);
                               });
                             })),

                          _buildFilterSection(loc.recipesDetailDifficulty, _currentFilters.difficulties.isNotEmpty, 
                             buildMultiSelect('difficulties', _currentFilters.difficulties, _filterOptions!['difficulties'], (v){
                               setSheetState((){
                                 if(_currentFilters.difficulties.contains(v)) _currentFilters.difficulties.remove(v);
                                 else _currentFilters.difficulties.add(v);
                               });
                             })),

                          _buildFilterSection(loc.recipesDetailKcal, _currentFilters.maxKcal != null, 
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text('Max: ${_currentFilters.maxKcal} kcal'),
                                 Slider(
                                   value: (_currentFilters.maxKcal ?? 1500).toDouble(),
                                   min: 0,
                                   max: (_filterOptions!['max_kcal'] ?? 1500).toDouble(),
                                   divisions: 20,
                                   activeColor: Colors.orange,
                                   onChanged: (v) => setSheetState(() => _currentFilters.maxKcal = v.round()),
                                 ),
                               ],
                             )),

                          _buildFilterSection(loc.recipesDetailPreparationTime, _currentFilters.maxPrepTime != null, 
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text('Max: ${_currentFilters.maxPrepTime} min'),
                                 Slider(
                                   value: (_currentFilters.maxPrepTime ?? 120).toDouble(),
                                   min: 0,
                                   max: (_filterOptions!['max_prep_time'] ?? 120).toDouble(),
                                   divisions: 12,
                                   activeColor: Colors.orange,
                                   onChanged: (v) => setSheetState(() => _currentFilters.maxPrepTime = v.round()),
                                 ),
                               ],
                             )),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _performSearch(_searchController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Toepassen', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () {
                      setSheetState(() => _currentFilters.reset());
                    },
                    child: Text('Filters wissen', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(String title, bool isVisible, Widget child) {
    if (!isVisible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  String? _loadError;

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _resetAnimation() {
    _isAnimating = false;
    _animOffset = null;
    _animRotation = null;
    _animController.reset();
    setState(() {
      _dragOffset = Offset.zero;
      _dragRotation = 0.0;
    });
  }

  Future<List<Map<String, dynamic>>> _getRecommendations({
    int limit = 5,
  }) async {
    final res = await http.get(
      Uri.parse('$apiBase/recipes/recommendations/$userId?limit=$limit'),
      headers: _headers,
    );
    debugPrint('RECS status=${res.statusCode} body=${res.body}');

    if (res.statusCode != 200) {
      final loc = AppLocalizations.of(context)!;
      throw Exception(loc.recipesErrorServer(res.statusCode.toString()));
    }

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
  }

  Future<void> _loadInitialRecipes() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _isSearchMode = false;
      _recipes.clear();
      _shownIds.clear();
    });

    try {
      final recs = await _getRecommendations();

      if (_isSearchMode) return;

      if (recs.isNotEmpty) {
        for (final r in recs) {
          final id = r['id']?.toString();
          if (id != null) {
            _recipes.add(r);
            _shownIds.add(id);
          }
        }
      } else {
        final loc = AppLocalizations.of(context)!;
        setState(() {
          _loadError = loc.recipesErrorNoRecommendations;
        });
      }
      debugPrint('Loaded recs: ${recs.length}');
    } catch (e) {
      debugPrint('Load recipes failed: $e');
      final loc = AppLocalizations.of(context)!;
      setState(() {
        if (e.toString().contains('502')) {
          _loadError = loc.recipesError502;
        } else {
          _loadError =
              '${loc.recipesErrorLoading}${e.toString().replaceFirst('Exception: ', '')}';
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty && _currentFilters.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _loadError = null;
      _isSearchMode = true;
      _recipes.clear();
      _shownIds.clear();
    });

    try {
      final queryParams = <String, dynamic>{
        'query': query,
      };

      if (_currentFilters.kitchens.isNotEmpty) {
        queryParams['kitchen'] = _currentFilters.kitchens;
      }
      if (_currentFilters.courses.isNotEmpty) {
        queryParams['course'] = _currentFilters.courses;
      }
      if (_currentFilters.tags.isNotEmpty) {
        queryParams['tag'] = _currentFilters.tags;
      }
      if (_currentFilters.difficulties.isNotEmpty) {
        queryParams['difficulty'] = _currentFilters.difficulties;
      }
      if (_currentFilters.maxKcal != null) {
        queryParams['max_kcal'] = _currentFilters.maxKcal.toString();
      }
      if (_currentFilters.maxPrepTime != null) {
        queryParams['max_prep_time'] = _currentFilters.maxPrepTime.toString();
      }

      final uri = Uri.parse('$apiBase/recipes/search').replace(
        queryParameters: queryParams,
      );

      final res = await http.get(uri, headers: _headers);
      debugPrint('SEARCH status=${res.statusCode} body=${res.body}');

      if (res.statusCode != 200) {
        final loc = AppLocalizations.of(context)!;
        throw Exception(loc.recipesErrorServer(res.statusCode.toString()));
      }

      final decoded = json.decode(res.body);
      List<Map<String, dynamic>> results = [];
      if (decoded is List) {
        results = List<Map<String, dynamic>>.from(decoded);
      } else if (decoded is Map && decoded['recipes'] is List) {
        results = List<Map<String, dynamic>>.from(decoded['recipes']);
      } else if (decoded is Map && decoded['results'] is List) {
        results = List<Map<String, dynamic>>.from(decoded['results']);
      }

      final limitedResults = results.take(30).toList();
      final detailFutures = limitedResults.map((r) {
        final id = r['id']?.toString();
        if (id == null) return Future.value(null);
        return _getRecipeDetail(id);
      }).toList();

      final details = await Future.wait(detailFutures);
      final List<Map<String, dynamic>> detailedRecipes = [];
      for (var d in details) {
        if (d != null) detailedRecipes.add(d);
      }

      final loc = AppLocalizations.of(context)!;
      setState(() {
        if (detailedRecipes.isEmpty) {
          _loadError = results.isEmpty
              ? loc.recipesNoResultsFound(query)
              : loc.recipesErrorLoadingDetails;
        } else {
          for (final r in detailedRecipes) {
            final id = r['id']?.toString();
            if (id != null) {
              _recipes.add(r);
              _shownIds.add(id);
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Search failed: $e');
      final loc = AppLocalizations.of(context)!;
      setState(() {
        _loadError =
            '${loc.recipesErrorSearchFailed}${e.toString().replaceFirst('Exception: ', '')}';
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

  Future<void> _rateRecipe(int recipeId, int rating) async {
    debugPrint('rateRecipe: id=$recipeId rating=$rating');
    try {
      final response = await http.post(
        Uri.parse('$apiBase/recipes/rate'),
        headers: _headers,
        body: json.encode({
          'user_id': userId,
          'recipe_id': recipeId,
          'rating': rating,
        }),
      );
      debugPrint('rateRecipe: done. status=${response.statusCode}');
    } catch (e) {
      debugPrint('rateRecipe: error=$e');
    }
  }

  void _handleSwipeComplete(_SwipeDirection dir) async {
    if (_recipes.isEmpty) return;

    final recipe = _recipes.removeAt(0);
    setState(() {});

    final liked = dir == _SwipeDirection.right;

    _rateRecipe(int.parse(recipe['id'].toString()), liked ? 5 : 1).catchError((
      e,
    ) {
      debugPrint('Rating failed: $e');
      return null;
    });

    if (_recipes.isNotEmpty || _isFetchingMore || _isSearchMode) {
      return;
    }

    setState(() => _isFetchingMore = true);

    try {
      final newRecs = await _getRecommendations(limit: 5);

      if (_isSearchMode) return;

      int addedCount = 0;
      for (final r in newRecs) {
        final id = r['id']?.toString();
        if (id != null && !_shownIds.contains(id)) {
          _recipes.add(r);
          _shownIds.add(id);
          addedCount++;
        }
      }
      debugPrint(
        'Fetched more: ${newRecs.length} total, added $addedCount new',
      );
    } catch (e) {
      debugPrint('Fetch more failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isFetchingMore = false);
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;

    final velocity = details.velocity.pixelsPerSecond.dx;
    final bool fastSwipe =
        velocity.abs() > 500 && velocity.sign == _dragOffset.dx.sign;
    final bool farSwipe = _dragOffset.dx.abs() > _swipeThreshold;

    if (farSwipe || fastSwipe) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: loc.recipesSearchHint,
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty ||
                          _isSearchMode ||
                          !_currentFilters.isEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _currentFilters.reset();
                            _loadInitialRecipes();
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: _currentFilters.isEmpty
                              ? Colors.grey
                              : Colors.orange,
                        ),
                        onPressed: _showFilterSheet,
                      ),
                    ],
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onSubmitted: (val) => _performSearch(val),
                onChanged: (val) => setState(() {}),
              ),
            ),

            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : _loadError != null
                    ? Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu_outlined,
                              size: 80,
                              color: isDark ? Colors.grey[700] : Colors.grey[300],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _loadError!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: _loadInitialRecipes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.refresh),
                              label: Text(loc.recipesRetry),
                            ),
                          ],
                        ),
                      )
                    : _recipes.isEmpty
                    ? (_isFetchingMore
                          ? const CircularProgressIndicator()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Icon(
                                  _isSearchMode ? Icons.check_circle_outline : Icons.error_outline,
                                  size: 64,
                                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _isSearchMode ? loc.recipesNoMoreSearchResults : loc.recipesErrorNoMoreRecipes,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _loadInitialRecipes,
                                  icon: const Icon(Icons.refresh),
                                  label: Text(loc.recipesRetry),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ))
                    : LayoutBuilder(
                        builder: (context, c) {
                          final visible = math.min(3, _recipes.length);
                          return SizedBox(
                            width: math.min(380, c.maxWidth * 0.85),
                            height: math.min(580, c.maxHeight * 0.8),
                            child: Stack(
                              children: List.generate(visible, (i) {
                                final recipe = _recipes[i];
                                final isTop = i == 0;

                                Widget card = _recipeCard(recipe);

                                if (isTop) {
                                  card = GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onPanUpdate: (d) {
                                      setState(() {
                                        _dragOffset += d.delta;
                                        _dragRotation =
                                            _dragOffset.dx *
                                            _rotationMultiplier;
                                      });
                                    },
                                    onPanEnd: (d) => _onPanEnd(d),
                                    onTap: () {
                                      debugPrint(
                                        'Tapped recipe: ${recipe['id']}',
                                      );
                                      _showDetails(recipe);
                                    },
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

            if (_recipes.isNotEmpty && !_isLoading) ...[
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
          ],
        ),
      ),
    ));
  }

  Widget _recipeCard(Map<String, dynamic> r) {
    final title = r['title']?.toString() ?? '';
    final imageUrl = _getSafeImageUrl(r);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: _buildNetworkImage(imageUrl, title)),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _cardTag(
                        Icons.timer_outlined,
                        '${r['preparation_time'] ?? '?'}\'',
                      ),
                      const SizedBox(width: 8),
                      _cardTag(
                        Icons.local_fire_department_outlined,
                        '${r['kcal'] ?? '?'}',
                      ),
                      const SizedBox(width: 8),
                      if (r['difficulty'] != null)
                        _cardTag(
                          Icons.speed_outlined,
                          r['difficulty']['name'] ?? '?',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String url, String title, {double? height}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.network(
      url,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: isDark ? Colors.grey[900] : Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        final boodschappenUrl = _getBoodschappenUrl(title);
        final placeholderUrl = _getPlaceholderUrl(title);

        if (url != boodschappenUrl && !url.contains('placehold.co')) {
          return _buildNetworkImage(boodschappenUrl, title, height: height);
        }

        if (url != placeholderUrl) {
          return _buildNetworkImage(placeholderUrl, title, height: height);
        }

        return _buildImageErrorPlaceholder(height);
      },
    );
  }

  Widget _buildImageErrorPlaceholder(double? height) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      color: isDark ? Colors.grey[900] : Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: 64,
          color: isDark ? Colors.grey[700] : Colors.grey,
        ),
      ),
    );
  }

  String _getSafeImageUrl(Map<String, dynamic> r) {
    final title = r['title']?.toString() ?? 'recept';
    final apiLink = (r['image_link'] ?? r['image_url'] ?? r['image'] ?? '')
        .toString();

    if (apiLink.isNotEmpty &&
        apiLink != 'null' &&
        !apiLink.contains('placehold.co')) {
      return apiLink;
    }

    return _getBoodschappenUrl(title);
  }

  String _getBoodschappenUrl(String title) {
    final slug = title
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');

    return 'https://www.boodschappen.nl/app/uploads/recipe_images/4by3_header@2x/$slug.jpg';
  }

  String _getPlaceholderUrl(String title) {
    final cleanTitle = title.trim();
    return 'https://placehold.co/600x400.png?text=${Uri.encodeComponent(cleanTitle)}';
  }

  void _showDetails(Map<String, dynamic> recipe) async {
    final detail = await _getRecipeDetail(recipe['id'].toString());
    if (!mounted || detail == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecipeDetailSheet(detail: detail),
    );
  }
}

class _RecipeDetailImage extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _RecipeDetailImage({required this.imageUrl, required this.title});

  String _getBoodschappenUrl(String title) {
    final slug = title
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
    return 'https://www.boodschappen.nl/app/uploads/recipe_images/4by3_header@2x/$slug.jpg';
  }

  String _getPlaceholderUrl(String title) {
    return 'https://placehold.co/600x400.png?text=${Uri.encodeComponent(title.trim())}';
  }

  @override
  Widget build(BuildContext context) {
    return _buildImage(context, imageUrl);
  }

  Widget _buildImage(BuildContext context, String url) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.network(
      url,
      width: double.infinity,
      height: 220,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: double.infinity,
          height: 220,
          color: isDark ? Colors.grey[900] : Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        final bUrl = _getBoodschappenUrl(title);
        final pUrl = _getPlaceholderUrl(title);

        if (url != bUrl && !url.contains('placehold.co')) {
          return _buildImage(context, bUrl);
        }
        if (url != pUrl) {
          return _buildImage(context, pUrl);
        }
        return _buildErrorIcon(context);
      },
    );
  }

  Widget _buildErrorIcon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: 220,
      color: isDark ? Colors.grey[900] : Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: 64,
          color: isDark ? Colors.grey[700] : Colors.grey,
        ),
      ),
    );
  }
}

class _RecipeDetailSheet extends StatelessWidget {
  final Map<String, dynamic> detail;

  const _RecipeDetailSheet({required this.detail});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = detail['title'] ?? '';
    String imageUrl =
        (detail['image_link'] ?? detail['image_url'] ?? detail['image'] ?? '')
            .toString();

    if (imageUrl.isEmpty || imageUrl == 'null' || imageUrl.contains('placehold.co')) {
      final slug = title
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '-');
      imageUrl = 'https://www.boodschappen.nl/app/uploads/recipe_images/4by3_header@2x/$slug.jpg';
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: _RecipeDetailImage(
                        imageUrl: imageUrl,
                        title: title,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                _detailCardTag(
                                  Icons.timer_outlined,
                                  '${detail['preparation_time'] ?? '?'}\'',
                                ),
                                _detailCardTag(
                                  Icons.local_fire_department_outlined,
                                  '${detail['kcal'] ?? '?'}',
                                ),
                                if (detail['difficulty'] != null)
                                  _detailCardTag(
                                    Icons.speed_outlined,
                                    detail['difficulty']['name'] ?? '?',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _infoItem(
                            context,
                            Icons.timer_outlined,
                            '${detail['preparation_time'] ?? '?'}\'',
                            loc.recipesDetailPreparationTime,
                          ),
                          _infoItem(
                            context,
                            Icons.local_fire_department_outlined,
                            '${detail['kcal'] ?? '?'}',
                            loc.recipesDetailKcal,
                          ),
                          if (detail['difficulty'] != null)
                            _infoItem(
                              context,
                              Icons.speed_outlined,
                              detail['difficulty']['name'] ?? '?',
                              loc.recipesDetailDifficulty,
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      _sectionTitle(context, loc.personalInfo),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 20,
                        runSpacing: 12,
                        children: [
                          _nutriSmall(context, loc.recipesDetailFat, detail['fat']),
                          _nutriSmall(context, loc.recipesDetailCarbs, detail['carbs']),
                          _nutriSmall(
                            context,
                            loc.recipesDetailProtein,
                            detail['protein'],
                          ),
                          _nutriSmall(
                            context,
                            loc.recipesDetailFibers,
                            detail['fibers'],
                          ),
                          _nutriSmall(
                            context,
                            loc.recipesDetailSalt,
                            detail['salt'],
                            unit: 'mg',
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      if (detail['kitchens'] != null ||
                          detail['courses'] != null ||
                          detail['tags'] != null) ...[
                        _sectionTitle(context, loc.recipesDetailCharacteristics),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (detail['kitchens'] is List)
                              ...(detail['kitchens'] as List).map(
                                (k) => _chipTag(
                                  k['name'] ?? '',
                                  isDark ? Colors.blue.withOpacity(0.2) : Colors.blue[50]!,
                                  isDark ? Colors.blue[200]! : Colors.blue,
                                ),
                              ),
                            if (detail['courses'] is List)
                              ...(detail['courses'] as List).map(
                                (c) => _chipTag(
                                  c['main'] ?? '',
                                  isDark ? Colors.green.withOpacity(0.2) : Colors.green[50]!,
                                  isDark ? Colors.green[200]! : Colors.green,
                                ),
                              ),
                            if (detail['tags'] is List)
                              ...(detail['tags'] as List).map(
                                (t) => _chipTag(
                                  t['sub'] ?? t['name'] ?? '',
                                  isDark ? Colors.orange.withOpacity(0.2) : Colors.orange[50]!,
                                  isDark ? Colors.orange[200]! : Colors.orange,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],

                      if (detail['requirements'] != null &&
                          (detail['requirements'] as List).isNotEmpty) ...[
                        _sectionTitle(context, loc.recipesDetailRequirements),
                        const SizedBox(height: 12),
                        ...?_buildRequirements(context, detail['requirements']),
                        const SizedBox(height: 32),
                      ],

                      _sectionTitle(context, loc.recipesIngredients),
                      const SizedBox(height: 12),
                      ...?_buildIngredients(detail['ingredients']),

                      const SizedBox(height: 32),

                      _sectionTitle(context, loc.recipesSteps),
                      const SizedBox(height: 12),
                      ...?_buildSteps(context, detail['steps']),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailCardTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipTag(String label, Color bg, Color text) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: text.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget>? _buildRequirements(BuildContext context, dynamic reqs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (reqs is! List) return null;
    return reqs.map((r) {
      final name = r['name_singular'] ?? r['name_plural'] ?? '';
      final variant = r['variant_name'] != null ? ' (${r['variant_name']})' : '';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.handyman_outlined,
              size: 18,
              color: isDark ? Colors.grey[400] : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text('$name$variant', style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
    }).toList();
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }

  Widget _infoItem(BuildContext context, IconData icon, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(icon, color: Colors.orange, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _nutriSmall(BuildContext context, String label, dynamic value, {String unit = 'g'}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (value == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 13,
          ),
        ),
        Text(
          '$value $unit',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    );
  }

  List<Widget>? _buildIngredients(dynamic ingredients) {
    if (ingredients is! List) return null;
    return ingredients.map((ing) {
      final amount = ing['amount'] ?? '';
      final unit = ing['unit'] ?? '';
      final name = ing['name'] ?? '';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: Text(
                '$amount $unit $name'.trim(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget>? _buildSteps(BuildContext context, dynamic steps) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (steps is! List) return null;
    int i = 1;
    return steps.map((step) {
      final text = step['text'] ?? step.toString();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isDark ? Colors.orange.withOpacity(0.2) : Colors.orange[100],
              child: Text(
                '${i++}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
