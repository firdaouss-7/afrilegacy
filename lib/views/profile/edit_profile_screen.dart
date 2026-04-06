import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:afrilegacy/services/auth_service.dart';
import 'package:afrilegacy/services/cloudinary_service.dart';
import 'package:afrilegacy/models/user_model.dart';

class _P {
  static const bg       = Color(0xFFFBF8F3);
  static const bg2      = Color(0xFFF2EBE0);
  static const dark     = Color(0xFF3D2B1A);
  static const gold     = Color(0xFFC4A96A);
  static const honey    = Color(0xFFE8C87A);
  static const nil      = Color(0xFF8FAFC0);
  static const savane   = Color(0xFFA8C4A2);
  static const laterite = Color(0xFFD4A89A);
  static const ocre     = Color(0xFF8C7A68);
  static const sand     = Color(0xFFD9C9B2);
  static const clay     = Color(0xFFC9B99F);
  static const mid      = Color(0xFF5C3D2E);
}

class EditProfileScreen extends StatefulWidget {
  final UserModel? user;
  const EditProfileScreen({super.key, this.user});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {

  final _auth = AuthService();
  late AnimationController _anim;

  late TextEditingController _nomC;
  late TextEditingController _photoUrlC;

  bool _saving = false;
  bool _uploadingPhoto = false;
  String? _error;
  String? _success;
  File? _localImage; // image choisie localement avant upload

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _nomC      = TextEditingController(text: widget.user?.nom      ?? '');
    _photoUrlC = TextEditingController(text: widget.user?.photoUrl ?? '');
  }

  @override
  void dispose() {
    _anim.dispose();
    _nomC.dispose();
    _photoUrlC.dispose();
    super.dispose();
  }

  // ── Choisir image depuis la galerie et uploader sur Cloudinary ──────────
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;

    setState(() { _uploadingPhoto = true; _error = null; });

    final file = File(picked.path);
    final url = await CloudinaryService.uploadFile(file, 'afrilegacy/avatars');

    if (!mounted) return;

    if (url != null) {
      setState(() {
        _localImage  = file;
        _photoUrlC.text = url;
        _uploadingPhoto = false;
      });
    } else {
      setState(() {
        _uploadingPhoto = false;
        _error = 'Erreur lors de l\'upload. Réessayez.';
      });
    }
  }

  // ── Sauvegarder le profil ────────────────────────────────────────────────
  Future<void> _save() async {
    if (_nomC.text.trim().isEmpty) {
      setState(() => _error = 'Le nom ne peut pas être vide.');
      return;
    }
    setState(() { _saving = true; _error = null; _success = null; });

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'nom':       _nomC.text.trim(),
        'photoUrl':  _photoUrlC.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() { _success = 'Profil mis à jour avec succès !'; _saving = false; });
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur : $e'; _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _P.bg,
      body: FadeTransition(
        opacity: _anim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ───────────────────────────────
            SliverAppBar(
              expandedHeight: 130,
              pinned: true,
              backgroundColor: const Color(0xFF1A1008),
              elevation: 0,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _P.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _P.gold.withOpacity(0.3))),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: _P.gold, size: 16)),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1008), Color(0xFF3D2B1A),
                               Color(0xFF2A1F0E)])),
                  child: const SafeArea(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Badge(text: 'MODIFIER'),
                            SizedBox(height: 8),
                            Text('Mon Profil',
                              style: TextStyle(fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFECE2D0))),
                            Text('Mettez à jour vos informations',
                              style: TextStyle(fontSize: 11, color: _P.ocre)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Formulaire ───────────────────────────
            SliverToBoxAdapter(
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, 0.06), end: Offset.zero)
                    .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  child: Column(children: [

                    // ── Avatar cliquable ─────────────
                    _buildAvatarPicker(),
                    const SizedBox(height: 28),

                    // ── Messages ─────────────────────
                    if (_error   != null) _buildMsg(_error!,   _P.laterite, Icons.error_outline),
                    if (_success != null) _buildMsg(_success!, _P.savane,   Icons.check_circle_outline),

                    // ── Infos personnelles ───────────
                    _buildSection('Informations personnelles', [
                      _buildField(
                        controller: _nomC,
                        label: 'Nom',
                        hint: 'Votre nom complet',
                        icon: Icons.person_outline_rounded,
                        color: _P.gold,
                      ),
                    ]),

                    const SizedBox(height: 12),

                    // ── Email non modifiable ─────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _P.bg2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _P.sand.withOpacity(0.5))),
                      child: Row(children: [
                        Container(width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: _P.ocre.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.lock_outline,
                              color: _P.ocre, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Email', style: TextStyle(fontSize: 10,
                                color: _P.ocre, fontWeight: FontWeight.w600)),
                            Text(widget.user?.email ?? '',
                              style: const TextStyle(fontSize: 13,
                                  color: _P.clay, fontWeight: FontWeight.w600)),
                          ])),
                        const Text('Non modifiable',
                          style: TextStyle(fontSize: 9, color: _P.clay)),
                      ]),
                    ),

                    const SizedBox(height: 28),

                    // ── Bouton sauvegarder ───────────
                    _buildSaveButton(),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Avatar avec bouton galerie ───────────────────────────────────────────
  Widget _buildAvatarPicker() {
    final nom      = _nomC.text.isNotEmpty ? _nomC.text : 'U';
    final initial  = nom[0].toUpperCase();
    final photoUrl = _photoUrlC.text.trim();

    return Column(children: [
      GestureDetector(
        onTap: _uploadingPhoto ? null : _pickAndUploadImage,
        child: Stack(alignment: Alignment.bottomRight, children: [
          // Cercle avatar
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF5C3D2E), Color(0xFF3D2B1A)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(color: _P.gold, width: 2.5),
              boxShadow: [BoxShadow(color: _P.gold.withOpacity(0.25),
                  blurRadius: 16, offset: const Offset(0, 4))]),
            child: _uploadingPhoto
                // Spinner pendant l'upload
                ? const Center(child: SizedBox(width: 30, height: 30,
                    child: CircularProgressIndicator(
                        color: _P.gold, strokeWidth: 2.5)))
                : ClipOval(
                    child: _localImage != null
                        // Image locale choisie
                        ? Image.file(_localImage!, fit: BoxFit.cover,
                            width: 100, height: 100)
                        : photoUrl.isNotEmpty
                            // Image distante existante
                            ? Image.network(photoUrl, fit: BoxFit.cover,
                                width: 100, height: 100,
                                loadingBuilder: (_, child, progress) =>
                                    progress == null ? child
                                        : const Center(child: CircularProgressIndicator(
                                            color: _P.gold, strokeWidth: 2)),
                                errorBuilder: (_, __, ___) =>
                                    Center(child: Text(initial,
                                      style: const TextStyle(fontSize: 36,
                                          fontWeight: FontWeight.w900,
                                          color: _P.gold))))
                            // Initiale par défaut
                            : Center(child: Text(initial,
                                style: const TextStyle(fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: _P.gold))),
                  ),
          ),

          // Bouton crayon
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _P.gold,
              shape: BoxShape.circle,
              border: Border.all(color: _P.bg, width: 2),
              boxShadow: [BoxShadow(color: _P.gold.withOpacity(0.4),
                  blurRadius: 8, offset: const Offset(0, 2))]),
            child: const Icon(Icons.camera_alt_rounded, size: 13, color: _P.dark)),
        ]),
      ),

      const SizedBox(height: 10),

      // Texte indicatif sous le cercle
      Text(
        _uploadingPhoto ? 'Upload en cours...' : 'Appuyer pour changer la photo',
        style: TextStyle(
          fontSize: 11,
          color: _uploadingPhoto ? _P.gold : _P.ocre,
          fontWeight: _uploadingPhoto ? FontWeight.w700 : FontWeight.w500),
      ),
    ]);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _P.sand.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: _P.gold.withOpacity(0.04),
            blurRadius: 16, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 3, height: 16,
            decoration: BoxDecoration(color: _P.gold,
                borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w800, color: _P.dark)),
        ]),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: _P.dark, letterSpacing: 0.3)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: _P.dark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _P.clay, fontSize: 12),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: color, size: 16)),
          filled: true,
          fillColor: _P.bg2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _P.gold, width: 1.8)),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14)),
      ),
    ]);
  }

  Widget _buildMsg(String msg, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: TextStyle(fontSize: 12,
            color: color, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: (_saving || _uploadingPhoto) ? null : _save,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          color: (_saving || _uploadingPhoto) ? _P.mid : _P.dark,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: _P.dark.withOpacity(0.3),
              blurRadius: 16, offset: const Offset(0, 6))]),
        child: _saving
            ? const Center(child: SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(color: _P.gold, strokeWidth: 2)))
            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.save_outlined, color: _P.gold, size: 18),
                SizedBox(width: 8),
                Text('Enregistrer les modifications',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                      color: Color(0xFFD9C9B2), letterSpacing: 0.5)),
              ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFC4A96A).withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFC4A96A).withOpacity(0.3))),
    child: Text(text, style: const TextStyle(fontSize: 9, letterSpacing: 2.5,
        color: Color(0xFFC4A96A), fontWeight: FontWeight.w700)));
}