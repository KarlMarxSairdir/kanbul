import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/features/auth/providers/password_reset_notifier.dart';
import 'package:kan_bul/l10n/app_localizations.dart';
import 'package:kan_bul/widgets/custom_button.dart';
import 'package:kan_bul/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      try {
        await ref.read(passwordResetNotifierProvider.notifier).run(email);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                ).translate('passwordResetEmailSent'),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Error handling is done by the listener below
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Listen for password reset state changes
    ref.listen(passwordResetNotifierProvider, (previous, current) {
      if (current.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    final resetState = ref.watch(passwordResetNotifierProvider);
    final isLoading = resetState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('forgotPasswordTitle'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.translate('forgotPasswordInstruction'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _emailController,
                label: l10n.translate('emailLabel'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return l10n.translate('invalidEmailError');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                    text: l10n.translate('sendResetEmailButton'),
                    onPressed: _resetPassword,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
