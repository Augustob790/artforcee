import 'package:flutter/material.dart';

import '../services/services.dart';
import 'controllers/quote_controller.dart';
import 'models/rules/business_rule.dart';
import 'repositories/repositories.dart';
import 'screens/home_screen.dart';

void main() {
  FactoryRegistry.initializeDefaultFactories();

  runApp(const OrcamentosDinamicosApp());
}

class OrcamentosDinamicosApp extends StatelessWidget {
  const OrcamentosDinamicosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orçamentos Dinâmicos - AltForce',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
      ),
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Widget responsável por inicializar a aplicação
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late QuoteController _quoteController;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Inicializa repositórios
      final productRepository = ProductRepository();
      final ruleRepository = BusinessRuleRepository();
      final fieldRepository = FormFieldRepository();

      // Inicializa engine de regras
      final rulesEngine = RulesEngine<BusinessRule>(ruleRepository);

      // Inicializa controller principal
      _quoteController = QuoteController(
        productRepository,
        ruleRepository,
        fieldRepository,
        rulesEngine,
      );

      // Carrega dados iniciais
      await _quoteController.initialize();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao inicializar aplicação: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro na Inicialização',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isInitialized = false;
                  });
                  _initializeApp();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Inicializando Aplicação...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Carregando produtos e regras de negócio',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return HomeScreen(quoteController: _quoteController);
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _quoteController.dispose();
    }
    super.dispose();
  }
}
