SELECT * FROM ptcl_inventory.raw_sheet1;
SELECT count(*) FROM ptcl_inventory.raw_sheet1;

SELECT COUNT(*) FROM raw_sheet1 WHERE posting_date IS NULL;

DELETE FROM raw_sheet1 WHERE posting_date IS NULL;

SET SQL_SAFE_UPDATES = 0;