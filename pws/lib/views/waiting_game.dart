import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fFinder/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaitingGame extends StatefulWidget {
  final VoidCallback onInteraction;

  const WaitingGame({super.key, required this.onInteraction});

  @override
  State<WaitingGame> createState() => _WaitingGameState();
}

class _WaitingGameState extends State<WaitingGame> {
  int _score = 0;
  int _highScore = 0;
  final math.Random _random = math.Random();
  Alignment _alignment = Alignment.center;
  String _currentIcon = '🍎';
  bool _isBomb = false;
  Timer? _bombTimer;

  final List<String> _icons = [
    '🍎',
    '🍌',
    '🍇',
    '🍊',
    '🍓',
    '🍔',
    '🍕',
    '🍩',
    '🥕',
    '🥦',
    '🥑',
    '🥥',
    '🍒',
    '🍋',
    '🍉',
    '🍐',
    '🍑',
    '🍍',
    '🥝',
    '🍅',
    '🌽',
    '🌶️',
    '🥒',
    '🍄',
    '🥜',
    '🌰',
    '🍞',
    '🥐',
    '🥖',
    '🥨',
    '🥞',
    '🧇',
    '🧀',
    '🍖',
    '🍗',
    '🥩',
    '🥓',
    '🥪',
    '🌮',
    '🌯',
    '🥗',
    '🥚',
    '🥘',
    '🍲',
    '🥣',
    '🍿',
    '🧂',
    '🥫',
    '🍱',
    '🍙',
    '🍚',
    '🍛',
    '🍜',
    '🍝',
    '🍠',
    '🍢',
    '🍣',
    '🍤',
    '🍥',
    '🥮',
    '🍡',
    '🥟',
    '🥠',
    '🍦',
    '🍧',
    '🍨',
    '🥧',
    '🧁',
    '🍰',
    '🎂',
    '🍮',
    '🍬',
    '🍭',
    '🍫',
    '🍪',
    '🍯',
    '🍼',
    '🥛',
    '☕',
    '🧃',
  ];

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  @override
  void dispose() {
    _bombTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _highScore = prefs.getInt('waiting_game_highscore') ?? 0;
      });
    }
  }

  Future<void> _updateHighScore() async {
    if (_score > _highScore) {
      setState(() {
        _highScore = _score;
        // Save automatically
        SharedPreferences.getInstance().then((prefs) {
          prefs.setInt('waiting_game_highscore', _highScore);
        });
      });
    }
  }

  void _handleTap() {
    widget.onInteraction();

    // Als het een bom is: reset score
    if (_isBomb) {
      setState(() {
        _score = 0;
        _isBomb = false;
        _bombTimer?.cancel();
        // Reset naar willekeurig fruit
        _currentIcon = _icons[_random.nextInt(_icons.length)];
        // Verplaatsen
        _moveIcon();
      });
      return;
    }

    setState(() {
      _score++;

      // 20% kans op een bom bij volgende stap
      if (_random.nextDouble() < 0.2) {
        _isBomb = true;
        _currentIcon = '💣';
        _moveIcon();

        // Timer starten om bom weer weg te halen als er niet op geklikt wordt
        _bombTimer?.cancel();
        _bombTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isBomb = false;
              _currentIcon = _icons[_random.nextInt(_icons.length)];
            });
          }
        });
      } else {
        _currentIcon = _icons[_random.nextInt(_icons.length)];
        _moveIcon();
      }
    });
    _updateHighScore();
  }

  void _moveIcon() {
    double nextX = _alignment.x + (_random.nextDouble() - 0.5) * 1.5;
    double nextY = _alignment.y + (_random.nextDouble() - 0.5) * 1.5;

    if (nextX < -0.9) nextX = -0.7;
    if (nextX > 0.9) nextX = 0.7;
    if (nextY < -0.9) nextY = -0.7;
    if (nextY > 0.9) nextY = 0.7;

    _alignment = Alignment(nextX, nextY);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    AppLocalizations.of(context)!.gameScore(_score),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.gameHighScore(_highScore),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: _alignment,
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isBomb ? Colors.redAccent : Colors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(_currentIcon, style: const TextStyle(fontSize: 28)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                AppLocalizations.of(context)!.tapTheFood,
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
