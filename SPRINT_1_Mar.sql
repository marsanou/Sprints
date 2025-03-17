#NIVELL 1 EXERCICI 2:
#Llistat de paisos q estan fent compres:
SELECT DISTINCT country FROM transaction
JOIN company
ON transaction.company_id = company.id;

#Des de quants països es realitzen les compres.
SELECT COUNT(DISTINCT country) AS num_paisos
FROM transaction
JOIN company
ON transaction.company_id = company.id;

#Identifica la companyia amb la mitjana més gran de vendes.
SELECT company_name AS empresa, AVG(amount) as mitjana
FROM transaction
JOIN company
ON transaction.company_id = company.id
GROUP BY company_id
ORDER BY mitjana DESC
LIMIT 1;


#NIVELL 1 EX 3

#Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT * 
FROM transaction
JOIN company
ON transaction.company_id = company.id
WHERE (country = "Germany");

#Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT company_name
FROM company
WHERE company.id IN
	(SELECT DISTINCT company_id
    FROM transaction
    WHERE amount >
		(SELECT AVG(amount) AS mitjana
		FROM transaction));
        

#Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT id FROM company
WHERE NOT EXISTS (
	SELECT 1
    FROM transaction
    WHERE transaction.company_id = company.id);
    
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
GROUP BY country
ORDER BY mitja DESC;

#NIVELL 3 EXERCICI 3 

#amb JOIN 
SELECT *
FROM transaction
JOIN company
ON transaction.company_id = company.id
WHERE country = (
			SELECT country
			FROM company
			WHERE (company_name = "Non Institute"));

# Nivell 3 ex 3 sense JOIN
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
            
