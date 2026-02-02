import 'package:flutter/material.dart';
import 'package:raheel/theme_constants.dart';
import 'package:raheel/pages/privacy_policy.dart';
import 'package:raheel/l10n/app_localizations.dart';

import 'package:raheel/auth/auth_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with SingleTickerProviderStateMixin {
  // Driver controllers
    final TextEditingController _driverFirstNameController = TextEditingController();
    final TextEditingController _driverLastNameController = TextEditingController();
    final TextEditingController _driverUsernameController = TextEditingController();
    final TextEditingController _driverPhoneController = TextEditingController();
    final TextEditingController _driverEmailController = TextEditingController();
    final TextEditingController _driverPasswordController = TextEditingController();
    final TextEditingController _driverPassword2Controller = TextEditingController();
    final TextEditingController _driverCarTypeController = TextEditingController();
    final TextEditingController _driverCarPlateController = TextEditingController();

    // Traveler controllers
    final TextEditingController _travelerFirstNameController = TextEditingController();
    final TextEditingController _travelerLastNameController = TextEditingController();
    final TextEditingController _travelerUsernameController = TextEditingController();
    final TextEditingController _travelerPhoneController = TextEditingController();
    final TextEditingController _travelerEmailController = TextEditingController();
    final TextEditingController _travelerPasswordController = TextEditingController();
    final TextEditingController _travelerPassword2Controller = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _driverAcceptedPolicy = false;
  bool _travelerAcceptedPolicy = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Show the user type selection dialog when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUserTypeSelectionDialog();
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _driverFirstNameController.dispose();
    _driverLastNameController.dispose();
    _driverPhoneController.dispose();
    _driverEmailController.dispose();
    _driverPasswordController.dispose();
    _driverPassword2Controller.dispose();
    _driverCarTypeController.dispose();
    _driverCarPlateController.dispose();
    _travelerFirstNameController.dispose();
    _travelerLastNameController.dispose();
    _travelerPhoneController.dispose();
    _travelerEmailController.dispose();
    _travelerPasswordController.dispose();
    _travelerPassword2Controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showUserTypeSelectionDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kBodyColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 60,
                  color: kAppBarColor,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.selectAccountType,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kAppBarColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Driver Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAppBarColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _tabController.animateTo(1);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.drive_eta, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          l10n.driver,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Passenger Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAppBarColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _tabController.animateTo(2);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          l10n.passenger,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _registerDriver() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    if (!_driverAcceptedPolicy) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.mustAcceptPrivacyPolicy;
      });
      return;
    }
    // Validate username: 4-8 alphanumeric characters
    final username = _driverUsernameController.text.trim();
    if (!RegExp(r'^[a-zA-Z0-9]{4,8}$').hasMatch(username)) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.usernameValidation;
      });
      return;
    }
    // Validate email address: must contain '@' and '.'
    final email = _driverEmailController.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.emailValidation;
      });
      return;
    }
    // Validate phone number: exactly 10 digits
    final phone = _driverPhoneController.text.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.phoneValidation;
      });
      return;
    }
    // Validate password: must contain uppercase, lowercase, and digit
    final password = _driverPasswordController.text;
    if (!RegExp(r'^(?=(?:.*[A-Z]){4,})(?=(?:.*[a-z]){4,})(?=.*\d)').hasMatch(password)) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.passwordValidation;
      });
      return;
    }
    if (_driverPasswordController.text != _driverPassword2Controller.text) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.passwordsDoNotMatch;
      });
      return;
    }
    try {
      await _authService.registerUser(
        password: _driverPasswordController.text,
        firstName: _driverFirstNameController.text.trim(),
        lastName: _driverLastNameController.text.trim(),
        username: _driverUsernameController.text.trim(),
        userType: 'driver',
        phone: _driverPhoneController.text.trim(),
        emailAddress: _driverEmailController.text.trim(),
        carType: _driverCarTypeController.text.trim(),
        carPlate: _driverCarPlateController.text.trim(),
      );
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: kBodyColor,
          title: Text(
            l10n.registrationSuccess,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kAppBarColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Directionality(
            textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    l10n.accountCreatedSuccess,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAppBarColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text(l10n.login),
              ),
            ],
          ),
        );
    } catch (e) {
      debugPrint('Driver registration error: ${e.toString()}');
      setState(() {
        final msg = e.toString().toLowerCase();
        if (msg.contains('already registered') || msg.contains('already exists') || msg.contains('user already')) {
          _errorMessage = l10n.accountAlreadyExists;
        } else if (msg.contains('رقم الجوال')) {
          _errorMessage = l10n.phoneAlreadyUsed;
        } else if (msg.contains('البريد الإلكتروني') || msg.contains('email')) {
          _errorMessage = l10n.emailAlreadyUsed;
        } else if (msg.contains('password')) {
          _errorMessage = l10n.weakPassword;
        } else if (msg.contains('مسجل')) {
          _errorMessage = l10n.userAlreadyRegistered;
        } else {
          _errorMessage = l10n.errorOccurred;
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerTraveler() async {
      debugPrint('Starting traveler registration');
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    if (!_travelerAcceptedPolicy) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.mustAcceptPrivacyPolicy;
      });
      return;
    }
    // Validate username: 4-8 alphanumeric characters
    final username = _travelerUsernameController.text.trim();
    if (!RegExp(r'^[a-zA-Z0-9]{4,8}$').hasMatch(username)) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.usernameValidation;
      });
      return;
    }
    // Validate email address: must contain '@' and '.'
    final email = _travelerEmailController.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.emailValidation;
      });
      return;
    }
    // Validate phone number: exactly 10 digits
    final phone = _travelerPhoneController.text.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.phoneValidation;
      });
      return;
    }
    // Validate password: must contain uppercase, lowercase, and digit
    final password = _travelerPasswordController.text;
    if (!RegExp(r'^(?=(?:.*[A-Z]){4,})(?=(?:.*[a-z]){4,})(?=.*\d)').hasMatch(password)) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.passwordValidation;
      });
      return;
    }
    if (_travelerPasswordController.text != _travelerPassword2Controller.text) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.passwordsDoNotMatch;
      });
      return;
    }
    try {
      debugPrint('Calling registerUser...');
      await _authService.registerUser(
        password: _travelerPasswordController.text,
        firstName: _travelerFirstNameController.text.trim(),
        lastName: _travelerLastNameController.text.trim(),
        username: _travelerUsernameController.text.trim(),
        userType: 'traveler',
        phone: _travelerPhoneController.text.trim(),
        emailAddress: _travelerEmailController.text.trim(),
      );
      debugPrint('registerUser completed successfully');
      if (!mounted) {
        debugPrint('Widget not mounted after registration');
        return;
      }
      setState(() {
        _isLoading = false;
      });
      debugPrint('Showing success dialog');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: kBodyColor,
          title: Text(
            l10n.registrationSuccess,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kAppBarColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Directionality(
            textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    l10n.accountCreatedSuccess,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAppBarColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text(l10n.login),
              ),
            ],
          ),
        );
      debugPrint('Success dialog shown');
    } catch (e) {
      debugPrint('Registration error: ${e.toString()}');
      setState(() {
        _isLoading = false;
        final msg = e.toString().toLowerCase();
        if (msg.contains('already registered') || msg.contains('already exists') || msg.contains('user already')) {
          _errorMessage = l10n.accountAlreadyExists;
        } else if (msg.contains('رقم الجوال')) {
          _errorMessage = l10n.phoneAlreadyUsed;
        } else if (msg.contains('البريد الإلكتروني') || msg.contains('email')) {
          _errorMessage = l10n.emailAlreadyUsed;
        } else if (msg.contains('password')) {
          _errorMessage = l10n.weakPassword;
        } else if (msg.contains('مسجل')) {
          _errorMessage = l10n.userAlreadyRegistered;
        } else {
          _errorMessage = l10n.errorOccurred;
        }
      });
    }
  }

  void _validatePhoneInput(String value, bool isDriver) {
    final l10n = AppLocalizations.of(context);
    final phone = value.trim();

    if (phone.isEmpty) {
      if (_errorMessage == l10n.phoneValidation) {
        setState(() {
          _errorMessage = null;
        });
      }
      return;
    }

    // Just check if it's exactly 10 digits
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      setState(() {
        _errorMessage = l10n.phoneValidation;
      });
    } else {
      if (_errorMessage == l10n.phoneValidation) {
        setState(() {
          _errorMessage = null;
        });
      }
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    String? hint,
    Function(String)? onChanged,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon, color: kAppBarColor)
            : null,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black12.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black12.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAppBarColor, width: 1.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: kBodyColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_add, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              l10n.createAccount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.black,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kAppBarColor, Color.fromARGB(255, 85, 135, 105)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Empty Tab (default)
          const Center(child: SizedBox.shrink()),
          // Driver Tab
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                      child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.transparent, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              l10n.vehicleDriver,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: kAppBarColor,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _driverFirstNameController,
                            l10n.firstName,
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _driverLastNameController,
                            l10n.lastName,
                            icon: Icons.person_outline,
                          ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              _driverUsernameController,
                              l10n.username,
                              icon: Icons.account_circle_outlined,
                              onChanged: (value) {
                                final trimmed = value.trim();
                                if (trimmed.isEmpty) {
                                  if (_errorMessage == l10n.usernameValidation) {
                                    setState(() => _errorMessage = null);
                                  }
                                  return;
                                }
                                if (RegExp(r'^[a-zA-Z0-9]{4,8}$').hasMatch(trimmed)) {
                                  if (_errorMessage == l10n.usernameValidation) {
                                    setState(() => _errorMessage = null);
                                  }
                                } else {
                                  setState(() => _errorMessage = l10n.usernameValidation);
                                }
                              },
                            ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _driverPhoneController,
                            l10n.mobileNumber,
                            onChanged: (value) =>
                                _validatePhoneInput(value, true),
                            icon: Icons.phone_iphone,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _driverEmailController,
                            l10n.emailAddress,
                            onChanged: (value) {
                              final trimmed = value.trim();
                              if (trimmed.isEmpty) {
                                if (_errorMessage == l10n.emailValidation) {
                                  setState(() => _errorMessage = null);
                                }
                                return;
                              }
                              if (trimmed.contains('@') && trimmed.contains('.')) {
                                if (_errorMessage == l10n.emailValidation) {
                                  setState(() => _errorMessage = null);
                                }
                              } else {
                                setState(() => _errorMessage = l10n.emailValidation);
                              }
                            },
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _driverPasswordController,
                            l10n.password,
                            obscureText: true,
                            hint: l10n.passwordHint,
                            onChanged: (value) {
                              if (value.isEmpty) {
                                if (_errorMessage == l10n.passwordValidation) {
                                  setState(() => _errorMessage = null);
                                }
                                return;
                              }
                              if (RegExp(r'^(?=(?:.*[A-Z]){4,})(?=(?:.*[a-z]){4,})(?=.*\d)').hasMatch(value)) {
                                if (_errorMessage == l10n.passwordValidation) {
                                  setState(() => _errorMessage = null);
                                }
                              } else {
                                setState(() => _errorMessage = l10n.passwordValidation);
                              }
                            },
                            icon: Icons.lock_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _driverPassword2Controller,
                            l10n.reEnterPassword,
                            obscureText: true,
                            onChanged: (value) {
                              if (value.isEmpty) {
                                if (_errorMessage == l10n.passwordsDoNotMatch) {
                                  setState(() => _errorMessage = null);
                                }
                                return;
                              }
                              if (value == _driverPasswordController.text) {
                                if (_errorMessage == l10n.passwordsDoNotMatch) {
                                  setState(() => _errorMessage = null);
                                }
                              } else {
                                setState(() => _errorMessage = l10n.passwordsDoNotMatch);
                              }
                            },
                            icon: Icons.lock_reset,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _driverCarTypeController,
                            l10n.carType,
                            icon: Icons.directions_car_filled_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _driverCarPlateController,
                            l10n.carPlateNumber,
                            icon: Icons.confirmation_number_outlined,
                          ),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            value: _driverAcceptedPolicy,
                            onChanged: (value) {
                              setState(() {
                                _driverAcceptedPolicy = value ?? false;
                              });
                            },
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.acceptPrivacyPolicy,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const PrivacyPolicyPage(),
                                      ),
                                    );
                                  },
                                  child: Text(l10n.view),
                                ),
                              ],
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                if (_successMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(color: Colors.green, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: kAppBarColor,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: _isLoading ? null : _registerDriver,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(l10n.createAccount),
                  ),
                ),
              ],
            ),
          ),
          // Traveler Tab
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.transparent, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              l10n.traveler,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: kAppBarColor,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _travelerFirstNameController,
                            l10n.firstName,
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _travelerLastNameController,
                            l10n.lastName,
                            icon: Icons.person_outline,
                          ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              _travelerUsernameController,
                              l10n.username,
                              icon: Icons.account_circle_outlined,
                              onChanged: (value) {
                                final trimmed = value.trim();
                                if (trimmed.isEmpty) {
                                  if (_errorMessage == l10n.usernameValidation) {
                                    setState(() => _errorMessage = null);
                                  }
                                  return;
                                }
                                if (RegExp(r'^[a-zA-Z0-9]{4,8}$').hasMatch(trimmed)) {
                                  if (_errorMessage == l10n.usernameValidation) {
                                    setState(() => _errorMessage = null);
                                  }
                                } else {
                                  setState(() => _errorMessage = l10n.usernameValidation);
                                }
                              },
                            ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _travelerPhoneController,
                            l10n.mobileNumber,
                            onChanged: (value) =>
                                _validatePhoneInput(value, false),
                            icon: Icons.phone_iphone,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _travelerEmailController,
                            l10n.emailAddress,
                            onChanged: (value) {
                              final trimmed = value.trim();
                              if (trimmed.isEmpty) {
                                if (_errorMessage == l10n.emailValidation) {
                                  setState(() => _errorMessage = null);
                                }
                                return;
                              }
                              if (trimmed.contains('@') && trimmed.contains('.')) {
                                if (_errorMessage == l10n.emailValidation) {
                                  setState(() => _errorMessage = null);
                                }
                              } else {
                                setState(() => _errorMessage = l10n.emailValidation);
                              }
                            },
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _travelerPasswordController,
                            l10n.password,
                            obscureText: true,
                            hint: l10n.passwordHint,
                            onChanged: (value) {
                              if (value.isEmpty) {
                                if (_errorMessage == l10n.passwordValidation) {
                                  setState(() => _errorMessage = null);
                                }
                                return;
                              }
                              if (RegExp(r'^(?=(?:.*[A-Z]){4,})(?=(?:.*[a-z]){4,})(?=.*\d)').hasMatch(value)) {
                                if (_errorMessage == l10n.passwordValidation) {
                                  setState(() => _errorMessage = null);
                                }
                              } else {
                                setState(() => _errorMessage = l10n.passwordValidation);
                              }
                            },
                            icon: Icons.lock_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _travelerPassword2Controller,
                            l10n.reEnterPassword,
                            obscureText: true,
                            onChanged: (value) {
                              if (value.isEmpty) {
                                if (_errorMessage == l10n.passwordsDoNotMatch) {
                                  setState(() => _errorMessage = null);
                                }
                                return;
                              }
                              if (value == _travelerPasswordController.text) {
                                if (_errorMessage == l10n.passwordsDoNotMatch) {
                                  setState(() => _errorMessage = null);
                                }
                              } else {
                                setState(() => _errorMessage = l10n.passwordsDoNotMatch);
                              }
                            },
                            icon: Icons.lock_reset,
                          ),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            value: _travelerAcceptedPolicy,
                            onChanged: (value) {
                              setState(() {
                                _travelerAcceptedPolicy = value ?? false;
                              });
                            },
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.acceptPrivacyPolicy,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const PrivacyPolicyPage(),
                                      ),
                                    );
                                  },
                                  child: Text(l10n.view),
                                ),
                              ],
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                if (_successMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(color: Colors.green, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: kAppBarColor,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: _isLoading ? null : _registerTraveler,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(l10n.createAccount),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
