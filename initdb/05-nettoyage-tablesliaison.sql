
-- 07 Nettoyage des tables de liaison

-- 1 FOURNISSEURS_MATERIELS

INSERT INTO fournisseurs_materiels (id_fournisseurs, id_materiels)
SELECT DISTINCT
    f.id,
    m.id
FROM staging.fournisseurs_contacts src


CROSS JOIN LATERAL (
    SELECT TRIM(valeur) AS type_mat
    FROM unnest(string_to_array(src.type_materiel, ',')) AS valeur
    WHERE TRIM(valeur) <> ''
) AS mat_eclate


JOIN fournisseurs f
    ON LOWER(TRIM(f.entreprises)) = LOWER(TRIM(src.entreprise))


JOIN materiels m
    ON LOWER(TRIM(m.type_materiels)) LIKE '%' || LOWER(mat_eclate.type_mat) || '%'
    OR LOWER(mat_eclate.type_mat) LIKE '%' || LOWER(TRIM(m.type_materiels)) || '%'

ON CONFLICT DO NOTHING;


-- 2. SIGNALEMENT_INTERVENTION

INSERT INTO signalement_intervention (id_signalement, id_intervention)
SELECT DISTINCT
    s.id AS id_signalement,
    i.id AS id_intervention
FROM signalement s
JOIN intervention i
    ON (

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

        AND (
            (LOWER(s.objet) LIKE '%banc%'       AND LOWER(i.objet) LIKE '%banc%')
         OR (LOWER(s.objet) LIKE '%lampadaire%' AND LOWER(i.objet) LIKE '%lampadaire%')
         OR (LOWER(s.objet) LIKE '%fontaine%'   AND LOWER(i.objet) LIKE '%fontaine%')
         OR (LOWER(s.objet) LIKE '%poubelle%'   AND LOWER(i.objet) LIKE '%poubelle%')
         OR (LOWER(s.objet) LIKE '%corbeille%'  AND LOWER(i.objet) LIKE '%poubelle%')
         OR (LOWER(s.objet) LIKE '%borne%'      AND LOWER(i.objet) LIKE '%borne%')
         OR (LOWER(s.objet) LIKE '%panneau%'    AND LOWER(i.objet) LIKE '%panneau%')
        )

        AND i.date >= s.date
        AND i.date <= s.date + INTERVAL '90 days'
    )
ON CONFLICT DO NOTHING;