DROP TABLE layoffs;
DROP TABLE layoffs_staging;

CREATE TABLE layoffs(
	company varchar(255),
    location varchar(255),
    industry varchar(255) DEFAULT NULL,
    total_laid_off bigint DEFAULT NULL,
    percentage_laid_off FLOAT DEFAULT NULL,
    date DATE DEFAULT NULL,
    stage varchar(255) DEFAULT NULL,
    country varchar(255),
    funds_raised_millions bigint DEFAULT NULL
);

SELECT * FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;
