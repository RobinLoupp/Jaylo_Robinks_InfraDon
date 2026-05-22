-- Active: 1772185782000@@127.0.0.1@5432@service_technique
-- Active: 1776260001431@@localhost@5432
-- Nettoyage table type_... les petites tables

-- Thibault: Manque INSERT pour réellement insérer dans les tables finales
INSERT INTO type_intervention (type_intervention)
SELECT * FROM (
SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(type_intervention)) LIKE '%peinture%' THEN 'peinture'
        WHEN LOWER(TRIM(type_intervention)) LIKE '%remplacement%' THEN 'remplacement'
        WHEN LOWER(TRIM(type_intervention)) LIKE '%nettoyage%' THEN 'nettoyage'
        WHEN LOWER(TRIM(type_intervention)) LIKE '%réparation%' THEN 'réparation'
        WHEN LOWER(TRIM(type_intervention)) LIKE '%remplacement%' THEN 'remplacement'
        WHEN LOWER(TRIM(type_intervention)) LIKE '%remise en service%' THEN 'remise en service'
        WHEN LOWER(TRIM(type_intervention)) LIKE '%hivernage%' THEN 'hivernage'
        WHEN LOWER(TRIM(type_intervention)) LIKE '%redressage%' THEN 'redressage'
        WHEN LOWER(TRIM(type_intervention)) LIKE '%détartrage%' THEN 'détartrage'
        ELSE NULL
    END AS type_intervention_corrigee
FROM staging.interventions
) 
WHERE
    type_intervention_corrigee IS NOT NULL; 


INSERT INTO statut_signalement (statut)
SELECT * FROM (    
SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(statut)) LIKE '%fait%' THEN 'fait'
        WHEN LOWER(TRIM(statut)) LIKE '%en attente %' THEN 'en attente'
        WHEN LOWER(TRIM(statut)) LIKE '%en cours%' THEN 'en cours'
        WHEN LOWER(TRIM(statut)) IS NULL THEN 'non traité' 
        ELSE NULL
    END AS statut_signalement_corrigee
FROM staging.signalements
)
WHERE
    statut_signalement_corrigee IS NOT NULL;


INSERT INTO urgence_signalement (statut)
SELECT * FROM (    
SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(urgence)) LIKE '%normal%' THEN 'normal'
        WHEN LOWER(TRIM(urgence)) LIKE '%urgent%' THEN 'urgent'
        ELSE 'non spécifié'
    END AS urgence_signalement_corrigee
FROM staging.signalements
)
WHERE
    urgence_signalement_corrigee IS NOT NULL;

-- Thibault: Cette table empêche les objets inventaire d'être dans d'autres lieux que ceux-ci
/*SELECT DISTINCT
CASE
        WHEN LOWER(TRIM(lieux_inventaire)) IN (
            'avenue de la gare',
            'avenuede la gare',
            'av dela gare'
        ) THEN 'avenue de la gare'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'place de la gare' THEN 'place de la gare'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'rue du lac' THEN 'rue du lac'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'rue du casino' THEN 'rue du casino'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'heig-vd' THEN 'heig-vd'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'place pestalozzi' THEN 'place pestalozzi'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'rue du milieu' THEN 'rue du milieu'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'y-parc' THEN 'y-parc'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'chemin de maillefer' THEN 'chemin de maillefer'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'rue haldimand' THEN 'rue haldimand'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'rue de la maison rouge' THEN 'rue de la maison rouge'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'route de lausanne' THEN 'route de lausanne'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'centre sportif' THEN 'centre sportif'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'quai de nogent' THEN 'quai de nogent'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'avenue des sports' THEN 'avenue des sports'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'rue de la plaine' THEN 'rue de la plaine'
        WHEN LOWER(TRIM(lieux_inventaire)) IN (
            'rue des pêcheurs',
            'rue des pecheurs'
        ) THEN 'rue des pêcheurs'
        WHEN LOWER(TRIM(lieux_inventaire)) IN (
            'passage de lhtel de ville',
            'passage de l''hotel de ville',
            'passage l''hôtel de ville'
        ) THEN 'passage de l''hôtel de ville'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'parc des rives' THEN 'parc des rives'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'plage dyverdon' THEN 'plage d’yverdon'
        WHEN LOWER(TRIM(lieux_inventaire)) = 'avenue des bains' THEN 'avenue des bains'
        ELSE LOWER(TRIM(lieux_inventaire))
    END
FROM staging.inventaire_mobilier
WHERE
    lieux_inventaire IS NOT NULL
    AND TRIM(lieux_inventaire) <> ''; */
--pas sur

--IN c'est mieux que like?
-- Thibault: IN pour vérifier qu'un élément est dans un liste, LIKE pour voir si un élément égale, commence, finit par le mot


INSERT INTO etat_inventaire (etat)
SELECT * FROM ( 
SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(etat)) LIKE '%bon%' THEN 'bon'
        WHEN LOWER(TRIM(etat)) LIKE '%usé %' THEN 'usé'
        WHEN LOWER(TRIM(etat)) LIKE '%à remplacer%' THEN 'à remplacer'
        ELSE 'non spécifié'
    END AS etat_inventaire_corrigee
FROM staging.inventaire_mobilier
)
WHERE
    etat_inventaire_corrigee IS NOT NULL;


INSERT INTO type_inventaire (type)
SELECT * FROM ( 
SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(type)) LIKE '%banc%' THEN 'banc'
        WHEN LOWER(TRIM(type)) LIKE '%banc public %' THEN 'banc'
        WHEN LOWER(TRIM(type)) LIKE '%lampadaire%' THEN 'lampadaire'
        WHEN LOWER(TRIM(type)) LIKE '%lampadaire sodium%' THEN 'lampadaire'
        WHEN LOWER(TRIM(type)) LIKE '%lampadaire LED%' THEN 'lampadaire'
        WHEN LOWER(TRIM(type)) LIKE '%corbeille%' THEN 'poubelle'
        WHEN LOWER(TRIM(type)) LIKE '%poubelle%' THEN 'poubelle'
        WHEN LOWER(TRIM(type)) LIKE '%poubelle tri%' THEN 'poubelle tri'
        WHEN LOWER(TRIM(type)) LIKE '%fontaine%' THEN 'fontaine'
        WHEN LOWER(TRIM(type)) LIKE '%fontaine publique%' THEN 'fontaine'
        WHEN LOWER(TRIM(type)) LIKE '%borne EV%' THEN 'borne recharge'
        WHEN LOWER(TRIM(type)) LIKE '%borne recharge%' THEN 'borne recharge'
        WHEN LOWER(TRIM(type)) LIKE '%borne recharge EV%' THEN 'borne recharge'
        -- on c fait chier ou pas ? estce que borne comprends toutes les bornes de base? -- Thibault: oui avec les %
        WHEN LOWER(TRIM(type)) LIKE '%panneau%' THEN 'panneau'
        WHEN LOWER(TRIM(type)) LIKE '%panneau info%' THEN 'panneau'
        WHEN LOWER(TRIM(type)) LIKE '%panneau affichage%' THEN 'panneau'
        ELSE 'non spécifié'
    END AS type_inventaire_corrigee
FROM staging.inventaire_mobilier
)
WHERE
    type_inventaire_corrigee IS NOT NULL;

INSERT INTO materiaux_inventaire (type)
SELECT * FROM ( 
SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(materiau)) LIKE '%bois%' THEN 'bois'
        WHEN LOWER(TRIM(materiau)) LIKE '%métal %' THEN 'métal'
        WHEN LOWER(TRIM(materiau)) LIKE '%metal%' THEN 'métal'
        WHEN LOWER(TRIM(materiau)) LIKE '%pierre%' THEN 'pierre'
        WHEN LOWER(TRIM(materiau)) LIKE '%béton%' THEN 'béton'
        WHEN LOWER(TRIM(materiau)) LIKE '%beton%' THEN 'béton'
        WHEN LOWER(TRIM(materiau)) LIKE '%LED%' THEN 'LED'
        WHEN LOWER(TRIM(materiau)) LIKE '%sodium%' THEN 'sodium'
    END AS materiaux_inventaire_corrigee
FROM staging.inventaire_mobilier
)
WHERE
    materiaux_inventaire_corrigee IS NOT NULL;

