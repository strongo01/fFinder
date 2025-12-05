import 'package:cryptography/cryptography.dart';
import 'package:fFinder/views/crypto_class.dart';
import 'package:fFinder/views/feedback_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'edit_product_view.dart';
import 'barcode_scanner.dart';

class AddFoodPage extends StatefulWidget {
  final String? scannedBarcode;
  final Map<String, dynamic>?
  initialProductData; //initialproductdata: de data van het product als die al bekend is (barcode)

  const AddFoodPage({super.key, this.scannedBarcode, this.initialProductData});
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

  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    /*if (widget.scannedBarcode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // wacht totdat de build klaar is
        if (mounted) {
          _showProductDetails(
            widget.scannedBarcode!,
            productData: widget.initialProductData,
          );
        }
      });
    }*/
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _createTutorial();
    //_showTutorial();
    _handleInitialAction();
  }

  void _handleInitialAction() async {
    final user = FirebaseAuth.instance.currentUser;

    // Standaard is de tutorial niet afgerond als er geen gebruiker is
    bool tutorialCompleted = false;

    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        tutorialCompleted = userDoc.data()?['tutorialFoodAf'] ?? false;
      } catch (e) {
        // Fout bij ophalen, ga er voor de veiligheid van uit dat de tutorial niet is voltooid
        print("Kon tutorial status niet ophalen: $e");
        tutorialCompleted = false;
      }
    }

    if (tutorialCompleted) {
      // Tutorial is afgerond, open de productdetails als er een barcode is
      if (widget.scannedBarcode != null && mounted) {
        // Gebruik addPostFrameCallback om zeker te weten dat de build klaar is
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showProductDetails(
              widget.scannedBarcode!,
              productData: widget.initialProductData,
            );
          }
        });
      }
    } else {
      // Tutorial is nog niet afgerond, start de tutorial
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
      hideSkip: true,
      onFinish: () {
        print("Tutorial voltooid");
        prefs.setBool('food_tutorial_shown', true); // lokaal opslaan
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'tutorialFoodAf': true,
          });
        }
      },
      onClickTarget: (target) {
        // wanneer een target wordt aangeklikt
        print('Target geklikt: $target');
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

  Future<void> _searchProducts(String query) async {
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
    });

    try {
      List all = []; // Lege lijst om producten op te slaan

      try {
        print("--- Poging 1: ffinder.nl endpoint ---");
        final ffinderUrl = Uri.parse(
          "https://ffinder.nl/search?query=${Uri.encodeComponent(trimmed)}",
        );
        print("URL: $ffinderUrl");
        final appKey = dotenv.env["APP_KEY"];

        final response = await http.get(
          ffinderUrl,
          headers: {"x-app-key": appKey ?? ""},
        );

        print("ffinder.nl Status Code: ${response.statusCode}");
        print("ffinder.nl Response Body: ${response.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final foodsObject = data["foods"];
          if (foodsObject != null && foodsObject["food"] is List) {
            final products = foodsObject["food"] as List;

            if (products.isNotEmpty) {
              print(
                "Succes: ${products.length} producten gevonden via ffinder.nl",
              );
              all = products;
            } else {
              print("ffinder.nl gaf een leeg resultaat.");
            }
          }
        } else {
          print("ffinder.nl gaf een error status: ${response.statusCode}");
        }
      } catch (e) {
        print("Fout bij het aanroepen van ffinder.nl: $e");
        // De 'all' lijst is nog steeds leeg, dus de fallback wordt automatisch gebruikt.
      }

      // Fallback naar Open Food Facts
      if (all.isEmpty) {
        print("\n--- Poging 2: Open Food Facts (Fallback) ---");
        final openFoodFactsUrl = Uri.parse(
          "https://nl.openfoodfacts.org/cgi/search.pl"
          "?search_terms=${Uri.encodeComponent(trimmed)}"
          "&search_simple=1"
          "&json=1"
          "&action=process",
        );
        print("URL: $openFoodFactsUrl");

        final response = await http.get(openFoodFactsUrl);
        print("OpenFoodFacts Status Code: ${response.statusCode}");
        //print("OpenFoodFacts Response Body: ${response.body}"); // Kan erg lang zijn

        if (response.statusCode != 200) {
          throw Exception("HTTP ${response.statusCode}");
        }

        final data = jsonDecode(response.body);
        all = (data["products"] as List?) ?? []; // alle producten
        print("Succes: ${all.length} producten gevonden via Open Food Facts.");
      }

      final escaped = RegExp.escape(trimmed); // escape speciale tekens
      final wholeWord = RegExp(
        // hele woord matchen
        r'\b' + escaped + r'\b',
        caseSensitive: false,
        unicode: true,
      );
      final startsWith = RegExp(
        '^' + escaped,
        caseSensitive: false,
        unicode: true,
      );

      List filtered = all.where((p) {
        // filter op hele woord
        final name =
            "${p["product_name"] ?? ''} "
            "${p["generic_name"] ?? ''} "
            "${p["brands"] ?? ''}";
        return wholeWord.hasMatch(name);
      }).toList();

      if (filtered.isEmpty) {
        // als geen hele woord matches, filter op starts with
        filtered = all.where((p) {
          final name =
              "${p["product_name"] ?? ''} "
              "${p["generic_name"] ?? ''} "
              "${p["brands"] ?? ''}";
          return startsWith.hasMatch(name);
        }).toList();
      }

      // fallback naar alle producten
      final finalList = filtered.isNotEmpty ? filtered : all;

      // limiet
      const maxResults = 50;
      final limited = finalList.length > maxResults
          ? finalList.sublist(0, maxResults)
          : finalList;

      if (mounted) {
        setState(() {
          _searchResults = limited;
        });
      }
    } catch (e) {
      print("Algemene fout in _searchProducts: $e");
      setState(() {
        _errorMessage = 'Fout bij ophalen: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scanBarcode() async {
    //hij reset de foutmeldingen
    setState(() {
      _errorMessage = null;
    });
    // hij opent de barcode scanner en wacht totdat hij klaar is
    var res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()),
    );

    // als er een geldige barcode is gescand en niet -1
    if (res is String && res != '-1') {
      final barcode = res;
      final user = FirebaseAuth.instance.currentUser;

      // Als er geen gebruiker is, haal direct op van API
      if (user == null) {
        _showProductDetails(barcode);
        return;
      }

      // Toon laadindicator terwijl we Firestore controleren
      setState(() {
        _isLoading = true;
      });

      try {
        // Controleer eerst collectie
        final recentDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('recents')
            .doc(barcode);

        final docSnapshot = await recentDocRef.get();

        if (docSnapshot.exists) {
          // Product gevonden in recents, haal de data op
          final encryptedData = docSnapshot.data() as Map<String, dynamic>;
          final decryptedData = Map<String, dynamic>.from(encryptedData);
          final userDEK = await getUserDEKFromRemoteConfig(user.uid);

          if (userDEK != null) {
            // Decrypt de velden als de sleutel beschikbaar is
            try {
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
            } catch (e) {
              print("Fout bij decrypten van recente producten: $e");
              // Ga door met versleutelde (of niet-versleutelde) data bij een fout
            }
          }
          // Roep de details sheet aan met de (mogelijk) gedecrypteerde data
          _showProductDetails(barcode, productData: decryptedData);
        } else {
          // Product niet in recents, haal op van API
          _showProductDetails(barcode);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = "Fout bij controleren van recente producten: $e";
          });
        }
      } finally {
        // Verberg laadindicator NADAT de data is doorgegeven
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
    // bouw de zoekresultaten lijst
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
              // knop om eigen product toe te voegen
              onPressed: _showAddMyProductSheet,
              child: const Text('Wilt u zelf een product toevoegen?'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount:
          _searchResults!.length +
          1, // +1 voor de knop om eigen product toe te voegen
      itemBuilder: (context, index) {
        if (index == _searchResults!.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextButton(
              onPressed: _showAddMyProductSheet,
              child: const Text(
                'Niet de gewenste resultaten: voeg een product toe!',
              ),
            ),
          );
        }

        final product = _searchResults![index] as Map<String, dynamic>;
        final imageUrl = product['image_front_small_url'] as String?;

        return ListTile(
          // toon elk product in de lijst
          leading: imageUrl != null
              ? SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.network(
                    // laad de afbeelding van het product
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
          title: Text((product['product_name'] as String?) ?? 'Onbekende naam'),
          subtitle: Text((product['brands'] as String?) ?? 'Onbekend merk'),
          onTap: () {
            final barcode = product['_id'] as String?;
            if (barcode != null) {
              _showProductDetails(barcode);
            }
          },
        );
      },
    );
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

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                    decoration: const InputDecoration(labelText: 'Productnaam'),
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
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Voedingswaarden per 100g/ml',
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
                    keyboardType: TextInputType.number,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Calorieën zijn verplicht'
                        : null,
                  ),
                  TextFormField(
                    controller: _fatController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Vetten'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _saturatedFatController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: '  - Waarvan verzadigd',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _carbsController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'Koolhydraten',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _sugarsController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: '  - Waarvan suikers',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _fiberController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Vezels'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _proteinsController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Eiwitten'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _saltController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Zout'),
                    keyboardType: TextInputType.number,
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
                              double.tryParse(_caloriesController.text) ?? 0,
                              userDEK,
                            ),
                            'fat': await encryptDouble(
                              double.tryParse(_fatController.text) ?? 0,
                              userDEK,
                            ),
                            'saturated-fat': await encryptDouble(
                              double.tryParse(_saturatedFatController.text) ??
                                  0,
                              userDEK,
                            ),
                            'carbohydrates': await encryptDouble(
                              double.tryParse(_carbsController.text) ?? 0,
                              userDEK,
                            ),
                            'sugars': await encryptDouble(
                              double.tryParse(_sugarsController.text) ?? 0,
                              userDEK,
                            ),
                            'fiber': await encryptDouble(
                              double.tryParse(_fiberController.text) ?? 0,
                              userDEK,
                            ),
                            'proteins': await encryptDouble(
                              double.tryParse(_proteinsController.text) ?? 0,
                              userDEK,
                            ),
                            'salt': await encryptDouble(
                              double.tryParse(_saltController.text) ?? 0,
                              userDEK,
                            ),
                          },
                        };

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('my_products')
                            .add(dataToSave);
                        Navigator.pop(context); // sluit de sheet na opslaan
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
      print("Fout: Kon encryptiesleutel niet ophalen voor recents.");
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
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        // toon de product bewerk sheet
        return ProductEditSheet(
          barcode: barcode,
          productData: productData,
          isForMeal: isForMeal,
          initialAmount: initialAmount,
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
                if (!dekSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final userDEK = dekSnapshot.data;

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final productDoc = products[index];
                    final product = productDoc.data() as Map<String, dynamic>;
                    final isMyProduct =
                        product['isMyProduct'] as bool? ?? false;

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
                            // Optioneel: decrypt nutriments als ze encrypted zijn
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
                            print("Fout bij decrypten: $e");
                          }
                        }
                        return decrypted;
                      }(),
                      builder: (context, decryptedSnapshot) {
                        if (!decryptedSnapshot.hasData) {
                          return const ListTile(
                            title: Text('Product wordt geladen...'),
                          );
                        }
                        final decryptedProduct = decryptedSnapshot.data!;
                        final name =
                            decryptedProduct['product_name'] ??
                            'Onbekende naam';
                        final brand =
                            decryptedProduct['brands'] ?? 'Onbekend merk';
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
                            print("Fout bij decrypten favoriet: $e");
                          }
                        }
                        return decrypted;
                      }(),
                      builder: (context, decryptedSnapshot) {
                        if (!decryptedSnapshot.hasData) {
                          return const ListTile(
                            title: Text('Product wordt geladen...'),
                          );
                        }
                        final decryptedProduct = decryptedSnapshot.data!;
                        final name =
                            decryptedProduct['product_name'] ??
                            'Onbekende naam';
                        final brand =
                            decryptedProduct['brands'] ?? 'Onbekend merk';
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
                            print("Fout bij decrypten eigen product: $e");
                          }
                        }
                        return decrypted;
                      }(),
                      builder: (context, decryptedSnapshot) {
                        if (!decryptedSnapshot.hasData) {
                          return const ListTile(
                            title: Text('Product wordt geladen...'),
                          );
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
                            print("Fout bij decrypten maaltijd: $e");
                          }
                        }
                        return decryptedMeal;
                      }(),
                      builder: (context, decryptedSnapshot) {
                        if (!decryptedSnapshot.hasData) {
                          return const ListTile(
                            title: Text('Maaltijd wordt geladen...'),
                          );
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

    final now = DateTime.now();
    final todayDocId =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

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
    final _mealNameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    List<Map<String, dynamic>> ingredientEntries = [];

    if (existingMeal != null) {
      // als er een bestaande maaltijd is
      _mealNameController.text = existingMeal['name'] ?? '';
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
        });
      }
    } else {
      ingredientEntries.add({
        'searchController': TextEditingController(),
        'amountController': TextEditingController(),
        'searchResults': null,
        'selectedProduct': null,
        'isSearching': false,
      });
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // bouw de sheet
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            final textColor = isDarkMode ? Colors.white : Colors.black;

            Future<void> searchProductsForIngredient(
              String query,
              int index,
            ) async {
              if (query.length < 2) {
                // minimale lengte voor zoeken
                setModalState(() {
                  ingredientEntries[index]['searchResults'] = null;
                });
                return;
              }

              setModalState(() {
                ingredientEntries[index]['isSearching'] = true;
              });

              List all = [];
              final appKey = dotenv.env["APP_KEY"] ?? "";

              try {
                //Probeer eerst ffinder.nl (jouw backend)
                try {
                  final ffinderUrl = Uri.parse(
                    "https://ffinder.nl/search?query=${Uri.encodeComponent(query)}",
                  );

                  final ffinderResponse = await http.get(
                    ffinderUrl,
                    headers: {"x-app-key": appKey},
                  );

                  if (ffinderResponse.statusCode == 200) {
                    final data = jsonDecode(ffinderResponse.body);
                    final foodsObject = data["foods"];
                    if (foodsObject != null && foodsObject["food"] is List) {
                      all = foodsObject["food"] as List;
                    }
                  } else {
                    print(
                      "ffinder.nl gaf status ${ffinderResponse.statusCode}",
                    );
                  }
                } catch (e) {
                  print("Fout bij zoeken op ffinder.nl: $e");
                  // laat 'all' leeg zodat fallback wordt gebruikt
                }

                // Fallback naar OpenFoodFacts als ffinder niets teruggeeft of error
                if (all.isEmpty) {
                  final offUrl = Uri.parse(
                    "https://nl.openfoodfacts.org/cgi/search.pl"
                    "?search_terms=${Uri.encodeComponent(query)}"
                    "&search_simple=1"
                    "&json=1"
                    "&action=process",
                  );

                  final offResponse = await http.get(offUrl);
                  if (offResponse.statusCode == 200) {
                    final data = jsonDecode(offResponse.body);
                    all = (data["products"] as List?) ?? [];
                  } else {
                    print("OpenFoodFacts gaf status ${offResponse.statusCode}");
                  }
                }

                //Resultaten in state zetten
                setModalState(() {
                  ingredientEntries[index]['searchResults'] = all;
                  ingredientEntries[index]['isSearching'] = false;
                });
              } catch (e) {
                print("Algemene fout bij zoeken: $e");
                setModalState(() {
                  ingredientEntries[index]['searchResults'] = [];
                  ingredientEntries[index]['isSearching'] = false;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Nieuwe Maaltijd Samenstellen',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(color: textColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _mealNameController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          labelText: 'Naam van maaltijd',
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Naam is verplicht'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ingrediënten',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: textColor),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // in een scrollview
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
                              entry['selectedProduct'] as Map<String, dynamic>?;

                          if (selectedProduct != null) {
                            // toon geselecteerd product
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                title: Text(selectedProduct['product_name']),
                                subtitle: Text(
                                  'Hoeveelheid: ${amountController.text}g',
                                ),
                                onTap: () async {
                                  final barcode =
                                      selectedProduct['_id'] as String?;
                                  if (barcode == null) return;

                                  final currentAmount = double.tryParse(
                                    amountController.text,
                                  );

                                  final result = await _showProductDetails(
                                    // toon productdetails om hoeveelheid aan te passen
                                    barcode,
                                    productData: selectedProduct,
                                    isForMeal: true,
                                    initialAmount: currentAmount,
                                  );

                                  if (result != null &&
                                      result['amount'] != null) {
                                    // update hoeveelheid
                                    setModalState(() {
                                      amountController.text = result['amount']
                                          .toString();
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
                                  if (ingredientEntries.length > 1)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setModalState(() {
                                          ingredientEntries.removeAt(index);
                                        });
                                      },
                                    ),
                                ],
                              ),
                              if (entry['isSearching']
                                  as bool) // toon laadindicator
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              if (entry['searchResults'] !=
                                  null) // toon zoekresultaten
                                SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    itemCount:
                                        (entry['searchResults'] as List).length,
                                    itemBuilder: (context, resultIndex) {
                                      final product =
                                          (entry['searchResults']
                                              as List)[resultIndex];
                                      return ListTile(
                                        title: Text(
                                          product['product_name'] ?? 'Onbekend',
                                        ),
                                        subtitle: Text(
                                          product['brands'] ?? 'Onbekend',
                                        ),
                                        onTap: () async {
                                          final barcode =
                                              product['_id'] as String?;
                                          if (barcode == null) return;

                                          final result =
                                              await _showProductDetails(
                                                barcode,
                                                isForMeal: true,
                                              );

                                          if (result != null &&
                                              result['amount'] != null) {
                                            setModalState(() {
                                              amountController.text =
                                                  result['amount'].toString();
                                              entry['selectedProduct'] =
                                                  result['product'];
                                              entry['searchResults'] = null;
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
                                'searchController': TextEditingController(),
                                'amountController': TextEditingController(),
                                'searchResults': null,
                                'selectedProduct': null,
                                'isSearching': false,
                              });
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
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
                                    'Kon encryptiesleutel niet ophalen.',
                                  ),
                                ),
                              );
                              return;
                            }

                            List<Map<String, dynamic>> finalProducts = [];
                            for (var entry in ingredientEntries) {
                              if (entry['selectedProduct'] != null &&
                                  (entry['amountController']
                                          as TextEditingController)
                                      .text
                                      .isNotEmpty) {
                                final product =
                                    entry['selectedProduct']
                                        as Map<String, dynamic>;
                                final amount = double.tryParse(
                                  (entry['amountController']
                                          as TextEditingController)
                                      .text,
                                );
                                if (amount != null) {
                                  finalProducts.add({
                                    'product_id': product['_id'],
                                    'product_name': await encryptValue(
                                      product['product_name'],
                                      userDEK,
                                    ),
                                    'brands': await encryptValue(
                                      product['brands'],
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
                                          (product['nutriments_per_100g'][key]
                                                      as num?)
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
                              // controleer of er producten zijn toegevoegd
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
                              'name': _mealNameController.text,
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
                            Navigator.pop(context);
                          }
                        },
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

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                    decoration: const InputDecoration(labelText: 'Productnaam'),
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
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Voedingswaarden per 100g/ml',
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
                    keyboardType: TextInputType.number,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Calorieën zijn verplicht'
                        : null,
                  ),
                  TextFormField(
                    controller: _fatController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Vetten'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _saturatedFatController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: '  - Waarvan verzadigd',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _carbsController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'Koolhydraten',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _sugarsController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: '  - Waarvan suikers',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _fiberController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Vezels'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _proteinsController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Eiwitten'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _saltController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Zout'),
                    keyboardType: TextInputType.number,
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
                              double.tryParse(_caloriesController.text) ?? 0,
                              userDEK,
                            ),
                            'fat': await encryptDouble(
                              double.tryParse(_fatController.text) ?? 0,
                              userDEK,
                            ),
                            'saturated-fat': await encryptDouble(
                              double.tryParse(_saturatedFatController.text) ??
                                  0,
                              userDEK,
                            ),
                            'carbohydrates': await encryptDouble(
                              double.tryParse(_carbsController.text) ?? 0,
                              userDEK,
                            ),
                            'sugars': await encryptDouble(
                              double.tryParse(_sugarsController.text) ?? 0,
                              userDEK,
                            ),
                            'fiber': await encryptDouble(
                              double.tryParse(_fiberController.text) ?? 0,
                              userDEK,
                            ),
                            'proteins': await encryptDouble(
                              double.tryParse(_proteinsController.text) ?? 0,
                              userDEK,
                            ),
                            'salt': await encryptDouble(
                              double.tryParse(_saltController.text) ?? 0,
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
          // maak de sheet sleepbaar
          expand: false, // niet volledig uitvouwen
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16.0),
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
                  const Divider(height: 24),
                  Text(
                    'Voedingswaarden per 100g/ml',
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
  ) async {
    final amountController =
        TextEditingController(); // controller voor hoeveelheid input
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

                      final now = DateTime.now();
                      final todayDocId =
                          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

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
