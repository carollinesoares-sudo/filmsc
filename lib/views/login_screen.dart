import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedAvatar = 0;

  final List<IconData> _avatars = [
    Icons.person_rounded,
    Icons.face_rounded,
    Icons.theater_comedy_rounded,
  ];

  void _saveUser() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe seu nome.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final profileId =
        DateTime.now().microsecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
    await prefs.setString('activeProfileId', profileId);
    await prefs.setString('userName', _nameController.text.trim());
    await prefs.setInt('userAvatarIndex', _selectedAvatar);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.movie_filter_rounded,
                size: 80,
                color: Color(0xFFE50914),
              ),
              const SizedBox(height: 12),
              Text(
                'CineFavorite',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: const Color(0xFFE50914),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Quem está assistindo?',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Escolha seu avatar:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _avatars.asMap().entries.map((entry) {
                  final isSelected = _selectedAvatar == entry.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = entry.key),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE50914)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFF151A22),
                        child: Icon(
                          entry.value,
                          size: 34,
                          color: isSelected
                              ? const Color(0xFFE50914)
                              : const Color(0xFF8993A4),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Seu Nome',
                  filled: true,
                  fillColor: const Color(0xFF151A22),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ENTRAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
