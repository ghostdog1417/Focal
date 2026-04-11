import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../theme/app_style.dart';
import '../widgets/focus_nest_logo.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUpMode = false;
  bool _isSigningIn = false;
  String? _errorMessage;
  AuthCredential? _pendingGoogleCredential;

  String _friendlyAuthMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled in Firebase Authentication.';
      case 'unauthorized-domain':
        return 'This web domain is not authorized in Firebase Authentication.';
      case 'popup-blocked':
        return 'Popup was blocked. Allow popups and try again.';
      case 'popup-closed-by-user':
        return 'Sign-in popup was closed before completion.';
      case 'network-request-failed':
        return 'Network error. Check your internet and try again.';
      case 'account-exists-with-different-credential':
        return 'This email already uses another sign-in method. Sign in with email/password to link Google.';
      default:
        return error.message ?? 'Google sign-in failed. Please try again.';
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      if (!mounted) return;

      if (userCredential?.user == null) {
        setState(() {
          _isSigningIn = false;
          _errorMessage =
              'Sign-in was cancelled or redirected. Try again if needed.';
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _isSigningIn = false;
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSigningIn = false;
        if (error.code == 'account-exists-with-different-credential' &&
            error.credential != null) {
          _pendingGoogleCredential = error.credential;
          if (error.email != null && error.email!.isNotEmpty) {
            _emailController.text = error.email!;
          }
        }
        _errorMessage = _friendlyAuthMessage(error);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSigningIn = false;
        _errorMessage = 'Google sign-in failed. Please try again.';
      });
    }
  }

  Future<void> _signInWithEmailPassword() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Enter both email and password.';
      });
      return;
    }

    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUpMode) {
        await _authService.signUp(email, password);
      } else {
        await _authService.signIn(email, password);
      }

      if (_pendingGoogleCredential != null &&
          FirebaseAuth.instance.currentUser != null) {
        try {
          await FirebaseAuth.instance.currentUser!
              .linkWithCredential(_pendingGoogleCredential!);
        } on FirebaseAuthException catch (linkError) {
          if (linkError.code != 'provider-already-linked' &&
              linkError.code != 'credential-already-in-use') {
            rethrow;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _isSigningIn = false;
        _pendingGoogleCredential = null;
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSigningIn = false;
        _errorMessage = _friendlyAuthMessage(error);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSigningIn = false;
        _errorMessage = 'Email sign-in failed. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.progressCardStart, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: const Color(0xFFDDE6F7),
                    ),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FocusNestLogo(size: 72),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in with Google to continue your study flow.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const <String>[AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        autofillHints: const <String>[AutofillHints.password],
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isSigningIn ? null : _signInWithEmailPassword,
                          icon: const Icon(Icons.email_outlined),
                          label: Text(
                            _isSignUpMode ? 'Create account' : 'Sign in with Email',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.button,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _isSigningIn
                            ? null
                            : () {
                                setState(() {
                                  _isSignUpMode = !_isSignUpMode;
                                  _errorMessage = null;
                                });
                              },
                        child: Text(
                          _isSignUpMode
                              ? 'Have an account? Sign in'
                              : 'New user? Create account',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.divider,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('or'),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.divider,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isSigningIn ? null : _signInWithGoogle,
                          icon: _isSigningIn
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.login_rounded),
                          label: Text(
                            _isSigningIn ? 'Signing in...' : 'Continue with Google',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.button,
                            ),
                          ),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
