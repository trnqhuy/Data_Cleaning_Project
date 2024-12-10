USE world_layoffs;

SELECT COUNT(*)
FROm layoffs;

SELECT *
FROm layoffs;


-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns or Rows



-- CREATE TABLE STAGGING
CREATE TABLE layoffs_stagging
LIKE layoffs;

SELECT *
FROm layoffs_stagging;

INSERT layoffs_stagging
SELECT * FROM layoffs;


SELECT COUNT(*)
FROM layoffs_stagging;


-- 1. Remove Duplicates
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_stagging;

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage
, country, funds_raised_millions) AS row_num
FROM layoffs_stagging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


SELECT * 
FROM layoffs_stagging
WHERE company = 'Casper';


WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage
, country, funds_raised_millions) AS row_num
FROM layoffs_stagging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;




CREATE TABLE `layoffs_stagging2` (
  `company` varchar(29) NOT NULL,
  `location` varchar(16) NOT NULL,
  `industry` varchar(15) DEFAULT NULL,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` varchar(10) DEFAULT NULL,
  `date` varchar(10) DEFAULT NULL,
  `stage` varchar(14) DEFAULT NULL,
  `country` varchar(20) NOT NULL,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROm layoffs_stagging2;

SELECT COUNT(*)
FROm layoffs_stagging2;


INSERT INTO layoffs_stagging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage
, country, funds_raised_millions) AS row_num
FROM layoffs_stagging;


DELETE
FROM layoffs_stagging2
WHERE row_num > 1;

SELECT *
FROM layoffs_stagging2;


-- 2. Standardizing Data

SELECT company, TRIM(company)
FROM layoffs_stagging2;


UPDATE layoffs_stagging2
SET company = TRIM(company); -- TRIM Xóa khoảng trắng 2 bên


SELECT DISTINCT industry
FROM layoffs_stagging2
;


UPDATE layoffs_stagging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_stagging2
ORDER BY 1;


UPDATE layoffs_stagging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


SELECT `date`
FROM layoffs_stagging2;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')  -- Convert data type of column date
FROM layoffs_stagging2;


UPDATE layoffs_stagging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


ALTER TABLE layoffs_stagging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_stagging2;




-- 3. Null Values or Blank Values

SELECT *
FROM layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_stagging2
SET industry = NULL
WHERE industry = '';  -- Set industry lines from blank to NULL

SELECT *
FROM layoffs_stagging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_stagging2
WHERE company LIKE 'Bally%';


SELECT  t1.industry, t2.industry
FROM layoffs_stagging2 t1
JOIN layoffs_stagging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_stagging2
WHERE company = 'Airbnb';


UPDATE layoffs_stagging2 t1
JOIN layoffs_stagging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL      -- The update command does not execute with blanks so is need convert blanks into NULL first
AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_stagging2;

ALTER TABLE layoffs_stagging2
DROP COLUMN row_num;




