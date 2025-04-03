# NIVELL 1 PREPARACIÓ DE LA BBDD: 
CREATE DATABASE transactions;
CREATE TABLE companies 
	(company_id VARCHAR(45),
    company_name VARCHAR(45),
    phone VARCHAR(45),
    email VARCHAR(45),
    country VARCHAR(45),
    website VARCHAR(45));

CREATE TABLE products (
	id VARCHAR(45),
    product_name VARCHAR(45),
    price VARCHAR(45),
    colour VARCHAR(45),
    weight VARCHAR(45),
    warehouse_id VARCHAR(45));
    
CREATE TABLE transactions (
	id VARCHAR(45),
    card_id VARCHAR(45),
    business_id VARCHAR(45),
    timestamp VARCHAR(45),
    amount VARCHAR(45),
    declined VARCHAR(45),
    product_ids VARCHAR(45),
    user_id VARCHAR(45),
    lat VARCHAR(45),
    longitude VARCHAR(45));

CREATE TABLE users (
	id VARCHAR(45),
    name VARCHAR(45),
    surname VARCHAR(45),
    phone VARCHAR(45),
    email VARCHAR(45),
    birth_date VARCHAR(45),
    country VARCHAR(45),
    city VARCHAR(45),
    postal_code VARCHAR(45),
    address VARCHAR(100));
    
CREATE TABLE credit_cards (
	id VARCHAR(45),
    user_id VARCHAR(45),
    iban VARCHAR(45),
    pan VARCHAR(45),
    pin VARCHAR(45),
    cvv VARCHAR(45),
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date VARCHAR(45));

#busco la carpeta on puc desar els arxius per carregar-los
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA
INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\companies.csv'
INTO TABLE companies 
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

LOAD DATA
INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\credit_cards.csv'
INTO TABLE credit_cards 
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

LOAD DATA
INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\products.csv'
INTO TABLE products 
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

LOAD DATA
INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions.csv'
INTO TABLE transactions 
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

LOAD DATA
INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_ca.csv'
INTO TABLE users 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA
INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_UK.csv'
INTO TABLE users 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA
INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_usa.csv'
INTO TABLE users 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

#establim FK  I RELACIONS ENTRE TAULES:
ALTER TABLE companies
ADD CONSTRAINT PK_company PRIMARY KEY (company_id);

ALTER TABLE Products
ADD CONSTRAINT PK_prod PRIMARY KEY (id);

ALTER TABLE users
ADD CONSTRAINT PK_user PRIMARY KEY (id);

ALTER TABLE transactions
ADD CONSTRAINT PK_trans PRIMARY KEY(id);

ALTER TABLE credit_cards
ADD CONSTRAINT PK_ccard PRIMARY KEY(id);

#intentem relacionar amb productes, però ens dona error. 
ALTER TABLE transactions
ADD CONSTRAINT FK_prod FOREIGN KEY(product_ids) REFERENCES Products(id);

#veiem que a transactions hi ha registres amb més d'un product ID
SELECT product_ids
FROM transactions
WHERE product_ids NOT IN (SELECT id FROM products);


# CREAR TAULA DE DETALLS DE TRANSACCIONS
CREATE TABLE transaction_details (
    detail_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    transact_id VARCHAR(45),
    product_ids VARCHAR(45)
);

# I UN COP CREADA  HI AFEGIM EL CONTINGUT DE LA TAULA TRANSACCIONS. 
INSERT INTO transaction_details (transact_id, product_ids)
SELECT id, part
FROM (
    WITH RECURSIVE split_cte AS (
        SELECT 
            id,
            SUBSTRING_INDEX(product_ids, ',', 1) AS part,
            SUBSTRING(product_ids, LENGTH(SUBSTRING_INDEX(product_ids, ',', 1)) + 2) AS rest
        FROM transactions
        UNION ALL
        SELECT 
            id,
            SUBSTRING_INDEX(rest, ',', 1),
            SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
        FROM split_cte
        WHERE rest != ''
    )
    SELECT id, part
    FROM split_cte
) AS temp_results;

SELECT transactions.id, transactions.product_ids, transaction_details.product_ids
FROM transactions
JOIN transaction_details
ON transactions.id = transaction_details.transact_id
WHERE length(transactions.product_ids)>3
ORDER BY id;

#ESTABLIM RELACIONS ENTRE LES TAULES: 

ALTER TABLE transactions
ADD CONSTRAINT FK_company FOREIGN KEY(business_id) REFERENCES companies(company_id);

ALTER TABLE transactions
ADD CONSTRAINT FK_CC FOREIGN KEY(card_id) REFERENCES Credit_Cards(id);

ALTER TABLE transactions
ADD CONSTRAINT FK_user FOREIGN KEY(user_id) REFERENCES users(id);

ALTER TABLE transaction_details
ADD CONSTRAINT FK_transact FOREIGN KEY(transact_id) REFERENCES transactions(id);

#la FK de transaction_details dona error,  hi ha numeros amb espais en blanc. 
UPDATE transaction_details
SET product_ids = TRIM(product_ids);

ALTER TABLE transaction_details
ADD CONSTRAINT FK_product FOREIGN KEY(product_ids) REFERENCES products(id);

#NIVELL 1 EXERCICI 1
#Mostra tots els usuaris amb més de 30 transaccions.

CREATE VIEW Transact AS(
SELECT * 
FROM transactions
WHERE declined = 0);

SELECT COUNT(*)
FROM transactions;

SELECT COUNT(*)
FROM NotDeclined;

SELECT user_id, users.name, users.surname, COUNT(transact.ID) as num_trans
FROM transact
JOIN users 
ON transact.user_id = users.id
GROUP BY user_id
HAVING num_trans > 30
;
#NIVELL 1 EXERCICI 2
#mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd

SELECT iban, ROUND(AVg(amount),2) AS mitja_per_tarja
FROM credit_cards
JOIN transact
ON transact.card_id = credit_cards.id
WHERE transact.business_id = (SELECT company_id
	FROM companies
	WHERE company_name = "Donec Ltd")
GROUP BY iban;

#COMPROVEM QUE LA QUANTITAT NOT DECLINED COINCIDEIX
#(la persona que em corregeix no havia filtrat per declined).
SELECT company_id, amount, DECLINED
	FROM companies
    JOIN transactions
    ON transactions.business_id = companies.company_id
	WHERE company_name = "Donec Ltd";

#NIVELL 2 EXERCICI 1

CREATE TABLE Estat_Targetes (
    targeta VARCHAR(45),
    estat VARCHAR(20)
);

INSERT INTO Estat_Targetes (targeta, estat)
SELECT 
    card_id,
    CASE 
        WHEN SUM(declined) = 3 THEN 'Bloquejada'
        ELSE 'Activa'
    END AS estat
FROM (
    SELECT 
        card_id,
        declined,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS fila
    FROM transactions
) ultimes_transact
WHERE fila <= 3
GROUP BY card_id;
    
# comptem les targetes actives:
SELECT COUNT(*)
FROM estat_targetes
WHERE estat = "Activa";

#NIVELL 3 EXERCICI 1
#comptem el numero de transaccions que s'han fet amb cada id de producte.

SELECT product_ids, COUNT(transact_id) AS recompte_vendes
FROM transaction_details
GROUP BY product_ids;

