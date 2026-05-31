-- Active: 1775727990562@@127.0.0.1@5432@service_technique
-- 06 - Sécurité : rôles et permissions

-- Citoyen : lecture seule sur les données publiques
CREATE ROLE citoyen;

-- Technicien : lecture + écriture sur les tables opérationnelles
CREATE ROLE technicien;

-- Administrateur : tous les privilèges sur la base
CREATE ROLE administrateur;


-- PERMISSIONS : CITOYEN
-- Peut consulter l'inventaire et les signalements publics
-- Ne voit PAS les données internes

GRANT SELECT ON inventaire             TO citoyen;
GRANT SELECT ON type_inventaire        TO citoyen;
GRANT SELECT ON etat_inventaire        TO citoyen;
GRANT SELECT ON signalement            TO citoyen;
GRANT SELECT ON statut_signalement     TO citoyen;
GRANT SELECT ON urgence_signalement    TO citoyen;



-- PERMISSIONS : TECHNICIEN
-- Peut lire toutes les tables et modifier les données opérationnelles

-- Lecture sur toutes les tables
GRANT SELECT ON ALL TABLES IN SCHEMA public TO technicien;

-- Écriture sur les tables qu'il gère au quotidien
GRANT INSERT, UPDATE ON intervention            TO technicien;
GRANT INSERT, UPDATE ON signalement             TO technicien;
GRANT INSERT, UPDATE ON signalement_intervention TO technicien;
GRANT INSERT, UPDATE ON inventaire              TO technicien;

-- Accès aux séquences (nécessaire pour INSERT avec SERIAL)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO technicien;



-- PERMISSIONS pour les ADMINISTRATEUR
-- Contrôle total sur la base de données

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public    TO administrateur;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO administrateur;
GRANT CREATE ON SCHEMA public                          TO administrateur;


