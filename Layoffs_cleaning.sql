-- Data cleaning

SELECT *
FROM layoffs_staging;
-- Steps on cleaning data:
-- 1. Remove any Duplicates
-- 2. Standardize the data
-- 3. Null values or blank values
-- 4. Remove unnecessary columns and rows

-- 1. Remove any Duplicates

WITH duplicate_cte as(			 -- Similar to a function/method call in a programming language
	SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
	FROM layoffs_staging
)

SELECT *					-- Finds the duplicates
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (		-- Creates a new table since removeing by CTE cannot work on the original table
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;			-- Check if the table is created successfully 

INSERT INTO layoffs_staging2		-- Inserting the data into the new table
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

SELECT *					-- Finds the duplicates
FROM layoffs_staging2
WHERE row_num > 1;

DELETE 					 	-- Removes the duplicates
FROM layoffs_staging2
WHERE row_num > 1;

-- 2. Standardize the data

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2			-- TRIM gets rid of the white space before and after the text
SET company = TRIM(company);

SELECT DISTINCT(industry)		-- Looking for distinct industries 
FROM layoffs_staging2
ORDER BY 1;

SELECT * 						-- Looking for crypto since it doesnt have a standard naming convention
FROM layoffs_staging2
WHERE industry LIKE "Crypto%";

UPDATE layoffs_staging2			-- Updates all crypto name to a standardized form
SET industry = 'Crypto'
WHERE industry LIKE "Crypto%";

SELECT DISTINCT Country			-- United states had some issues
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2			-- Fixed the US issue
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`,						-- Date needs to be changed from mm/dd/yyyy to yyyy/mm/dd
STR_TO_DATE(`date`, '%m/%d/%Y') 
FROM layoffs_staging;

UPDATE layoffs_staging2							-- Updates the table
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2				-- Changes the data type of date from text to DATE (NEVER DO THIS ON THE ORIGINAL TABLE)
MODIFY COLUMN `date` DATE;


-- 3. Dealing Null values or blank values

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';		-- Checking which rows had empty values 

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company 
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1									-- If there exsits another row with the same company set the industries to be the same when the industry value is empty
JOIN layoffs_staging2 t2 ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;

-- 4.Remove unnecessary columns and rows
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP column row_num;





