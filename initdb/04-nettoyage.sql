-- Nettoyage table type_... les petites tables

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
    END
FROM staging.interventions
WHERE
    type_intervention IS NOT NULL;

SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(statut_signalement)) LIKE '%fait%' THEN 'fait'
        WHEN LOWER(TRIM(statut_signalement)) LIKE '%en attente %' THEN 'en attente'
        WHEN LOWER(TRIM(statut_signalement)) LIKE '%en cours%' THEN 'en cours'
        WHEN LOWER(TRIM(statut_signalement)) LIKE '%NULL%' THEN 'non traité'
        ELSE NULL
    END
FROM staging.signalements
WHERE
    statut_signalement IS NOT NULL;

SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(urgence_signalement)) LIKE '%normal%' THEN 'normal'
        WHEN LOWER(TRIM(urgence_signalement)) LIKE '%urgent%' THEN 'urgent'
        WHEN LOWER(TRIM(urgence_signalement)) LIKE '%NULL%' THEN 'non spécifié'
        ELSE NULL
    END
FROM staging.signalements
WHERE
    urgence_signalement IS NOT NULL;

SELECT DISTINCT
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
    AND TRIM(lieux_inventaire) <> '';
--pas sur

--IN c'est mieux que like?

SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(etat_inventaire)) LIKE '%bon%' THEN 'bon'
        WHEN LOWER(TRIM(etat_inventaire)) LIKE '%usé %' THEN 'usé'
        WHEN LOWER(TRIM(etat_inventaire)) LIKE '%à remplacer%' THEN 'à remplacer'
        WHEN LOWER(TRIM(etat_inventaire)) LIKE '%NULL%' THEN 'non traité' --on laisse ou pas ?
        ELSE NULL
    END
FROM staging.inventaire_mobilier
WHERE
    etat_inventaire IS NOT NULL;

SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%banc%' THEN 'banc'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%banc public %' THEN 'banc'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%lampadaire%' THEN 'lampadaire'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%lampadaire sodium%' THEN 'lampadaire'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%lampadaire LED%' THEN 'lampadaire'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%corbeille%' THEN 'poubelle'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%poubelle%' THEN 'poubelle'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%poubelle tri%' THEN 'poubelle tri'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%fontaine%' THEN 'fontaine'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%fontaine publique%' THEN 'fontaine'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%borne EV%' THEN 'borne recharge'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%borne recharge%' THEN 'borne recharge'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%borne recharge EV%' THEN 'borne recharge'
        -- on c fait chier ou pas ? estce que borne comprends toutes les bornes de base?
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%panneau%' THEN 'panneau'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%panneau info%' THEN 'panneau'
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%panneau affichage%' THEN 'panneau'
        ELSE NULL
    END
FROM staging.inventaire_mobilier
WHERE
    type_inventaire IS NOT NULL;

SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(materiaux_inventaire)) LIKE '%bois%' THEN 'bois'
        WHEN LOWER(TRIM(materiaux_inventaire)) LIKE '%métal %' THEN 'métal'
        WHEN LOWER(TRIM(materiaux_inventaire)) LIKE '%metal%' THEN 'métal'
        WHEN LOWER(TRIM(materiaux_inventaire)) LIKE '%pierre%' THEN 'pierre'
        WHEN LOWER(TRIM(materiaux_inventaire)) LIKE '%béton%' THEN 'béton'
        WHEN LOWER(TRIM(materiaux_inventaire)) LIKE '%beton%' THEN 'béton'
        WHEN LOWER(TRIM(materiaux_inventaire)) LIKE '%LED%' THEN 'LED'
        WHEN LOWER(TRIM(materiaux_inventaire)) LIKE '%sodium%' THEN 'sodium'
        -- quand on a des champs vide comment on fait ?
    END -- end as ? pourquoi il faut ?
FROM staging.inventaire_mobilier
WHERE
    materiaux_inventaire IS NOT NULL;


    SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(materiels_fournisseurs)) LIKE '%%' THEN ''
        WHEN LOWER(TRIM(materiels_fournisseurs)) LIKE '%%' THEN ''
        WHEN LOWER(TRIM(materiels_fournisseurs)) LIKE '%%' THEN ' '
        ELSE NULL
    END
FROM staging.fournisseurs_contacts
WHERE
    materiels_fournisseurs IS NOT NULL;

    -- ON SAIT PAS QUOI FAIRE ICI...