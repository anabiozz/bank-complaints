CREATE ROLE oracle password 'welcome1' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;

SET ROLE oracle;

CREATE DATABASE consumer_complains;

CREATE TABLE bank_account_complaints (
 complaint_id text PRIMARY KEY,
 date_received date,
 product text,
 sub_product text,
 issue text,
 sub_issue text,
 consumer_complaint_narrative text,
 company_public_response text,
 company text,
 state text,
 zip_code text,
 tags text,
 consumer_consent_provided text,
 submitted_via text,
 date_sent date,
 company_response_to_consumer text,
 timely_response text,
 consumer_disputed text);;
 
 CREATE TABLE credit_card_complaints (
 complaint_id text PRIMARY KEY,
 date_received date,
 product text,
 sub_product text,
 issue text,
 sub_issue text,
 consumer_complaint_narrative text,
 company_public_response text,
 company text,
 state text,
 zip_code text,
 tags text,
 consumer_consent_provided text,
 submitted_via text,
 date_sent date,
 company_response_to_consumer text,
 timely_response text,
 consumer_disputed text);;
 
 
SELECT count(*) FROM bank_account_complaints;
 

SELECT count(*) FROM credit_card_complaints
WHERE consumer_complaint_narrative IS NOT NULL;
 

SELECT count(*) FROM bank_account_complaints
WHERE consumer_complaint_narrative IS NOT NULL;


DROP VIEW credit_card_w_complaints;


CREATE VIEW credit_card_w_complaints AS
SELECT * FROM credit_card_complaints
WHERE consumer_complaint_narrative IS NOT NULL;


CREATE VIEW credit_card_wo_complaints as
SELECT * FROM credit_card_complaints
WHERE consumer_complaint_narrative IS NULL;
    
   
CREATE VIEW bank_account_w_complaints AS
SELECT * FROM bank_account_complaints
WHERE consumer_complaint_narrative IS NOT NULL;
    
   
CREATE VIEW bank_account_wo_complaints AS
SELECT * FROM bank_account_complaints
WHERE consumer_complaint_narrative IS NULL;
    
   
SELECT * FROM credit_card_w_complaints LIMIT 5;


SELECT * FROM credit_card_complaints WHERE complaint_id = '1297939';


CREATE VIEW with_complaints AS
SELECT * from credit_card_w_complaints
UNION ALL
SELECT * from bank_account_w_complaints;

   
SELECT * FROM with_complaints;


CREATE VIEW without_complaints AS
SELECT * FROM credit_card_wo_complaints
UNION ALL
SELECT * FROM bank_account_wo_complaints;
    
   
SELECT * FROM without_complaints;


SELECT count(*) FROM credit_card_wo_complaints;
 
 
SELECT count(*)FROM (SELECT * FROM without_complaints
	INTERSECT
	SELECT * FROM credit_card_wo_complaints)
ppg;
 
 
SELECT count(*)FROM (SELECT * FROM without_complaints
EXCEPT
SELECT * FROM credit_card_wo_complaints) ppg;


SELECT complaint_id, product, company, zip_code,
       complaint_id || '-' || product || '-' || company || '-' ||
 zip_code AS concat
FROM credit_card_complaints
LIMIT 10


SELECT company, state, zip_code, count(complaint_id) AS complaint_count
FROM credit_card_complaints
WHERE company = 'Citibank' AND state IS NOT NULL
GROUP BY company, state, zip_code
ORDER BY 4 DESC
LIMIT 10;


SELECT ppt.company, ppt.state, max(ppt.complaint_count) AS complaint_count
FROM (SELECT company, state, zip_code, count(complaint_id) AS complaint_count
      FROM credit_card_complaints
      WHERE company = 'Citibank'
       AND state IS NOT NULL
      GROUP BY company, state, zip_code
      ORDER BY 4 DESC) ppt
GROUP BY ppt.company, ppt.state
ORDER BY 3 DESC
LIMIT 10;


SELECT ens.company, ens.state, ens.zip_code, ens.complaint_count
FROM (select company, state, zip_code, count(complaint_id) AS complaint_count
      FROM credit_card_complaints
      WHERE state IS NOT NULL
      GROUP BY company, state, zip_code) ens
INNER JOIN
   (SELECT ppx.company, max(ppx.complaint_count) AS complaint_count
    FROM (SELECT ppt.company, ppt.state, max(ppt.complaint_count) AS complaint_count
          FROM (SELECT company, state, zip_code, count(complaint_id) AS complaint_count
                FROM credit_card_complaints
                 WHERE state IS NOT NULL
                GROUP BY company, state, zip_code
                ORDER BY 4 DESC) ppt
          GROUP BY ppt.company, ppt.state
          ORDER BY 3 DESC) ppx
    GROUP BY ppx.company) apx
ON apx.company = ens.company
 AND apx.complaint_count = ens.complaint_count
ORDER BY 4 DESC;


SELECT CAST(complaint_id AS float) AS complaint_id
FROM bank_account_complaints LIMIT 10;


SELECT CAST(complaint_id AS int) AS complaint_id,
       date_received, product, sub_product, issue, company,
       state, zip_code, submitted_via, date_sent, company_response_to_consumer,
       timely_response, consumer_disputed
FROM bank_account_complaints
WHERE state = 'CA'
    AND consumer_disputed = 'No'
    AND company = 'Wells Fargo & Company'
LIMIT 5;


CREATE VIEW wells_complaints_v AS (
    SELECT CAST(complaint_id AS int) AS complaint_id,
           date_received, product, sub_product, issue, company,
           state, zip_code, submitted_via, date_sent,
           company_response_to_consumer,
           timely_response, consumer_disputed
    FROM bank_account_complaints
     WHERE state = 'CA'
           AND consumer_disputed = 'No'
          AND company = 'Wells Fargo & Company')

          
SELECT * FROM wells_complaints_v;


SELECT company, COUNT(company) AS company_amt
FROM credit_card_complaints
GROUP BY company
ORDER BY 2 DESC;


SELECT company, COUNT(company) as company_amt,
    (SELECT COUNT(*) FROM credit_card_complaints) AS total
FROM credit_card_complaints
GROUP BY company
ORDER BY 2 DESC;


SELECT ppg.company, ppg.company_amt, ppg.total,
       ((CAST(ppg.company_amt AS double precision) / CAST(ppg.total as double precision)) * 100) AS percent
FROM (SELECT company, COUNT(company) as company_amt, (SELECT COUNT(*) FROM credit_card_complaints) AS total
      FROM credit_card_complaints
      GROUP BY company
      ORDER BY 2 DESC) ppg;