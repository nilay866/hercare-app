import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/ui_utils.dart';
import 'dashboard_screen.dart';
import 'doctor_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _role = 'patient';
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      UiUtils.showSnackBar(context, 'Please fill email and password', isError: true);
      return;
    }
    if (!_isLogin && (_nameCtrl.text.isEmpty || _ageCtrl.text.isEmpty)) {
      UiUtils.showSnackBar(context, 'Please fill all fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      if (_isLogin) {
        await auth.login(email: _emailCtrl.text.trim(), password: _passCtrl.text.trim());
      } else {
        await auth.register(
          name: _nameCtrl.text.trim(), email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(), age: int.parse(_ageCtrl.text.trim()), role: _role,
        );
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => 
            auth.role == 'doctor' ? const DoctorDashboardScreen() : const DashboardScreen()
          ),
        );
      }
    } catch (e) {
      if (mounted) UiUtils.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [const Color(0xFFE91E8C).withValues(alpha: 0.15), Colors.teal.withValues(alpha: 0.1)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, size: 64, color: Color(0xFFE91E8C)),
              ),
              const SizedBox(height: 16),
              const Text('HerCare', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFFE91E8C))),
              const SizedBox(height: 4),
              Text(_isLogin ? 'Welcome back!' : 'Create your account', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              const SizedBox(height: 32),

              // Name (register only)
              if (!_isLogin) ...[
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 16),
              ],

              // Email
              TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passCtrl, obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Age + Role (register only)
              if (!_isLogin) ...[
                TextField(controller: _ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.cake_outlined))),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge_outlined)),
                  items: const [DropdownMenuItem(value: 'patient', child: Text('👩 Patient')), DropdownMenuItem(value: 'doctor', child: Text('👨‍⚕️ Doctor'))],
                  onChanged: (v) => setState(() => _role = v!),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isLogin ? 'Login' : 'Sign Up'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() { _isLogin = !_isLogin; _animCtrl.reset(); _animCtrl.forward(); }),
                child: Text(_isLogin ? "Don't have an account? Sign Up" : 'Already have an account? Login', style: const TextStyle(color: Color(0xFFE91E8C))),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
