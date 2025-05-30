import 'package:flutter/material.dart';
import '../services/translation_service.dart';
import '../services/history_service.dart';
import '../models/translation_item.dart';
import '../managers/favorites_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

final Map<String, String> languageFlags = {
  'en': 'assets/flags/en.svg',
  'fr': 'assets/flags/fr.svg',
  'es': 'assets/flags/es.svg',
  'de': 'assets/flags/de.svg',
  'ru': 'assets/flags/ru.svg',
};

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({Key? key}) : super(key: key);

  @override
  _TranslateScreenState createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _translatedText = "";
  String _fromLang = "en";
  String _toLang = "fr";

  bool _isFavorite = false;

  late AnimationController _swapController;
  late Animation<double> _swapAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final FavoritesManager _favoritesManager = FavoritesManager();

  @override
  void initState() {
    super.initState();

    _swapController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _swapAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _swapController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _focusNode.addListener(() {
      setState(() {});
    });

    _favoritesManager.loadFavorites();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _swapController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final translated = await TranslationService.translate(text, _fromLang, _toLang);

      final newTranslation = TranslationItem(
        original: text,
        translated: translated,
        fromLang: _fromLang,
        toLang: _toLang,
        timestamp: DateTime.now(),
        isFavorite: _isFavorite,
      );

      await HistoryService.saveTranslation(newTranslation.original, newTranslation.translated);

      setState(() {
        _translatedText = translated;
        _isFavorite = _favoritesManager.isFavorite(newTranslation);
      });

      _fadeController.forward(from: 0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Translation error: $e')),
      );
    }
  }

  void _swapLanguages() {
    _swapController.forward(from: 0).then((_) {
      setState(() {
        final tmp = _fromLang;
        _fromLang = _toLang;
        _toLang = tmp;
        _translatedText = "";
        _isFavorite = false;
      });
      _swapController.reverse();
      _fadeController.reset();
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    final item = TranslationItem(
      original: _controller.text.trim(),
      translated: _translatedText,
      fromLang: _fromLang,
      toLang: _toLang,
      timestamp: DateTime.now(),
      isFavorite: _isFavorite,
    );

    if (_isFavorite) {
      await _favoritesManager.addFavorite(item);
    } else {
      await _favoritesManager.removeFavorite(item);
    }
  }

  Widget _buildLanguageDropdown(String value, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: value,
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down),
      underline: SizedBox(),
      onChanged: onChanged,
      items: languageFlags.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(entry.value, width: 24, height: 24),
              SizedBox(width: 8),
              Text(entry.key.toUpperCase()),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(child: _buildLanguageDropdown(_fromLang, (val) {
                  if (val != null && val != _fromLang) {
                    setState(() {
                      _fromLang = val;
                      _translatedText = "";
                      _isFavorite = false;
                    });
                    FocusScope.of(context).requestFocus(_focusNode);
                  }
                })),
                RotationTransition(
                  turns: _swapAnimation,
                  child: IconButton(
                    iconSize: 36,
                    icon: Icon(Icons.swap_horiz, color: Color(0xFF4A90E2)),
                    onPressed: _swapLanguages,
                  ),
                ),
                Expanded(child: _buildLanguageDropdown(_toLang, (val) {
                  if (val != null && val != _toLang) {
                    setState(() {
                      _toLang = val;
                      _translatedText = "";
                      _isFavorite = false;
                    });
                    FocusScope.of(context).requestFocus(_focusNode);
                  }
                })),
              ],
            ),
            const SizedBox(height: 30),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow: isFocused
                    ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))]
                    : [],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.text,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Enter text to translate...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.black : Color(0xFF4A90E2),
                  ),
                ),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                onSubmitted: (_) => _translate(),
                cursorColor: Color(0xFF4A90E2),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _translate,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.black : Color(0xFFEF5350),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text("Translate", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _fadeAnimation,
              child: _translatedText.isEmpty
                  ? SizedBox.shrink()
                  : Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black54 : Colors.blue.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _translatedText,
                        style: TextStyle(
                          fontSize: 22,
                          color: isDark ? Colors.white : Color(0xFF4A90E2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey,
                        size: 30,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
