-- Exploratory Data Analysis 

SELECT * 
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *						-- Companies that laid off all of their staff
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions desc;

SELECT company, SUM(total_laid_off)		-- total layoffs per company ordered by the sum
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 desc;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2; 

SELECT industry, SUM(total_laid_off)		-- total layoffs per industry ordered by the sum
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 desc;

SELECT country, SUM(total_laid_off)		-- total layoffs per country ordered by the sum
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 desc;

SELECT YEAR(`date`), SUM(total_laid_off)		-- total layoffs per year ordered by each year
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 desc;

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) -- Rolling total layoff by month 
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL 
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_total AS(
	SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) as total_off	-- Rolling total layoff by month 
	FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL 
	GROUP BY `MONTH`
	ORDER BY 1 ASC
)

SELECT `MONTH`, total_off,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total -- Rolling total layoff by month 
FROM Rolling_total;

SELECT company, SUM(total_laid_off)		-- total layoffs per company ordered by the sum
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 desc;

SELECT company, YEAR(`date`),SUM(total_laid_off)		-- total layoffs per company ordered by the sum
FROM layoffs_staging2
GROUP BY company, `date`
ORDER BY 3 DESC;

WITH Company_year (company, years, total_laid_off) AS(
	SELECT company, YEAR(`date`),SUM(total_laid_off)		-- RANK by total_laid_off
	FROM layoffs_staging2
	GROUP BY company, `date`
	ORDER BY 3 DESC
), Company_year_rank AS (
	SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) as `Rank`
	FROM Company_year
	WHERE years IS NOT NULL
	ORDER BY `Rank` ASC
)

SELECT * 						-- The companies with the most layoffs per year
FROM Company_year_rank
WHERE `Rank`<= 5;







