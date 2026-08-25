import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List<Map<String, dynamic>> _profiles = [];
  String _activeId = '';
  final _icons = [
    Icons.person_rounded,
    Icons.face_rounded,
    Icons.theater_comedy_rounded,
    Icons.pets_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('profiles') ?? [];
    final profiles = stored
        .map((item) => Map<String, dynamic>.from(jsonDecode(item) as Map))
        .toList();
    if (profiles.isEmpty) {
      final id = prefs.getString('activeProfileId') ?? 'default';
      profiles.add({
        'id': id,
        'name': prefs.getString('userName') ?? 'Usuário',
        'avatarIndex': prefs.getInt('userAvatarIndex') ?? 0,
      });
      await _saveProfiles(profiles);
    }
    if (mounted) {
      setState(() {
        _profiles = profiles;
        _activeId = prefs.getString('activeProfileId') ?? profiles.first['id'];
      });
    }
  }

  Future<void> _saveProfiles(List<Map<String, dynamic>> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('profiles', profiles.map(jsonEncode).toList());
  }

  Future<void> _selectProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('activeProfileId', profile['id'] as String);
    await prefs.setString('userName', profile['name'] as String);
    await prefs.setInt('userAvatarIndex', profile['avatarIndex'] as int);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _createProfile() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo perfil'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome do perfil'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) {
      return;
    }
    final profile = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'name': name,
      'avatarIndex': _profiles.length % _icons.length,
    };
    final profiles = [..._profiles, profile];
    await _saveProfiles(profiles);
    if (mounted) setState(() => _profiles = profiles);
  }

  Future<void> _deleteProfile(Map<String, dynamic> profile) async {
    if (_profiles.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mantenha pelo menos um perfil.')),
      );
      return;
    }
    final profiles = _profiles
        .where((item) => item['id'] != profile['id'])
        .toList();
    await _saveProfiles(profiles);
    if (mounted) setState(() => _profiles = profiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quem está assistindo?')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 24,
            children: [
              ..._profiles.map(
                (profile) => SizedBox(
                  width: 110,
                  child: InkWell(
                    onTap: () => _selectProfile(profile),
                    onLongPress: () => _deleteProfile(profile),
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: const Color(0xFF151A22),
                          child: Icon(
                            _icons[(profile['avatarIndex'] as int) %
                                _icons.length],
                            size: 42,
                            color: profile['id'] == _activeId
                                ? const Color(0xFFE50914)
                                : const Color(0xFF8993A4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile['name'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                child: InkWell(
                  onTap: _createProfile,
                  borderRadius: BorderRadius.circular(8),
                  child: const Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Color(0xFF151A22),
                        child: Icon(
                          Icons.add,
                          size: 42,
                          color: Color(0xFF00A8E1),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Adicionar'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 110),
              TextButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sair'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
