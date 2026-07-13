 CREATE DATABASE world_layoffs;
 USE world_layoffs;

SELECT * FROM layoffs;

-- Cleaning to do 
# Remove Duplicates 
# Standardzing Data 
# 
# Remove unnessary columan  

# Copying the dataset 
CREATE TABLE layoffs_staging LIKE layoffs;
SELECT * FROM layoffs_staging;

INSERT layoffs_staging 
SELECT * FROM layoffs;


-- Identifying And Removing Duplicates 

# Identifying  duplicates 
WITH duplicate_cte AS 
(
SELECT * ,
    ROW_NUMBER() OVER(
    PARTITION BY company,location,industry,total_laid_off, percentage_laid_off , `Date`,stage, country,funds_raised_millions) AS row_num
FROM layoffs_staging
)

SELECT * 
FROM duplicate_cte
WHERE row_num > 1;


# Creating a Duplicate table with the row_num column  
CREATE TABLE `layoffs_staging2` (
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
FROM layoffs_staging2
WHERE row_num > 1;

# Inserting all the data with the identified Duplicates  
INSERT INTO layoffs_staging2
SELECT * ,
    ROW_NUMBER() OVER(
    PARTITION BY company,location,industry,total_laid_off, percentage_laid_off , `Date`,stage, country,funds_raised_millions) AS row_num
FROM layoffs_staging;


# Removing Duplicates Value  
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;


-- Standardizing Data 
# Removing Extra Space From Data 
UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT * 
FROM layoffs_staging2;


#Grouping the Same Column with the different names LIke crypto , cryptoCurrency , crypto Currency In industry columns 

# Identifying  
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'; 

#Grouping  or changing name to One 
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

 
#Identifying problem in country column ;
SELECT DISTINCT(country)
FROM  layoffs_staging2
ORDER BY 1 ; 

UPDATE layoffs_staging2
SET country =  TRIM(TRAILING '.' FROM country )
WHERE country LIKE 'United States%';

# Changing  the data type of Data column : text to Date
SELECT `Date`,
	STR_TO_DATE(`Date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `Date`= STR_TO_DATE(`Date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `Date` DATE;

SELECT * FROM layoffs_staging2;



-- REMOVING and imputing  NULL AND BLANK VALUES 

#Identifying  FROM total_laid_off Column 
 SELECT * 
 FROM layoffs_staging2
 WHERE total_laid_off IS NULL 
 AND percentage_laid_off IS NULL;
 
 UPDATE layoffs_staging2
 SET industry = NULL 
 WHERE industry = '';
 
 SELECT * 
 FROM layoffs_staging2
 WHERE company = '%J%';

# Identifying Null and blanks in industry 
SELECT t1.industry , t2.industry  
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
    AND t1.location = t2.location 
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL ;

# Imputing Null Values in industry columns 
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
SET t1.industry = t2.industry  
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL ;


# Removing  meaning less null values 
DELETE
 FROM layoffs_staging2
 WHERE total_laid_off IS NULL 
 AND percentage_laid_off IS NULL;
 
# Removing Unnessary columns  
 ALTER TABLE layoffs_staging2
 DROP COLUMN row_num;
 
 SELECT * FROM layoffs_staging2;
 
 

