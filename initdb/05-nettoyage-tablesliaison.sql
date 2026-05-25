-- ============================================================
-- 07 - Nettoyage des tables de liaison
-- Service technique d'Yverdon-les-Bains
-- ============================================================
-- 1. FOURNISSEURS_MATERIELS
-- La colonne type_materiel du CSV contient plusieurs valeurs
-- séparées par virgule : "bancs, poubelles", "lampadaires, éclairage LED"
-- On éclate chaque valeur et on joint sur les deux tables finales.
-- ============================================================

INSERT INTO fournisseurs_materiels (id_fournisseurs, id_materiels)
SELECT DISTINCT
    f.id,
    m.id
FROM staging.fournisseurs_contacts src

-- Éclater la colonne multi-valeurs en lignes individuelles
CROSS JOIN LATERAL (
    SELECT TRIM(valeur) AS type_mat
    FROM unnest(string_to_array(src.type_materiel, ',')) AS valeur
    WHERE TRIM(valeur) <> ''
) AS mat_eclate

-- Joindre sur le fournisseur nettoyé
JOIN fournisseurs f
    ON LOWER(TRIM(f.entreprises)) = LOWER(TRIM(src.entreprise))

-- Joindre sur le matériel nettoyé (matching souple)
JOIN materiels m
    ON LOWER(TRIM(m.type_materiels)) LIKE '%' || LOWER(mat_eclate.type_mat) || '%'
    OR LOWER(mat_eclate.type_mat) LIKE '%' || LOWER(TRIM(m.type_materiels)) || '%'

ON CONFLICT DO NOTHING;


-- ============================================================
-- 2. SIGNALEMENT_INTERVENTION

-- ============================================================

INSERT INTO signalement_intervention (id_signalement, id_intervention)
SELECT DISTINCT
    s.id AS id_signalement,
    i.id AS id_intervention
FROM signalement s
JOIN intervention i
    ON (
        -- Condition 1 : même lieu mentionné dans les deux objets
        -- On extrait les mots-clés de lieu communs (>= 3 caractères)
        EXISTS (
            SELECT 1
            FROM unnest(
                string_to_array(LOWER(s.objet), ' ')
            ) AS mot_s(mot)
            WHERE LENGTH(mot_s.mot) >= 4
              AND LOWER(i.objet) LIKE '%' || mot_s.mot || '%'
              -- Exclure les mots trop génériques
              AND mot_s.mot NOT IN (
                  'le', 'la', 'les', 'de', 'du', 'des', 'un', 'une',
                  'près', 'devant', 'public', 'publique', 'près', 'banc',
                  'lampadaire', 'fontaine', 'borne', 'panneau', 'poubelle'
              )
        )
        -- Condition 2 : même type de mobilier
        AND (
            (LOWER(s.objet) LIKE '%banc%'       AND LOWER(i.objet) LIKE '%banc%')
         OR (LOWER(s.objet) LIKE '%lampadaire%' AND LOWER(i.objet) LIKE '%lampadaire%')
         OR (LOWER(s.objet) LIKE '%fontaine%'   AND LOWER(i.objet) LIKE '%fontaine%')
         OR (LOWER(s.objet) LIKE '%poubelle%'   AND LOWER(i.objet) LIKE '%poubelle%')
         OR (LOWER(s.objet) LIKE '%corbeille%'  AND LOWER(i.objet) LIKE '%poubelle%')
         OR (LOWER(s.objet) LIKE '%borne%'      AND LOWER(i.objet) LIKE '%borne%')
         OR (LOWER(s.objet) LIKE '%panneau%'    AND LOWER(i.objet) LIKE '%panneau%')
        )
        -- Condition 3 : intervention dans les 90 jours qui suivent le signalement
        AND i.date >= s.date
        AND i.date <= s.date + INTERVAL '90 days'
    )
ON CONFLICT DO NOTHING;