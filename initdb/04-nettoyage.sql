-- Nettoyage table type_... les petites tables

SELECT DISTINCT
    CASE 
        WHEN LOWER(TRIM(type_intervention))LIKE '%peinture%' THEN 'peinture'
        WHEN LOWER(TRIM(type_intervention))LIKE '%remplacement%' THEN 'remplacement'
        WHEN LOWER(TRIM(type_intervention))LIKE '%nettoyage%' THEN 'nettoyage'
        WHEN LOWER(TRIM(type_intervention))LIKE '%réparation%' THEN 'réparation'
        WHEN LOWER(TRIM(type_intervention))LIKE '%remplacement%' THEN 'remplacement' 
        WHEN LOWER(TRIM(type_intervention))LIKE '%remise en service%' THEN 'remise en service'
        WHEN LOWER(TRIM(type_intervention))LIKE '%hivernage%' THEN 'hivernage'
        WHEN LOWER(TRIM(type_intervention))LIKE '%redressage%' THEN 'redressage' 
        WHEN LOWER(TRIM(type_intervention))LIKE '%détartrage%' THEN 'détartrage' 

        ELSE NULL
    END
    FROM staging.interventions
    WHERE type_intervention IS NOT NULL;


SELECT DISTINCT
    CASE 
        WHEN LOWER(TRIM(statut_signalement))LIKE '%fait%' THEN 'fait'
        WHEN LOWER(TRIM(statut_signalement))LIKE '%en attente %' THEN 'en attente'
        WHEN LOWER(TRIM(statut_signalement))LIKE '%en cours%' THEN 'en cours'
        WHEN LOWER(TRIM(statut_signalement))LIKE '%NULL%' THEN 'non traité'

        ELSE NULL
    END
    FROM staging.signalements
    WHERE type_intervention IS NOT NULL;