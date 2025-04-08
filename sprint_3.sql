
CREATE TABLE credit_card 
	(id VARCHAR(15) , 
	iban VARCHAR(40),
	pan VARCHAR(25), 
	pin VARCHAR(4), 
	cvv VARCHAR(3),
	expiring_date VARCHAR(20),
	PRIMARY KEY (id));

#insertem les dades del fitxer SQL. 

ALTER TABLE transaction
ADD CONSTRAINT FK_ccid
FOREIGN KEY(credit_card_id) REFERENCES credit_card(id);


UPDATE  transactions.credit_card
SET iban = 'R323456312213576817699999' 
WHERE id ="CcU-2938";

SELECT id, iban
FROM  transactions.credit_card
WHERE id ="CcU-2938";

INSERT INTO company(id) VALUES ("b-9999");
INSERT INTO credit_card(ID) VALUES ("CcU-9999");

INSERT INTO transaction (
		id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD","CcU-9999","b-9999","9999","829.999","-117.999","111.11","0");

ALTER TABLE credit_card
DROP COLUMN pan;

SHOW COLUMNS
FROM credit_card;

## N2-Exercici 1
DELETE FROM transaction
WHERE ID = "02C6201E-D90A-1859-B4EE-88D2986D3B02";


# Nivell 2 Ex 2
CREATE VIEW VistaMarketing AS 
SELECT company_name, phone, country, AVG(amount) as mitjana
FROM transaction
JOIN company
ON transaction.company_id = company.id
WHERE declined <>0
GROUP BY company_id
ORDER BY mitjana DESC;

select * 
FROM VistaMarketing
WHERE country ="Germany";

#N3 Ex1 (importem estructura i contingut taula users)	

ALTER TABLE transaction
ADD CONSTRAINT FK_UserID
FOREIGN KEY(user_id) REFERENCES user(id);

SELECT user_id
FROM transaction
WHERE user_id NOT IN (SELECT id FROM user);


INSERT INTO user(id) VALUES ("9999");
#NIVELL 3 PREGUNTA 1 (MODIFICAR TAULES): 

RENAME TABLE user to data_user;

ALTER TABLE transaction
ADD CONSTRAINT FK_userID
FOREIGN KEY(user_id) REFERENCES user(id);

RENAME TABLE user to data_user;

ALTER TABLE data_user
DROP COLUMN birth_date;

ALTER TABLE company
DROP COLUMN website;
#A la taula credit_card, la longitud de l’id és de 20 enlloc de 15, 
#l’Iban és de 50, el cvv és INT i a més hi ha una columna amb la data actual:fecha_actual DATE.

ALTER TABLE credit_card
MODIFY ID VARCHAR(20),
MODIFY Iban VARCHAR(50),
MODIFY CVV INT,
ADD fecha_actual DATE;

CREATE VIEW InformeTecnico AS
SELECT transaction.id AS ID_transaccio, user.name AS nom_usuari, user.surname AS cognom_usuari, iban, company_name
FROM transaction
JOIN user
ON transaction.user_id = user.id
JOIN company
ON transaction.company_id = company.id
JOIN credit_card
ON transaction.credit_card_id = credit_card.id;

SELECT* 
from informeTecnico
ORDER BY ID_transaccio DESC;

SHOW INDEXES FROM  transaction;

