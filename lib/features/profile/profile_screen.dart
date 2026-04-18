// lib/features/profile/profile_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Update Profile State ────────────
  final _profileFormKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _userCtrl;
  bool _profileLoading = false;

  // ── Change Password State ───────────
  final _passFormKey = GlobalKey<FormState>();
  final _currPassCtrl = TextEditingController();
  final _newPassCtrl  = TextEditingController();
  final _confPassCtrl = TextEditingController();
  bool _passLoading   = false;
  bool _showCurrPass  = false;
  bool _showNewPass   = false;
  bool _showConfPass  = false;

  // ── Photo preview (cross-platform) ──
  Uint8List? _previewBytes; // Used for Image.memory preview (Web + Mobile)

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _userCtrl = TextEditingController(text: user?.username ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _currPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confPassCtrl.dispose();
    super.dispose();
  }

  // ── Pick & Upload Photo ─────────────
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();

    Future<void> pickFrom(ImageSource source) async {
      final picked = await picker.pickImage(
          source: source, imageQuality: 80, maxWidth: 512);
      if (picked == null || !mounted) return;

      // Always read as bytes – works on Web, Android, and iOS
      final bytes = await picked.readAsBytes();

      // Show local preview immediately using Image.memory
      setState(() => _previewBytes = bytes);

      // Read provider before async gap
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.updatePhoto(
        imageFile:     kIsWeb ? null : File(picked.path),
        imageBytes:    bytes,
        imageFilename: picked.name,
      );

      if (!mounted) return;
      showAppSnackBar(
        context,
        message: success
            ? 'Foto profil diperbarui.'
            : authProvider.errorMessage,
        type: success ? SnackBarType.success : SnackBarType.error,
      );

      // After upload, clear preview so server photo takes over
      if (success && mounted) {
        setState(() => _previewBytes = null);
      }
    }

    if (kIsWeb) {
      await pickFrom(ImageSource.gallery);
      return;
    }

    // Mobile: sheet
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari Galeri'),
                onTap: () { Navigator.pop(ctx); pickFrom(ImageSource.gallery); },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Ambil Foto'),
                onTap: () { Navigator.pop(ctx); pickFrom(ImageSource.camera); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Submit Profile ──────────────────
  Future<void> _submitProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    setState(() => _profileLoading = true);

    final success = await context.read<AuthProvider>().updateProfile(
      name:     _nameCtrl.text.trim(),
      username: _userCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _profileLoading = false);
    showAppSnackBar(
      context,
      message: success
          ? 'Profil berhasil diperbarui.'
          : context.read<AuthProvider>().errorMessage,
      type: success ? SnackBarType.success : SnackBarType.error,
    );
  }

  // ── Submit Password ─────────────────
  Future<void> _submitPassword() async {
    if (!_passFormKey.currentState!.validate()) return;
    setState(() => _passLoading = true);

    final success = await context.read<AuthProvider>().updatePassword(
      currentPassword: _currPassCtrl.text.trim(),
      newPassword:     _newPassCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _passLoading = false);
    showAppSnackBar(
      context,
      message: success
          ? 'Kata sandi berhasil diubah.'
          : context.read<AuthProvider>().errorMessage,
      type: success ? SnackBarType.success : SnackBarType.error,
    );

    if (success) {
      _currPassCtrl.clear();
      _newPassCtrl.clear();
      _confPassCtrl.clear();
    }
  }

  // ── Logout ─────────────────────────
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(d).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(d).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) context.go(RouteConstants.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider    = context.watch<AuthProvider>();
    final user        = provider.user;
    final colorScheme = Theme.of(context).colorScheme;

    if (provider.status == AuthStatus.loading && user == null) {
      return const Scaffold(body: LoadingWidget());
    }

    return Scaffold(
      appBar: TopAppBarWidget(
        title: 'Profil Saya',
        showBackButton: true,
        menuItems: [
          TopAppBarMenuItem(
            text: 'Keluar',
            icon: Icons.logout,
            isDestructive: true,
            onTap: _logout,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Avatar Section ──────────────────────────
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      // Cross-platform avatar:
                      // 1. Local preview with Image.memory (after picking, before upload completes)
                      // 2. Server photo with NetworkImage
                      // 3. Initials fallback
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage: _previewBytes != null
                            ? MemoryImage(_previewBytes!) as ImageProvider
                            : (user?.urlPhoto != null
                            ? NetworkImage(user!.urlPhoto!)
                            : null),
                        child: (_previewBytes == null && user?.urlPhoto == null)
                            ? Text(
                          (user?.name.isNotEmpty == true)
                              ? user!.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                              fontSize: 38,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold),
                        )
                            : null,
                      ),
                      // Camera badge
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.surface, width: 2.5),
                          ),
                          child: Icon(Icons.camera_alt_rounded,
                              size: 15, color: colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user?.username ?? ''}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.edit_rounded, size: 14),
                  label: const Text('Ubah Foto', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Edit Profil ─────────────────────────────
          _SectionCard(
            title: 'Edit Profil',
            icon: Icons.person_outline_rounded,
            child: Form(
              key: _profileFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Nama tidak boleh kosong.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _userCtrl,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Username tidak boleh kosong.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _profileLoading ? null : _submitProfile,
                      icon: _profileLoading
                          ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save_rounded),
                      label: Text(_profileLoading ? 'Menyimpan...' : 'Simpan Profil'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Ganti Kata Sandi ────────────────────────
          _SectionCard(
            title: 'Ganti Kata Sandi',
            icon: Icons.lock_outline_rounded,
            child: Form(
              key: _passFormKey,
              child: Column(
                children: [
                  _PasswordField(
                    controller: _currPassCtrl,
                    label: 'Kata Sandi Saat Ini',
                    show: _showCurrPass,
                    onToggle: () => setState(() => _showCurrPass = !_showCurrPass),
                    validator: (v) =>
                    (v == null || v.isEmpty)
                        ? 'Kata sandi saat ini diperlukan.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _PasswordField(
                    controller: _newPassCtrl,
                    label: 'Kata Sandi Baru',
                    show: _showNewPass,
                    onToggle: () => setState(() => _showNewPass = !_showNewPass),
                    validator: (v) =>
                    (v == null || v.trim().length < 6)
                        ? 'Minimal 6 karakter.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _PasswordField(
                    controller: _confPassCtrl,
                    label: 'Konfirmasi Kata Sandi Baru',
                    show: _showConfPass,
                    onToggle: () => setState(() => _showConfPass = !_showConfPass),
                    validator: (v) =>
                    v != _newPassCtrl.text ? 'Kata sandi tidak cocok.' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _passLoading ? null : _submitPassword,
                      icon: _passLoading
                          ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.key_rounded),
                      label: Text(_passLoading ? 'Mengubah...' : 'Ganti Kata Sandi'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.show,
    required this.onToggle,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool show;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !show,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(show
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }
}
