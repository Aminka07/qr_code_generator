import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const QrGeneratorApp());
}

class QrGeneratorApp extends StatefulWidget {
  const QrGeneratorApp({Key? key}) : super(key: key);

  @override
  State<QrGeneratorApp> createState() => _QrGeneratorAppState();
}

class _QrGeneratorAppState extends State<QrGeneratorApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF5B4DF0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR code generator',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      home: QrHomeScreen(
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class QrHomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const QrHomeScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<QrHomeScreen> createState() => _QrHomeScreenState();
}

class _QrHomeScreenState extends State<QrHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  String _qrData = 'https://mnu.kz';
  double _qrSize = 200.0;
  Color _qrColor = Colors.deepPurple;

  @override
  void initState() {
    super.initState();
    _textController.text = _qrData;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _textController.text = 'https://mnu.kz';
      _qrData = 'https://mnu.kz';
      _qrSize = 200.0;
      _qrColor = Colors.deepPurple;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR code generator'),
        actions: [
          Row(
            children: [
              const Icon(Icons.dark_mode_outlined),
              Switch(
                value: widget.isDarkMode,
                onChanged: widget.onThemeChanged,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: _resetForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Анимированное превью QR-кода
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: QrImageView(
                    key: ValueKey('$_qrData-$_qrSize-$_qrColor'),
                    data: _qrData.isEmpty ? ' ' : _qrData,
                    version: QrVersions.auto,
                    size: _qrSize,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: _qrColor,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: _qrColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Форма с валидацией
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Text or URL',
                      hintText: 'https://example.com',
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder(),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter some text or URL';
                      }
                      if (value.length > 500) {
                        return 'Text is too long (max 500 characters)';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _qrData = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Настройка размера (Slider)
                  Text(
                    'QR code size: ${_qrSize.toInt()} px',
                    style: theme.textTheme.titleMedium,
                  ),
                  Slider(
                    value: _qrSize,
                    min: 120.0,
                    max: 280.0,
                    divisions: 16,
                    label: _qrSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _qrSize = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),

                  // Выбор цвета
                  Text(
                    'Select QR color:',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildColorOption(Colors.deepPurple),
                      _buildColorOption(Colors.blue),
                      _buildColorOption(Colors.teal),
                      _buildColorOption(Colors.red),
                      _buildColorOption(Colors.black),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _qrColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _qrColor = color;
        });
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3)
              : null,
        ),
      ),
    );
  }
}