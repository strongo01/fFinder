import 'dart:async';

import 'package:cryptography/cryptography.dart';
import 'package:fFinder/views/crypto_class.dart';
import 'package:fFinder/views/feedback_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'edit_product_view.dart';
import 'barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ai/firebase_ai.dart';

enum SourceStatus { idle, loading, success, error }

SourceStatus _ffinderStatus = SourceStatus.idle;
SourceStatus _offStatus = SourceStatus.idle;

class AddFoodPage extends StatefulWidget {
  final String? scannedBarcode;
  final Map<String, dynamic>?
  initialProductData; //initialproductdata: de data van het product als die al bekend is (barcode)
  final DateTime? selectedDate;
  const AddFoodPage({
    super.key,
    this.scannedBarcode,
    this.initialProductData,
    this.selectedDate,
  });
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _searchController = TextEditingController();
  int _selectedTabIndex = 0;
  String? _errorMessage;
  bool _isLoading = false;
  List<dynamic>? _searchResults;
  final List<bool> _selectedToggle = <bool>[
    true,
    false,
    false,
    false,
  ]; // Recent, Favorieten, Mijn producten, Maaltijden

  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _barcodeKey = GlobalKey();
  final GlobalKey _recentKey = GlobalKey();
  final GlobalKey _favoritesKey = GlobalKey();
  final GlobalKey _myproductsKey = GlobalKey();
  final GlobalKey _myproductsAddKey = GlobalKey();
  final GlobalKey _maaltijdenKey = GlobalKey();
  final GlobalKey _maaltijdenAddKey = GlobalKey();
  final GlobalKey _maaltijdenLogKey = GlobalKey();

  bool _isSheetShown =
      false; // Vlag om te controleren of de sheet al is getoond

  late TutorialCoachMark tutorialCoachMark;
  int _searchToken = 0;

  bool _hasLoadedMore = false;

  @override
  void initState() {
    super.initState();
    _createTutorial();
    _handleInitialAction();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Verplaatst naar initState om meervoudige aanroepen te voorkomen
  }

  void _handleInitialAction() async {
    // Wacht kort om zeker te zijn dat context beschikbaar is.
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted || _isSheetShown) return;

    final user = FirebaseAuth.instance.currentUser;
    bool tutorialCompleted = false;

    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        tutorialCompleted = userDoc.data()?['tutorialFoodAf'] ?? false;
      } catch (e) {
        debugPrint("[ADD_FOOD_VIEW] Kon tutorial status niet ophalen: $e");
      }
    }

    if (widget.scannedBarcode != null) {
      debugPrint(
        "[ADD_FOOD_VIEW] _handleInitialAction: Barcode detected from widget.",
      );
      debugPrint(
        "[ADD_FOOD_VIEW] _handleInitialAction: initialProductData: ${widget.initialProductData}",
      );

      _isSheetShown = true; // voorkom herhaling

      // Als er geen initialProductData is, probeer OFF te fetchen voordat sheet opent
      Map<String, dynamic>? productData = widget.initialProductData;
      if (productData == null) {
        try {
          final offUrl = Uri.parse(
            'https://nl.openfoodfacts.org/api/v0/product/${widget.scannedBarcode}.json',
          );
          final resp = await http.get(offUrl);
          if (resp.statusCode == 200) {
            final j = jsonDecode(resp.body) as Map<String, dynamic>;
            if (j['status'] == 1 && j['product'] is Map) {
              final fetched = Map<String, dynamic>.from(j['product'] as Map);

              // helper: parse numeric-ish values
              double _asDouble(dynamic v) {
                if (v == null) return 0.0;
                if (v is num) return v.toDouble();
                if (v is String)
                  return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
                return 0.0;
              }

              // normaliseer nutriments indien nodig
              if (fetched['nutriments_per_100g'] == null &&
                  fetched['nutriments'] is Map) {
                final n = fetched['nutriments'] as Map<String, dynamic>;
                fetched['nutriments_per_100g'] = {
                  'energy-kcal': _asDouble(
                    n['energy-kcal_100g'] ?? n['energy-kcal'],
                  ),
                  'fat': _asDouble(n['fat_100g'] ?? n['fat']),
                  'saturated-fat': _asDouble(
                    n['saturated-fat_100g'] ?? n['saturated-fat'],
                  ),
                  'carbohydrates': _asDouble(
                    n['carbohydrates_100g'] ?? n['carbohydrates'],
                  ),
                  'sugars': _asDouble(n['sugars_100g'] ?? n['sugars']),
                  'fiber': _asDouble(n['fiber_100g'] ?? n['fiber']),
                  'proteins': _asDouble(n['proteins_100g'] ?? n['proteins']),
                  'salt': _asDouble(n['salt_100g'] ?? n['salt']),
                };
              } else if (fetched['nutriments_per_100g'] is Map) {
                final mp = Map<String, dynamic>.from(
                  fetched['nutriments_per_100g'] as Map,
                );
                final fixed = <String, dynamic>{};
                for (final k in mp.keys) {
                  fixed[k] = _asDouble(mp[k]);
                }
                fetched['nutriments_per_100g'] = fixed;
              }

              // normaliseer tags via bestaande helper
              fetched['allergens_tags'] = _normalizeTags(
                fetched['allergens_tags'] ?? fetched['allergens'],
              );
              fetched['additives_tags'] = _normalizeTags(
                fetched['additives_tags'] ?? fetched['additives'],
              );
              fetched['traces_tags'] = _normalizeTags(
                fetched['traces_tags'] ?? fetched['traces'],
              );

              // vul enkele velden zodat sheet minder hoeft te fetchen
              fetched['product_name'] = fetched['product_name'] ?? '';
              fetched['brands'] = fetched['brands'] ?? '';
              fetched['quantity'] = fetched['quantity'] ?? '';
              fetched['serving_size'] = _extractServingSize(
                fetched['serving_size'] ??
                    fetched['serving-size'] ??
                    fetched['servingSize'] ??
                    fetched['serving_quantity'],
              );
              productData = fetched;
              debugPrint(
                "[ADD_FOOD_VIEW] Fetched product from OFF for ${widget.scannedBarcode}",
              );
            }
          }
        } catch (e) {
          debugPrint(
            "[ADD_FOOD_VIEW] OFF fetch failed in _handleInitialAction: $e",
          );
        }
      }

      // Open sheet met (mogelijk) gefetchte data
      if (mounted) {
        _showProductDetails(widget.scannedBarcode!, productData: productData);
      }
    } else if (!tutorialCompleted) {
      // Start tutorial alleen als geen barcode
      debugPrint(
        "[ADD_FOOD_VIEW] _handleInitialAction: No barcode, starting tutorial.",
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          tutorialCoachMark.show(context: context);
        }
      });
    }
  }

  void _createTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(context),
      colorShadow: Colors.blue.withOpacity(0.7),
      paddingFocus: 10,
      opacityShadow: 0.8,
      hideSkip: false,
      onFinish: () {
        debugPrint("Tutorial voltooid");
        prefs.setBool('food_tutorial_shown', true); // lokaal opslaan
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'tutorialFoodAf': true,
          });
        }
      },
      onSkip: () {
        debugPrint("Tutorial overgeslagen");
        prefs.setBool('food_tutorial_shown', true);
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'tutorialFoodAf': true,
          });
        }
        return true; // Return true om de tutorial te sluiten
      },
      onClickTarget: (target) {
        // wanneer een target wordt aangeklikt
        debugPrint('Target geklikt: $target');
        final String? identify = target.identify;
        int? targetIndex;

        switch (identify) {
          case 'recent-key':
            targetIndex = 0;
            break;
          case 'favorites-key':
            targetIndex = 1;
            break;
          case 'myproducts-key':
            targetIndex = 2;
            break;
          case 'maaltijden-key':
            targetIndex = 3;
            break;
        }

        if (targetIndex != null) {
          setState(() {
            _selectedTabIndex = targetIndex!;
            for (int i = 0; i < _selectedToggle.length; i++) {
              // update toggle state
              _selectedToggle[i] = i == targetIndex;
            }
          });
        }
      },
    );
  }

  List<TargetFocus> _createTargets(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    List<TargetFocus> targets = [];

    //Zoekbalk
    targets.add(
      TargetFocus(
        identify: "search-key",
        keyTarget: _searchKey,
        shape: ShapeLightFocus.RRect,
        color: Colors.blue,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              'Zoekbalk',
              'Hier kan je een product zoeken om toe te voegen aan je dag.',
              isDarkMode,
            ),
          ),
        ],
      ),
    );
    //Barcode
    targets.add(
      TargetFocus(
        identify: "barcode-key",
        keyTarget: _barcodeKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              'Barcode Scannen',
              'Tik hier om een product te scannen en snel toe te voegen aan je dag.',
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    // Recent
    targets.add(
      TargetFocus(
        identify: "recent-key",
        keyTarget: _recentKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              'Recente Producten',
              'Hier zie je alle producten die je recent hebt toegevoegd.',
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    // Favorieten-kaart
    targets.add(
      TargetFocus(
        identify: "favorites-key",
        keyTarget: _favoritesKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              'Favorieten',
              'Hier zie je al jouw favoriete producten.',
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    // Mijn producten
    targets.add(
      TargetFocus(
        identify: "myproducts-key",
        keyTarget: _myproductsKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              'Mijn producten',
              'Hier kan je zelf producten toevoegen die niet gevonden kunnen worden.',
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    // Maaltijden knop
    targets.add(
      TargetFocus(
        identify: "maaltijden-key",
        keyTarget: _maaltijdenKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              'Maaltijden',
              'Hier kan je maaltijden zien en loggen, maaltijden bestaan uit meerdere producten.',
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    // Maaltijden knop +
    targets.add(
      TargetFocus(
        identify: "maaltijdenplus-key",
        keyTarget: _maaltijdenAddKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              'Maaltijden toevoegen',
              'Tik op dit plusje om maaltijden te maken uit meerdere producten, zodat je sneller vaak gegeten maaltijden kan toevoegen.',
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    // Maaltijden knop toevoegen
    targets.add(
      TargetFocus(
        identify: "maaltijdenlog-key",
        keyTarget: _maaltijdenLogKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              'Maaltijden loggen',
              'Tik op dit winkelwagentje om maaltijden toe te voegen aan de logs.',
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    return targets;
  }

  Widget _buildTutorialContent(String title, String text, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //<Widget> omdat anders error geeft
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _normalize(String? s) {
    if (s == null || s.isEmpty) return '';
    var v = s.toLowerCase();
    v = v.replaceAll(RegExp(r'[-–—/,&+]'), ' ');
    v = v.replaceAll(RegExp(r'[^\w\s]', unicode: true), ' ');
    return v.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  List<String> _tokensWithCompounds(String? s) {
    final base = _normalize(s);
    if (base.isEmpty) return [];

    // losse tokens
    final parts = base.split(' ').where((e) => e.isNotEmpty).toList();

    final out = <String>[];
    out.addAll(parts);

    // voeg bigram-concatenaties toe (volkoren + brood -> volkorenbrood)
    for (int i = 0; i < parts.length - 1; i++) {
      out.add(parts[i] + parts[i + 1]);
    }

    // voeg full concat toe (als meerdere woorden) (volkoren brood tarwe -> volkorenbroodtarwe)
    if (parts.length > 1) {
      out.add(parts.join());
    }

    // optioneel: voeg trigram concats (beperkt) — comment uit als je dat te ver vindt
    // if (parts.length >= 3) out.add(parts[0] + parts[1] + parts[2]);

    // dedupe and return
    return out.toSet().toList();
  }

  bool _isSingleWordQuery(String q) {
    return q.trim().split(' ').length == 1;
  }

  String _stem(String token) {
    // eenvoudige singularisatie: appels -> appel, bananen -> banaan
    if (token.length <= 3) return token;
    if (token.endsWith('en')) return token.substring(0, token.length - 2);
    if (token.endsWith('s')) return token.substring(0, token.length - 1);
    return token;
  }

  int scoreProduct(Map p, String query) {
    final rawName = (p['product_name'] ?? p['generic_name'] ?? '').toString();
    if (rawName.isEmpty) return 0;

    final name = _normalize(rawName);
    final nameTokensRaw = _tokensWithCompounds(
      rawName,
    ); // tokens from raw name, normalized
    final nameTokens = nameTokensRaw
        .map((t) => _stem(t))
        .toList(); // stemmed tokens
    final queryTokens = _tokensWithCompounds(
      query,
    ).map((t) => _stem(t)).toList();

    final categories = _normalize(p['categories'] ?? '');
    final catTags = _normalize((p['categories_tags'] ?? '').toString());

    final hasSeparator =
        rawName.contains(',') ||
        rawName.contains('&') ||
        rawName.contains('/') ||
        rawName.contains('-');

    int score = 0;
    final reasons = <String>[];

    // 1) token-based matching (gestemd)
    for (final qt in queryTokens) {
      if (nameTokens.contains(qt)) {
        score += 900; // sterke match op gestemd token
        reasons.add('+900 token match (stemmed) [$qt]');
      } else if (nameTokensRaw.any((t) => t.startsWith(qt))) {
        score += 250; // token startsWith query (appelmoes, appel-limoen)
        reasons.add('+250 token startsWith [$qt]');
      } else if (name.contains(qt)) {
        score += 150; // substring fallback
        reasons.add('+150 substring match [$qt]');
      }
      // category boost per token
      if (categories.contains(qt) || catTags.contains(qt)) {
        score += 700;
        reasons.add('+700 category match [$qt]');
      }
    }

    // 2) exact normalized full-string match
    if (name == _normalize(query)) {
      score += 1400;
      reasons.add('+1400 exact name == query');
    }

    // 3) commodity boost for single-word queries when product looks "simple"
    final isSingle = _isSingleWordQuery(query);
    if (isSingle) {
      final qt = queryTokens.isNotEmpty ? queryTokens.first : '';
      if (qt.isNotEmpty &&
          nameTokens.contains(qt) &&
          !hasSeparator &&
          nameTokens.length <= 3) {
        score += 1000;
        reasons.add('+1000 commodity boost');
      }
      // milde penalty for clear combos
      if (hasSeparator || nameTokens.length >= 4) {
        score -= 400;
        reasons.add('-400 combo/long (single-word intent)');
      }
    }

    // 4) processed-word penalty (detect ook in compounds)
    const processedWords = [
      'stroop',
      'sap',
      'drink',
      'smoothie',
      'reep',
      'repen',
      'koek',
      'koeken',
      'muesli',
      'granola',
      'kwark',
      'yoghurt',
      'saus',
      'puree',
      'chips',
    ];
    for (final w in processedWords) {
      // check stemmed tokens and raw tokens contains
      if (nameTokens.any((t) => t.contains(w)) ||
          nameTokensRaw.any((t) => t.contains(w))) {
        score -= 800; // milder dan eerst, maar merkbaar
        reasons.add('-800 processed contains ($w)');
        // break; // optional: break after first processed word found
      }
    }

    // 5) length penalty (mild)
    if (nameTokensRaw.length >= 6) {
      score -= 250;
      reasons.add('-250 long name');
    }

    // tie-breaker prefer filled product_name
    if (name.isNotEmpty) {
      score += 5;
    }

    debugPrint('SCORE $score — $rawName → ${reasons.join(', ')}');
    return score;
  }

  bool isPrimaryProduct(Map p, String query) {
    final categories = _normalize(p['categories']);
    final tags = _normalize((p['categories_tags'] ?? '').toString());

    // exacte productcategorie (meest betrouwbaar)
    if (categories.contains(query) || tags.contains(query)) {
      return true;
    }

    // enkelvoudige productnaam (zoals "appel", "elstar", "fuji")
    final nameTokens = _tokensWithCompounds(p['product_name']);
    if (nameTokens.length <= 2 && nameTokens.any((t) => t == query)) {
      return true;
    }

    return false;
  }

  List<Map<String, dynamic>> _rankProducts(
    List products,
    String query, {
    int take = 50,
  }) {
    final q = _normalize(query);
    final ranked = products.map((p) {
      final map = p as Map<String, dynamic>;
      final score = scoreProduct(map, q);
      return {'product': map, 'score': score};
    }).toList();

    ranked.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return ranked
        .take(take)
        .map((e) => Map<String, dynamic>.from(e['product'] as Map))
        .toList();
  }

  Future<void> _searchProducts(String query, {bool loadMore = false}) async {
    // zoek producten via openfoodfacts api
    if (query.isEmpty) {
      setState(() {
        _searchResults = null;
        _isLoading = false;
      });
      return;
    }

    final trimmed = query.trim(); // verwijder spaties aan begin en eind

    if (trimmed.length < 2) {
      // minimaal 2 tekens
      setState(() {
        _searchResults = null;
        _errorMessage = 'Voer minimaal 2 tekens in.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;

      _ffinderStatus = SourceStatus.loading;
      _offStatus = SourceStatus.loading;
    });
    final int currentToken = ++_searchToken;

    _searchOffParallel(trimmed)
        .then((offProducts) {
          if (!mounted || offProducts.isEmpty) return;
          if (currentToken != _searchToken) return; // voorkom oude resultaten
          if (offProducts.isNotEmpty) {
            setState(() {
              _offStatus = SourceStatus.success;
              final merged = _mergeProductsPreserveLogic(
                _searchResults ?? [],
                offProducts,
              );
              _searchResults = _rankProducts(merged, trimmed, take: 50);
            });
          } else {
            // lege lijst of timeout -> markeer als error
            setState(() {
              _offStatus = SourceStatus.error;
            });
          }
        })
        .catchError((e) {
          if (!mounted) return;
          setState(() {
            _offStatus = SourceStatus.error;
          });
        });

    try {
      List all = []; // Lege lijst om producten op te slaan

      try {
        debugPrint("--- Poging 1: ffinder.nl endpoint ---");
        final ffinderUrl = Uri.parse(
          "https://ffinder.nl/product?q=${Uri.encodeComponent(trimmed)}",
        );
        debugPrint("URL: $ffinderUrl");

        final appKey = dotenv.env["APP_KEY"];
        final response = await http.get(
          ffinderUrl,
          headers: {"x-app-key": appKey ?? ""},
        );

        debugPrint("ffinder.nl Status Code: ${response.statusCode}");
        debugPrint("ffinder.nl Response Headers: ${response.headers}");

        if (response.statusCode == 200) {
          debugPrint(
            "ffinder.nl response body (preview): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}",
          );
          final data = jsonDecode(response.body);
          final foodsObject = data["foods"];
          if (foodsObject != null && foodsObject["food"] is List) {
            final productsRaw = foodsObject["food"] as List;
            // Maak een bewerkbare kopie (Map per item)
            final products = productsRaw
                .map((p) => p is Map ? Map<String, dynamic>.from(p) : {})
                .toList();

            // Toon direct de producten (zonder extra OFF-afbeeldingen)
            setState(() {
              _searchResults = _rankProducts(products, trimmed, take: 50);
              _ffinderStatus = products.isNotEmpty
                  ? SourceStatus.success
                  : SourceStatus.error;
            });

            // Asynchroon: verrijk elk product met afbeelding van OFF (indien barcode aanwezig)
            for (int i = 0; i < products.length; i++) {
              final raw = products[i];
              try {
                final code =
                    raw['barcode'] ??
                    raw['code'] ??
                    raw['_id'] ??
                    raw['gtin'] ??
                    raw['ean'];
                final barcode = code?.toString();
                if (barcode == null || barcode.isEmpty) continue;

                // Fire-and-forget fetch per product — kleine timeout en foutafhandeling
                () async {
                  try {
                    final offUrl = Uri.parse(
                      'https://nl.openfoodfacts.org/api/v0/product/$barcode.json',
                    );
                    final offResp = await http
                        .get(offUrl)
                        .timeout(const Duration(seconds: 6));
                    if (offResp.statusCode != 200) return;
                    final offJson =
                        jsonDecode(offResp.body) as Map<String, dynamic>?;
                    if (offJson == null ||
                        offJson['status'] != 1 ||
                        offJson['product'] is! Map)
                      return;
                    final offProd = offJson['product'] as Map<String, dynamic>;
                    final img =
                        offProd['image_front_small_url'] ??
                        offProd['image_front_thumb_url'] ??
                        offProd['image_front_url'];
                    if (img is String && img.isNotEmpty) {
                      // Update local copy
                      raw['image_front_small_url'] = img;

                      // Zoek en update in de getoonde lijst (indien nog zichtbaar)
                      if (mounted) {
                        setState(() {
                          if (_searchResults != null &&
                              _searchResults!.isNotEmpty) {
                            // replace matching product by id/code if present, anders by identity
                            for (int j = 0; j < _searchResults!.length; j++) {
                              final p =
                                  _searchResults![j] as Map<String, dynamic>;
                              final idP =
                                  (p['_id'] ?? p['code'] ?? p['barcode'])
                                      ?.toString();
                              final idRaw =
                                  (raw['_id'] ?? raw['code'] ?? raw['barcode'])
                                      ?.toString();
                              if (idP != null &&
                                  idRaw != null &&
                                  idP == idRaw) {
                                final updated = Map<String, dynamic>.from(p);
                                updated['image_front_small_url'] = img;
                                _searchResults![j] = updated;
                                return;
                              }
                            }
                            // fallback: update first occurrence of same product_name
                            for (int j = 0; j < _searchResults!.length; j++) {
                              final p =
                                  _searchResults![j] as Map<String, dynamic>;
                              if ((p['product_name'] ?? '') ==
                                  (raw['product_name'] ?? '')) {
                                final updated = Map<String, dynamic>.from(p);
                                updated['image_front_small_url'] = img;
                                _searchResults![j] = updated;
                                return;
                              }
                            }
                          }
                        });
                      }
                    }
                  } catch (e) {
                    debugPrint(
                      '[ffinder->OFF image async] failed for $barcode: $e',
                    );
                  }
                }();
              } catch (e) {
                debugPrint('[ffinder processing] item error: $e');
              }
            }

            // zet 'all' zodat fallback logic nog klopt
            all = products;
            debugPrint(
              "Succes: ${products.length} producten gevonden via ffinder.nl (direct getoond; images worden asynchroon verrijkt)",
            );
          } else {
            debugPrint(
              "ffinder.nl gaf een leeg resultaat of verkeerde structuur.",
            );
            setState(() {
              _ffinderStatus = SourceStatus.error;
            });
          }
        } else {
          debugPrint("ffinder.nl gaf een foutstatus: ${response.statusCode}");
          debugPrint("Response body: ${response.body}");
        }
      } catch (e, stack) {
        debugPrint("Fout bij het aanroepen van ffinder.nl: $e");
        debugPrint(stack.toString());
        setState(() {
          _ffinderStatus = SourceStatus.error;
        });
      }

      // Fallback naar Open Food Facts
      if (all.isEmpty || loadMore) {
        debugPrint("\n--- Poging 2: Open Food Facts (Fallback) ---");
        final openFoodFactsUrl = Uri.parse(
          "https://nl.openfoodfacts.org/cgi/search.pl"
          "?search_terms=${Uri.encodeComponent(trimmed)}"
          "&search_simple=1&json=1&action=process",
        );
        final response = await http.get(openFoodFactsUrl);
        debugPrint("Open Food Facts Status Code: ${response.statusCode}");
        if (response.statusCode == 200) {
          debugPrint(
            "Open Food Facts response body (preview): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}",
          );
          final data = jsonDecode(response.body);
          final rawProducts = (data["products"] as List?) ?? [];
          if (rawProducts.isNotEmpty) {
            // Normaliseer elk item naar Map<String,dynamic> om veilige casting te garanderen
            final normalized = rawProducts
                .map(
                  (p) => p is Map
                      ? Map<String, dynamic>.from(p)
                      : <String, dynamic>{},
                )
                .toList();
            setState(() {
              _offStatus = SourceStatus.success;
            });
            if (loadMore) {
              all.addAll(normalized);
            } else {
              all = normalized;
            }
            _hasLoadedMore = true; // geeft aan dat we extra hebben geladen
          } else {
            setState(() {
              _offStatus = SourceStatus.error;
            });
          }
        } else {
          setState(() {
            _offStatus = SourceStatus.error;
          });
        }
      }

      final Map<String, Map<String, dynamic>> seen = {};
      int _anonCounter = 0;
      for (final item in all) {
        if (item is! Map) continue;
        final Map<String, dynamic> m = Map<String, dynamic>.from(item);
        final id = (m['_id'] ?? m['code'] ?? m['barcode'] ?? m['gtin'])
            ?.toString();
        final key = (id != null && id.isNotEmpty)
            ? id
            : (m['product_name']?.toString() ?? 'anon_${_anonCounter++}');

        if (!seen.containsKey(key)) {
          seen[key] = m;
        } else {
          // Merge: vul ontbrekende nuttige velden in (image/url/brands/quantity)
          final existing = seen[key]!;
          void copyIfMissing(String k) {
            final vNew = m[k];
            if ((existing[k] == null || existing[k].toString().isEmpty) &&
                vNew != null &&
                vNew.toString().isNotEmpty) {
              existing[k] = vNew;
            }
          }

          copyIfMissing('image_front_small_url');
          copyIfMissing('image_front_url');
          copyIfMissing('image_thumb_url');
          copyIfMissing('brands');
          copyIfMissing('quantity');
        }
      }

      final safeAll = seen.values
          .map((p) => Map<String, dynamic>.from(p))
          .toList(growable: false);
      final rankedProducts = _rankProducts(safeAll, trimmed, take: 50);
      setState(() {
        _searchResults = rankedProducts;
      });
    } catch (e, stack) {
      debugPrint("Algemene fout in _searchProducts: $e");
      debugPrint(stack.toString());
      setState(() {
        _errorMessage = 'Fout bij ophalen: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _searchOffParallel(String query) async {
    try {
      final url = Uri.parse(
        "https://nl.openfoodfacts.org/cgi/search.pl"
        "?search_terms=${Uri.encodeComponent(query)}"
        "&search_simple=1&json=1&action=process",
      );

      final response = await http.get(url).timeout(const Duration(seconds: 60));
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final products = data['products'];
      if (products is! List) return [];

      return products
          .whereType<Map>()
          .map((p) => Map<String, dynamic>.from(p))
          .toList();
    } catch (e) {
      debugPrint('[OFF parallel] error: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _mergeProductsPreserveLogic(
    List existing,
    List incoming,
  ) {
    final Map<String, Map<String, dynamic>> seen = {};
    int anonCounter = 0;

    void add(Map<String, dynamic> m) {
      final id = (m['_id'] ?? m['code'] ?? m['barcode'] ?? m['gtin'])
          ?.toString();
      final key = (id != null && id.isNotEmpty)
          ? id
          : (m['product_name']?.toString() ?? 'anon_${anonCounter++}');

      if (!seen.containsKey(key)) {
        seen[key] = Map<String, dynamic>.from(m);
      } else {
        final existing = seen[key]!;
        void copyIfMissing(String k) {
          final vNew = m[k];
          if ((existing[k] == null || existing[k].toString().isEmpty) &&
              vNew != null &&
              vNew.toString().isNotEmpty) {
            existing[k] = vNew;
          }
        }

        copyIfMissing('image_front_small_url');
        copyIfMissing('image_front_url');
        copyIfMissing('image_thumb_url');
        copyIfMissing('brands');
        copyIfMissing('quantity');
      }
    }

    for (final p in existing) {
      if (p is Map<String, dynamic>) add(p);
    }
    for (final p in incoming) {
      if (p is Map<String, dynamic>) add(p);
    }

    return seen.values.map((p) => Map<String, dynamic>.from(p)).toList();
  }

  Future<void> _scanImage() async {
    final picker = ImagePicker();

    // Vraag gebruiker om bron te kiezen
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Maak een foto'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Kies uit galerij'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geen afbeelding geselecteerd.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Voorkom wegklikken
      builder: (context) => const _AILoadingDialog(),
    );

    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
      );
      final prompt = TextPart(
        "Wat voor ingrediënten zie je hier? Antwoord in het Nederlands. "
        "Negeer marketingtermen, productnamen, en niet-relevante woorden zoals 'zero', 'light', etc. "
        "Antwoord alleen met daadwerkelijke ingrediënten die in het product zitten. "
        "Antwoord alleen als het plaatje een voedselproduct toont."
        "Antwoord als: {ingredient}, {ingredient}, ...",
      );
      final imageBytes = await pickedFile.readAsBytes();
      final imagePart = InlineDataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      if (mounted) {
        Navigator.of(context).pop();
      }

      final result = response.text?.trim() ?? '';
      if (result.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Geen resultaat van AI.')));
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) {
          final isDarkMode = Theme.of(ctx).brightness == Brightness.dark;
          final textColor = isDarkMode ? Colors.white : Colors.black;

          // Split de string in losse ingrediënten voor de weergave
          final ingredients = result
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Gevonden Ingrediënten',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'De AI heeft de volgende ingrediënten herkend:',
                      style: TextStyle(color: textColor.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: ingredients.map((ingredient) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            ingredient,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Annuleren'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showAddMealFromAI(result);
                },
                child: const Text('Maaltijd samenstellen'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fout bij AI-analyse: $e')));
    }
  }

  Future<void> _showAddMealFromAI(String aiResult) async {
    final ingredients = aiResult
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final formKey = GlobalKey<FormState>();
    final mealNameController = TextEditingController();

    // Voor elk AI-ingredient een zoekcontroller, amountcontroller, etc.
    final List<Map<String, dynamic>> ingredientEntries = [
      for (final name in ingredients)
        {
          'searchController': TextEditingController(text: name),
          'amountController': TextEditingController(),
          'searchResults': null,
          'selectedProduct': null,
          'isSearching': false,
          'hasLoadedMore': false,
        },
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        final isDarkMode = Theme.of(modalContext).brightness == Brightness.dark;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.90,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                                                Future<void> searchProductsForIngredient(
                  String query,
                  int index, {
                  bool loadMore = false,
                }) async {
                  final trimmed = query.trim();
                  if (trimmed.length < 2) {
                    setModalState(() {
                      ingredientEntries[index]['searchResults'] = null;
                    });
                    return;
                  }

                  setModalState(() {
                    ingredientEntries[index]['isSearching'] = true;
                    if (!loadMore) {
                      ingredientEntries[index]['hasLoadedMore'] = false;
                    }
                  });

                  final appKey = dotenv.env["APP_KEY"] ?? "";
                  List existingResults = [];
                  if (loadMore) {
                    existingResults.addAll(ingredientEntries[index]['searchResults'] ?? []);
                  }

                  try {
                    // start beide requests parallel
                    final ffinderFuture = () async {
                      try {
                        final ffinderUrl = Uri.parse(
                          "https://ffinder.nl/product?q=${Uri.encodeComponent(trimmed)}",
                        );
                        final resp = await http.get(ffinderUrl, headers: {"x-app-key": appKey}).timeout(const Duration(seconds: 10));
                        if (resp.statusCode != 200) return <Map<String, dynamic>>[];
                        final data = jsonDecode(resp.body);
                        final foods = data["foods"];
                        if (foods != null && foods["food"] is List) {
                          return (foods["food"] as List)
                              .map((p) => p is Map ? Map<String, dynamic>.from(p) : <String, dynamic>{})
                              .toList();
                        }
                        return <Map<String, dynamic>>[];
                      } catch (_) {
                        return <Map<String, dynamic>>[];
                      }
                    }();

                    final offFuture = _searchOffParallel(trimmed).catchError((_) => <Map<String, dynamic>>[]);

                    final resultsPair = await Future.wait([ffinderFuture, offFuture]);
                    final List<Map<String, dynamic>> ffinderProducts = resultsPair[0] as List<Map<String, dynamic>>;
                    final List<Map<String, dynamic>> offProducts = resultsPair[1] as List<Map<String, dynamic>>;

                    // merge (preserve logic de-dup + fill missing fields)
                    final merged = _mergeProductsPreserveLogic(ffinderProducts, offProducts);

                    // als loadMore: voeg bij bestaande, anders vervang
                    final ranked = _rankProducts(merged, trimmed, take: 50);
                    setModalState(() {
                      if (loadMore) {
                        ingredientEntries[index]['searchResults'] = [
                          ...existingResults,
                          ...ranked,
                        ];
                        ingredientEntries[index]['hasLoadedMore'] = true;
                      } else {
                        ingredientEntries[index]['searchResults'] = ranked;
                      }
                      ingredientEntries[index]['isSearching'] = false;
                    });

                    // asynchrone extra OFF-image verrijking voor items zonder afbeelding (fire-and-forget)
                    for (final raw in ffinderProducts) {
                      final code = raw['barcode'] ?? raw['code'] ?? raw['_id'] ?? raw['gtin'] ?? raw['ean'];
                      final barcode = code?.toString();
                      if (barcode == null || barcode.isEmpty) continue;

                      () async {
                        try {
                          final offUrl = Uri.parse('https://nl.openfoodfacts.org/api/v0/product/$barcode.json');
                          final offResp = await http.get(offUrl).timeout(const Duration(seconds: 6));
                          if (offResp.statusCode != 200) return;
                          final offJson = jsonDecode(offResp.body) as Map<String, dynamic>?;
                          if (offJson == null || offJson['status'] != 1 || offJson['product'] is! Map) return;
                          final offProd = offJson['product'] as Map<String, dynamic>;
                          final img = offProd['image_front_small_url'] ?? offProd['image_front_thumb_url'] ?? offProd['image_front_url'];
                          if (img is String && img.isNotEmpty) {
                            raw['image_front_small_url'] = img;
                            if (mounted) {
                              setModalState(() {
                                final list = (ingredientEntries[index]['searchResults'] as List?) ?? [];
                                for (int j = 0; j < list.length; j++) {
                                  final p = list[j] as Map<String, dynamic>;
                                  final idP = (p['_id'] ?? p['code'] ?? p['barcode'])?.toString();
                                  final idRaw = (raw['_id'] ?? raw['code'] ?? raw['barcode'])?.toString();
                                  if (idP != null && idRaw != null && idP == idRaw) {
                                    final updated = Map<String, dynamic>.from(p);
                                    updated['image_front_small_url'] = img;
                                    list[j] = updated;
                                    break;
                                  }
                                }
                                ingredientEntries[index]['searchResults'] = list;
                              });
                            }
                          }
                        } catch (_) {
                          // ignore per-item image errors
                        }
                      }();
                    }

                    return;
                  } catch (e) {
                    setModalState(() {
                      ingredientEntries[index]['searchResults'] = [];
                      ingredientEntries[index]['isSearching'] = false;
                    });
                  }
                }
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 30,
                      top: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Maaltijd samenstellen',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: textColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: mealNameController,
                            style: TextStyle(color: textColor),
                            decoration: const InputDecoration(
                              labelText: 'Naam van maaltijd',
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Naam is verplicht'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          ...ingredientEntries.asMap().entries.map((entry) {
                            final index = entry.key;
                            final ingredient = entry.value;
                            final searchController =
                                ingredient['searchController']
                                    as TextEditingController;
                            final amountController =
                                ingredient['amountController']
                                    as TextEditingController;
                            final selectedProduct =
                                ingredient['selectedProduct']
                                    as Map<String, dynamic>?;

                            if (selectedProduct != null) {
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: ListTile(
                                  title: Text(
                                    _displayProductName(
                                      selectedProduct['product_name'],
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Hoeveelheid: ${amountController.text}g',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setModalState(() {
                                        ingredient['selectedProduct'] = null;
                                        amountController.text = '';
                                      });
                                    },
                                  ),
                                  onTap: () async {
                                    final barcode =
                                        selectedProduct['_id'] as String? ??
                                        'temp_${DateTime.now().millisecondsSinceEpoch}';

                                    final currentAmount = double.tryParse(
                                      amountController.text,
                                    );

                                    final normalizedProductData =
                                        Map<String, dynamic>.from(
                                          selectedProduct,
                                        );

                                    // Functie om een veld naar een lijst te converteren
                                    List<dynamic> toList(dynamic value) {
                                      if (value is List) return value;
                                      if (value is String && value.isNotEmpty)
                                        return [value];
                                      return [];
                                    }

                                    // Pas toe op velden die lijsten zouden moeten zijn
                                    normalizedProductData['allergens_tags'] =
                                        toList(
                                          normalizedProductData['allergens_tags'],
                                        );
                                    normalizedProductData['traces_tags'] =
                                        toList(
                                          normalizedProductData['traces_tags'],
                                        );
                                    normalizedProductData['additives_tags'] =
                                        toList(
                                          normalizedProductData['additives_tags'],
                                        );

                                    final result = await _showProductDetails(
                                      barcode,
                                      productData:
                                          normalizedProductData, // Gebruik de genormaliseerde data
                                      isForMeal: true,
                                      initialAmount: currentAmount,
                                    );
                                    if (result != null &&
                                        result['amount'] != null) {
                                      setModalState(() {
                                        amountController.text = result['amount']
                                            .toString();
                                        ingredient['selectedProduct'] =
                                            result['product'];
                                      });
                                    }
                                  },
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: searchController,
                                        style: TextStyle(color: textColor),
                                        decoration: InputDecoration(
                                          labelText:
                                              'Zoek ${searchController.text}',
                                          suffixIcon: IconButton(
                                            icon: const Icon(Icons.search),
                                            onPressed: () =>
                                                searchProductsForIngredient(
                                                  searchController.text,
                                                  index,
                                                ),
                                          ),
                                        ),
                                        onSubmitted: (query) =>
                                            searchProductsForIngredient(
                                              query,
                                              index,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (ingredient['isSearching'] as bool)
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                if (ingredient['searchResults'] != null)
                                  SizedBox(
                                    height: 150,
                                    child: ListView.builder(
                                      itemCount:
                                          (ingredient['searchResults'] as List)
                                              .length +
                                          ((ingredient['hasLoadedMore']
                                                      as bool? ??
                                                  false)
                                              ? 0
                                              : 1),
                                      itemBuilder: (context, resultIndex) {
                                        final results =
                                            ingredient['searchResults'] as List;
                                        if (resultIndex == results.length) {
                                          return TextButton(
                                            onPressed: () =>
                                                searchProductsForIngredient(
                                                  searchController.text,
                                                  index,
                                                  loadMore: true,
                                                ),
                                            child: const Text(
                                              'Meer producten laden...',
                                            ),
                                          );
                                        }
                                        final product = results[resultIndex];
                                        final imageUrl =
                                            (product['image_front_small_url'] ??
                                                    product['image_front_url'] ??
                                                    product['image_thumb_url'])
                                                as String?;
                                        return ListTile(
                                          leading: imageUrl != null
                                              ? SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child: Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => const Icon(
                                                          Icons
                                                              .image_not_supported,
                                                        ),
                                                  ),
                                                )
                                              : const SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child: Icon(Icons.fastfood),
                                                ),
                                          title: Text(
                                            _displayProductName(
                                              product['product_name'],
                                            ),
                                          ),
                                          subtitle: Text(
                                            _displayString(product['brands']),
                                          ),
                                          onTap: () async {
                                            final barcode =
                                                (product['_id'] ??
                                                        product['code'] ??
                                                        product['barcode'])
                                                    as String?;
                                            if (barcode == null) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Geen barcode gevonden voor dit product.',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            final normalized =
                                                Map<String, dynamic>.from(
                                                  product,
                                                );

                                            normalized['allergens_tags'] =
                                                _normalizeTags(
                                                  normalized['allergens_tags'],
                                                );
                                            normalized['traces_tags'] =
                                                _normalizeTags(
                                                  normalized['traces_tags'],
                                                );
                                            normalized['additives_tags'] =
                                                _normalizeTags(
                                                  normalized['additives_tags'],
                                                );

                                            if (normalized['nutriments_per_100g'] ==
                                                null) {
                                              if (normalized['nutriments']
                                                  is Map) {
                                                final n =
                                                    normalized['nutriments']
                                                        as Map<String, dynamic>;
                                                double _asDouble(dynamic v) {
                                                  if (v == null) return 0.0;
                                                  if (v is num)
                                                    return v.toDouble();
                                                  if (v is String)
                                                    return double.tryParse(
                                                          v.replaceAll(
                                                            ',',
                                                            '.',
                                                          ),
                                                        ) ??
                                                        0.0;
                                                  return 0.0;
                                                }

                                                normalized['nutriments_per_100g'] = {
                                                  'energy-kcal': _asDouble(
                                                    n['energy-kcal_100g'] ??
                                                        n['energy-kcal'],
                                                  ),
                                                  'fat': _asDouble(
                                                    n['fat_100g'] ?? n['fat'],
                                                  ),
                                                  'saturated-fat': _asDouble(
                                                    n['saturated-fat_100g'] ??
                                                        n['saturated-fat'],
                                                  ),
                                                  'carbohydrates': _asDouble(
                                                    n['carbohydrates_100g'] ??
                                                        n['carbohydrates'],
                                                  ),
                                                  'sugars': _asDouble(
                                                    n['sugars_100g'] ??
                                                        n['sugars'],
                                                  ),
                                                  'fiber': _asDouble(
                                                    n['fiber_100g'] ??
                                                        n['fiber'],
                                                  ),
                                                  'proteins': _asDouble(
                                                    n['proteins_100g'] ??
                                                        n['proteins'],
                                                  ),
                                                  'salt': _asDouble(
                                                    n['salt_100g'] ?? n['salt'],
                                                  ),
                                                };
                                              } else {
                                                normalized['nutriments_per_100g'] =
                                                    (normalized['nutriments_per_100g']
                                                        as Map<
                                                          String,
                                                          dynamic
                                                        >?) ??
                                                    {};
                                              }
                                            }

                                            normalized['product_name'] =
                                                normalized['product_name'] ??
                                                '';
                                            normalized['brands'] =
                                                normalized['brands'] ?? '';
                                            normalized['quantity'] =
                                                normalized['quantity'] ?? '';
                                            final result =
                                                await _showProductDetails(
                                                  barcode,
                                                  productData: normalized,
                                                  isForMeal: true,
                                                );

                                            if (result != null &&
                                                result['amount'] != null) {
                                              setModalState(() {
                                                (ingredient['amountController']
                                                        as TextEditingController)
                                                    .text = result['amount']
                                                    .toString();
                                                ingredient['selectedProduct'] =
                                                    result['product'];
                                                ingredient['searchResults'] =
                                                    null;
                                              });
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                if (selectedProduct == null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: TextField(
                                      controller: amountController,
                                      style: TextStyle(color: textColor),
                                      decoration: const InputDecoration(
                                        labelText: 'Hoeveelheid (g)',
                                      ),
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) return;

                                final userDEK =
                                    await getUserDEKFromRemoteConfig(user.uid);
                                if (userDEK == null) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Kon encryptiesleutel niet ophalen.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final List<Map<String, dynamic>>
                                finalIngredients = [];
                                for (final ingredient in ingredientEntries) {
                                  final selectedProduct =
                                      ingredient['selectedProduct']
                                          as Map<String, dynamic>?;
                                  final amount = double.tryParse(
                                    (ingredient['amountController']
                                            as TextEditingController)
                                        .text
                                        .replaceAll(',', '.'),
                                  );
                                  if (selectedProduct != null &&
                                      amount != null) {
                                    finalIngredients.add({
                                      'product_id': selectedProduct['_id'],
                                      'product_name': await encryptValue(
                                        selectedProduct['product_name'],
                                        userDEK,
                                      ),
                                      'brands': await encryptValue(
                                        selectedProduct['brands'],
                                        userDEK,
                                      ),
                                      'image_front_small_url':
                                          selectedProduct['image_front_small_url'],
                                      'amount': amount,
                                      'nutriments_per_100g': {
                                        for (final key
                                            in (selectedProduct['nutriments_per_100g']
                                                    as Map<String, dynamic>)
                                                .keys)
                                          key: await encryptDouble(
                                            (selectedProduct['nutriments_per_100g'][key]
                                                        as num?)
                                                    ?.toDouble() ??
                                                0,
                                            userDEK,
                                          ),
                                      },
                                    });
                                  }
                                }

                                if (finalIngredients.isEmpty) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Voeg minimaal één product toe.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final mealData = {
                                  'name': mealNameController.text,
                                  'ingredients': finalIngredients,
                                  'timestamp': FieldValue.serverTimestamp(),
                                };

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('meals')
                                    .add(mealData);

                                if (!mounted) return;
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Maaltijd opgeslagen!'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Maaltijd opslaan'),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _scanBarcode() async {
    // Reset de foutmeldingen
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    debugPrint(
      "[ADD_FOOD_VIEW] Starting barcode scan from within AddFoodPage...",
    );

    // Open de barcode scanner
    var res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()),
    );

    // Als er een geldige barcode is gescand
    if (res is String && res != '-1') {
      final barcode = res;
      debugPrint("[ADD_FOOD_VIEW] Scanned barcode: $barcode");
      final user = FirebaseAuth.instance.currentUser;
      Map<String, dynamic>? productData;

      if (user != null) {
        try {
          // Controleer de 'recents' collectie op een bestaand product
          final recentDocRef = FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('recents')
              .doc(barcode);

          final docSnapshot = await recentDocRef.get();

          if (docSnapshot.exists) {
            debugPrint(
              "[ADD_FOOD_VIEW] Product found in recents for barcode: $barcode",
            );
            // Product gevonden, decrypt de data
            final encryptedData = docSnapshot.data() as Map<String, dynamic>;
            debugPrint(
              "[ADD_FOOD_VIEW] Encrypted data from recents: $encryptedData",
            );

            final userDEK = await getUserDEKFromRemoteConfig(user.uid);
            if (userDEK != null) {
              debugPrint("[ADD_FOOD_VIEW] User DEK found. Decrypting...");
              final decryptedData = Map<String, dynamic>.from(encryptedData);
              if (encryptedData['product_name'] != null) {
                decryptedData['product_name'] = await decryptValue(
                  encryptedData['product_name'],
                  userDEK,
                );
              }
              if (encryptedData['brands'] != null) {
                decryptedData['brands'] = await decryptValue(
                  encryptedData['brands'],
                  userDEK,
                );
              }
              if (encryptedData['quantity'] != null) {
                decryptedData['quantity'] = await decryptValue(
                  encryptedData['quantity'],
                  userDEK,
                );
              }
              if (encryptedData['serving_size'] != null) {
                decryptedData['serving_size'] = await decryptValue(
                  encryptedData['serving_size'],
                  userDEK,
                );
              }
              // Decrypt de geneste voedingswaarden
              if (encryptedData['nutriments_per_100g'] != null &&
                  encryptedData['nutriments_per_100g'] is Map) {
                final encryptedNutriments =
                    encryptedData['nutriments_per_100g']
                        as Map<String, dynamic>;
                final decryptedNutriments = <String, dynamic>{};
                for (final key in encryptedNutriments.keys) {
                  decryptedNutriments[key] = await decryptDouble(
                    encryptedNutriments[key],
                    userDEK,
                  );
                }
                decryptedData['nutriments_per_100g'] = decryptedNutriments;
              }

              productData = decryptedData;
              debugPrint("[ADD_FOOD_VIEW] Decrypted data: $productData");
            } else {
              debugPrint(
                "[ADD_FOOD_VIEW] User DEK not found. Using encrypted data as fallback.",
              );
              productData = encryptedData; // Fallback naar versleutelde data
            }
          } else {
            debugPrint(
              "[ADD_FOOD_VIEW] Product not found in recents for barcode: $barcode",
            );
          }
        } catch (e) {
          debugPrint("[ADD_FOOD_VIEW] Error fetching from recents: $e");
          if (mounted) {
            setState(() {
              _errorMessage = "Fout bij ophalen recente producten: $e";
            });
          }
        }
      }

      // Toon de product details sheet met de (mogelijk) gedecrypteerde data
      if (mounted) {
        // Als we geen lokaal (gedecodeerd) product hebben, probeer eerst OpenFoodFacts
        if (productData == null) {
          try {
            final offUrl = Uri.parse(
              'https://nl.openfoodfacts.org/api/v0/product/$barcode.json',
            );
            final resp = await http.get(offUrl);
            if (resp.statusCode == 200) {
              final j = jsonDecode(resp.body) as Map<String, dynamic>;
              if (j['status'] == 1 && j['product'] is Map) {
                final p = j['product'] as Map<String, dynamic>;
                final normalized = Map<String, dynamic>.from(p);

                // normalize tags/nutriments similar to _showProductDetails
                normalized['allergens_tags'] = _normalizeTags(
                  normalized['allergens_tags'],
                );
                normalized['traces_tags'] = _normalizeTags(
                  normalized['traces_tags'],
                );
                normalized['additives_tags'] = _normalizeTags(
                  normalized['additives_tags'],
                );

                // ensure nutriments_per_100g numeric
                double _asDouble(dynamic v) {
                  if (v == null) return 0.0;
                  if (v is num) return v.toDouble();
                  if (v is String)
                    return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
                  return 0.0;
                }

                if (normalized['nutriments_per_100g'] == null &&
                    normalized['nutriments'] is Map) {
                  final n = normalized['nutriments'] as Map<String, dynamic>;
                  normalized['nutriments_per_100g'] = {
                    'energy-kcal': _asDouble(
                      n['energy-kcal_100g'] ?? n['energy-kcal'],
                    ),
                    'fat': _asDouble(n['fat_100g'] ?? n['fat']),
                    'saturated-fat': _asDouble(
                      n['saturated-fat_100g'] ?? n['saturated-fat'],
                    ),
                    'carbohydrates': _asDouble(
                      n['carbohydrates_100g'] ?? n['carbohydrates'],
                    ),
                    'sugars': _asDouble(n['sugars_100g'] ?? n['sugars']),
                    'fiber': _asDouble(n['fiber_100g'] ?? n['fiber']),
                    'proteins': _asDouble(n['proteins_100g'] ?? n['proteins']),
                    'salt': _asDouble(n['salt_100g'] ?? n['salt']),
                  };
                }

                productData = normalized;
                productData['serving_size'] = _extractServingSize(
                  normalized['serving_size'] ??
                      normalized['serving-size'] ??
                      normalized['servingSize'] ??
                      normalized['serving_quantity'],
                );
                debugPrint(
                  '[ADD_FOOD_VIEW] Fetched product from OFF for $barcode',
                );
              }
            }
          } catch (e) {
            debugPrint('[ADD_FOOD_VIEW] OFF fetch failed: $e');
          }
        }

        _showProductDetails(barcode, productData: productData);
      }
    } else {
      debugPrint(
        "[ADD_FOOD_VIEW] Barcode scan cancelled or failed. Result: $res",
      );
    }

    // Verberg de laadindicator
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: _searchKey,
          controller: _searchController,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Zoek producten...',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              // afgeronde hoeken
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Zoek',
              onPressed: () {
                FocusScope.of(context).unfocus();
                _searchProducts(_searchController.text);
              },
            ),
          ),
          onSubmitted: (value) {
            FocusScope.of(context).unfocus(); // sluit toetsenbord
            _searchProducts(value);
          },
        ),
        actions: [
          if (_searchController.text.isEmpty &&
              (_selectedTabIndex == 2 ||
                  _selectedTabIndex ==
                      3)) // alleen tonen bij mijn producten of maaltijden
            IconButton(
              key: _selectedTabIndex == 2
                  ? _myproductsAddKey
                  : _maaltijdenAddKey,
              icon: const Icon(Icons.add),
              tooltip: 'Toevoegen',
              onPressed: () async {
                final choice = await showModalBottomSheet<String>(
                  context: context,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  builder: (ctx) {
                    final isDark = Theme.of(ctx).brightness == Brightness.dark;
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(
                              'Wat wil je toevoegen?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.fastfood),
                            title: Text(
                              'Product toevoegen',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            onTap: () => Navigator.of(ctx).pop('product'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.restaurant_menu),
                            title: Text(
                              'Maaltijd toevoegen',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            onTap: () => Navigator.of(ctx).pop('meal'),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                );

                if (choice == 'product') {
                  // toon sheet om eigen product toe te voegen
                  setState(() {
                    _selectedTabIndex = 2;
                    for (int i = 0; i < _selectedToggle.length; i++) {
                      _selectedToggle[i] = i == 2;
                    }
                  });
                  _showAddMyProductSheet();
                } else if (choice == 'meal') {
                  // toon sheet om maaltijd toe te voegen
                  setState(() {
                    _selectedTabIndex = 3;
                    for (int i = 0; i < _selectedToggle.length; i++) {
                      _selectedToggle[i] = i == 3;
                    }
                  });
                  _showAddMealSheet();
                }
              },
            ),
          IconButton(
            key: _barcodeKey,
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
          ),
          IconButton(icon: const Icon(Icons.smart_toy), onPressed: _scanImage),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (_searchController.text.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    _selectedTabIndex = index;
                    for (int i = 0; i < _selectedToggle.length; i++) {
                      // update toggle state
                      _selectedToggle[i] = i == index;
                    }
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                constraints: BoxConstraints(
                  minHeight: 40.0,
                  minWidth:
                      (MediaQuery.of(context).size.width - 48) /
                      4, // verdeel groote gelijk
                ),
                isSelected: _selectedToggle,
                children: [
                  Text('Recent', key: _recentKey),
                  Text('Favorieten', key: _favoritesKey),
                  Text('Mijn producten', key: _myproductsKey),
                  Text('Maaltijden', key: _maaltijdenKey),
                ],
              ),
            ),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: const FeedbackButton(),
    );
  }

  Widget _buildContent() {
    // bouw de juiste content op basis van de zoekterm
    if (_searchController.text.isNotEmpty) {
      return _buildSearchResults();
    } else {
      return _buildProductList();
    }
  }

  Widget _buildSearchResults() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final sourceStatusRow = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Links: ffinder
          _statusBadge(_ffinderStatus, 'fFinder'),
          // Rechts: Open Food Facts
          _statusBadge(_offStatus, 'OpenFoodFacts'),
        ],
      ),
    );

    if (_isLoading) {
      return Column(
        children: [
          sourceStatusRow,
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      );
    }

    return Column(
      children: [
        sourceStatusRow,
        Expanded(child: _buildResultsListOrPlaceholder(isDarkMode)),
      ],
    );
  }

  Widget _buildResultsListOrPlaceholder(bool isDarkMode) {
    if (_searchResults == null) {
      return Center(
        child: Text(
          'Begin met typen om te zoeken.',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      );
    }

    if (_searchResults!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Geen producten gevonden.',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _showAddMyProductSheet,
              style: TextButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
                foregroundColor: isDarkMode ? Colors.white : Colors.black,
                side: BorderSide(
                  color: isDarkMode ? Colors.white : Colors.black,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 18,
                ),
              ),
              child: const Text('Wilt u zelf een product toevoegen?'),
            ),
          ],
        ),
      );
    }

    // Bouw een lijst van widgets
    List<Widget> resultWidgets = [];

    for (var product in _searchResults!) {
      final imageUrl = product['image_front_small_url'] as String?;
      resultWidgets.add(
        ListTile(
          leading: imageUrl != null
              ? SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
                  ),
                )
              : const SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(Icons.fastfood),
                ),
          title: Text(_displayProductName(product['product_name'])),
          subtitle: Text(
            _displayString(product['brands'], fallback: 'Onbekend merk'),
          ),
          onTap: () {
            // bestaande onTap logic — keep unchanged
            final barcode =
                (product['_id'] ?? product['code'] ?? product['barcode'])
                    as String?;
            if (barcode != null) {
              // Normalize product for OFF structure
              final normalized = Map<String, dynamic>.from(product);
              normalized['serving_size'] = _extractServingSize(
                normalized['serving_size'] ??
                    normalized['serving-size'] ??
                    normalized['servingSize'] ??
                    normalized['serving_quantity'],
              );
              normalized['allergens_tags'] = _normalizeTags(
                normalized['allergens_tags'],
              );
              normalized['traces_tags'] = _normalizeTags(
                normalized['traces_tags'],
              );
              normalized['additives_tags'] = _normalizeTags(
                normalized['additives_tags'],
              );

              if (normalized['nutriments_per_100g'] == null) {
                if (normalized['nutriments'] is Map) {
                  final n = normalized['nutriments'] as Map<String, dynamic>;
                  double _asDouble(dynamic v) {
                    if (v == null) return 0.0;
                    if (v is num) return v.toDouble();
                    if (v is String)
                      return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
                    return 0.0;
                  }

                  normalized['nutriments_per_100g'] = {
                    'energy-kcal': _asDouble(
                      n['energy-kcal_100g'] ?? n['energy-kcal'],
                    ),
                    'fat': _asDouble(n['fat_100g'] ?? n['fat']),
                    'saturated-fat': _asDouble(
                      n['saturated-fat_100g'] ?? n['saturated-fat'],
                    ),
                    'carbohydrates': _asDouble(
                      n['carbohydrates_100g'] ?? n['carbohydrates'],
                    ),
                    'sugars': _asDouble(n['sugars_100g'] ?? n['sugars']),
                    'fiber': _asDouble(n['fiber_100g'] ?? n['fiber']),
                    'proteins': _asDouble(n['proteins_100g'] ?? n['proteins']),
                    'salt': _asDouble(n['salt_100g'] ?? n['salt']),
                  };
                } else {
                  normalized['nutriments_per_100g'] =
                      (normalized['nutriments_per_100g']
                          as Map<String, dynamic>?) ??
                      {};
                }
              }

              normalized['product_name'] = normalized['product_name'] ?? '';
              normalized['brands'] = normalized['brands'] ?? '';
              normalized['quantity'] = normalized['quantity'] ?? '';
              _showProductDetails(barcode, productData: normalized);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Geen barcode gevonden voor dit product.'),
                ),
              );
            }
          },
        ),
      );
    }

    // "Meer laden" knop
    if (!_hasLoadedMore) {
      resultWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextButton(
            onPressed: () async {
              await _searchProducts(_searchController.text, loadMore: true);
            },
            child: const Text('Meer producten laden…'),
          ),
        ),
      );
    }

    // "Niet de gewenste resultaten" knop
    resultWidgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: _showAddMyProductSheet,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'Voeg een nieuw product toe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
          ),
        ),
      ),
    );

    return ListView(children: resultWidgets);
  }

  Widget _statusBadge(SourceStatus status, String label) {
    return _AnimatedStatusBadge(status: status, label: label);
  }

  Future<void> _showAddMyProductSheet() async {
    // toon sheet om eigen product toe te voegen
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(); // naam controller
    final _brandController = TextEditingController();
    final _quantityController = TextEditingController();
    final _caloriesController = TextEditingController();
    final _fatController = TextEditingController();
    final _saturatedFatController = TextEditingController();
    final _carbsController = TextEditingController();
    final _sugarsController = TextEditingController();
    final _fiberController = TextEditingController();
    final _proteinsController = TextEditingController();
    final _saltController = TextEditingController();

    await showModalBottomSheet(
      // toon modal sheet. modal is een soort popup
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 30,
                  top: 12,
                  left: 20,
                  right: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Nieuw Product Toevoegen',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(color: textColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            labelText: 'Productnaam',
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Naam is verplicht'
                              : null,
                        ),
                        TextFormField(
                          controller: _brandController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(labelText: 'Merk'),
                        ),
                        TextFormField(
                          controller: _quantityController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            labelText: 'Hoeveelheid (bijv. 100g, 250ml)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*[,.]?\d*'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Voedingswaarden per 100g of ml',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: textColor),
                        ),
                        TextFormField(
                          controller: _caloriesController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            labelText: 'Energie (kcal)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*[,.]?\d*'),
                            ),
                          ],
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Calorieën zijn verplicht'
                              : null,
                        ),
                        TextFormField(
                          controller: _fatController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            labelText: 'Vetten',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*[,.]?\d*'),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _saturatedFatController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            labelText: '  - Waarvan verzadigd',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*[,.]?\d*'),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _carbsController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            labelText: 'Koolhydraten',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*[,.]?\d*'),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _sugarsController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            labelText: '  - Waarvan suikers',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*[,.]?\d*'),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _fiberController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            labelText: 'Vezels',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*[,.]?\d*'),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _proteinsController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            labelText: 'Eiwitten',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*[,.]?\d*'),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _saltController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(labelText: 'Zout'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*[,.]?\d*'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          // knop om product op te slaan
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // valideer formulier
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) return;

                              final userDEK = await getUserDEKFromRemoteConfig(
                                user.uid,
                              );
                              if (userDEK == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Fout: Kon encryptiesleutel niet ophalen.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final dataToSave = {
                                'product_name': await encryptValue(
                                  _nameController.text,
                                  userDEK,
                                ),
                                'brands': await encryptValue(
                                  _brandController.text,
                                  userDEK,
                                ),
                                'quantity': await encryptValue(
                                  _quantityController.text,
                                  userDEK,
                                ),
                                'timestamp': FieldValue.serverTimestamp(),
                                'nutriments_per_100g': {
                                  'energy-kcal': await encryptDouble(
                                    double.tryParse(
                                          _caloriesController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ) ??
                                        0,
                                    userDEK,
                                  ),
                                  'fat': await encryptDouble(
                                    double.tryParse(
                                          _fatController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ) ??
                                        0,
                                    userDEK,
                                  ),
                                  'saturated-fat': await encryptDouble(
                                    double.tryParse(
                                          _saturatedFatController.text
                                              .replaceAll(',', '.'),
                                        ) ??
                                        0,
                                    userDEK,
                                  ),
                                  'carbohydrates': await encryptDouble(
                                    double.tryParse(
                                          _carbsController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ) ??
                                        0,
                                    userDEK,
                                  ),
                                  'sugars': await encryptDouble(
                                    double.tryParse(
                                          _sugarsController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ) ??
                                        0,
                                    userDEK,
                                  ),
                                  'fiber': await encryptDouble(
                                    double.tryParse(
                                          _fiberController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ) ??
                                        0,
                                    userDEK,
                                  ),
                                  'proteins': await encryptDouble(
                                    double.tryParse(
                                          _proteinsController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ) ??
                                        0,
                                    userDEK,
                                  ),
                                  'salt': await encryptDouble(
                                    double.tryParse(
                                          _saltController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ) ??
                                        0,
                                    userDEK,
                                  ),
                                },
                              };

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .collection('my_products')
                                  .add(dataToSave);
                              Navigator.pop(
                                context,
                              ); // sluit de sheet na opslaan
                            }
                          },
                          child: const Text('Opslaan'),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<dynamic> _normalizeTags(dynamic v) {
    if (v == null) return <dynamic>[];
    if (v is List) return v;
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return <dynamic>[];

      // 1) Probeer expliciete OFF-tags zoals "en:milk" te vinden
      final matches = RegExp(
        r'en:[^,;\/\s]+',
      ).allMatches(s).map((m) => m.group(0)!).toList();
      if (matches.isNotEmpty) return matches;

      // 2) Fallback: split op komma/semicolon/slash/whitespace
      final parts = s
          .split(RegExp(r'[,\;\/\s]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) return parts;

      return <dynamic>[s];
    }
    return <dynamic>[];
  }

  String? _extractServingSize(dynamic v) {
    if (v == null) return null;
    if (v is num) return "${v.toString()} g";
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      final unitMatch = RegExp(
        r'(\d+(?:[.,]\d+)?)\s*(g|gram|gr|ml)',
        caseSensitive: false,
      ).firstMatch(s);
      if (unitMatch != null) {
        final numPart = unitMatch.group(1)!.replaceAll(',', '.');
        final unit = unitMatch.group(2)!.toLowerCase();
        if (unit == 'ml')
          return "${double.tryParse(numPart)?.toString() ?? numPart} ml";
        return "${double.tryParse(numPart)?.toString() ?? numPart} g";
      }
      final numOnly = double.tryParse(s.replaceAll(',', '.'));
      if (numOnly != null) return "${numOnly.toString()} g";
      return s;
    }
    return v.toString();
  }

  Future<void> _addRecentMyProduct(
    // voeg recent eigen product toe
    Map<String, dynamic> productData,
    String docId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDEK = await getUserDEKFromRemoteConfig(user.uid);
    if (userDEK == null) {
      debugPrint("Fout: Kon encryptiesleutel niet ophalen voor recents.");
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('recents')
        .doc(docId);

    // Maak een kopie om te versleutelen en op te slaan
    final dataToSave = {
      'product_name': await encryptValue(
        productData['product_name'] ?? '',
        userDEK,
      ),
      'brands': await encryptValue(productData['brands'] ?? '', userDEK),
      'quantity': await encryptValue(productData['quantity'] ?? '', userDEK),
      'nutriments_per_100g':
          productData['nutriments_per_100g'], // Deze data is al versleuteld
      'timestamp': FieldValue.serverTimestamp(),
      'isMyProduct': true, // markeer als eigen product
    };

    await docRef.set(dataToSave, SetOptions(merge: true)); // sla op met merge
  }

  Future<Map<String, dynamic>?> _showProductDetails(
    String barcode, {
    Map<String, dynamic>? productData,
    bool isForMeal = false,
    double? initialAmount,
  }) async {
    debugPrint(
      "[ADD_FOOD_VIEW] _showProductDetails called for barcode: $barcode",
    );
    debugPrint("[ADD_FOOD_VIEW] _showProductDetails productData: $productData");
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final normalized = Map<String, dynamic>.from(productData ?? {});
        normalized['serving_size'] = _extractServingSize(
          normalized['serving_size'] ??
              normalized['serving-size'] ??
              normalized['servingSize'] ??
              normalized['serving_quantity'],
        );
        // Parse num or numeric string to double
        double _asDouble(dynamic v) {
          if (v == null) return 0.0;
          if (v is num) return v.toDouble();
          if (v is String) {
            final s = v.trim();
            if (s.isEmpty) return 0.0;
            return double.tryParse(s.replaceAll(',', '.')) ?? 0.0;
          }
          return 0.0;
        }

        try {
          normalized['allergens_tags'] = _normalizeTags(
            normalized['allergens_tags'],
          );
          normalized['traces_tags'] = _normalizeTags(normalized['traces_tags']);
          normalized['additives_tags'] = _normalizeTags(
            normalized['additives_tags'],
          );

          // Ensure nutriments_per_100g contains numeric doubles
          if (normalized['nutriments_per_100g'] == null) {
            if (normalized['nutriments'] is Map) {
              final n = normalized['nutriments'] as Map<String, dynamic>;
              normalized['nutriments_per_100g'] = {
                'energy-kcal': _asDouble(
                  n['energy-kcal_100g'] ?? n['energy-kcal'],
                ),
                'fat': _asDouble(n['fat_100g'] ?? n['fat']),
                'saturated-fat': _asDouble(
                  n['saturated-fat_100g'] ?? n['saturated-fat'],
                ),
                'carbohydrates': _asDouble(
                  n['carbohydrates_100g'] ?? n['carbohydrates'],
                ),
                'sugars': _asDouble(n['sugars_100g'] ?? n['sugars']),
                'fiber': _asDouble(n['fiber_100g'] ?? n['fiber']),
                'proteins': _asDouble(n['proteins_100g'] ?? n['proteins']),
                'salt': _asDouble(n['salt_100g'] ?? n['salt']),
              };
            } else {
              // if already present but values might be strings, normalize them
              final mp =
                  normalized['nutriments_per_100g'] as Map<String, dynamic>?;
              if (mp != null) {
                final fixed = <String, dynamic>{};
                for (final k in mp.keys) {
                  fixed[k] = _asDouble(mp[k]);
                }
                normalized['nutriments_per_100g'] = fixed;
              } else {
                normalized['nutriments_per_100g'] = <String, dynamic>{};
              }
            }
          } else {
            // normalize existing map values
            final mp =
                normalized['nutriments_per_100g'] as Map<String, dynamic>?;
            if (mp != null) {
              final fixed = <String, dynamic>{};
              for (final k in mp.keys) {
                fixed[k] = _asDouble(mp[k]);
              }
              normalized['nutriments_per_100g'] = fixed;
            }
          }

          normalized['product_name'] = normalized['product_name'] ?? '';
          normalized['brands'] = normalized['brands'] ?? '';
          normalized['quantity'] = normalized['quantity'] ?? '';
        } catch (e) {
          debugPrint("[ADD_FOOD_VIEW] Normalization failed: $e");
          // fall back to original productData if normalization fails
        }

        // toon de product bewerk sheet met altijd genormaliseerde data
        return ProductEditSheet(
          barcode: barcode,
          productData: normalized,
          isForMeal: isForMeal,
          initialAmount: initialAmount,
          selectedDate: widget.selectedDate,
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    // bouw een rij met niet-bewerkbare info
    if (value == null || value.trim().isEmpty) {
      // geen waarde om te tonen
      return const SizedBox.shrink();
    }
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:', // label tekst
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  String _displayString(dynamic v, {String fallback = 'Onbekend'}) {
    if (v == null) return fallback;
    if (v is String && v.trim().isNotEmpty) return v.trim();
    return fallback;
  }

  String _displayProductName(dynamic v) =>
      _displayString(v, fallback: 'Onbekende naam');

  Widget _buildProductList() {
    // bouw de lijst met producten op basis van geselecteerde tab
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    switch (_selectedTabIndex) {
      // bepaal welke tab is geselecteerd
      case 0: // Recent
        if (user == null) {
          return Center(
            child: Text(
              'Log in om je recente producten te zien.',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          );
        }
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('recents')
              .orderBy('timestamp', descending: true)
              .limit(50)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Geen recente producten gevonden.',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Er is een fout opgetreden.',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              );
            }

            final products = snapshot.data!.docs;

            return FutureBuilder<SecretKey?>(
              future: getUserDEKFromRemoteConfig(user.uid),
              builder: (context, dekSnapshot) {
                if (dekSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!dekSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final userDEK = dekSnapshot.data;

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final productDoc = products[index];
                    final product = productDoc.data() as Map<String, dynamic>;
                    final isMyProduct = product['isMyProduct'] == true;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: () async {
                        if (userDEK == null) return product;
                        final decryptedProduct = Map<String, dynamic>.from(
                          product,
                        );
                        try {
                          // Volledige decryptie voor recente items
                          if (product['product_name'] != null) {
                            decryptedProduct['product_name'] =
                                await decryptValue(
                                  product['product_name'],
                                  userDEK,
                                );
                          }
                          if (product['brands'] != null) {
                            decryptedProduct['brands'] = await decryptValue(
                              product['brands'],
                              userDEK,
                            );
                          }
                          if (product['serving_size'] != null) {
                            decryptedProduct['serving_size'] =
                                await decryptValue(
                                  product['serving_size'],
                                  userDEK,
                                );
                          }
                          if (product['quantity'] != null) {
                            decryptedProduct['quantity'] = await decryptValue(
                              product['quantity'],
                              userDEK,
                            );
                          }
                          if (product['nutriments_per_100g'] != null &&
                              product['nutriments_per_100g'] is Map) {
                            final nutriments =
                                product['nutriments_per_100g']
                                    as Map<String, dynamic>;
                            final decryptedNutriments = <String, dynamic>{};
                            for (final key in nutriments.keys) {
                              decryptedNutriments[key] = await decryptDouble(
                                nutriments[key],
                                userDEK,
                              );
                            }
                            decryptedProduct['nutriments_per_100g'] =
                                decryptedNutriments;
                          }
                        } catch (e) {
                          debugPrint(
                            "[ADD_FOOD_VIEW] Decryption failed for recent item: $e",
                          );
                        }
                        return decryptedProduct;
                      }(),
                      builder: (context, decryptedSnapshot) {
                        if (decryptedSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }

                        final decryptedProduct =
                            decryptedSnapshot.data ?? product;
                        final productName = _displayProductName(
                          decryptedProduct['product_name'],
                        );
                        final brands = decryptedProduct['brands'] ?? 'Onbekend';
                        final imageUrl =
                            decryptedProduct['image_front_small_url']
                                as String? ??
                            decryptedProduct['image_front_url'] as String?;

                        return ListTile(
                          leading: imageUrl != null
                              ? SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image_not_supported,
                                            ),
                                  ),
                                )
                              : const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.fastfood),
                                ),
                          title: Text(productName),
                          subtitle: Text(brands),
                          onTap: () {
                            if (isMyProduct) {
                              _showMyProductDetails(
                                decryptedProduct,
                                productDoc.id,
                              );
                            } else {
                              _showProductDetails(
                                productDoc.id,
                                productData: decryptedProduct,
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      case 1: // Favorieten
        if (user == null) {
          return Center(
            child: Text(
              'Log in om je favoriete producten te zien.',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          );
        }
        return FutureBuilder<SecretKey?>(
          future: getUserDEKFromRemoteConfig(user.uid),
          builder: (context, dekSnapshot) {
            if (!dekSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final userDEK = dekSnapshot.data;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('favorites')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Geen favoriete producten gevonden.',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Er is een fout opgetreden.',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }

                final products = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final productDoc = products[index];
                    final product = productDoc.data() as Map<String, dynamic>;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: () async {
                        final decrypted = Map<String, dynamic>.from(product);
                        if (userDEK != null) {
                          try {
                            if (product['product_name'] != null) {
                              decrypted['product_name'] = await decryptValue(
                                product['product_name'],
                                userDEK,
                              );
                            }
                            if (product['brands'] != null) {
                              decrypted['brands'] = await decryptValue(
                                product['brands'],
                                userDEK,
                              );
                            }
                            if (product['quantity'] != null) {
                              decrypted['quantity'] = await decryptValue(
                                product['quantity'],
                                userDEK,
                              );
                            }
                            if (product['serving_size'] != null) {
                              decrypted['serving_size'] = await decryptValue(
                                product['serving_size'],
                                userDEK,
                              );
                            }
                            if (product['nutriments_per_100g'] != null) {
                              final nutriments =
                                  product['nutriments_per_100g']
                                      as Map<String, dynamic>;
                              final decryptedNutriments = <String, dynamic>{};
                              for (final key in nutriments.keys) {
                                decryptedNutriments[key] = await decryptDouble(
                                  nutriments[key],
                                  userDEK,
                                );
                              }
                              decrypted['nutriments_per_100g'] =
                                  decryptedNutriments;
                            }
                          } catch (e) {
                            debugPrint("Fout bij decrypten favoriet: $e");
                          }
                        }
                        return decrypted;
                      }(),
                      builder: (context, decryptedSnapshot) {
                        if (!decryptedSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        final decryptedProduct = decryptedSnapshot.data!;
                        final name = _displayProductName(
                          decryptedProduct['product_name'],
                        );
                        final brand = _displayString(
                          decryptedProduct['brands'],
                        );
                        final imageUrl =
                            decryptedProduct['image_front_url'] as String?;

                        return ListTile(
                          leading: imageUrl != null
                              ? SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image_not_supported,
                                            ),
                                  ),
                                )
                              : const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.fastfood),
                                ),
                          title: Text(name),
                          subtitle: Text(brand),
                          onTap: () {
                            _showProductDetails(
                              productDoc.id,
                              productData: decryptedProduct,
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      case 2: // Door gebruiker aangemaakt
        if (user == null) {
          return Center(
            child: Text(
              'Log in om je producten te zien.',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          );
        }
        return FutureBuilder<SecretKey?>(
          future: getUserDEKFromRemoteConfig(user.uid),
          builder: (context, dekSnapshot) {
            if (!dekSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final userDEK = dekSnapshot.data;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('my_products')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Je hebt nog geen producten aangemaakt.',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Er is een fout opgetreden.',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }

                final products = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final productDoc = products[index];
                    final product = productDoc.data() as Map<String, dynamic>;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: () async {
                        final decrypted = Map<String, dynamic>.from(product);
                        if (userDEK != null) {
                          try {
                            if (product['product_name'] != null) {
                              decrypted['product_name'] = await decryptValue(
                                product['product_name'],
                                userDEK,
                              );
                            }
                            if (product['brands'] != null) {
                              decrypted['brands'] = await decryptValue(
                                product['brands'],
                                userDEK,
                              );
                            }
                            if (product['quantity'] != null) {
                              decrypted['quantity'] = await decryptValue(
                                product['quantity'],
                                userDEK,
                              );
                            }
                            if (product['serving_size'] != null) {
                              decrypted['serving_size'] = await decryptValue(
                                product['serving_size'],
                                userDEK,
                              );
                            }
                            if (product['nutriments_per_100g'] != null) {
                              final nutriments =
                                  product['nutriments_per_100g']
                                      as Map<String, dynamic>;
                              final decryptedNutriments = <String, dynamic>{};
                              for (final key in nutriments.keys) {
                                decryptedNutriments[key] = await decryptDouble(
                                  nutriments[key],
                                  userDEK,
                                );
                              }
                              decrypted['nutriments_per_100g'] =
                                  decryptedNutriments;
                            }
                          } catch (e) {
                            debugPrint("Fout bij decrypten eigen product: $e");
                          }
                        }
                        return decrypted;
                      }(),
                      builder: (context, decryptedSnapshot) {
                        if (!decryptedSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        final decryptedProduct = decryptedSnapshot.data!;
                        final name =
                            decryptedProduct['product_name'] ??
                            'Onbekende naam';
                        final brand = decryptedProduct['brands'] ?? 'Geen merk';
                        final nutriments =
                            decryptedProduct['nutriments_per_100g']
                                as Map<String, dynamic>?;
                        final calories =
                            nutriments?['energy-kcal']?.toString() ?? '0';

                        return Dismissible(
                          key: Key(productDoc.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Bevestig verwijdering",
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  content: Text(
                                    "Weet je zeker dat je '$name' wilt verwijderen?",
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Annuleren"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text(
                                        "Verwijderen",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('my_products')
                                .doc(productDoc.id)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("'$name' verwijderd")),
                            );
                          },
                          child: ListTile(
                            title: Text(name),
                            subtitle: Text(brand),
                            trailing: Text('$calories kcal'),
                            onTap: () {
                              _showMyProductDetails(
                                decryptedProduct,
                                productDoc.id,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      case 3: // Maaltijden
        if (user == null) {
          return Center(
            child: Text(
              'Log in om je maaltijden te zien.',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          );
        }
        return FutureBuilder<SecretKey?>(
          future: getUserDEKFromRemoteConfig(user.uid),
          builder: (context, dekSnapshot) {
            if (!dekSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final userDEK = dekSnapshot.data;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('meals')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Er is een fout opgetreden.',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return ListTile(
                    title: const Text('Voorbeeld Maaltijd'),
                    subtitle: const Text(
                      'Klik op + om je eerste maaltijd te maken',
                    ),
                    trailing: IconButton(
                      key: _maaltijdenLogKey,
                      icon: const Icon(Icons.add_shopping_cart),
                      tooltip: 'Log maaltijd',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Dit is een voorbeeld. Maak eerst een eigen maaltijd aan.',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                    ),
                  );
                }

                final meals = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final mealDoc = meals[index];
                    final meal = mealDoc.data() as Map<String, dynamic>;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: () async {
                        final decryptedMeal = Map<String, dynamic>.from(meal);
                        if (userDEK != null && meal['ingredients'] != null) {
                          try {
                            final decryptedIngredients =
                                <Map<String, dynamic>>[];
                            for (final ingredient
                                in (meal['ingredients'] as List)) {
                              final decryptedIngredient =
                                  Map<String, dynamic>.from(ingredient);
                              if (ingredient['product_name'] != null) {
                                decryptedIngredient['product_name'] =
                                    await decryptValue(
                                      ingredient['product_name'],
                                      userDEK,
                                    );
                              }
                              if (ingredient['brands'] != null) {
                                decryptedIngredient['brands'] =
                                    await decryptValue(
                                      ingredient['brands'],
                                      userDEK,
                                    );
                              }
                              if (ingredient['nutriments_per_100g'] != null) {
                                final nutriments =
                                    ingredient['nutriments_per_100g']
                                        as Map<String, dynamic>;
                                final decryptedNutriments = <String, dynamic>{};
                                for (final key in nutriments.keys) {
                                  decryptedNutriments[key] =
                                      await decryptDouble(
                                        nutriments[key],
                                        userDEK,
                                      );
                                }
                                decryptedIngredient['nutriments_per_100g'] =
                                    decryptedNutriments;
                              }
                              decryptedIngredients.add(decryptedIngredient);
                            }
                            decryptedMeal['ingredients'] = decryptedIngredients;
                          } catch (e) {
                            debugPrint("Fout bij decrypten maaltijd: $e");
                          }
                        }
                        return decryptedMeal;
                      }(),
                      builder: (context, decryptedSnapshot) {
                        if (!decryptedSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        final decryptedMeal = decryptedSnapshot.data!;
                        final name =
                            decryptedMeal['name'] ?? 'Onbekende maaltijd';

                        return Dismissible(
                          key: Key(mealDoc.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Bevestig verwijdering",
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  content: Text(
                                    "Weet je zeker dat je maaltijd '$name' wilt verwijderen?",
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Annuleren"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text(
                                        "Verwijderen",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('meals')
                                .doc(mealDoc.id)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Maaltijd '$name' verwijderd"),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(name),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              tooltip: 'Log maaltijd',
                              key: index == 0 ? _maaltijdenLogKey : null,
                              onPressed: () {
                                final mealWithId = Map<String, dynamic>.from(
                                  decryptedMeal,
                                );
                                mealWithId['id'] = mealDoc.id;
                                _logMeal(context, mealWithId);
                              },
                            ),
                            onTap: () {
                              _showAddMealSheet(
                                existingMeal: decryptedMeal,
                                mealId: mealDoc.id,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      default:
        return Container();
    }
  }

  Future<void> _logMeal(BuildContext context, Map<String, dynamic> meal) async {
    // log een maaltijd naar de logs in firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDEK = await getUserDEKFromRemoteConfig(user.uid);
    if (userDEK == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kon encryptiesleutel niet ophalen.')),
      );
      return;
    }

    final ingredients =
        (meal['ingredients'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        []; // haal de ingrediënten op
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deze maaltijd heeft geen ingrediënten.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final totalNutriments = <String, double>{
      // totale voedingswaarden initialiseren
      'energy-kcal': 0,
      'fat': 0,
      'saturated-fat': 0,
      'carbohydrates': 0,
      'sugars': 0,
      'fiber': 0,
      'proteins': 0,
      'salt': 0,
    };
    double totalAmount = 0;

    for (final ingredient in ingredients) {
      final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0;
      final nutrimentsPer100g =
          (ingredient['nutriments_per_100g'] as Map<String, dynamic>?) ?? {};
      final factor = amount / 100.0;
      totalAmount += amount;

      totalNutriments.forEach((key, value) {
        final nutrientValue =
            (nutrimentsPer100g[key] as num?)?.toDouble() ?? 0.0;
        totalNutriments[key] =
            (totalNutriments[key] ?? 0.0) + (nutrientValue * factor);
      });
    }

    final String? selectedMealType = await _showSelectMealTypeDialog(context);
    if (selectedMealType == null) return;

    /*final now = DateTime.now();
    final todayDocId =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
*/
    debugPrint("SELECTEDDATE: ${widget.selectedDate}");
    final date = widget.selectedDate ?? DateTime.now();
    final todayDocId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final dailyLogRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('logs')
        .doc(todayDocId);

    final encryptedLogEntry = {
      'product_name': await encryptValue(
        meal['name'] ?? 'Onbekende maaltijd',
        userDEK,
      ),
      'amount_g': await encryptDouble(totalAmount, userDEK),
      'timestamp': Timestamp.now(),
      'nutrients': {
        for (final key in totalNutriments.keys)
          key: await encryptDouble(totalNutriments[key] ?? 0, userDEK),
      },
      'meal_type': await encryptValue(selectedMealType, userDEK),
      'is_meal': true,
    };

    try {
      // probeer de maaltijd op te slaan
      await dailyLogRef.set({
        'entries': FieldValue.arrayUnion([encryptedLogEntry]),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text('"${meal['name']}" toegevoegd aan je logboek.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text('Fout bij opslaan van maaltijd: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showSelectMealTypeDialog(BuildContext context) async {
    // toon dialoog om maaltijdtype te selecteren
    final hour = DateTime.now().hour;
    String selectedMeal;
    if (hour >= 5 && hour < 11) {
      selectedMeal = 'Ontbijt';
    } else if (hour >= 11 && hour < 15) {
      selectedMeal = 'Lunch';
    } else if (hour >= 15 && hour < 22) {
      selectedMeal = 'Avondeten';
    } else {
      selectedMeal = 'Tussendoor';
    }
    final List<String> mealTypes = [
      'Ontbijt',
      'Lunch',
      'Avondeten',
      'Tussendoor',
    ];

    return showDialog<String>(
      // toon dialoog
      context: context,
      builder: (dialogContext) {
        // bouw de dialoog
        final isDarkMode =
            Theme.of(dialogContext).brightness == Brightness.dark;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Log Maaltijd', style: TextStyle(color: textColor)),
              content: DropdownButtonFormField<String>(
                // dropdown om maaltijdtype te selecteren
                value: selectedMeal,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(labelText: 'Sectie'),
                items: mealTypes.map((String value) {
                  // bouw de dropdown items
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setDialogState(() {
                    selectedMeal = newValue!;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuleren'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, selectedMeal);
                  },
                  child: const Text('Log'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddMealSheet({
    // toon de sheet om een maaltijd toe te voegen of te bewerken
    Map<String, dynamic>? existingMeal,
    String? mealId,
  }) async {
    final mealNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    List<Map<String, dynamic>> ingredientEntries = [];

    if (existingMeal != null) {
      // als er een bestaande maaltijd is
      mealNameController.text = existingMeal['name'] ?? '';
      final ingredients =
          (existingMeal['ingredients'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
      for (var ingredient in ingredients) {
        // loop door elk ingrediënt
        // vul de ingrediënten in
        ingredientEntries.add({
          'searchController': TextEditingController(),
          'amountController': TextEditingController(
            text: ingredient['amount']?.toString() ?? '',
          ),
          'searchResults': null,
          'selectedProduct': {
            'product_name': ingredient['product_name'],
            'brands': ingredient['brands'],
            '_id': ingredient['product_id'],
            'image_front_small_url': ingredient['image_front_small_url'],
            'nutriments_per_100g': ingredient['nutriments_per_100g'],
          },
          'isSearching': false,
          'hasLoadedMore': false,
        });
      }
    } else {
      ingredientEntries.add({
        'searchController': TextEditingController(),
        'amountController': TextEditingController(),
        'searchResults': null,
        'selectedProduct': null,
        'isSearching': false,
        'hasLoadedMore': false,
      });
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.90,
          builder: (sheetContext, scrollController) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                final textColor = isDarkMode ? Colors.white : Colors.black;

                Future<void> _saveMeal() async {
                  if (!formKey.currentState!.validate()) return;
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  final userDEK = await getUserDEKFromRemoteConfig(user.uid);
                  if (userDEK == null) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kon encryptiesleutel niet ophalen.'),
                      ),
                    );
                    return;
                  }

                  List<Map<String, dynamic>> finalProducts = [];
                  for (var entry in ingredientEntries) {
                    if (entry['selectedProduct'] != null &&
                        (entry['amountController'] as TextEditingController)
                            .text
                            .isNotEmpty) {
                      final product =
                          entry['selectedProduct'] as Map<String, dynamic>;
                      final amount = double.tryParse(
                        (entry['amountController'] as TextEditingController)
                            .text
                            .replaceAll(',', '.'),
                      );
                      if (amount != null) {
                        finalProducts.add({
                          'product_id': product['_id'],
                          'product_name': await encryptValue(
                            product['product_name'],
                            userDEK,
                          ),
                          'brands': await encryptValue(
                            product['brands'] ?? '',
                            userDEK,
                          ),
                          'image_front_small_url':
                              product['image_front_small_url'],
                          'amount': amount,
                          'nutriments_per_100g': {
                            for (final key
                                in (product['nutriments_per_100g']
                                        as Map<String, dynamic>)
                                    .keys)
                              key: await encryptDouble(
                                (product['nutriments_per_100g'][key] as num?)
                                        ?.toDouble() ??
                                    0,
                                userDEK,
                              ),
                          },
                        });
                      }
                    }
                  }

                  if (finalProducts.isEmpty) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voeg minimaal één product toe.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final mealData = {
                    'name': mealNameController.text,
                    'ingredients': finalProducts,
                    'timestamp': FieldValue.serverTimestamp(),
                  };

                  final collection = FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('meals');

                  if (mealId != null) {
                    await collection.doc(mealId).update(mealData);
                  } else {
                    await collection.add(mealData);
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }

                  Future<void> searchProductsForIngredient(
                  String query,
                  int index, {
                  bool loadMore = false,
                }) async {
                  final trimmed = query.trim();
                  if (trimmed.length < 2) {
                    setModalState(() {
                      ingredientEntries[index]['searchResults'] = null;
                    });
                    return;
                  }

                  setModalState(() {
                    ingredientEntries[index]['isSearching'] = true;
                    if (!loadMore) {
                      ingredientEntries[index]['hasLoadedMore'] = false;
                    }
                  });

                  final appKey = dotenv.env["APP_KEY"] ?? "";
                  List existingResults = [];
                  if (loadMore) {
                    existingResults.addAll(ingredientEntries[index]['searchResults'] ?? []);
                  }

                  try {
                    // start beide requests parallel (ffinder + OFF)
                    final ffinderFuture = () async {
                      try {
                        final ffinderUrl = Uri.parse(
                          "https://ffinder.nl/product?q=${Uri.encodeComponent(trimmed)}",
                        );
                        final resp = await http.get(ffinderUrl, headers: {"x-app-key": appKey}).timeout(const Duration(seconds: 10));
                        if (resp.statusCode != 200) return <Map<String, dynamic>>[];
                        final data = jsonDecode(resp.body);
                        final foods = data["foods"];
                        if (foods != null && foods["food"] is List) {
                          return (foods["food"] as List)
                              .map((p) => p is Map ? Map<String, dynamic>.from(p) : <String, dynamic>{})
                              .toList();
                        }
                        return <Map<String, dynamic>>[];
                      } catch (_) {
                        return <Map<String, dynamic>>[];
                      }
                    }();

                    final offFuture = _searchOffParallel(trimmed).catchError((_) => <Map<String, dynamic>>[]);

                    final resultsPair = await Future.wait([ffinderFuture, offFuture]);
                    final List<Map<String, dynamic>> ffinderProducts = resultsPair[0] as List<Map<String, dynamic>>;
                    final List<Map<String, dynamic>> offProducts = resultsPair[1] as List<Map<String, dynamic>>;

                    // merge (de-dup + fill missing fields)
                    final merged = _mergeProductsPreserveLogic(ffinderProducts, offProducts);

                    final ranked = _rankProducts(merged, trimmed, take: 50);
                    setModalState(() {
                      if (loadMore) {
                        ingredientEntries[index]['searchResults'] = [
                          ...existingResults,
                          ...ranked,
                        ];
                        ingredientEntries[index]['hasLoadedMore'] = true;
                      } else {
                        ingredientEntries[index]['searchResults'] = ranked;
                      }
                      ingredientEntries[index]['isSearching'] = false;
                    });

                    // async: verrijk ffinder-items met OFF-afbeelding waar mogelijk (fire-and-forget)
                    for (final raw in ffinderProducts) {
                      final code = raw['barcode'] ?? raw['code'] ?? raw['_id'] ?? raw['gtin'] ?? raw['ean'];
                      final barcode = code?.toString();
                      if (barcode == null || barcode.isEmpty) continue;

                      () async {
                        try {
                          final offUrl = Uri.parse('https://nl.openfoodfacts.org/api/v0/product/$barcode.json');
                          final offResp = await http.get(offUrl).timeout(const Duration(seconds: 6));
                          if (offResp.statusCode != 200) return;
                          final offJson = jsonDecode(offResp.body) as Map<String, dynamic>?;
                          if (offJson == null || offJson['status'] != 1 || offJson['product'] is! Map) return;
                          final offProd = offJson['product'] as Map<String, dynamic>;
                          final img = offProd['image_front_small_url'] ?? offProd['image_front_thumb_url'] ?? offProd['image_front_url'];
                          if (img is String && img.isNotEmpty) {
                            raw['image_front_small_url'] = img;
                            if (mounted) {
                              setModalState(() {
                                final list = (ingredientEntries[index]['searchResults'] as List?) ?? [];
                                for (int j = 0; j < list.length; j++) {
                                  final p = list[j] as Map<String, dynamic>;
                                  final idP = (p['_id'] ?? p['code'] ?? p['barcode'])?.toString();
                                  final idRaw = (raw['_id'] ?? raw['code'] ?? raw['barcode'])?.toString();
                                  if (idP != null && idRaw != null && idP == idRaw) {
                                    final updated = Map<String, dynamic>.from(p);
                                    updated['image_front_small_url'] = img;
                                    list[j] = updated;
                                    break;
                                  }
                                }
                                ingredientEntries[index]['searchResults'] = list;
                              });
                            }
                          }
                        } catch (_) {
                          // ignore per-item image errors
                        }
                      }();
                    }

                    return;
                  } catch (e) {
                    setModalState(() {
                      ingredientEntries[index]['searchResults'] = [];
                      ingredientEntries[index]['isSearching'] = false;
                    });
                  }
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FocusScope.of(
                    context,
                  ).unfocus(), // tik buiten om keyboard te sluiten
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 30,
                      top: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior
                                .onDrag, // veeg omlaag om keyboard te verbergen
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: ElevatedButton(
                                onPressed: _saveMeal,
                                child: Text(
                                  mealId != null
                                      ? 'Wijzigingen Opslaan'
                                      : 'Opslaan',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            Text(
                              existingMeal != null
                                  ? 'Maaltijd Bewerken'
                                  : 'Nieuwe Maaltijd Samenstellen',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: textColor),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: mealNameController,
                              style: TextStyle(color: textColor),
                              decoration: const InputDecoration(
                                labelText: 'Naam van maaltijd',
                              ),
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? 'Naam is verplicht'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Ingrediënten',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: textColor),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: ingredientEntries.length,
                              itemBuilder: (context, index) {
                                final entry = ingredientEntries[index];
                                final searchController =
                                    entry['searchController']
                                        as TextEditingController;
                                final amountController =
                                    entry['amountController']
                                        as TextEditingController;
                                final selectedProduct =
                                    entry['selectedProduct']
                                        as Map<String, dynamic>?;

                                if (selectedProduct != null) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        _displayProductName(
                                          selectedProduct['product_name'],
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Hoeveelheid: ${amountController.text}g',
                                      ),
                                      onTap: () async {
                                        final barcode =
                                            selectedProduct['_id'] as String? ??
                                            'temp_${DateTime.now().millisecondsSinceEpoch}';

                                        final currentAmount = double.tryParse(
                                          amountController.text,
                                        );

                                        final normalizedProductData =
                                            Map<String, dynamic>.from(
                                              selectedProduct,
                                            );

                                        List<dynamic> toList(dynamic value) {
                                          if (value is List) return value;
                                          if (value is String &&
                                              value.isNotEmpty)
                                            return [value];
                                          return [];
                                        }

                                        normalizedProductData['allergens_tags'] =
                                            toList(
                                              normalizedProductData['allergens_tags'],
                                            );
                                        normalizedProductData['traces_tags'] =
                                            toList(
                                              normalizedProductData['traces_tags'],
                                            );
                                        normalizedProductData['additives_tags'] =
                                            toList(
                                              normalizedProductData['additives_tags'],
                                            );

                                        final result = await _showProductDetails(
                                          barcode,
                                          productData:
                                              normalizedProductData, // Gebruik genormaliseerde data
                                          isForMeal: true,
                                          initialAmount: currentAmount,
                                        );

                                        if (result != null &&
                                            result['amount'] != null) {
                                          setModalState(() {
                                            amountController.text =
                                                result['amount'].toString();
                                            entry['selectedProduct'] =
                                                result['product'];
                                          });
                                        }
                                      },
                                      trailing: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          setModalState(() {
                                            ingredientEntries.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: searchController,
                                            style: TextStyle(color: textColor),
                                            decoration: InputDecoration(
                                              labelText: 'Product ${index + 1}',
                                              hintText:
                                                  'Typ om te zoeken of scan barcode',
                                              suffixIcon: IconButton(
                                                icon: const Icon(Icons.search),
                                                onPressed: () =>
                                                    searchProductsForIngredient(
                                                      searchController.text,
                                                      index,
                                                    ),
                                              ),
                                            ),
                                            onSubmitted: (query) async {
                                              await searchProductsForIngredient(
                                                query,
                                                index,
                                              );
                                              final results =
                                                  entry['searchResults']
                                                      as List?;
                                              if (results != null &&
                                                  results.isNotEmpty) {
                                                await showDialog(
                                                  context: context,
                                                  builder: (ctx) {
                                                    return SimpleDialog(
                                                      title: const Text(
                                                        'Kies product',
                                                      ),
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              double.maxFinite,
                                                          height: 300,
                                                          child: ListView.separated(
                                                            itemCount:
                                                                results.length,
                                                            separatorBuilder:
                                                                (_, __) =>
                                                                    const Divider(
                                                                      height: 1,
                                                                    ),
                                                            itemBuilder: (ctx2, ri) {
                                                              final p =
                                                                  results[ri]
                                                                      as Map<
                                                                        String,
                                                                        dynamic
                                                                      >;
                                                              final img =
                                                                  (p['image_front_small_url'] ??
                                                                          p['image_front_url'] ??
                                                                          p['image_thumb_url'])
                                                                      as String?;
                                                              return ListTile(
                                                                leading:
                                                                    img != null
                                                                    ? SizedBox(
                                                                        width:
                                                                            50,
                                                                        height:
                                                                            50,
                                                                        child: Image.network(
                                                                          img,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          errorBuilder:
                                                                              (
                                                                                _,
                                                                                __,
                                                                                ___,
                                                                              ) => const Icon(
                                                                                Icons.image_not_supported,
                                                                              ),
                                                                        ),
                                                                      )
                                                                    : const SizedBox(
                                                                        width:
                                                                            50,
                                                                        height:
                                                                            50,
                                                                        child: Icon(
                                                                          Icons
                                                                              .fastfood,
                                                                        ),
                                                                      ),
                                                                title: Text(
                                                                  _displayProductName(
                                                                    p['product_name'],
                                                                  ),
                                                                ),
                                                                subtitle: Text(
                                                                  p['brands'] ??
                                                                      '',
                                                                ),
                                                                onTap: () async {
                                                                  Navigator.of(
                                                                    ctx,
                                                                  ).pop();
                                                                  final barcode =
                                                                      (p['_id'] ??
                                                                              p['code'] ??
                                                                              p['barcode'])
                                                                          as String?;
                                                                  final normalized =
                                                                      Map<
                                                                        String,
                                                                        dynamic
                                                                      >.from(p);
                                                                  normalized['allergens_tags'] =
                                                                      _normalizeTags(
                                                                        normalized['allergens_tags'],
                                                                      );
                                                                  normalized['traces_tags'] =
                                                                      _normalizeTags(
                                                                        normalized['traces_tags'],
                                                                      );
                                                                  normalized['additives_tags'] =
                                                                      _normalizeTags(
                                                                        normalized['additives_tags'],
                                                                      );
                                                                  if (normalized['nutriments_per_100g'] ==
                                                                          null &&
                                                                      normalized['nutriments']
                                                                          is Map) {
                                                                    final n =
                                                                        normalized['nutriments']
                                                                            as Map<
                                                                              String,
                                                                              dynamic
                                                                            >;
                                                                    double
                                                                    _asDouble(
                                                                      dynamic v,
                                                                    ) {
                                                                      if (v ==
                                                                          null)
                                                                        return 0.0;
                                                                      if (v
                                                                          is num)
                                                                        return v
                                                                            .toDouble();
                                                                      if (v
                                                                          is String)
                                                                        return double.tryParse(
                                                                              v.replaceAll(
                                                                                ',',
                                                                                '.',
                                                                              ),
                                                                            ) ??
                                                                            0.0;
                                                                      return 0.0;
                                                                    }

                                                                    normalized['nutriments_per_100g'] = {
                                                                      'energy-kcal': _asDouble(
                                                                        n['energy-kcal_100g'] ??
                                                                            n['energy-kcal'],
                                                                      ),
                                                                      'fat': _asDouble(
                                                                        n['fat_100g'] ??
                                                                            n['fat'],
                                                                      ),
                                                                      'saturated-fat': _asDouble(
                                                                        n['saturated-fat_100g'] ??
                                                                            n['saturated-fat'],
                                                                      ),
                                                                      'carbohydrates': _asDouble(
                                                                        n['carbohydrates_100g'] ??
                                                                            n['carbohydrates'],
                                                                      ),
                                                                      'sugars': _asDouble(
                                                                        n['sugars_100g'] ??
                                                                            n['sugars'],
                                                                      ),
                                                                      'fiber': _asDouble(
                                                                        n['fiber_100g'] ??
                                                                            n['fiber'],
                                                                      ),
                                                                      'proteins': _asDouble(
                                                                        n['proteins_100g'] ??
                                                                            n['proteins'],
                                                                      ),
                                                                      'salt': _asDouble(
                                                                        n['salt_100g'] ??
                                                                            n['salt'],
                                                                      ),
                                                                    };
                                                                  }
                                                                  final result = await _showProductDetails(
                                                                    barcode ??
                                                                        'unknown_${DateTime.now().millisecondsSinceEpoch}',
                                                                    productData:
                                                                        normalized,
                                                                    isForMeal:
                                                                        true,
                                                                  );
                                                                  if (result !=
                                                                          null &&
                                                                      result['amount'] !=
                                                                          null) {
                                                                    setModalState(() {
                                                                      (entry['amountController']
                                                                              as TextEditingController)
                                                                          .text = result['amount']
                                                                          .toString();
                                                                      entry['selectedProduct'] =
                                                                          result['product'];
                                                                      entry['searchResults'] =
                                                                          null;
                                                                    });
                                                                  }
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Barcode scan per ingrediënt
                                        IconButton(
                                          icon: const Icon(
                                            Icons.qr_code_scanner,
                                          ),
                                          tooltip:
                                              'Scan barcode voor dit product',
                                          onPressed: () async {
                                            // Open barcode scanner page (verwacht String result)
                                            final scanned =
                                                await Navigator.of(
                                                  context,
                                                ).push<String>(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const SimpleBarcodeScannerPage(),
                                                  ),
                                                );
                                            if (scanned == null ||
                                                scanned.isEmpty)
                                              return;
                                            // geef korte feedback en zet loading state
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Zoeken op barcode...',
                                                ),
                                              ),
                                            );
                                            setModalState(() {
                                              entry['isSearching'] = true;
                                            });
                                            try {
                                              final offUrl = Uri.parse(
                                                'https://nl.openfoodfacts.org/api/v0/product/$scanned.json',
                                              );
                                              final resp = await http
                                                  .get(offUrl)
                                                  .timeout(
                                                    const Duration(seconds: 8),
                                                  );
                                              if (resp.statusCode != 200) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Product niet gevonden op OpenFoodFacts',
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                final j =
                                                    jsonDecode(resp.body)
                                                        as Map<
                                                          String,
                                                          dynamic
                                                        >?;
                                                if (j == null ||
                                                    j['status'] != 1 ||
                                                    j['product'] == null) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Geen productgegevens gevonden',
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  final p =
                                                      Map<String, dynamic>.from(
                                                        j['product'] as Map,
                                                      );
                                                  // normalize nutriments if needed (kopie van bestaande normalisatie)
                                                  double _asDouble(dynamic v) {
                                                    if (v == null) return 0.0;
                                                    if (v is num)
                                                      return v.toDouble();
                                                    if (v is String)
                                                      return double.tryParse(
                                                            v.replaceAll(
                                                              ',',
                                                              '.',
                                                            ),
                                                          ) ??
                                                          0.0;
                                                    return 0.0;
                                                  }

                                                  if (p['nutriments_per_100g'] ==
                                                          null &&
                                                      p['nutriments'] is Map) {
                                                    final n =
                                                        p['nutriments']
                                                            as Map<
                                                              String,
                                                              dynamic
                                                            >;
                                                    p['nutriments_per_100g'] = {
                                                      'energy-kcal': _asDouble(
                                                        n['energy-kcal_100g'] ??
                                                            n['energy-kcal'],
                                                      ),
                                                      'fat': _asDouble(
                                                        n['fat_100g'] ??
                                                            n['fat'],
                                                      ),
                                                      'saturated-fat': _asDouble(
                                                        n['saturated-fat_100g'] ??
                                                            n['saturated-fat'],
                                                      ),
                                                      'carbohydrates': _asDouble(
                                                        n['carbohydrates_100g'] ??
                                                            n['carbohydrates'],
                                                      ),
                                                      'sugars': _asDouble(
                                                        n['sugars_100g'] ??
                                                            n['sugars'],
                                                      ),
                                                      'fiber': _asDouble(
                                                        n['fiber_100g'] ??
                                                            n['fiber'],
                                                      ),
                                                      'proteins': _asDouble(
                                                        n['proteins_100g'] ??
                                                            n['proteins'],
                                                      ),
                                                      'salt': _asDouble(
                                                        n['salt_100g'] ??
                                                            n['salt'],
                                                      ),
                                                    };
                                                  } else if (p['nutriments_per_100g']
                                                      is Map) {
                                                    final mp =
                                                        Map<
                                                          String,
                                                          dynamic
                                                        >.from(
                                                          p['nutriments_per_100g']
                                                              as Map,
                                                        );
                                                    final fixed =
                                                        <String, dynamic>{};
                                                    for (final k in mp.keys) {
                                                      fixed[k] = _asDouble(
                                                        mp[k],
                                                      );
                                                    }
                                                    p['nutriments_per_100g'] =
                                                        fixed;
                                                  }
                                                  // normalize tags
                                                  p['allergens_tags'] =
                                                      _normalizeTags(
                                                        p['allergens_tags'] ??
                                                            p['allergens'],
                                                      );
                                                  p['additives_tags'] =
                                                      _normalizeTags(
                                                        p['additives_tags'] ??
                                                            p['additives'],
                                                      );
                                                  p['traces_tags'] =
                                                      _normalizeTags(
                                                        p['traces_tags'] ??
                                                            p['traces'],
                                                      );
                                                  p['product_name'] =
                                                      p['product_name'] ?? '';
                                                  p['brands'] =
                                                      p['brands'] ?? '';
                                                  p['image_front_small_url'] =
                                                      p['image_front_small_url'] ??
                                                      p['image_front_url'];
                                                  // vul geselecteerde product en eventueel hoeveelheid
                                                  setModalState(() {
                                                    entry['selectedProduct'] =
                                                        p;
                                                    entry['searchResults'] =
                                                        null;
                                                  });
                                                  // probeer portiegrootte te extraheren
                                                  final serving =
                                                      _extractServingSize(
                                                        p['serving_size'] ??
                                                            p['serving-size'] ??
                                                            p['servingSize'] ??
                                                            p['serving_quantity'],
                                                      );
                                                  if (serving != null) {
                                                    final m = RegExp(
                                                      r'(\d+(?:[.,]\d+)?)',
                                                    ).firstMatch(serving);
                                                    if (m != null) {
                                                      (entry['amountController']
                                                              as TextEditingController)
                                                          .text = m
                                                          .group(1)!
                                                          .replaceAll(',', '.');
                                                    }
                                                  }
                                                  // Open details zodat gebruiker hoeveelheid/portie kan bevestigen
                                                  final result = await _showProductDetails(
                                                    scanned,
                                                    productData: p,
                                                    isForMeal: true,
                                                    initialAmount: double.tryParse(
                                                      (entry['amountController']
                                                              as TextEditingController)
                                                          .text
                                                          .replaceAll(',', '.'),
                                                    ),
                                                  );
                                                  if (result != null &&
                                                      result['amount'] !=
                                                          null) {
                                                    setModalState(() {
                                                      (entry['amountController']
                                                              as TextEditingController)
                                                          .text = result['amount']
                                                          .toString();
                                                      entry['selectedProduct'] =
                                                          result['product'];
                                                    });
                                                  }
                                                }
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Fout bij barcode-zoekactie: $e',
                                                  ),
                                                ),
                                              );
                                            } finally {
                                              setModalState(() {
                                                entry['isSearching'] = false;
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    if (entry['isSearching'] as bool)
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    if (entry['searchResults'] != null)
                                      SizedBox(
                                        height: 150,
                                        child: ListView.builder(
                                          itemCount:
                                              (entry['searchResults'] as List)
                                                  .length +
                                              ((entry['hasLoadedMore']
                                                          as bool? ??
                                                      false)
                                                  ? 0
                                                  : 1),
                                          itemBuilder: (context, resultIndex) {
                                            final results =
                                                entry['searchResults'] as List;
                                            if (resultIndex == results.length) {
                                              return TextButton(
                                                onPressed: () =>
                                                    searchProductsForIngredient(
                                                      searchController.text,
                                                      index,
                                                      loadMore: true,
                                                    ),
                                                child: const Text(
                                                  'Meer producten laden...',
                                                ),
                                              );
                                            }

                                            final product =
                                                results[resultIndex];
                                            final imageUrl =
                                                (product['image_front_small_url'] ??
                                                        product['image_front_url'] ??
                                                        product['image_thumb_url'])
                                                    as String?;
                                            return ListTile(
                                              leading: imageUrl != null
                                                  ? SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: Image.network(
                                                        imageUrl,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) => const Icon(
                                                              Icons
                                                                  .image_not_supported,
                                                            ),
                                                      ),
                                                    )
                                                  : const SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: Icon(
                                                        Icons.fastfood,
                                                      ),
                                                    ),
                                              title: Text(
                                                _displayProductName(
                                                  product['product_name'],
                                                ),
                                              ),
                                              subtitle: Text(
                                                product['brands'] ?? 'Onbekend',
                                              ),

                                              onTap: () async {
                                                final barcode =
                                                    (product['_id'] ??
                                                            product['code'] ??
                                                            product['barcode'])
                                                        as String?;
                                                if (barcode == null) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Geen barcode gevonden voor dit product.',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                final normalized =
                                                    Map<String, dynamic>.from(
                                                      product,
                                                    );

                                                normalized['allergens_tags'] =
                                                    _normalizeTags(
                                                      normalized['allergens_tags'],
                                                    );
                                                normalized['traces_tags'] =
                                                    _normalizeTags(
                                                      normalized['traces_tags'],
                                                    );
                                                normalized['additives_tags'] =
                                                    _normalizeTags(
                                                      normalized['additives_tags'],
                                                    );

                                                if (normalized['nutriments_per_100g'] ==
                                                    null) {
                                                  if (normalized['nutriments']
                                                      is Map) {
                                                    final n =
                                                        normalized['nutriments']
                                                            as Map<
                                                              String,
                                                              dynamic
                                                            >;
                                                    double _asDouble(
                                                      dynamic v,
                                                    ) {
                                                      if (v == null) return 0.0;
                                                      if (v is num)
                                                        return v.toDouble();
                                                      if (v is String)
                                                        return double.tryParse(
                                                              v.replaceAll(
                                                                ',',
                                                                '.',
                                                              ),
                                                            ) ??
                                                            0.0;
                                                      return 0.0;
                                                    }

                                                    normalized['nutriments_per_100g'] = {
                                                      'energy-kcal': _asDouble(
                                                        n['energy-kcal_100g'] ??
                                                            n['energy-kcal'],
                                                      ),
                                                      'fat': _asDouble(
                                                        n['fat_100g'] ??
                                                            n['fat'],
                                                      ),
                                                      'saturated-fat': _asDouble(
                                                        n['saturated-fat_100g'] ??
                                                            n['saturated-fat'],
                                                      ),
                                                      'carbohydrates': _asDouble(
                                                        n['carbohydrates_100g'] ??
                                                            n['carbohydrates'],
                                                      ),
                                                      'sugars': _asDouble(
                                                        n['sugars_100g'] ??
                                                            n['sugars'],
                                                      ),
                                                      'fiber': _asDouble(
                                                        n['fiber_100g'] ??
                                                            n['fiber'],
                                                      ),
                                                      'proteins': _asDouble(
                                                        n['proteins_100g'] ??
                                                            n['proteins'],
                                                      ),
                                                      'salt': _asDouble(
                                                        n['salt_100g'] ??
                                                            n['salt'],
                                                      ),
                                                    };
                                                  } else {
                                                    normalized['nutriments_per_100g'] =
                                                        (normalized['nutriments_per_100g']
                                                            as Map<
                                                              String,
                                                              dynamic
                                                            >?) ??
                                                        {};
                                                  }
                                                }

                                                normalized['product_name'] =
                                                    normalized['product_name'] ??
                                                    '';
                                                normalized['brands'] =
                                                    normalized['brands'] ?? '';
                                                normalized['quantity'] =
                                                    normalized['quantity'] ??
                                                    '';
                                                final result =
                                                    await _showProductDetails(
                                                      barcode,
                                                      productData: normalized,
                                                      isForMeal: true,
                                                    );

                                                if (result != null &&
                                                    result['amount'] != null) {
                                                  setModalState(() {
                                                    amountController.text =
                                                        result['amount']
                                                            .toString();
                                                    entry['selectedProduct'] =
                                                        result['product'];
                                                    entry['searchResults'] =
                                                        null;
                                                  });
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.green,
                                  size: 30,
                                ),
                                tooltip: 'Voeg nog een product toe',
                                onPressed: () {
                                  setModalState(() {
                                    ingredientEntries.add({
                                      'searchController':
                                          TextEditingController(),
                                      'amountController':
                                          TextEditingController(),
                                      'searchResults': null,
                                      'selectedProduct': null,
                                      'hasLoadedMore': false,
                                      'isSearching': false,
                                    });
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _saveMeal,
                              child: Text(
                                mealId != null
                                    ? 'Wijzigingen Opslaan'
                                    : 'Maaltijd Opslaan',
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showEditMyProductSheet(
    // toon sheet om eigen product te bewerken
    Map<String, dynamic> productData,
    String docId,
  ) async {
    final _formKey = GlobalKey<FormState>();
    final nutriments =
        productData['nutriments_per_100g'] as Map<String, dynamic>? ?? {};

    final _nameController = TextEditingController(
      text: productData['product_name'],
    );
    final _brandController = TextEditingController(text: productData['brands']);
    final _quantityController = TextEditingController(
      text: productData['quantity'],
    );
    final _caloriesController = TextEditingController(
      text: nutriments['energy-kcal']?.toString(),
    );
    final _fatController = TextEditingController(
      text: nutriments['fat']?.toString(),
    );
    final _saturatedFatController = TextEditingController(
      text: nutriments['saturated-fat']?.toString(),
    );
    final _carbsController = TextEditingController(
      text: nutriments['carbohydrates']?.toString(),
    );
    final _sugarsController = TextEditingController(
      text: nutriments['sugars']?.toString(),
    );
    final _fiberController = TextEditingController(
      text: nutriments['fiber']?.toString(),
    );
    final _proteinsController = TextEditingController(
      text: nutriments['proteins']?.toString(),
    );
    final _saltController = TextEditingController(
      text: nutriments['salt']?.toString(),
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkMode ? Colors.white : Colors.black;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.90,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 30,
                top: 12,
                left: 20,
                right: 20,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Product Bewerken',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(color: textColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          labelText: 'Productnaam',
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Naam is verplicht'
                            : null,
                      ),
                      TextFormField(
                        controller: _brandController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(labelText: 'Merk'),
                      ),
                      TextFormField(
                        controller: _quantityController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          labelText: 'Hoeveelheid (bijv. 100g, 250ml)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[,.]?\d*'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Voedingswaarden per 100g of ml',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: textColor),
                      ),
                      TextFormField(
                        controller: _caloriesController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          labelText: 'Energie (kcal)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[,.]?\d*'),
                          ),
                        ],
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Calorieën zijn verplicht'
                            : null,
                      ),
                      TextFormField(
                        controller: _fatController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(labelText: 'Vetten'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[,.]?\d*'),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _saturatedFatController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          labelText: '  - Waarvan verzadigd',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[,.]?\d*'),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _carbsController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          labelText: 'Koolhydraten',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[,.]?\d*'),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _sugarsController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          labelText: '  - Waarvan suikers',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[,.]?\d*'),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _fiberController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(labelText: 'Vezels'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[,.]?\d*'),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _proteinsController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          labelText: 'Eiwitten',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[,.]?\d*'),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _saltController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(labelText: 'Zout'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[,.]?\d*'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;

                            final userDEK = await getUserDEKFromRemoteConfig(
                              user.uid,
                            );
                            if (userDEK == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Kon encryptiesleutel niet ophalen.',
                                  ),
                                ),
                              );
                              return;
                            }

                            final updatedData = {
                              'product_name': await encryptValue(
                                _nameController.text,
                                userDEK,
                              ),
                              'brands': await encryptValue(
                                _brandController.text,
                                userDEK,
                              ),
                              'quantity': await encryptValue(
                                _quantityController.text,
                                userDEK,
                              ),
                              'timestamp': FieldValue.serverTimestamp(),
                              'nutriments_per_100g': {
                                'energy-kcal': await encryptDouble(
                                  double.tryParse(
                                        _caloriesController.text.replaceAll(
                                          ',',
                                          '.',
                                        ),
                                      ) ??
                                      0,
                                  userDEK,
                                ),
                                'fat': await encryptDouble(
                                  double.tryParse(
                                        _fatController.text.replaceAll(
                                          ',',
                                          '.',
                                        ),
                                      ) ??
                                      0,
                                  userDEK,
                                ),
                                'saturated-fat': await encryptDouble(
                                  double.tryParse(
                                        _saturatedFatController.text.replaceAll(
                                          ',',
                                          '.',
                                        ),
                                      ) ??
                                      0,
                                  userDEK,
                                ),
                                'carbohydrates': await encryptDouble(
                                  double.tryParse(
                                        _carbsController.text.replaceAll(
                                          ',',
                                          '.',
                                        ),
                                      ) ??
                                      0,
                                  userDEK,
                                ),
                                'sugars': await encryptDouble(
                                  double.tryParse(
                                        _sugarsController.text.replaceAll(
                                          ',',
                                          '.',
                                        ),
                                      ) ??
                                      0,
                                  userDEK,
                                ),
                                'fiber': await encryptDouble(
                                  double.tryParse(
                                        _fiberController.text.replaceAll(
                                          ',',
                                          '.',
                                        ),
                                      ) ??
                                      0,
                                  userDEK,
                                ),
                                'proteins': await encryptDouble(
                                  double.tryParse(
                                        _proteinsController.text.replaceAll(
                                          ',',
                                          '.',
                                        ),
                                      ) ??
                                      0,
                                  userDEK,
                                ),
                                'salt': await encryptDouble(
                                  double.tryParse(
                                        _saltController.text.replaceAll(
                                          ',',
                                          '.',
                                        ),
                                      ) ??
                                      0,
                                  userDEK,
                                ),
                              },
                            };

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('my_products')
                                .doc(docId)
                                .update(updatedData);
                            Navigator.pop(context); // sluit de sheet
                          }
                        },
                        child: const Text('Opslaan'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showMyProductDetails(
    // toon details van eigen product
    Map<String, dynamic> productData,
    String docId,
  ) async {
    _addRecentMyProduct(productData, docId);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        final name = productData['product_name'] ?? 'Onbekende naam';
        final brand = productData['brands'] ?? 'Onbekend merk';
        final quantity = productData['quantity'] as String?;
        final nutriments =
            productData['nutriments_per_100g'] as Map<String, dynamic>? ?? {};

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.90,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 30,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(color: textColor),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit), // bewerk icoon
                        onPressed: () {
                          Navigator.pop(context); // Close details
                          _showEditMyProductSheet(productData, docId);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          final nutrimentsMap =
                              productData['nutriments_per_100g']
                                  as Map<String, dynamic>?;

                          final bool? wasAdded = await _showAddLogDialog(
                            context,
                            name,
                            nutrimentsMap,
                            productData['serving_size']?.toString(),
                          );

                          if (wasAdded == true && context.mounted) {
                            // als toegevoegd, sluit dan de sheet
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Merk', brand),
                  _buildInfoRow('Hoeveelheid', quantity),
                  _buildInfoRow(
                    'Portiegrootte',
                    productData['serving_size']?.toString(),
                  ),
                  const Divider(height: 24),
                  Text(
                    'Voedingswaarden per 100g of ml',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Energie (kcal)',
                    nutriments['energy-kcal']?.toString(),
                  ),
                  _buildInfoRow('Vetten', nutriments['fat']?.toString()),
                  _buildInfoRow(
                    '  - Waarvan verzadigd',
                    nutriments['saturated-fat']?.toString(),
                  ),
                  _buildInfoRow(
                    'Koolhydraten',
                    nutriments['carbohydrates']?.toString(),
                  ),
                  _buildInfoRow(
                    '  - Waarvan suikers',
                    nutriments['sugars']?.toString(),
                  ),
                  _buildInfoRow('Vezels', nutriments['fiber']?.toString()),
                  _buildInfoRow('Eiwitten', nutriments['proteins']?.toString()),
                  _buildInfoRow('Zout', nutriments['salt']?.toString()),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool?> _showAddLogDialog(
    // toon dialoog om product aan log toe te voegen
    BuildContext context,
    String productName,
    Map<String, dynamic>? nutriments,
    String? servingSize,
  ) async {
    final amountController =
        TextEditingController(); // controller voor hoeveelheid input
    if (servingSize != null && servingSize.trim().isNotEmpty) {
      final match = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(servingSize);
      if (match != null) {
        amountController.text = match.group(1)!.replaceAll(',', '.');
      }
    }
    final formKey = GlobalKey<FormState>();
    final hour = DateTime.now().hour;
    String selectedMeal;
    if (hour >= 5 && hour < 11) {
      selectedMeal = 'Ontbijt';
    } else if (hour >= 11 && hour < 15) {
      selectedMeal = 'Lunch';
    } else if (hour >= 15 && hour < 22) {
      selectedMeal = 'Avondeten';
    } else {
      selectedMeal = 'Tussendoor';
    }
    final List<String> mealTypes = [
      'Ontbijt',
      'Lunch',
      'Avondeten',
      'Tussendoor',
    ];

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDarkMode =
            Theme.of(dialogContext).brightness == Brightness.dark;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Hoeveelheid voor "$productName"',
                style: TextStyle(color: textColor),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: amountController,
                      autofocus: true,
                      style: TextStyle(color: textColor),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Hoeveelheid (gram of milliliter)',
                        suffixText: 'g of ml',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Voer een hoeveelheid in';
                        }
                        if (double.tryParse(value.replaceAll(',', '.')) ==
                            null) {
                          return 'Voer een geldig getal in';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      // dropdown voor maaltijdtype
                      value: selectedMeal,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(labelText: 'Sectie'),
                      items: mealTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        // update geselecteerd maaltijdtype
                        setDialogState(() {
                          selectedMeal = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Annuleren'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final amount = double.parse(
                        amountController.text.replaceAll(',', '.'),
                      );
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null || nutriments == null) {
                        Navigator.pop(dialogContext, false);
                        return;
                      }

                      final userDEK = await getUserDEKFromRemoteConfig(
                        user.uid,
                      );
                      if (userDEK == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kon encryptiesleutel niet ophalen.'),
                          ),
                        );
                        Navigator.pop(dialogContext, false);
                        return;
                      }

                      final factor = amount / 100.0;
                      final nutrimentsJson = nutriments;

                      final calculatedNutriments = {
                        'energy-kcal':
                            (nutrimentsJson['energy-kcal_100g'] as num? ??
                                nutrimentsJson['energy-kcal'] as num? ??
                                0) *
                            factor,
                        'fat':
                            (nutrimentsJson['fat_100g'] as num? ??
                                nutrimentsJson['fat'] as num? ??
                                0) *
                            factor,
                        'saturated-fat':
                            (nutrimentsJson['saturated-fat_100g'] as num? ??
                                nutrimentsJson['saturated-fat'] as num? ??
                                0) *
                            factor,
                        'carbohydrates':
                            (nutrimentsJson['carbohydrates_100g'] as num? ??
                                nutrimentsJson['carbohydrates'] as num? ??
                                0) *
                            factor,
                        'sugars':
                            (nutrimentsJson['sugars_100g'] as num? ??
                                nutrimentsJson['sugars'] as num? ??
                                0) *
                            factor,
                        'fiber':
                            (nutrimentsJson['fiber_100g'] as num? ??
                                nutrimentsJson['fiber'] as num? ??
                                0) *
                            factor,
                        'proteins':
                            (nutrimentsJson['proteins_100g'] as num? ??
                                nutrimentsJson['proteins'] as num? ??
                                0) *
                            factor,
                        'salt':
                            (nutrimentsJson['salt_100g'] as num? ??
                                nutrimentsJson['salt'] as num? ??
                                0) *
                            factor,
                      };

                      /*final now = DateTime.now();
                      final todayDocId =
                          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
*/
                      final date = widget.selectedDate ?? DateTime.now();
                      final todayDocId =
                          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

                      final dailyLogRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('logs')
                          .doc(todayDocId);

                      // Encrypt de waarden
                      final logEntry = {
                        'product_name': await encryptValue(
                          productName,
                          userDEK,
                        ),
                        'amount_g': await encryptDouble(amount, userDEK),
                        'timestamp': Timestamp.now(),
                        'nutrients': {
                          for (final key in calculatedNutriments.keys)
                            key: await encryptDouble(
                              calculatedNutriments[key] ?? 0,
                              userDEK,
                            ),
                        },
                        'meal_type': await encryptValue(selectedMeal, userDEK),
                      };

                      try {
                        await dailyLogRef.set({
                          'entries': FieldValue.arrayUnion([logEntry]),
                        }, SetOptions(merge: true));

                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$productName toegevoegd aan je logboek.',
                              ),
                            ),
                          );
                        }
                        Navigator.pop(dialogContext, true);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('Fout bij opslaan: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        Navigator.pop(dialogContext, false);
                      }
                    }
                  },
                  child: const Text('Opslaan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AILoadingDialog extends StatefulWidget {
  const _AILoadingDialog({Key? key}) : super(key: key);

  @override
  State<_AILoadingDialog> createState() => _AILoadingDialogState();
}

class _AILoadingDialogState extends State<_AILoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _messageIndex = 0;
  Timer? _textTimer;

  final List<String> _messages = [
    "Foto analyseren...",
    "Ingrediënten herkennen...",
    "Voedingswaarden inschatten...",
    "Even geduld...",
    "Bijna klaar...",
  ];

  @override
  void initState() {
    super.initState();
    // Animatie voor het pulserende icoon
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Timer om de tekst elke 2 seconden te veranderen
    _textTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final bgColor = isDarkMode ? Colors.grey[850] : Colors.white;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome, // AI sterretjes icoon
                  size: 48,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "AI is aan het werk",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _messages[_messageIndex],
                key: ValueKey<int>(_messageIndex),
                style: TextStyle(color: textColor.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedStatusBadge extends StatefulWidget {
  final SourceStatus status;
  final String label;
  const _AnimatedStatusBadge({
    Key? key,
    required this.status,
    required this.label,
  }) : super(key: key);

  @override
  State<_AnimatedStatusBadge> createState() => _AnimatedStatusBadgeState();
}

class _AnimatedStatusBadgeState extends State<_AnimatedStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOut),
    );
    if (widget.status == SourceStatus.loading) {
      _rotationController.repeat();
    } else {
      // korte forward/back voor entrance effect
      _rotationController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == SourceStatus.loading &&
        !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (widget.status != SourceStatus.loading &&
        _rotationController.isAnimating) {
      _rotationController.stop();
      // trigger a brief scale "pop" for status change
      _rotationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (widget.status) {
      case SourceStatus.success:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case SourceStatus.error:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case SourceStatus.loading:
      case SourceStatus.idle:
      default:
        icon = Icons.access_time;
        color = Colors.grey;
    }

    // Animatie: draaiend icoon bij loading, anders kleine scale/fade
    final iconWidget = widget.status == SourceStatus.loading
        ? RotationTransition(
            turns: _rotationController,
            child: Icon(icon, color: color, size: 18),
          )
        : ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(
                parent: _rotationController,
                curve: Curves.elasticOut,
              ),
            ),
            child: Icon(icon, color: color, size: 18),
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: SizedBox(
            key: ValueKey(widget.status),
            width: 18,
            height: 18,
            child: iconWidget,
          ),
        ),
        const SizedBox(width: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Text(
            widget.label,
            key: ValueKey<String>(widget.label + widget.status.toString()),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }
}
