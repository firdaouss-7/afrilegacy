# AfriLegacy — Musée Virtuel du Patrimoine Culturel Africain

Application mobile de musée virtuel interactif permettant d'explorer des œuvres d'art, sculptures, textiles et objets culturels africains, avec visualisation 3D et audioguide contextuel.

Projet réalisé dans le cadre du module Développement Mobile & Métavers, 2ème année du Cycle Ingénieur (Data Science, Big Data & IA), ENSIASD Taroudant.

## Fonctionnalités

- Authentification (email/mot de passe + Google OAuth 2.0), avec vérification d'email
- Exploration des œuvres : liste, recherche et filtrage par catégorie en temps réel
- Fiche détail par œuvre avec audioguide intégré
- **Visualisation 3D interactive** des œuvres (`model_viewer_plus`)
- Gestion des favoris en temps réel
- Profil utilisateur avec upload de photo (Cloudinary)
- Interface d'administration complète : gestion des œuvres (CRUD), gestion des membres, statistiques et tableau de bord analytique

## Stack technique

- **Frontend mobile** : Flutter / Dart
- **Backend & données** : Firebase (Firestore, Authentication)
- **Médias** : Cloudinary (hébergement images/audio)
- **Visualisation 3D** : model_viewer_plus
- **Architecture** : MVVM (Model–View–ViewModel), contrôle d'accès à deux niveaux (utilisateur / administrateur)

## Projet réalisé en équipe (Groupe 10)

- Lassana Kouma
- Firdaouss Zai
- Maryam Balmir
- Mwingoum Yanis Fadel Somda

Encadré par Pr. Latifa Rassam — Année universitaire 2025-2026
