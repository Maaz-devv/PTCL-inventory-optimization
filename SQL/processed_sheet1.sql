SELECT count(*) FROM ptcl_inventory.processed_sheet1;
SELECT * FROM ptcl_inventory.processed_sheet1;
DELETE FROM processed_sheet1 WHERE posting_date IS NULL;

SELECT COUNT(*) FROM processed_sheet1 WHERE entry_date IS NULL;

DESCRIBE processed_sheet1;


SELECT count(*) FROM processed_sheet1
WHERE movement_type = '101';


 SELECT plant from processed_sheet1
 group by plant;

SELECT count(*) FROM processed_sheet1
WHERE posting_date < entry_date;

UPDATE processed_sheet1 SET posting_date = entry_date;

UPDATE processed_sheet1
SET posting_date = DATE_ADD(entry_date, INTERVAL FLOOR(1 + (RAND() * 3)) DAY)
WHERE movement_type = '101' AND RAND() <= 0.3;

UPDATE processed_sheet1 SET posting_date = entry_date WHERE movement_type = '201';

-- KHI1: Efficient plant
UPDATE processed_sheet1 SET posting_date = entry_date WHERE plant = 'KHI1' AND movement_type = '101';
UPDATE processed_sheet1
SET quantity = ROUND(quantity * (0.9 + (RAND() * 0.2)), 0)
WHERE plant = 'KHI1' AND movement_type = '201';

-- LAH1: High-demand zone
UPDATE processed_sheet1
SET quantity = ROUND(quantity * (1.2 + (RAND() * 0.6)), 0)
WHERE plant = 'LAH1' AND movement_type = '201';

UPDATE processed_sheet1
SET posting_date = DATE_ADD(entry_date, INTERVAL FLOOR(1 + (RAND() * 2)) DAY)
WHERE plant = 'LAH1' AND movement_type = '101' AND RAND() <= 0.25;

-- FSD1: Delay-prone, high variability
UPDATE processed_sheet1
SET posting_date = DATE_ADD(entry_date, INTERVAL FLOOR(2 + (RAND() * 3)) DAY)
WHERE plant = 'FSD1' AND movement_type = '101' AND RAND() <= 0.4;

select count(*) from processed_sheet1
where plant = 'FSD1' and posting_date = NULL;

UPDATE processed_sheet1
SET posting_date = NULL
WHERE plant = 'FSD1' AND movement_type = '101' AND RAND() <= 0.05;

UPDATE processed_sheet1
SET quantity = ROUND(quantity * (0.6 + (RAND() * 1.0)), 0)
WHERE plant = 'FSD1' AND movement_type = '201';

-- ISB1: Centralized, consistent
UPDATE processed_sheet1 SET posting_date = entry_date WHERE plant = 'ISB1';
UPDATE processed_sheet1
SET quantity = ROUND(quantity * (0.95 + (RAND() * 0.1)), 0)
WHERE plant = 'ISB1' AND movement_type = '201';

UPDATE processed_sheet1 SET plant = 'ISB1'  WHERE plant = 'AN66';



UPDATE processed_sheet1
SET 
    entry_date = (@temp := entry_date),
    entry_date = posting_date,
    posting_date = @temp
WHERE entry_date > posting_date;

SET SQL_SAFE_UPDATES = 0;

UPDATE processed_sheet1
SET posting_date = entry_date;

ALTER TABLE processed_sheet1 ADD COLUMN rand_val FLOAT;
UPDATE processed_sheet1 SET rand_val = RAND();

UPDATE processed_sheet1
SET posting_date = DATE_ADD(entry_date, INTERVAL FLOOR(1 + (RAND() * 3)) DAY)
WHERE rand_val <= 0.3;

ALTER TABLE processed_sheet1 DROP COLUMN rand_val;







UPDATE processed_sheet1
SET posting_date = DATE_SUB(entry_date, INTERVAL 1 DAY)
WHERE rand_val > 0.25 AND rand_val <= 0.30;

# Spike 15% of quantities:
UPDATE processed_sheet1
SET quantity = quantity * (2 + RAND())
WHERE rand_val > 0.35 AND rand_val <= 0.50;

UPDATE processed_sheet1
SET quantity = quantity * (0.5 + (RAND() * 0.5))
WHERE rand_val > 0.57 AND rand_val <= 0.70;


-- Force same-day posting
UPDATE processed_sheet1
SET posting_date = entry_date
WHERE material_code = '47003960';

-- Increase quantity to simulate high usage
UPDATE processed_sheet1
SET quantity = ROUND(quantity * (1.5 + RAND()), 0)
WHERE material = '47003960';



-- Same-day posting only
UPDATE processed_sheet1
SET posting_date = entry_date
WHERE material_code = '50000601';

-- Slight quantity bump for criticality
UPDATE processed_sheet1
SET quantity = ROUND(quantity * (1.2 + RAND()*0.5), 0)
WHERE material = '50000601';




-- Posting delay for 20%
UPDATE processed_sheet1
SET posting_date = DATE_ADD(entry_date, INTERVAL FLOOR(1 + (RAND() * 2)) DAY)
WHERE material IN ('41000001', '41000002', '47003925', '47003926') 
  AND rand_val <= 0.2;

-- 80% same-day posting (default already same)
UPDATE processed_sheet1
SET posting_date = entry_date
WHERE material IN ('41000001', '41000002', '47003925', '47003926') 
  AND rand_val > 0.2;

-- Quantity range: 80% to 120%
UPDATE processed_sheet1
SET quantity = ROUND(quantity * (0.8 + (RAND() * 0.4)), 0)
WHERE material IN ('41000001', '41000002', '47003925', '47003926');



-- 25% delay
UPDATE processed_sheet1
SET posting_date = DATE_ADD(entry_date, INTERVAL FLOOR(1 + (RAND() * 3)) DAY)
WHERE material IN ('50006123', '50006124', '50006125', '50006126')
  AND rand_val <= 0.25;



-- 70% same-day (default)

-- Quantity variation
UPDATE processed_sheet1
SET quantity = ROUND(quantity * (0.7 + (RAND() * 0.6)), 0)
WHERE material IN ('50006123', '50006124', '50006125', '50006126');


UPDATE processed_sheet1
SET amt_in_loc_cur = ROUND(quantity * 20000, 0)
WHERE material = '47003960';


UPDATE processed_sheet1
SET amt_in_loc_cur = ROUND(quantity * 1200, 0)
WHERE material = '50000601';

UPDATE processed_sheet1
SET amt_in_loc_cur = ROUND(quantity * 25000, 0)
WHERE material = '50000127';

UPDATE processed_sheet1
SET quantity = ROUND(quantity * (0.2 + (RAND() * 0.4)), 0)
WHERE material= '50000127';

select material, sum(amt_in_loc_cur) from processed_sheet1
WHERE material = '50000127';

-- 30% backdated
UPDATE processed_sheet1
SET posting_date = DATE_SUB(entry_date, INTERVAL 1 DAY)
WHERE material = '50000127' AND rand_val <= 0.3;

-- 30% missing
UPDATE processed_sheet1
SET posting_date = NULL
WHERE material = '50000127' AND rand_val > 0.3 AND rand_val <= 0.6;

-- Boost summer months usage
UPDATE processed_sheet1
SET quantity = quantity * 1.2
WHERE MONTH(entry_date) IN (5,6,7,8) AND movement_type = '201';



-- Tube A-4', Tube B-8'
UPDATE processed_sheet1
SET amt_in_loc_cur = ROUND(quantity * 900, 0)
WHERE material IN ('41000001', '41000002');

-- OFC Joint Enclosure - 24 Fiber
UPDATE processed_sheet1
SET amt_in_loc_cur = ROUND(quantity * 6000, 0)
WHERE material = '47003925';

-- ODF 12 Fiber Wall Mounted
UPDATE processed_sheet1
SET amt_in_loc_cur = ROUND(quantity * 5000, 0)
WHERE material = '47003926';

-- HDPE Pipes
UPDATE processed_sheet1
SET amt_in_loc_cur = ROUND(quantity * (200 + (RAND() * 400)), 0)
WHERE material IN ('50006124', '50006125');

-- Sockets for HDPE Pipe
UPDATE processed_sheet1
SET amt_in_loc_cur = ROUND(quantity * (150 + (RAND() * 150)), 0)
WHERE material IN ('50006123', '50006126');


UPDATE processed_sheet1
SET amt_in_loc_cur = ROUND(amt_in_loc_cur * (0.95 + (RAND() * 0.1)), 0)
WHERE amt_in_loc_cur IS NOT NULL;


-- Delay: 15%
UPDATE processed_sheet1
SET posting_date = DATE_ADD(entry_date, INTERVAL FLOOR(1 + (RAND() * 3)) DAY)
WHERE movement_type = '101' AND RAND() <= 0.15;


-- Ensure same-day posting
UPDATE processed_sheet1
SET posting_date = entry_date
WHERE movement_type = '201';

-- Spike days: 10%
UPDATE processed_sheet1
SET quantity = ROUND(quantity * (1.5 + (RAND() * 0.5)), 0)
WHERE movement_type = '201' AND RAND() <= 0.15;

-- Low activity: 10%
UPDATE processed_sheet1
SET quantity = ROUND(quantity * (0.4 + (RAND() * 0.4)), 0)
WHERE movement_type = '201' AND RAND() > 0.1 AND RAND() <= 0.15;







-- Fiber Joint Closure (47003960)
UPDATE processed_sheet1
SET quantity = FLOOR(50 + RAND() * 100)  -- GR
WHERE material = '47003960' AND movement_type = '101';

UPDATE processed_sheet1
SET quantity = FLOOR(15 + RAND() * 35)  -- GI LAH1
WHERE material = '47003960' AND movement_type = '201' AND plant = 'LAH1';

-- Battery (50000127)
UPDATE processed_sheet1
SET quantity = FLOOR(30 + RAND() * 80)  -- GR
WHERE material = '50000127' AND movement_type = '101';

UPDATE processed_sheet1
SET quantity = FLOOR(5 + RAND() * 20)   -- GI any plant
WHERE material = '50000127' AND movement_type = '201';

-- HDPE Pipes (50006124, 50006125)
UPDATE processed_sheet1
SET quantity = FLOOR(40 + RAND() * 60)  -- GR
WHERE material IN ('50006124', '50006125') AND movement_type = '101';

UPDATE processed_sheet1
SET quantity = FLOOR(10 + RAND() * 20)  -- GI FSD1
WHERE material IN ('50006124', '50006125') AND movement_type = '201' AND plant = 'FSD1';

-- Sockets (50006123, 50006126)
UPDATE processed_sheet1
SET quantity = FLOOR(20 + RAND() * 30)  -- GR
WHERE material IN ('50006123', '50006126') AND movement_type = '101';

UPDATE processed_sheet1
SET quantity = FLOOR(5 + RAND() * 15)   -- GI FSD1
WHERE material_code IN ('50006123', '50006126') AND movement_type = '201' AND plant = 'FSD1';

-- Patch Cord & Converter Cable (47003925, 47003926)
UPDATE processed_sheet1
SET quantity = FLOOR(25 + RAND() * 40)  -- GR
WHERE material IN ('47003925', '47003926') AND movement_type = '101';

UPDATE processed_sheet1
SET quantity = FLOOR(10 + RAND() * 10)  -- GI KHI1
WHERE material IN ('47003925', '47003926') AND movement_type = '201' AND plant = 'KHI1';

-- ODF Panel (50000601)
UPDATE processed_sheet1
SET quantity = FLOOR(5 + RAND() * 10)   -- GR
WHERE material = '50000601' AND movement_type = '101';

UPDATE processed_sheet1
SET quantity = FLOOR(1 + RAND() * 5)    -- GI any
WHERE material = '50000601' AND movement_type = '201';

-- Splice Enclosure (47003950)
UPDATE processed_sheet1
SET quantity = FLOOR(15 + RAND() * 25)  -- GR
WHERE material = '47003950' AND movement_type = '101';

UPDATE processed_sheet1
SET quantity = FLOOR(5 + RAND() * 10)   -- GI LAH1
WHERE material = '47003950' AND movement_type = '201' AND plant = 'LAH1';


-- ✅ Step 6: Simulate amt_in_loc_cur (Amount in Local Currency)
-- Formula: amt_in_loc_cur = quantity × unit price × price noise (±5%)
-- Round to nearest rupee for ERP realism

UPDATE processed_sheet1
SET amt_in_loc_cur = ROUND(
  quantity * (
    CASE material
      WHEN '47003960' THEN 20000    -- Fiber Joint Closure
      WHEN '50000127' THEN 35000    -- Battery
      WHEN '50006124' THEN 600      -- HDPE Pipe (110mm)
      WHEN '50006125' THEN 400      -- HDPE Pipe (90mm)
      WHEN '50006123' THEN 200      -- Coupler
      WHEN '50006126' THEN 250      -- Socket
      WHEN '47003925' THEN 1500     -- Patch Cord
      WHEN '47003926' THEN 1400     -- Converter Cable
      WHEN '50000601' THEN 12000    -- ODF Panel
      WHEN '47003950' THEN 8000     -- Splice Enclosure
      ELSE 1000                     -- Default unit price for unknown materials
    END * (0.95 + (RAND() * 0.1))   -- Apply ±5% fluctuation
  ), 0)
WHERE quantity IS NOT NULL;


CREATE TEMPORARY TABLE plant_material_stock AS
SELECT
plant,
material,
SUM(CASE WHEN movement_type = 101 THEN quantity ELSE 0 END) AS total_received,
SUM(CASE WHEN movement_type = 201 THEN quantity ELSE 0 END) AS total_consumed,
SUM(CASE WHEN movement_type = 101 THEN quantity ELSE 0 END) -
SUM(CASE WHEN movement_type = 201 THEN quantity ELSE 0 END) AS net_available
FROM processed_sheet1
GROUP BY plant, material;

select * from plant_material_stock;

CREATE TEMPORARY TABLE material_received AS
SELECT
    plant,
    material,
    SUM(quantity) AS total_received
FROM processed_sheet1
WHERE movement_type = 101
GROUP BY plant, material;
select * from material_received;

UPDATE processed_sheet1 s
JOIN material_received r
  ON s.plant = r.plant AND s.material = r.material
SET s.quantity = ROUND(r.total_received * (0.3 + RAND() * 0.3))  -- 30% to 60% of received
WHERE s.movement_type = 201;

UPDATE processed_sheet1
SET amt_in_loc_cur = ROUND(quantity * (50 + FLOOR(RAND() * 100)), 0)
WHERE movement_type = 201;

SELECT
    s.plant,
    s.material,
    SUM(CASE WHEN s.movement_type = 101 THEN quantity ELSE 0 END) AS total_received,
    SUM(CASE WHEN s.movement_type = 201 THEN quantity ELSE 0 END) AS total_consumed
FROM processed_sheet1 s
GROUP BY s.plant, s.material
HAVING total_consumed > total_received;






-- Create summary of 101s again
CREATE TEMPORARY TABLE material_received1 AS
SELECT
    plant,
    material,
    SUM(quantity) AS total_received
FROM processed_sheet1
WHERE movement_type = 101
GROUP BY plant, material;

-- Now safely scale 201s
UPDATE processed_sheet1 s
JOIN material_received r
  ON s.plant = r.plant AND s.material= r.material
SET s.quantity = ROUND(r.total_received * (0.3 + RAND() * 0.3))  -- 30% to 60%
WHERE s.movement_type = 201;

UPDATE processed_sheet1
SET amt_in_loc_cur = ROUND(quantity * (50 + FLOOR(RAND() * 100)), 0)
WHERE movement_type = 201;


SELECT
    plant,
    material,
    SUM(CASE WHEN movement_type = 101 THEN quantity ELSE 0 END) AS total_received,
    SUM(CASE WHEN movement_type = 201 THEN quantity ELSE 0 END) AS total_consumed,
    SUM(CASE WHEN movement_type = 101 THEN quantity ELSE 0 END) -
    SUM(CASE WHEN movement_type = 201 THEN quantity ELSE 0 END) AS net_available
FROM processed_sheet1
GROUP BY plant, material
HAVING net_available < 0;

SELECT
  plant,
  material,
  SUM(CASE WHEN movement_type = 101 THEN quantity ELSE 0 END) AS total_received,
  SUM(CASE WHEN movement_type = 201 THEN quantity ELSE 0 END) AS total_consumed,
  SUM(CASE WHEN movement_type = 101 THEN quantity ELSE 0 END) -
  SUM(CASE WHEN movement_type = 201 THEN quantity ELSE 0 END) AS net_available
FROM processed_sheet1
WHERE plant = 'ISB1' AND material = '47003960'
GROUP BY plant, material;

UPDATE processed_sheet1
SET quantity = ROUND(quantity * (0.2 + RAND() * 0.2))
WHERE plant = 'ISB1' AND material = '47003960' AND movement_type = 201;

UPDATE processed_sheet1
SET quantity = ROUND((SELECT SUM(quantity) + 1000 FROM processed_sheet1 
                      WHERE plant = 'ISB1' AND material = '41000002' AND movement_type = 101)
                      * (0.4 + RAND() * 0.2))
WHERE plant = 'ISB1' AND material = '41000002' AND movement_type = 201;



SELECT @cap_quantity := (SUM(quantity) + 1000)
FROM processed_sheet1
WHERE plant = 'ISB1' AND material = '41000002' AND movement_type = 101;


UPDATE processed_sheet1
SET quantity = ROUND(@cap_quantity * (0.4 + RAND() * 0.2))
WHERE plant = 'ISB1' AND material = '41000002' AND movement_type = 201;


DELETE s
FROM processed_sheet1 s
LEFT JOIN (
    SELECT plant, material
    FROM processed_sheet1
    WHERE movement_type = 101
    GROUP BY plant, material
) r ON s.plant = r.plant AND s.material = r.material
WHERE s.movement_type = 201
  AND r.plant IS NULL;
  
  
  CREATE TEMPORARY TABLE material_received AS
SELECT plant, material_code, SUM(quantity) AS total_received
FROM processed_sheet1
WHERE movement_type = 101
GROUP BY plant, material_code;

UPDATE processed_sheet1 s
JOIN material_received r
  ON s.plant = r.plant AND s.material = r.material
SET s.quantity = ROUND(r.total_received * (0.3 + RAND() * 0.3))
WHERE s.movement_type = 201;

UPDATE processed_sheet1
SET amt_in_loc_cur = ROUND(quantity * (50 + FLOOR(RAND() * 100)), 0);

  
  
  SET SQL_SAFE_UPDATES = 0;

UPDATE processed_sheet1
SET quantity = ROUND(quantity * (0.3 + RAND() * 0.3))
WHERE plant = 'ISB1' AND material = '41000002' AND movement_type = 201;

UPDATE processed_sheet1
SET quantity = ROUND(quantity / 0.45)
WHERE plant = 'ISB1' AND material = '50006125' AND movement_type = 201;




-- ANALYSIS

SELECT
  plant,
  material,
  SUM(CASE WHEN movement_type = 101 THEN quantity ELSE 0 END) AS total_received,
  SUM(CASE WHEN movement_type = 201 THEN quantity ELSE 0 END) AS total_consumed,
  SUM(CASE WHEN movement_type = 101 THEN quantity ELSE 0 END) -
  SUM(CASE WHEN movement_type = 201 THEN quantity ELSE 0 END) AS net_available
FROM processed_sheet1
GROUP BY plant, material;


-- Top 5 Most Consumed Materials Across All Plants (Potentially Critical)
SELECT
  material,
  SUM(quantity) AS total_consumed
FROM processed_sheet1
WHERE movement_type = 201
GROUP BY material
ORDER BY total_consumed DESC
LIMIT 5;

-- Plants with Highest Net Negative Stock (Risk of Stockouts)
SELECT
  plant,
  material,
  SUM(CASE WHEN movement_type = 101 THEN quantity ELSE 0 END) -
  SUM(CASE WHEN movement_type = 201 THEN quantity ELSE 0 END) AS net_available
FROM processed_sheet1
GROUP BY plant, material
HAVING net_available < 0
ORDER BY net_available ASC;


SELECT
  plant,
  material,
  DATE_FORMAT(posting_date, '%Y-%m') AS month,
  SUM(quantity) AS monthly_consumed
FROM processed_sheet1
WHERE movement_type = 201
GROUP BY plant, material, month
ORDER BY plant, material, month;


SELECT
    material,
    SUM(CASE WHEN DATE_FORMAT(posting_date, '%Y-%m') = '2022-01' THEN quantity ELSE 0 END) AS '2022-01',
    SUM(CASE WHEN DATE_FORMAT(posting_date, '%Y-%m') = '2022-02' THEN quantity ELSE 0 END) AS '2022-02',
    SUM(CASE WHEN DATE_FORMAT(posting_date, '%Y-%m') = '2022-03' THEN quantity ELSE 0 END) AS '2022-03',
    SUM(CASE WHEN DATE_FORMAT(posting_date, '%Y-%m') = '2022-04' THEN quantity ELSE 0 END) AS '2022-04',
    SUM(CASE WHEN DATE_FORMAT(posting_date, '%Y-%m') = '2022-05' THEN quantity ELSE 0 END) AS '2022-05',
    SUM(CASE WHEN DATE_FORMAT(posting_date, '%Y-%m') = '2022-06' THEN quantity ELSE 0 END) AS '2022-06',
    SUM(CASE WHEN DATE_FORMAT(posting_date, '%Y-%m') = '2022-07' THEN quantity ELSE 0 END) AS '2022-07',
    SUM(CASE WHEN DATE_FORMAT(posting_date, '%Y-%m') = '2022-08' THEN quantity ELSE 0 END) AS '2022-08',
    SUM(CASE WHEN DATE_FORMAT(posting_date, '%Y-%m') = '2022-09' THEN quantity ELSE 0 END) AS '2022-09',
    SUM(CASE WHEN DATE_FORMAT(posting_date, '%Y-%m') = '2022-10' THEN quantity ELSE 0 END) AS '2022-10',
    SUM(CASE WHEN DATE_FORMAT(posting_date, '%Y-%m') = '2022-11' THEN quantity ELSE 0 END) AS '2022-11',
    SUM(CASE WHEN DATE_FORMAT(posting_date, '%Y-%m') = '2022-12' THEN quantity ELSE 0 END) AS '2022-12'
    -- Add more months as needed
  FROM
    processed_sheet1  
WHERE movement_type = 201
GROUP BY
    material
ORDER BY
    material;


