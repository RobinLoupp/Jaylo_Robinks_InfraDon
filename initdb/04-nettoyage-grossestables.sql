-- Active: 1772185782000@@127.0.0.1@5432@postgres
-- ============================================================
-- Nettoyage et insertion des grandes tables
-- Service technique d'Yverdon-les-Bains
-- ============================================================
-- 1. MATERIELS
--    Extraire les types distincts depuis la colonne multi-valeurs
-- ============================================================

INSERT INTO materiels (type_materiels)
SELECT DISTINCT TRIM(valeur)
FROM staging.fournisseurs_contacts
CROSS JOIN LATERAL unnest(string_to_array(type_materiel, ',')) AS valeur
WHERE TRIM(valeur) <> ''
ON CONFLICT DO NOTHING;


-- ============================================================
-- 2. FOURNISSEURS
--    Nettoyage téléphones (+41 → 0XX), validation emails
-- ============================================================

INSERT INTO fournisseurs (
    entreprises,
    contact,
    telephone,
    email,
    remarque
)
SELECT
    NULLIF(TRIM(entreprise), ''),

    NULLIF(TRIM(contact), ''),

    -- Normaliser les numéros : +41 21 456 78 90 → 021 456 78 90
    CASE
        WHEN TRIM(telephone) ~ '^\+41\s?'
            THEN regexp_replace(TRIM(telephone), '^\+41\s?', '0')
        WHEN TRIM(telephone) ~ '^0[0-9]'
            THEN TRIM(telephone)
        ELSE NULL
    END,

    -- Valider l'email : doit contenir @
    CASE
        WHEN TRIM(email) LIKE '%@%' THEN LOWER(TRIM(email))
        ELSE NULL
    END,

    NULLIF(TRIM(remarques), '')

FROM staging.fournisseurs_contacts
ON CONFLICT (telephone) DO NOTHING;


-- ============================================================
-- 3. INTERVENTION
--    Nettoyage dates, durées (→ INTERVAL), coûts, techniciens
-- ============================================================

INSERT INTO intervention (
    date,
    objet,
    technicien,
    duree,
    cout_materiel,
    remarque,
    id_type_intervention
)
SELECT
    -- Date : format CH (DD.MM.YYYY) ou ISO (YYYY-MM-DD)
    CASE
        WHEN TRIM(date) ~ '^\d{2}\.\d{2}\.\d{4}$'
            THEN TO_DATE(TRIM(date), 'DD.MM.YYYY')
        WHEN TRIM(date) ~ '^\d{4}-\d{2}-\d{2}$'
            THEN TRIM(date)::DATE
        ELSE NULL
    END,

    NULLIF(TRIM(objet), ''),

    -- Normaliser les noms de techniciens
    CASE
        WHEN TRIM(technicien) IN ('JM', 'Jean-Marc', 'jean-marc')
            THEN 'Jean-Marc Bonvin'
        WHEN TRIM(technicien) IN ('Pedro', 'P. Alves', 'Alves Pedro')
            THEN 'Pedro Alves'
        ELSE NULLIF(TRIM(technicien), '')
    END,

    -- Durée → INTERVAL PostgreSQL
    CASE
        WHEN LOWER(TRIM(duree)) = 'une matinée'  THEN '4 hours'::INTERVAL
        WHEN LOWER(TRIM(duree)) = 'une journée'  THEN '8 hours'::INTERVAL
        WHEN TRIM(duree) ~ '^\d+h\d{2}$'
            THEN (SPLIT_PART(TRIM(duree), 'h', 1)::INT || ' hours '
               || SPLIT_PART(TRIM(duree), 'h', 2)::INT || ' minutes')::INTERVAL
        WHEN TRIM(duree) ~ '^\d+h$'
            THEN (SPLIT_PART(TRIM(duree), 'h', 1)::INT || ' hours')::INTERVAL
        WHEN TRIM(duree) ~ '^\d+\s*min$'
            THEN (regexp_replace(TRIM(duree), '[^0-9]', '', 'g')::INT
               || ' minutes')::INTERVAL
        ELSE NULL
    END,

    -- Coût matériel : extraire le nombre, "gratuit" → 0, vide → NULL
    CASE
        WHEN LOWER(TRIM(cout_materiel)) IN ('gratuit', 'garantie', 'offert', '0')
            THEN 0.00
        WHEN NULLIF(TRIM(cout_materiel), '') IS NULL
            THEN NULL
        WHEN regexp_replace(TRIM(cout_materiel), '[^0-9,\.]', '', 'g')
             ~ '^\d+[,\.]?\d*$'
            THEN replace(
                    regexp_replace(TRIM(cout_materiel), '[^0-9,\.]', '', 'g'),
                    ',', '.'
                 )::NUMERIC(10, 2)
        ELSE NULL
    END,

    NULLIF(TRIM(remarque), ''),

    -- Jointure sur type_intervention (correction : type_interventionle → type_intervention)
    COALESCE(
        (
            SELECT ti.id
            FROM type_intervention ti
            WHERE LOWER(TRIM(i.type_intervention)) LIKE '%' || ti.type_intervention || '%'
            LIMIT 1
        ),
        (SELECT id FROM type_intervention WHERE LOWER(type_intervention) = 'non spécifié' LIMIT 1)
    )

FROM staging.interventions i
WHERE NULLIF(TRIM(date), '') IS NOT NULL;


-- ============================================================
-- 4. INVENTAIRE
--    Nettoyage IDs, dates multi-formats, GPS, FK vers référentiels
-- ============================================================

INSERT INTO inventaire (
    numero,
    date_installation,
    remarque,
    lieux,
    latitude,
    longitude,
    id_fournisseurs,
    id_type_inventaire,
    id_etat_inventaire
)
SELECT
    TRIM(id),

    -- Date : format CH, ISO, ou textes libres (mois année, année seule → NULL)
    CASE
        WHEN TRIM(date_installation) ~ '^\d{2}\.\d{2}\.\d{4}$'
            THEN TO_DATE(TRIM(date_installation), 'DD.MM.YYYY')
        WHEN TRIM(date_installation) ~ '^\d{4}-\d{2}-\d{2}$'
            THEN TRIM(date_installation)::DATE
        -- Année seule (ex: "2020") → 1er janvier de l'année
        WHEN TRIM(date_installation) ~ '^\d{4}$'
            THEN TO_DATE(TRIM(date_installation) || '-01-01', 'YYYY-MM-DD')
        -- Texte libre (ex: "février 2021", "avril 2023") → NULL
        ELSE NULL
    END,

    NULLIF(TRIM(remarques), ''),

    -- Lieu : normaliser la casse
    INITCAP(TRIM(lieu)),

    -- GPS : NULL si absent ou trop imprécis (moins de 4 décimales)
    CASE
        WHEN NULLIF(TRIM(latitude), '') IS NULL THEN NULL
        WHEN TRIM(latitude) ~ '^\d+\.\d{1,3}$' THEN NULL
        ELSE TRIM(latitude)::DECIMAL(10, 8)
    END,

    CASE
        WHEN NULLIF(TRIM(longitude), '') IS NULL THEN NULL
        WHEN TRIM(longitude) ~ '^\d+\.\d{1,3}$' THEN NULL
        ELSE TRIM(longitude)::DECIMAL(11, 8)
    END,

    -- id_fournisseurs : pas de colonne fournisseur dans l'inventaire CSV
    -- → valeur par défaut 1 (à adapter si un fournisseur générique est défini)
    1,

    -- Type inventaire : jointure sur la table de référence
    COALESCE(
        (
            SELECT ti.id FROM type_inventaire ti
            WHERE LOWER(TRIM(ti.type)) = CASE
                WHEN LOWER(TRIM(im.type)) LIKE '%banc%'       THEN 'banc'
                WHEN LOWER(TRIM(im.type)) LIKE '%lampadaire%' THEN 'lampadaire'
                WHEN LOWER(TRIM(im.type)) LIKE '%poubelle%'   THEN 'poubelle'
                WHEN LOWER(TRIM(im.type)) LIKE '%corbeille%'  THEN 'poubelle'
                WHEN LOWER(TRIM(im.type)) LIKE '%fontaine%'   THEN 'fontaine'
                WHEN LOWER(TRIM(im.type)) LIKE '%borne%'      THEN 'borne recharge'
                WHEN LOWER(TRIM(im.type)) LIKE '%panneau%'    THEN 'panneau'
                ELSE 'non spécifié'
            END
            LIMIT 1
        ),
        (SELECT id FROM type_inventaire WHERE type = 'non spécifié' LIMIT 1)
    ),

    -- État inventaire : jointure sur la table de référence
    COALESCE(
        (
            SELECT ei.id FROM etat_inventaire ei
            WHERE LOWER(TRIM(ei.etat)) = CASE
                WHEN LOWER(TRIM(im.etat)) LIKE '%bon%'         THEN 'bon'
                WHEN LOWER(TRIM(im.etat)) LIKE '%usé%'         THEN 'usé'
                WHEN LOWER(TRIM(im.etat)) LIKE '%à remplacer%' THEN 'à remplacer'
                ELSE 'non spécifié'
            END
            LIMIT 1
        ),
        (SELECT id FROM etat_inventaire WHERE etat = 'non spécifié' LIMIT 1)
    )

FROM staging.inventaire_mobilier im   -- correction : inventaire_mobiliers → inventaire_mobilier

-- Dédoublonnage : garder la première occurrence par (lieu + type)
-- Le CSV contient un doublon : id 1006 apparaît deux fois
WHERE im.ctid IN (
    SELECT DISTINCT ON (LOWER(TRIM(lieu)), LOWER(TRIM(type))) ctid
    FROM staging.inventaire_mobilier
    ORDER BY LOWER(TRIM(lieu)), LOWER(TRIM(type)), id
)

ON CONFLICT (numero) DO NOTHING;


-- ============================================================
-- 5. SIGNALEMENT
--    Nettoyage dates, statuts, urgences ; liaison vers inventaire
-- ============================================================

INSERT INTO signalement (
    date,
    signale_par,
    objet,
    description,
    id_statut_signalement,
    id_urgence_signalement,
    id_inventaire
)
SELECT
    -- Date : format CH ou ISO
    CASE
        WHEN TRIM(date) ~ '^\d{2}\.\d{2}\.\d{4}$'
            THEN TO_DATE(TRIM(date), 'DD.MM.YYYY')
        WHEN TRIM(date) ~ '^\d{4}-\d{2}-\d{2}$'
            THEN TRIM(date)::DATE
        ELSE NULL
    END,

    NULLIF(TRIM(signale_par), ''),

    NULLIF(TRIM(objet), ''),

    NULLIF(TRIM(description), ''),

    -- Statut : NULL dans le CSV = non traité
    COALESCE(
        (
            SELECT ss.id FROM statut_signalement ss
            WHERE LOWER(TRIM(ss.statut)) = CASE
                WHEN NULLIF(TRIM(s.statut), '') IS NULL      THEN 'non traité'
                WHEN LOWER(TRIM(s.statut)) LIKE '%fait%'     THEN 'fait'
                WHEN LOWER(TRIM(s.statut)) LIKE '%en cours%' THEN 'en cours'
                WHEN LOWER(TRIM(s.statut)) LIKE '%attente%'  THEN 'en attente'
                ELSE 'non traité'
            END
            LIMIT 1
        ),
        (SELECT id FROM statut_signalement WHERE statut = 'non traité' LIMIT 1)
    ),

    -- Urgence : NULL dans le CSV = non spécifié
    COALESCE(
        (
            SELECT us.id FROM urgence_signalement us
            WHERE LOWER(TRIM(us.statut)) = CASE
                WHEN NULLIF(TRIM(s.urgence), '') IS NULL       THEN 'non spécifié'
                WHEN LOWER(TRIM(s.urgence)) LIKE '%urgent%'   THEN 'urgent'
                WHEN LOWER(TRIM(s.urgence)) LIKE '%normal%'   THEN 'normal'
                ELSE 'non spécifié'
            END
            LIMIT 1
        ),
        (SELECT id FROM urgence_signalement WHERE statut = 'non spécifié' LIMIT 1)
    ),

    -- Liaison inventaire : matching best-effort via le lieu dans l'objet du signalement
    -- Ex : "banc Rue du Casino" → cherche un inventaire dont lieux contient "Rue du Casino"
    (
        SELECT inv.id
        FROM inventaire inv
        WHERE LOWER(TRIM(s.objet)) LIKE '%' || LOWER(TRIM(inv.lieux)) || '%'
        ORDER BY inv.id
        LIMIT 1
    )

FROM staging.signalements s
WHERE NULLIF(TRIM(date), '') IS NOT NULL;
