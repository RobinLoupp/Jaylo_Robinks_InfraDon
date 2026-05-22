-- Active: 1776260001431@@localhost@5432
--nettoyage des grandes tables 

INSERT INTO intervention (
      -- on met le id ? ils se mettent automatiquement selon thibs
    date,
    objet,
    technicien,
    duree,
    cout_materiel,
    remarque,
    id_type_intervention
)
SELECT
    CASE
        WHEN date ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_DATE(TRIM(date), 'DD.MM.YYYY')
        WHEN date ~ '^\d{4}-\d{2}-\d{2}$' THEN TRIM(date)::DATE
        ELSE NULL
    END,
    NULLIF(TRIM(objet), ''),
    CASE
        WHEN TRIM(technicien) IN ('JM', 'Jean-Marc') THEN 'Jean-Marc Bonvin'
        ELSE NULLIF(TRIM(technicien), '')
    END,
    CASE
        WHEN LOWER(TRIM(duree)) = 'une matinée' THEN 4
        WHEN LOWER(TRIM(duree)) = 'une journée' THEN 8
        WHEN TRIM(duree) ~ '^\d+h\d{2}$' THEN (SPLIT_PART(TRIM(duree), 'h', 1)::INT * 60 + SPLIT_PART(TRIM(duree), 'h', 2)::INT) / 60
        WHEN TRIM(duree) ~ '^\d+h$' THEN SPLIT_PART(TRIM(duree), 'h', 1)::INT
        WHEN TRIM(duree) ~ '^\d+\s*min$' THEN SPLIT_PART(TRIM(duree), ' ', 1)::INT / 60
        ELSE NULL
    END,
    CASE
        WHEN LOWER(TRIM(cout_materiel)) LIKE '%gratuit%' THEN 0.00
        WHEN regexp_replace(TRIM(cout_materiel), '[^0-9\.,]', '', 'g') ~ '^\d+[\.,]?\d*$' THEN regexp_replace(TRIM(cout_materiel), '[^0-9\.,]', '', 'g')::NUMERIC(10,2)
        ELSE NULL
    END,
    NULLIF(TRIM(remarque), ''),
    COALESCE(ti.id, (SELECT id FROM type_intervention WHERE libelle = 'autre'))

    FROM
    staging.interventions i
    LEFT JOIN type_intervention ti ON LOWER(i.type_intervention) LIKE '%' || ti.type_interventionle || '%';


INSERT INTO materiels (
      -- on met le id ?
    type_materiels
)


INSERT INTO fournisseurs (
      -- on met le id ?
    entreprises,
    contact,
    telephone,
    email,
    remarque,
    id_type_materiel
)
SELECT
    entreprise,
    NULLIF(TRIM(nom_contact), ''),
    CASE
        WHEN telephone LIKE '0%' THEN telephone
        WHEN telephone LIKE '+41%' THEN regexp_replace(telephone, '^\+41', '0')
        ELSE NULL
    END AS telephone,
    CASE
        WHEN email LIKE '%@%' THEN email
        ELSE NULL
    END AS email,
    NULLIF(TRIM(remarques), '')
FROM staging.fournisseurs_contacts;

INSERT INTO inventaire (
    -- on met le id ?
       numero, --id
       date_installation,
       remarque,
       id_fournisseurs,
       id_type_inventaire,
       id_type_materiaux,
       id_etat_inventaire,
       id_lieux_inventaire
    )
SELECT
    id_inventaire,
    CASE
        WHEN LOWER(id_type_inventaire) LIKE '%lampadaire%' THEN 1
        WHEN LOWER(id_type_inventaire) LIKE '%fontaine%' THEN 2
        WHEN LOWER(id_type_inventaire) LIKE '%banc%' THEN 3
        WHEN LOWER(id_type_inventaire) LIKE '%poubelle%' THEN 4
        WHEN LOWER(id_type_inventaire) LIKE '%corbeille%' THEN 4
        WHEN LOWER(id_type_inventaire) LIKE '%borne%' THEN 5
        WHEN LOWER(id_type_inventaire) LIKE '%panneau%' THEN 6
        ELSE 7 -- 'autre'
    END AS id_type_inventaire,
    CASE
        WHEN LOWER(id_type_materiau) LIKE '%bois%' THEN 1
        WHEN LOWER(id_type_materiau) LIKE '%métal%' THEN 2
        WHEN LOWER(id_type_materiau) LIKE '%sodium%' THEN 3
        WHEN LOWER(id_type_materiau) LIKE '%LED%' THEN 4
        WHEN LOWER(id_type_materiau) LIKE '%pierre%' THEN 5
        WHEN LOWER(id_type_materiau) LIKE '%béton%' THEN 6
        ELSE NULL
    END AS id_type_materiau,
    lieu,
    ST_SetSRID (
        ST_MakePoint (
            (
                CAST(latitude AS DOUBLE PRECISION)
            ),
            CAST(longitude AS DOUBLE PRECISION)
        ),
        2056
    ) AS geom,
    normalize_date (date_installation) AS date_installation,
    CASE
        WHEN LOWER(id_etat) LIKE '%remplace%' THEN 1
        WHEN LOWER(id_etat) LIKE '%bon%' THEN 2
        WHEN LOWER(id_etat) LIKE '%usé%' THEN 3
    END AS id_etat,
    remarques
FROM staging.inventaire_mobiliers;


    INSERT INTO signalement (
        -- on met le id ?
        date,
        signale_par, --faut supp toutes les tables et relancer la base de données psk on a corrigé lortho
        objet, -- colonne temporaire pour permettre une jointure
        description,
        id_urgence_signalement,
        id_statut_signalement,
        id_inventaire
    )