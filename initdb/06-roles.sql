-- Active: 1775727990562@@127.0.0.1@5432@service_technique
-- ============================================================
-- 06 - Sécurité : rôles et permissions
-- Service technique d'Yverdon-les-Bains
-- ============================================================
-- Principe du moindre privilège (PoLP) :
--   chaque rôle reçoit uniquement les permissions nécessaires
-- ============================================================


-- ============================================================
-- CRÉATION DES RÔLES
-- ============================================================

-- Citoyen : lecture seule sur les données publiques
CREATE ROLE citoyen;

-- Technicien : lecture + écriture sur les tables opérationnelles
CREATE ROLE technicien;

-- Administrateur : tous les privilèges sur la base
CREATE ROLE administrateur;


-- ============================================================
-- PERMISSIONS : CITOYEN
-- Peut consulter l'inventaire et les signalements publics
-- Ne voit PAS les données internes (fournisseurs, coûts, etc.)
-- ============================================================

GRANT SELECT ON inventaire             TO citoyen;
GRANT SELECT ON type_inventaire        TO citoyen;
GRANT SELECT ON etat_inventaire        TO citoyen;
GRANT SELECT ON signalement            TO citoyen;
GRANT SELECT ON statut_signalement     TO citoyen;
GRANT SELECT ON urgence_signalement    TO citoyen;

-- Le citoyen ne voit que certaines colonnes du signalement
-- (pas le nom du signataire, pour respecter la vie privée)
-- → si besoin d'aller plus loin, créer une vue publique


-- ============================================================
-- PERMISSIONS : TECHNICIEN
-- Peut lire toutes les tables et modifier les données opérationnelles
-- ============================================================

-- Lecture sur toutes les tables
GRANT SELECT ON ALL TABLES IN SCHEMA public TO technicien;

-- Écriture sur les tables qu'il gère au quotidien
GRANT INSERT, UPDATE ON intervention            TO technicien;
GRANT INSERT, UPDATE ON signalement             TO technicien;
GRANT INSERT, UPDATE ON signalement_intervention TO technicien;
GRANT INSERT, UPDATE ON inventaire              TO technicien;

-- Accès aux séquences (nécessaire pour INSERT avec SERIAL)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO technicien;


-- ============================================================
-- PERMISSIONS : ADMINISTRATEUR
-- Contrôle total sur la base de données
-- ============================================================

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public    TO administrateur;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO administrateur;
GRANT CREATE ON SCHEMA public                          TO administrateur;


-- ============================================================
-- EXEMPLES D'UTILISATION : créer des utilisateurs et leur attribuer un rôle
-- ============================================================

-- Décommenter et adapter selon les vrais utilisateurs :

-- CREATE USER alice WITH PASSWORD 'motdepasse_fort_1!' VALID UNTIL '2027-12-31';
-- GRANT citoyen TO alice;

-- CREATE USER jean_marc WITH PASSWORD 'motdepasse_fort_2!' NOSUPERUSER NOCREATEDB;
-- GRANT technicien TO jean_marc;

-- CREATE USER admin_service WITH PASSWORD 'motdepasse_fort_3!' NOSUPERUSER NOCREATEDB;
-- GRANT administrateur TO admin_service;


-- ============================================================
-- VÉRIFICATION : afficher les permissions accordées
-- ============================================================

-- Lister les membres de chaque rôle :
-- SELECT rolname, member::regrole FROM pg_auth_members
-- JOIN pg_roles ON pg_roles.oid = roleid;

-- Voir les permissions sur les tables :
-- SELECT grantee, table_name, privilege_type
-- FROM information_schema.role_table_grants
-- WHERE grantee IN ('citoyen', 'technicien', 'administrateur')
-- ORDER BY grantee, table_name;
