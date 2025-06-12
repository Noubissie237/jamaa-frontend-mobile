import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _enteredPin = '';
  String? _savedPin;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPin = prefs.getString('user_pin');
      _isLoading = false;
    });
  }

  void _onKeyTap(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _error = null;
      });
      if (_enteredPin.length == 4) {
        _validatePin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _error = null;
      });
    }
  }

  void _validatePin() {
    if (_enteredPin == _savedPin) {
      context.go('/main');
    } else {
      setState(() {
        _error = 'Code PIN incorrect';
        _enteredPin = '';
      });
    }
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final filled = index < _enteredPin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? Theme.of(context).primaryColor : Colors.transparent,
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeypadButton(String number, {IconData? icon, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => _onKeyTap(number),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                  )
                : Text(
                    number,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('1'),
            _buildKeypadButton('2'),
            _buildKeypadButton('3'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('4'),
            _buildKeypadButton('5'),
            _buildKeypadButton('6'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('7'),
            _buildKeypadButton('8'),
            _buildKeypadButton('9'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton(
              '',
              icon: Icons.login,
              onTap: () => context.go('/login'),
            ),
            _buildKeypadButton('0'),
            _buildKeypadButton(
              '',
              icon: Icons.backspace_outlined,
              onTap: _onBackspace,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion par code PIN'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 50,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Entrez votre code PIN',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildPinDots(),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const Spacer(),
              _buildNumericKeypad(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Se connecter par email'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text("S'inscrire"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
