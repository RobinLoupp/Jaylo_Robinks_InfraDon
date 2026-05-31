
-- 04 - Nettoyage des grandes tables



-- 1. MATERIELS

INSERT INTO materiels (type_materiels)
SELECT DISTINCT TRIM(valeur)
FROM staging.fournisseurs_contacts
CROSS JOIN LATERAL unnest(string_to_array(type_materiel, ',')) AS valeur
WHERE TRIM(valeur) <> ''
ON CONFLICT DO NOTHING;



-- 2. FOURNISSEURS

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

    CASE
        WHEN TRIM(telephone) ~ '^\+41\s?'
            THEN regexp_replace(TRIM(telephone), '^\+41\s?', '0')
        WHEN TRIM(telephone) ~ '^0[0-9]'
            THEN TRIM(telephone)
        ELSE NULL
    END,

    CASE
        WHEN TRIM(email) LIKE '%@%' THEN LOWER(TRIM(email))
        ELSE NULL
    END,

    NULLIF(TRIM(remarque), '')   

FROM staging.fournisseurs_contacts
ON CONFLICT (telephone) DO NOTHING;


-- 3. INTERVENTION

INSERT INTO type_intervention (type_intervention)
VALUES ('non spécifié')
ON CONFLICT DO NOTHING;

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
    CASE
        WHEN TRIM(date) ~ '^\d{2}\.\d{2}\.\d{4}$'
            THEN TO_DATE(TRIM(date), 'DD.MM.YYYY')
        WHEN TRIM(date) ~ '^\d{4}-\d{2}-\d{2}$'
            THEN TRIM(date)::DATE
        ELSE NULL
    END,

    NULLIF(TRIM(objet), ''),

    CASE
        WHEN TRIM(technicien) IN ('JM', 'Jean-Marc', 'jean-marc')
            THEN 'Jean-Marc Bonvin'
        WHEN TRIM(technicien) IN ('Pedro', 'P. Alves', 'Alves Pedro')
            THEN 'Pedro Alves'
        ELSE NULLIF(TRIM(technicien), '')
    END,

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

    CASE
        WHEN LOWER(TRIM(cout_materiel)) IN ('gratuit', 'garantie', 'offert', '0')
            THEN 0.00
        WHEN NULLIF(TRIM(cout_materiel), '') IS NULL
            THEN NULL
        WHEN regexp_replace(TRIM(cout_materiel), '[^0-9,\.]', '', 'g') ~ '^\d+[,\.]?\d*$'
            THEN replace(
                    regexp_replace(TRIM(cout_materiel), '[^0-9,\.]', '', 'g'),
                    ',', '.'
                 )::NUMERIC(10, 2)
        ELSE NULL
    END,

    NULLIF(TRIM(remarque), ''),

    COALESCE(
        (
            SELECT ti.id
            FROM type_intervention ti
            WHERE LOWER(TRIM(i.type_intervention)) LIKE '%' || ti.type_intervention || '%'
            LIMIT 1
        ),
        (SELECT id FROM type_intervention WHERE type_intervention = 'non spécifié' LIMIT 1)
    )

FROM staging.interventions i
WHERE NULLIF(TRIM(date), '') IS NOT NULL;


-- 4. INVENTAIRE
-- BUG CORRIGÉ : latitude/longitude sont NOT NULL dans le schéma
--   → WHERE exclut les 3 lignes sans coordonnées GPS
-- BUG CORRIGÉ : id_fournisseurs hardcodé → sous-requête sur premier fournisseur réel

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

    CASE
        WHEN TRIM(date_installation) ~ '^\d{2}\.\d{2}\.\d{4}$'
            THEN TO_DATE(TRIM(date_installation), 'DD.MM.YYYY')
        WHEN TRIM(date_installation) ~ '^\d{4}-\d{2}-\d{2}$'
            THEN TRIM(date_installation)::DATE
        WHEN TRIM(date_installation) ~ '^\d{4}$'
            THEN TO_DATE(TRIM(date_installation) || '-01-01', 'YYYY-MM-DD')
        ELSE NULL
    END,

    NULLIF(TRIM(remarques), ''),

    INITCAP(TRIM(lieu)),

    TRIM(latitude)::DECIMAL(10, 8),
    TRIM(longitude)::DECIMAL(11, 8),

    (SELECT id FROM fournisseurs ORDER BY id LIMIT 1),

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

FROM staging.inventaire_mobilier im

WHERE
    NULLIF(TRIM(latitude), '')  IS NOT NULL
    AND NULLIF(TRIM(longitude), '') IS NOT NULL
    AND TRIM(latitude)  !~ '^\d+\.\d{1,3}$'
    AND TRIM(longitude) !~ '^\d+\.\d{1,3}$'
    AND im.ctid IN (
        SELECT DISTINCT ON (LOWER(TRIM(lieu)), LOWER(TRIM(type))) ctid
        FROM staging.inventaire_mobilier
        ORDER BY LOWER(TRIM(lieu)), LOWER(TRIM(type)), id
    )

ON CONFLICT (numero) DO NOTHING;


-- 5. SIGNALEMENT

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

    COALESCE(
        (
            SELECT us.id FROM urgence_signalement us
            WHERE LOWER(TRIM(us.statut)) = CASE
                WHEN NULLIF(TRIM(s.urgence), '') IS NULL     THEN 'non spécifié'
                WHEN LOWER(TRIM(s.urgence)) LIKE '%urgent%' THEN 'urgent'
                WHEN LOWER(TRIM(s.urgence)) LIKE '%normal%' THEN 'normal'
                ELSE 'non spécifié'
            END
            LIMIT 1
        ),
        (SELECT id FROM urgence_signalement WHERE statut = 'non spécifié' LIMIT 1)
    ),

    (
        SELECT inv.id
        FROM inventaire inv
        WHERE LOWER(TRIM(s.objet)) LIKE '%' || LOWER(TRIM(inv.lieux)) || '%'
        ORDER BY inv.id
        LIMIT 1
    )

FROM staging.signalements s
WHERE
    NULLIF(TRIM(date), '') IS NOT NULL
    AND EXISTS (
        SELECT 1
        FROM inventaire inv
        WHERE LOWER(TRIM(s.objet)) LIKE '%' || LOWER(TRIM(inv.lieux)) || '%'
    );