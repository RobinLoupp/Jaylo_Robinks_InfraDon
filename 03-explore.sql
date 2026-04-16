-- Types de mobilier
SELECT type, COUNT(*) FROM staging.inventaire_mobilier GROUP BY type ORDER BY 2 DESC;

-- Matériaux
SELECT materiau, COUNT(*) FROM staging.inventaire_mobilier GROUP BY materiau;

-- Formats de date
SELECT date_installation, COUNT(*)
FROM staging.inventaire_mobilier
GROUP BY date_installation ORDER BY 2 DESC LIMIT 20;

-- Coûts
SELECT cout_materiel, COUNT(*) FROM staging.interventions GROUP BY cout_materiel ORDER BY 2 DESC;

-- Durées
SELECT duree, COUNT(*) FROM staging.interventions GROUP BY duree;

-- Techniciens
SELECT technicien, COUNT(*) FROM staging.interventions GROUP BY technicien ORDER BY 2 DESC;

-- Doublons potentiels (même lieu + type)
SELECT lieu, type, COUNT(*) FROM staging.inventaire_mobilier
GROUP BY lieu, type HAVING COUNT(*) > 1;