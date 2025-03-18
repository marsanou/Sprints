#NIVELL 1 EXERCICI 2:
#Llistat de paisos q estan fent compres:
SELECT DISTINCT country FROM transaction
JOIN company
ON transaction.company_id = company.id
WHERE declined =0;

#Des de quants països es realitzen les compres.
SELECT COUNT(DISTINCT country) AS num_paisos
FROM transaction
JOIN company
ON transaction.company_id = company.id
WHERE declined =0;

#Identifica la companyia amb la mitjana més gran de vendes.
SELECT company_name AS empresa, AVG(amount) as mitjana
FROM transaction
JOIN company
ON transaction.company_id = company.id
WHERE declined = 0
GROUP BY company_id
ORDER BY mitjana DESC
LIMIT 1;


#NIVELL 1 EX 3

#Mostra totes les transaccions realitzades per empreses d'Alemanya. (sense join)
SELECT * 
FROM transaction
WHERE company_id IN(
		SELECT id
        FROM company
        WHERE(country="Germany")) AND declined =0;

#Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT company_name
FROM company
WHERE company.id IN
	(SELECT DISTINCT company_id
    FROM transaction
    WHERE declined =0 and amount >
		(SELECT AVG(amount) AS mitjana
		FROM transaction
        WHERE declined =0));
        

#Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT id, company_name FROM company
WHERE id NOT IN(
	SELECT company_id
    FROM transaction);
    
#ho comprovo amb una join...
SELECT company.id
FROM company
LEFT JOIN transaction
ON transaction.company_id = company.id
WHERE company_id IS NULL;

#NIVELL 2 EXERCICI 1
#Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 

SELECT  DATE(timestamp) AS dia, SUM(amount) AS vendes
FROM transaction
GROUP BY dia
ORDER BY vendes DESC
limit 5;

#NIVELL 2 EXERCICI 2
#Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT country, AVG(amount) AS mitja
FROM company
JOIN transaction
ON transaction.company_id = company.id
WHERE declined =0
GROUP BY country
ORDER BY mitja DESC;

#NIVELL 2 EXERCICI 3 

#amb JOIN 
SELECT *
FROM transaction
JOIN company
ON transaction.company_id = company.id
WHERE country = (
			SELECT country
			FROM company
			WHERE (company_name = "Non Institute"));

# Nivell 2 ex 3 sense JOIN
SELECT * 
FROM transaction
WHERE company_id IN(
	SELECT id
	FROM company
	WHERE country IN 
			(
			SELECT country
			FROM company
			WHERE (company_name = "Non Institute")));
#NIVELL 3Exercici 1
#Presenta nom, telf, país, data i amount, empreses q van realitzar transaccions amb un valor comprès entre 100 i 200 euros
# i en alguna d'aquestes dates: 29/04/2021, 20/07/2021 i 13/03/2022. Ordena els resultats de major a menor quantitat.		
SELECT company_name, phone, date(timestamp), amount
FROM company
JOIN transaction
ON transaction.company_id = company.id
WHERE DATE(timestamp) in ("2021-04-29", "2021-07-20", "2022-03-13")
AND amount BETWEEN 100 AND 200
ORDER BY amount DESC;

#NIVELL 2 EX 3
#quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent
# i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.
SELECT company_name, COUNT(*) AS num_tr,
CASE 
	WHEN COUNT(*)>4 THEN "SÍ"
    ELSE "NO"
END AS superior_a_4
FROM transaction
JOIN company
ON transaction.company_id = company.id 
WHERE declined =0
GROUP BY company_id;