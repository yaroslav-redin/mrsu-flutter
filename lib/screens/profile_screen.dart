import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/network_service.dart';
import '../services/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _networkService = NetworkService();
  UserProfile? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);
    final response = await _networkService.makeAuthorizedRequest('User');
    if (response != null) {
      try {
        final Map<String, dynamic> jsonResponse = response;
        setState(() {
          _user = UserProfile.fromJson(jsonResponse);
          _isLoading = false;
        });
      } catch (e) {
        _showError('Ошибка обработки данных профиля: $e');
      }
    } else {
      _showError('Ошибка получения данных профиля');
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: _buildGlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Выход из аккаунта',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Вы уверены, что хотите выйти из аккаунта?'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Нет'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.7),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Да'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await _networkService.clearToken();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  Widget _buildGlassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.05 : 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Профиль', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUserProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          children: [
            // Карточка профиля
            _buildGlassContainer(
              padding: const EdgeInsets.all(24),
              child: _isLoading 
                ? const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ))
                : _user == null 
                  ? Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                        const SizedBox(height: 16),
                        const Text(
                          'Не удалось загрузить данные профиля',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: _fetchUserProfile,
                          child: const Text('Попробовать снова'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: themeProvider.primaryColor, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.transparent,
                                backgroundImage: CachedNetworkImageProvider(_user!.photo.urlMedium),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _user!.fio,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _user!.email,
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                        ),
                        Text(
                          'ID: ${_user!.studentCod}',
                          style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            // Блок настроек
            _buildGlassContainer(
              child: Column(
                children: [
                  const ListTile(
                    title: Text('Настройки', style: TextStyle(fontWeight: FontWeight.bold)),
                    leading: Icon(Icons.settings_outlined),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  SwitchListTile(
                    title: const Text('Темная тема'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    value: themeProvider.themeMode == ThemeMode.dark,
                    activeColor: themeProvider.primaryColor,
                    onChanged: (bool value) => themeProvider.toggleTheme(),
                  ),
                  ListTile(
                    title: const Text('Цвет темы'),
                    leading: const Icon(Icons.palette_outlined),
                    trailing: DropdownButton<AppColorTheme>(
                      value: themeProvider.colorTheme,
                      underline: Container(),
                      dropdownColor: isDark ? const Color(0xFF16213E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      onChanged: (AppColorTheme? newValue) {
                        if (newValue != null) themeProvider.setColorTheme(newValue);
                      },
                      items: const [
                        DropdownMenuItem(value: AppColorTheme.standard, child: Text('Стандартный')),
                        DropdownMenuItem(value: AppColorTheme.blue, child: Text('Синий')),
                        DropdownMenuItem(value: AppColorTheme.purple, child: Text('Фиолетовый')),
                        DropdownMenuItem(value: AppColorTheme.green, child: Text('Зелёный')),
                        DropdownMenuItem(value: AppColorTheme.orange, child: Text('Оранжевый')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Кнопка выхода
            GestureDetector(
              onTap: _logout,
              child: _buildGlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.redAccent),
                    SizedBox(width: 12),
                    Text(
                      'Выйти из аккаунта',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
