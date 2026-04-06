import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afrilegacy/views/admin/afri_theme.dart';

class AdminOeuvreForm extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;
  const AdminOeuvreForm({super.key, this.docId, this.existingData});
  @override
  State<AdminOeuvreForm> createState() => _AdminOeuvreFormState();
}

class _AdminOeuvreFormState extends State<AdminOeuvreForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _anim;
  bool _saving = false;
  bool get _isEdit => widget.docId != null;

  // Champs Firestore
  final _titreC      = TextEditingController();
  final _artisteC    = TextEditingController();
  final _paysC       = TextEditingController();
  final _anneeC      = TextEditingController();
  final _descC       = TextEditingController();
  final _imageUrlC   = TextEditingController();
  final _audioUrlC   = TextEditingController();
  final _model3dUrlC = TextEditingController();

  String _categorie  = 'Sculpture';
  bool   _isFeatured = false;
  bool   _hasAudio   = false;
  bool   _has3D      = false;

  static const _cats = [
    'Sculpture',
    'Peinture',
    'Textile',
    'Bijoux',
    'Poterie',
    'Instrument',
    'Architecture'
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();

    if (_isEdit) {
      final d = widget.existingData!;
      _titreC.text      = d['titre']       ?? '';
      _artisteC.text    = d['artiste']     ?? '';
      _paysC.text       = d['pays']        ?? '';
      _anneeC.text      = d['annee']       ?? '';
      _descC.text       = d['description'] ?? '';
      _imageUrlC.text   = d['imageUrl']    ?? '';
      _audioUrlC.text   = d['audioUrl']    ?? '';
      _model3dUrlC.text = d['model3dUrl']  ?? '';
      _categorie        = d['categorie']   ?? 'Sculpture';
      _isFeatured       = d['isFeatured']  ?? false;
      _hasAudio         = (d['audioUrl']   ?? '').toString().isNotEmpty;
      _has3D            = (d['model3dUrl'] ?? '').toString().isNotEmpty;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    for (final c in [
      _titreC, _artisteC, _paysC, _anneeC, _descC,
      _imageUrlC, _audioUrlC, _model3dUrlC,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = <String, dynamic>{
      'titre':       _titreC.text.trim(),
      'artiste':     _artisteC.text.trim(),
      'pays':        _paysC.text.trim(),
      'annee':       _anneeC.text.trim(),
      'description': _descC.text.trim(),
      'imageUrl':    _imageUrlC.text.trim(),
      'audioUrl':    _hasAudio ? _audioUrlC.text.trim() : '',
      'model3dUrl':  _has3D   ? _model3dUrlC.text.trim() : '',
      'categorie':   _categorie,
      'isFeatured':  _isFeatured,
      'updatedAt':   FieldValue.serverTimestamp(),
    };

    try {
      if (_isEdit) {
        await FirebaseFirestore.instance
            .collection('oeuvres')
            .doc(widget.docId)
            .update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('oeuvres').add(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Œuvre modifiée ✓' : 'Œuvre ajoutée ✓'),
          backgroundColor: Afri.gold,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Afri.bg,
        body: FadeTransition(
          opacity: _anim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              AfriSliverHeader(
                title: _isEdit ? 'Modifier l\'œuvre' : 'Nouvelle œuvre',
                subtitle: _isEdit
                    ? (_titreC.text.isNotEmpty ? _titreC.text : 'Modifier')
                    : 'Remplissez les informations',
                badge: _isEdit ? 'MODIFICATION' : 'AJOUT',
                expandedHeight: 130,
              ),
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0, 0.06), end: Offset.zero)
                      .animate(CurvedAnimation(
                          parent: _anim, curve: Curves.easeOut)),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
                      child: Column(children: [

                        // ── Aperçu image ──────────────────────────
                        _buildImagePreview(),
                        const SizedBox(height: 16),

                        // ── Infos principales ─────────────────────
                        AfriSection(
                            title: 'Informations principales',
                            children: [
                              AfriField(
                                controller: _titreC,
                                label: 'Titre de l\'œuvre',
                                hint: 'Ex: Bronzes du Bénin',
                                validator: (v) =>
                                    (v ?? '').isEmpty ? 'Requis' : null,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 12),
                              AfriField(
                                controller: _artisteC,
                                label: 'Artiste / Origine',
                                hint: 'Ex: Artisans Bénin',
                              ),
                              const SizedBox(height: 12),
                              Row(children: [
                                Expanded(child: AfriField(
                                  controller: _paysC,
                                  label: 'Pays d\'origine',
                                  hint: 'Ex: Nigeria',
                                )),
                                const SizedBox(width: 12),
                                Expanded(child: AfriField(
                                  controller: _anneeC,
                                  label: 'Période / Année',
                                  hint: 'Ex: 1500',
                                )),
                              ]),
                              const SizedBox(height: 12),
                              _CatDropdown(
                                value: _categorie,
                                items: _cats,
                                onChanged: (v) =>
                                    setState(() => _categorie = v!),
                              ),
                              const SizedBox(height: 12),
                              AfriField(
                                controller: _descC,
                                label: 'Description historique',
                                hint: 'Décrivez le contexte culturel...',
                                maxLines: 4,
                              ),
                            ]),

                        // ── Image ─────────────────────────────────
                        AfriSection(title: 'Image principale', children: [
                          AfriField(
                            controller: _imageUrlC,
                            label: 'URL de l\'image',
                            hint: 'https://...',
                            keyboardType: TextInputType.url,
                            onChanged: (_) => setState(() {}),
                          ),
                        ]),

                        // ── Mise en avant ─────────────────────────
                        AfriSection(title: 'Mise en avant', children: [
                          AfriToggle(
                            icon: Icons.star_rounded,
                            iconColor: Afri.gold,
                            title: 'Mettre à la une',
                            subtitle: 'Apparaît en section Featured',
                            value: _isFeatured,
                            onChanged: (v) => setState(() => _isFeatured = v),
                          ),
                        ]),

                        // ── Fonctionnalités avancées ──────────────
                        AfriSection(
                            title: 'Fonctionnalités avancées',
                            children: [
                              AfriToggle(
                                icon: Icons.view_in_ar_rounded,
                                iconColor: Afri.kente,
                                title: 'Modèle 3D',
                                subtitle: 'Active la visualisation 3D',
                                value: _has3D,
                                onChanged: (v) => setState(() => _has3D = v),
                              ),
                              if (_has3D) ...[
                                const SizedBox(height: 10),
                                AfriField(
                                  controller: _model3dUrlC,
                                  label: 'URL modèle 3D (.glb)',
                                  hint: 'https://... .glb',
                                  keyboardType: TextInputType.url,
                                ),
                              ],
                              const SizedBox(height: 10),
                              AfriToggle(
                                icon: Icons.headphones_outlined,
                                iconColor: Afri.nil,
                                title: 'Audio Guide',
                                subtitle: 'Narration audio de l\'œuvre',
                                value: _hasAudio,
                                onChanged: (v) => setState(() => _hasAudio = v),
                              ),
                              if (_hasAudio) ...[
                                const SizedBox(height: 10),
                                AfriField(
                                  controller: _audioUrlC,
                                  label: 'URL audio (.mp3)',
                                  hint: 'https://... .mp3',
                                  keyboardType: TextInputType.url,
                                ),
                              ],
                            ]),

                        // ── Bouton save ───────────────────────────
                        AfriButton(
                          label: _isEdit
                              ? 'Enregistrer les modifications'
                              : 'Ajouter l\'œuvre',
                          icon: _isEdit
                              ? Icons.save_outlined
                              : Icons.add_circle_outline,
                          isLoading: _saving,
                          onTap: _save,
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildImagePreview() {
    final url = _imageUrlC.text.trim();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 120,
      decoration: BoxDecoration(
        color: url.isNotEmpty ? Colors.transparent : Afri.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: url.isNotEmpty ? Afri.gold : Afri.sand,
          width: url.isNotEmpty ? 2 : 1,
        ),
      ),
      child: url.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => _imgPlaceholder(),
              ),
            )
          : _imgPlaceholder(),
    );
  }

  Widget _imgPlaceholder() =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 30, color: Afri.gold.withOpacity(0.6)),
        const SizedBox(height: 6),
        const Text('Aperçu de l\'image',
            style: TextStyle(
                fontSize: 12, color: Afri.ocre, fontWeight: FontWeight.w600)),
        const Text('Entrez l\'URL ci-dessous',
            style: TextStyle(fontSize: 10, color: Afri.clay)),
      ]);
}

// ─── Dropdown catégorie ──────────────────────────────────────
class _CatDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _CatDropdown(
      {required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Catégorie',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Afri.dark,
                  letterSpacing: 0.3)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
                color: Afri.bg2, borderRadius: BorderRadius.circular(14)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                style: const TextStyle(fontSize: 13, color: Afri.dark),
                dropdownColor: Afri.bg2,
                borderRadius: BorderRadius.circular(14),
                items: items
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      );
}