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


		