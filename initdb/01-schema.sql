-- SCHEMA:

-- table libelle de type intervention, liée à la table INTERVENTION
CREATE TABLE type_intervention (
    id SERIAL PRIMARY KEY,
    type_intervention VARCHAR(100) UNIQUE NOT NULL
);

-- Interventions
CREATE TABLE intervention (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    objet VARCHAR(255),
    technicien VARCHAR(255),
    duree INTERVAL, -- ou DECIMAL pour heures
    cout_materiel NUMERIC(10, 2),
    remarque TEXT,
    id_type_intervention INTEGER NOT NULL REFERENCES type_intervention (id)
);

-- table libelle de statut signalement, liée à la table SIGNALEMENT
CREATE TABLE statut_signalement (
    id SERIAL PRIMARY KEY,
    statut VARCHAR(100) NOT NULL
);

-- table libelle de statut urgence, liée à la table SIGNALEMENT
CREATE TABLE urgence_signalement (
    id SERIAL PRIMARY KEY,
    statut VARCHAR(100) NOT NULL
);

-- table libelle de lieux inventaire, liée à la table INVENTAIRE
CREATE TABLE lieux_inventaire (
    id SERIAL PRIMARY KEY,
    lieux VARCHAR(255) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL 
);

-- table libelle de etat_iventaire, liée à la table INVENTAIRE
CREATE TABLE etat_inventaire (
    id SERIAL PRIMARY KEY,
    etat VARCHAR(100) NOT NULL
);

-- table libelle de type_iventaire, liée à la table INVENTAIRE
CREATE TABLE type_inventaire (
    id SERIAL PRIMARY KEY,
    type VARCHAR(100) NOT NULL
);

-- table libelle de type_materiaux, liée à la table INVENTAIRE
CREATE TABLE type_materiaux (
    id SERIAL PRIMARY KEY,
    type VARCHAR(100) NOT NULL
);

-- table libelle de type_materiels, liée à la table FOURNISSEURS
CREATE TABLE type_materiels (
    id SERIAL PRIMARY KEY,
    type_materiels VARCHAR(100) NOT NULL
);

-- Fournisseurs
CREATE TABLE fournisseurs (
    id SERIAL PRIMARY KEY,
    entreprises VARCHAR(255),
    contact VARCHAR(255),
    telephone VARCHAR(20) UNIQUE,
    email VARCHAR(255) UNIQUE,
    remarque TEXT,
    id_type_materiel INTEGER NOT NULL REFERENCES type_materiaux(id)
);
-- Inventaire (table centrale)
CREATE TABLE inventaire (
    id SERIAL PRIMARY KEY,
    numero VARCHAR(100) UNIQUE NOT NULL, -- "ID" comme identifiant unique
    date_installation DATE,
    remarque TEXT,
    id_fournisseurs INTEGER NOT NULL REFERENCES fournisseurs (id),
    id_type_inventaire INTEGER NOT NULL REFERENCES type_inventaire (id),
    id_type_materiaux INTEGER NOT NULL REFERENCES type_materiaux (id),
    id_etat_inventaire INTEGER NOT NULL REFERENCES etat_inventaire (id),
    id_lieux_inventaire INTEGER NOT NULL REFERENCES lieux_inventaire (id)
);

-- Signalement
CREATE TABLE signalement (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    signal_par VARCHAR(255),
    objet VARCHAR(255),
    description TEXT,
    id_statut_signalement INTEGER NOT NULL REFERENCES statut_signalement (id),
    id_statut_urgence INTEGER NOT NULL REFERENCES statut_urgence (id),
    id_inventaire INTEGER NOT NULL REFERENCES inventaire (id)
);

-- Table de liaison Signalement-Intervention (N-N)
CREATE TABLE signalement_intervention (
    id SERIAL PRIMARY KEY,
    id_signalement INTEGER NOT NULL REFERENCES signalement(id),
    id_intervention INTEGER NOT NULL REFERENCES intervention(id)
);