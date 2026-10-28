import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = true;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      setState(() => _errorMessage = 'Vui lòng đồng ý với Điều khoản & Chính sách');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text,
            _fullNameController.text.trim(),
          );
      if (mounted) context.go('/');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                const Text(
                  'Tạo tài khoản mới',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bắt đầu trải nghiệm du lịch thông minh',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  _buildErrorBanner(_errorMessage!),
                  const SizedBox(height: 16),
                ],
                _buildTextField('Họ và tên', _fullNameController, 'Nguyễn Văn A',
                    validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập họ và tên' : null),
                const SizedBox(height: 16),
                _buildTextField('Email', _emailController, 'email@example.com',
                    keyboardType: TextInputType.emailAddress, validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập email';
                  if (!val.contains('@')) return 'Email không hợp lệ';
                  return null;
                }),
                const SizedBox(height: 16),
                _buildPasswordField('Mật khẩu', _passwordController, _obscurePassword, () {
                  setState(() => _obscurePassword = !_obscurePassword);
                }, (val) => val == null || val.length < 6 ? 'Mật khẩu phải từ 6 ký tự trở lên' : null),
                const SizedBox(height: 16),
                _buildPasswordField('Xác nhận mật khẩu', _confirmPasswordController, _obscureConfirmPassword, () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                }, (val) => val != _passwordController.text ? 'Mật khẩu xác nhận không khớp' : null),
                const SizedBox(height: 14),
                _buildTermsCheckbox(),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Tạo tài khoản', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Đã có tài khoản? ', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                    GestureDetector(
                      onTap: () => context.push('/login'),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(color: Color(0xFF0077B6), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => context.canPop() ? context.pop() : context.go('/login'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF0F172A)),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: const Row(
            children: [
              Icon(Icons.explore, size: 16, color: Color(0xFF0077B6)),
              SizedBox(width: 6),
              Text(
                'SMARTTRAVEL',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0077B6), letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField(
      String label, TextEditingController controller, bool obscure, VoidCallback onToggle, String? Function(String?)? validator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: _inputDecoration('Tối thiểu 6 ký tự').copyWith(
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: const Color(0xFF64748B), size: 20),
              onPressed: onToggle,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreeTerms,
            activeColor: const Color(0xFF0077B6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) => setState(() => _agreeTerms = val ?? false),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
              children: [
                TextSpan(text: 'Tôi đồng ý với '),
                TextSpan(text: 'Điều khoản', style: TextStyle(color: Color(0xFF0077B6), fontWeight: FontWeight.w600)),
                TextSpan(text: ' & '),
                TextSpan(text: 'Chính sách bảo mật', style: TextStyle(color: Color(0xFF0077B6), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0077B6), width: 1.5),
      ),
    );
  }
}
