import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:bac_monitor/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService auth = AuthService();

  bool isLoading = false;
  bool isGoogleLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void login() async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter both email and password");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await auth.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        print("LOGIN SUCCESS: ${user.email}");
        _showSuccessSnackBar("Login successful!");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
      _showErrorSnackBar("Login failed: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void signUp() async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter both email and password");
      return;
    }

    if (passwordController.text.trim().length < 6) {
      _showErrorSnackBar("Password must be at least 6 characters");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await auth.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        print("SIGNUP SUCCESS: ${user.email}");
        _showSuccessSnackBar("Sign up successful! Welcome!");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      print("SIGNUP ERROR: $e");
      _showErrorSnackBar("Sign up failed: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void loginWithGoogle() async {
    setState(() => isGoogleLoading = true);

    try {
      print("Google Sign In button pressed");
      final user = await auth.signInWithGoogle();

      if (user != null) {
        print("GOOGLE LOGIN SUCCESS: ${user.email}");
        _showSuccessSnackBar("Google login successful!");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        print("Google sign in was cancelled");
        _showErrorSnackBar("Google sign in was cancelled");
      }
    } catch (e) {
      print("GOOGLE LOGIN ERROR: $e");
      _showErrorSnackBar("Google sign in failed: ${e.toString()}");
    } finally {
      setState(() => isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: const Text(
          "BAC Monitor",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // 🔹 APP LOGO
              Icon(
                Icons.water_drop,
                size: 80,
                color: Colors.lightBlue,
              ),

              const SizedBox(height: 20),

              // 🔹 TITLE
              const Text(
                "Blood Alcohol Concentration Monitor",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              // 🔹 EMAIL INPUT
              TextField(
                controller: emailController,
                enabled: !isLoading && !isGoogleLoading,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Enter your email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 15),

              // 🔹 PASSWORD INPUT
              TextField(
                controller: passwordController,
                enabled: !isLoading && !isGoogleLoading,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter your password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),

              const SizedBox(height: 25),

              // 🔐 LOGIN BUTTON
              ElevatedButton(
                onPressed: isLoading || isGoogleLoading ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  disabledBackgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // 🆕 SIGN UP BUTTON
              ElevatedButton(
                onPressed: isLoading || isGoogleLoading ? null : signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              // 🔹 DIVIDER
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "OR",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              const SizedBox(height: 20),

              // 🔵 GOOGLE LOGIN BUTTON
              ElevatedButton.icon(
                onPressed: isLoading || isGoogleLoading ? null : loginWithGoogle,
                icon: isGoogleLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.login),
                label: const Text(
                  "Sign in with Google",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}