import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:afrilegacy/models/oeuvre_model.dart';
import 'package:afrilegacy/models/user_model.dart';
import 'package:afrilegacy/services/oeuvre_service.dart';
import 'package:afrilegacy/services/user_service.dart';
import 'package:afrilegacy/services/auth_service.dart';
import 'package:afrilegacy/services/cloudinary_service.dart';
import 'package:afrilegacy/views/auth/welcome_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _oeuvreService = OeuvreService();
  final _userService = UserService();
  final _authService = AuthService();

  int _selectedTab = 0;
  UserModel? _adminUser;

  static const _sand = Color(0xFFFBF8F3);
  static const _papyrus = Color(0xFFF2EBE0);
  static const _brun = Color(0xFF3D2B1A);
  static const _or = Color(0xFFC4A96A);
  static const _ocre = Color(0xFF8C7A68);
  static const _roseLat = Color(0xFFD4A89A);

  @override
  void initState() {
    super.initState();
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      final user = await _userService.getUser(uid);
      setState(() => _adminUser = user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sand,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: const BoxDecoration(
        color: _brun,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _or.withOpacity(0.2),
              border: Border.all(color: _or, width: 1.5),
            ),
            child: Center(
              child: Text(
                _adminUser?.nom.isNotEmpty == true
                    ? _adminUser!.nom[0].toUpperCase()
                    : 'A',
                style: const TextStyle(
                  color: _or,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '👑 Admin Dashboard',
                  style: TextStyle(
                    color: _or,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  _adminUser?.nom ?? '',
                  style: TextStyle(
                    color: _papyrus.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: _roseLat),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Oeuvres', 'Ajouter', 'Utilisateurs'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? _brun : _papyrus,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? _papyrus : _ocre,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedTab) {
      case 0:
        return _buildOeuvresList();
      case 1:
        return _buildAddOeuvreForm();
      case 2:
        return _buildUsersList();
      default:
        return _buildOeuvresList();
    }
  }

  // ==================== LISTE OEUVRES ====================

  Widget _buildOeuvresList() {
    return StreamBuilder<List<OeuvreModel>>(
      stream: _oeuvreService.getOeuvresStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _or));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucune oeuvre'));
        }
        final oeuvres = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: oeuvres.length,
          itemBuilder: (context, index) {
            final o = oeuvres[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _brun.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: o.imageUrl.isNotEmpty
                        ? Image.network(
                            o.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: _or.withOpacity(0.15),
                              child: const Icon(Icons.image, color: _or),
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: _or.withOpacity(0.15),
                            child: const Icon(Icons.image, color: _or),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o.titre,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _brun,
                          ),
                        ),
                        Text(
                          '${o.pays} · ${o.categorie}',
                          style: const TextStyle(fontSize: 12, color: _ocre),
                        ),
                        if (o.statut == 'volé')
                          const Text(
                            '🔴 Stolen Art',
                            style: TextStyle(
                              fontSize: 11,
                              color: _roseLat,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: _roseLat,
                      size: 22,
                    ),
                    onPressed: () => _confirmDelete(o.id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _sand,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer ?', style: TextStyle(color: _brun)),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: _ocre)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: _roseLat)),
          ),
        ],
      ),
    );
    if (confirm == true) await _oeuvreService.deleteOeuvre(id);
  }

  // ==================== FORMULAIRE AJOUT ====================

  final _titreController = TextEditingController();
  final _artisteController = TextEditingController();
  final _paysController = TextEditingController();
  final _anneeController = TextEditingController();
  final _descController = TextEditingController();
  final _museeController = TextEditingController();
  final _paysActuelController = TextEditingController();

  String _selectedCategorie = 'Sculpture';
  String _selectedStatut = 'normal';
  bool _isFeatured = false;
  bool _isUploading = false;

  File? _imageFile;
  File? _audioFile;
  File? _model3dFile;

  String? _imageUrl;
  String? _audioUrl;
  String? _model3dUrl;

  final _categories = [
    'Sculpture',
    'Peinture',
    'Textile',
    'Bijoux',
    'Poterie',
    'Monument',
  ];

  Widget _buildAddOeuvreForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajouter une oeuvre',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _brun,
            ),
          ),
          const SizedBox(height: 20),

          _buildTextField(_titreController, 'Titre', Icons.title),
          _buildTextField(_artisteController, 'Artiste', Icons.person_outline),
          _buildTextField(
            _paysController,
            'Pays d\'origine',
            Icons.flag_outlined,
          ),
          _buildTextField(
            _anneeController,
            'Année',
            Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
          ),
          _buildTextField(
            _descController,
            'Description',
            Icons.description_outlined,
            maxLines: 4,
          ),

          const SizedBox(height: 16),

          _buildLabel('Catégorie'),
          DropdownButtonFormField<String>(
            value: _selectedCategorie,
            decoration: _inputDecoration(),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategorie = v!),
          ),

          const SizedBox(height: 16),

          _buildLabel('Statut'),
          DropdownButtonFormField<String>(
            value: _selectedStatut,
            decoration: _inputDecoration(),
            items: const [
              DropdownMenuItem(value: 'normal', child: Text('Normal')),
              DropdownMenuItem(value: 'volé', child: Text('🔴 Stolen Art')),
            ],
            onChanged: (v) => setState(() => _selectedStatut = v!),
          ),

          if (_selectedStatut == 'volé') ...[
            const SizedBox(height: 16),
            _buildTextField(
              _museeController,
              'Musée actuel',
              Icons.museum_outlined,
            ),
            _buildTextField(
              _paysActuelController,
              'Pays actuel',
              Icons.location_on_outlined,
            ),
          ],

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _papyrus,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '✨ Mettre à la une',
                  style: TextStyle(color: _brun, fontWeight: FontWeight.w600),
                ),
                Switch(
                  value: _isFeatured,
                  activeColor: _or,
                  onChanged: (v) => setState(() => _isFeatured = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildLabel('Image de l\'oeuvre'),
          _buildUploadButton(
            label: _imageFile != null
                ? '✅ Image sélectionnée'
                : _imageUrl != null
                ? '✅ Uploadée'
                : 'Choisir une image',
            icon: Icons.image_outlined,
            color: _or,
            onTap: _pickImage,
          ),

          const SizedBox(height: 12),

          _buildLabel('Audio guide'),
          _buildUploadButton(
            label: _audioFile != null
                ? '✅ Audio sélectionné'
                : _audioUrl != null
                ? '✅ Uploadé'
                : 'Choisir un fichier audio',
            icon: Icons.audiotrack_outlined,
            color: const Color(0xFF8FAFC0),
            onTap: _pickAudio,
          ),

          const SizedBox(height: 12),

          _buildLabel('Modèle 3D (.glb)'),
          _buildUploadButton(
            label: _model3dFile != null
                ? '✅ Modèle 3D sélectionné'
                : _model3dUrl != null
                ? '✅ Uploadé'
                : 'Choisir un fichier .glb',
            icon: Icons.view_in_ar_outlined,
            color: const Color(0xFFB8A8CC),
            onTap: _pickModel3d,
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isUploading ? null : _saveOeuvre,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brun,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _isUploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: _or,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Upload en cours...',
                          style: TextStyle(color: _papyrus),
                        ),
                      ],
                    )
                  : const Text(
                      'Enregistrer l\'oeuvre',
                      style: TextStyle(
                        color: _papyrus,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() => _audioFile = File(result.files.single.path!));
    }
  }

  Future<void> _pickModel3d() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['glb', 'gltf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _model3dFile = File(result.files.single.path!));
    }
  }

  Future<void> _saveOeuvre() async {
    if (_titreController.text.trim().isEmpty ||
        _paysController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titre et pays sont obligatoires')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      if (_imageFile != null) {
        _imageUrl = await CloudinaryService.uploadFile(
          _imageFile!,
          'afrilegacy/images',
        );
      }
      if (_audioFile != null) {
        _audioUrl = await CloudinaryService.uploadFile(
          _audioFile!,
          'afrilegacy/audio',
        );
      }
      if (_model3dFile != null) {
        _model3dUrl = await CloudinaryService.uploadFile(
          _model3dFile!,
          'afrilegacy/models3d',
        );
      }

      final oeuvre = OeuvreModel(
        id: '',
        titre: _titreController.text.trim(),
        artiste: _artisteController.text.trim(),
        pays: _paysController.text.trim(),
        annee: _anneeController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: _imageUrl ?? '',
        audioUrl: _audioUrl ?? '',
        model3dUrl: _model3dUrl ?? '',
        categorie: _selectedCategorie,
        statut: _selectedStatut,
        museeActuel: _museeController.text.trim(),
        paysActuel: _paysActuelController.text.trim(),
        isFeatured: _isFeatured,
      );

      await _oeuvreService.addOeuvre(oeuvre);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Oeuvre ajoutée avec succès !'),
            backgroundColor: Color(0xFF8C7A68),
          ),
        );
        _resetForm();
        setState(() => _selectedTab = 0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _resetForm() {
    _titreController.clear();
    _artisteController.clear();
    _paysController.clear();
    _anneeController.clear();
    _descController.clear();
    _museeController.clear();
    _paysActuelController.clear();
    setState(() {
      _imageFile = null;
      _audioFile = null;
      _model3dFile = null;
      _imageUrl = null;
      _audioUrl = null;
      _model3dUrl = null;
      _selectedCategorie = 'Sculpture';
      _selectedStatut = 'normal';
      _isFeatured = false;
    });
  }

  // ==================== LISTE USERS ====================

  Widget _buildUsersList() {
    return StreamBuilder<List<UserModel>>(
      stream: _userService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _or));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun utilisateur'));
        }
        final users = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final u = users[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _brun.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _or.withOpacity(0.2),
                    child: Text(
                      u.nom.isNotEmpty ? u.nom[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: _brun,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.nom,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _brun,
                          ),
                        ),
                        Text(
                          u.email,
                          style: const TextStyle(fontSize: 12, color: _ocre),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: u.isAdmin ? _or.withOpacity(0.15) : _papyrus,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      u.isAdmin ? '👑 Admin' : 'User',
                      style: TextStyle(
                        fontSize: 11,
                        color: u.isAdmin ? _brun : _ocre,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==================== HELPERS UI ====================

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: _brun),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _ocre),
          prefixIcon: Icon(icon, color: _or, size: 20),
          filled: true,
          fillColor: _papyrus,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _or, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _brun,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUploadButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: _papyrus,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _or, width: 1.5),
      ),
    );
  }
}
