import 'package:flutter/material.dart';

void main() {
  runApp(const DnaCalculatorApp());
}

class DnaCalculatorApp extends StatelessWidget {
  const DnaCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DNA Dilution Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.black87,
          surface: Colors.white,
          background: Color(0xFFF8F9FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CalculatorScreen(
      kitName: 'GlobalFiler',
      defaultTargetAmount: 1.0,
      defaultMaxVolume: 15.0,
    ),
    const CalculatorScreen(
      kitName: 'Identifiler Plus',
      defaultTargetAmount: 1.0,
      defaultMaxVolume: 10.0,
    ),
    const CalculatorScreen(
      kitName: 'MiniFiler',
      defaultTargetAmount: 0.5,
      defaultMaxVolume: 10.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black38,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'GlobalFiler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.biotech),
            label: 'Identifiler+',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.microscope),
            label: 'MiniFiler',
          ),
        ],
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final String kitName;
  final double defaultTargetAmount;
  final double defaultMaxVolume;

  const CalculatorScreen({
    super.key,
    required this.kitName,
    required this.defaultTargetAmount,
    required this.defaultMaxVolume,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late TextEditingController _targetAmountController;
  late TextEditingController _maxVolumeController;
  late TextEditingController _concentrationController;

  double? _sampleVolume;
  double? _teVolume;
  String? _recommendation;
  Color? _recommendationColor;
  String? _dilutionInstructions;

  @override
  void initState() {
    super.initState();
    _targetAmountController = TextEditingController(text: widget.defaultTargetAmount.toString());
    _maxVolumeController = TextEditingController(text: widget.defaultMaxVolume.toString());
    _concentrationController = TextEditingController();
  }

  @override
  void dispose() {
    _targetAmountController.dispose();
    _maxVolumeController.dispose();
    _concentrationController.dispose();
    super.dispose();
  }

  void _calculate() {
    final targetAmount = double.tryParse(_targetAmountController.text);
    final maxVolume = double.tryParse(_maxVolumeController.text);
    final concentration = double.tryParse(_concentrationController.text);

    if (targetAmount == null || maxVolume == null || concentration == null || concentration <= 0) {
      setState(() {
        _sampleVolume = null;
        _teVolume = null;
        _recommendation = null;
        _recommendationColor = null;
        _dilutionInstructions = null;
      });
      return;
    }

    double requiredVolume = targetAmount / concentration;

    setState(() {
      if (requiredVolume > maxVolume) {
        // Low concentration DIRECT
        _sampleVolume = maxVolume;
        _teVolume = 0.0;
        _recommendation = 'Low Concentration DIRECT';
        _recommendationColor = Colors.red;
        _dilutionInstructions = 'Sample concentration is too low to reach target amount. Use maximum input volume.';
      } else if (requiredVolume >= 2.0) {
        // DIRECT
        _sampleVolume = requiredVolume;
        _teVolume = maxVolume - requiredVolume;
        _recommendation = 'DIRECT';
        _recommendationColor = Colors.green;
        _dilutionInstructions = 'Pipetting volume is acceptable (≥ 2.0 µL). No prior dilution needed.';
      } else {
        // Dilution needed (pipetting < 2.0 µL is inaccurate)
        _recommendation = 'Dilution Recommended';
        _recommendationColor = Colors.blue;
        
        // Suggest taking 2 µL of sample, diluting such that we can use maxVolume of the dilution
        // Target concentration for the dilution: targetAmount / maxVolume
        double targetDilutionConc = targetAmount / maxVolume;
        double totalDilutionVolume = (2.0 * concentration) / targetDilutionConc;
        double teToAddForDilution = totalDilutionVolume - 2.0;

        _sampleVolume = requiredVolume; // theoretical
        _teVolume = maxVolume - requiredVolume;
        
        _dilutionInstructions = 
            'Pipetting volume is < 2.0 µL (${requiredVolume.toStringAsFixed(2)} µL). '
            'Suggested Dilution: Add 2.0 µL of sample to ${teToAddForDilution.toStringAsFixed(2)} µL of TE buffer. '
            'Then use ${maxVolume.toStringAsFixed(2)} µL of this dilution (0 µL additional TE).';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.kitName} Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCard(
                  title: 'Kit Parameters',
                  children: [
                    _buildTextField(
                      controller: _targetAmountController,
                      label: 'Target DNA Amount (ng)',
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _maxVolumeController,
                      label: 'Max Input Volume (µL)',
                      onChanged: (_) => _calculate(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'Sample Data',
                  children: [
                    _buildTextField(
                      controller: _concentrationController,
                      label: 'DNA Concentration (ng/µL)',
                      onChanged: (_) => _calculate(),
                      autoFocus: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_recommendation != null) ...[
                  _buildResultsCard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
    bool autoFocus = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      autofocus: autoFocus,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _recommendationColor ?? Colors.grey, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: _recommendationColor),
                const SizedBox(width: 8),
                Text(
                  'Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _recommendationColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _recommendationColor?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _recommendation!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _recommendationColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_recommendation != 'Dilution Recommended') ...[
              _buildResultRow('Sample Volume', '${_sampleVolume?.toStringAsFixed(2)} µL'),
              const SizedBox(height: 8),
              _buildResultRow('TE Buffer Volume', '${_teVolume?.toStringAsFixed(2)} µL'),
              const Divider(height: 24),
              _buildResultRow('Total Volume', '${(_sampleVolume! + _teVolume!).toStringAsFixed(2)} µL', isTotal: true),
            ],
            const SizedBox(height: 16),
            Text(
              _dilutionInstructions ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
