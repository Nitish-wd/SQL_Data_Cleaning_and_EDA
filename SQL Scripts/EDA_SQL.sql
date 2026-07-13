-- Elploratory Data Analysis 

SELECT * 
FROM layoffs_staging2 ; 

# What are the maximul layoffs happen 
SELECT MAX(total_laid_off) AS max_laid_off,
	MAX(percentage_laid_off) AS highest_laid_percentage 
FROM layoffs_staging2;

# Company that having  100 % of employees laid off Or get closed . 
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

# Find the companys with there total laid offs 
SELECT company ,SUM(total_laid_off) AS total_laid_ByCompany
 FROM layoffs_staging2 
 GROUP BY company 
 ORDER BY 2 DESC;
 
# Find the total Layoffs by industries  
 SELECT industry, SUM(total_laid_off) AS industri_layoffs 
 FROM layoffs_staging2 
 GROUP BY industry 
 ORDER BY 2 DESC;

# Find the total_layoffs By countries 
SELECT country , AVG(total_laid_off) 
FROM layoffs_staging2
GROUP BY country 
ORDER BY 2 DESC;

# Find the Average percentage of laid_off by company  
SELECT 	company , 
		AVG(percentage_laid_off)
FROM layoffs_staging2 
GROUP BY company 
ORDER BY 2 DESC; 

#Total laid off rolling by months 
SELECT * FROM layoffs_staging2;

WITH Rolling_Total AS 
(
SELECT 	SUBSTRING(`Date`,1,7) AS `MONTH`,
		SUM(total_laid_off) AS Total_laidoffs 
FROM layoffs_staging2 
WHERE SUBSTRING(`Date`,1,7) IS NOT NULL 
GROUP BY `MONTH`
ORDER BY 1 ASC
)

SELECT 	`MONTH`,
		Total_laidoffs,
		SUM(Total_laidoffs) OVER(ORDER BY `MONTH`) AS rolling_laidoffs
FROM Rolling_Total ;

# Find the Number of layoff happend  by the starting year to most recent year  
SELECT 	company ,
		YEAR(`Date`) AS laidoff_Year,
		SUM(total_laid_off) AS total_laid_ByCompany
 FROM layoffs_staging2 
 GROUP BY company ,YEAR(`Date`)
 ORDER BY company ASC;
 
# Find the top 5 company of every year that have the highest layoff and rank them for every year  
 WITH Company_Year(Company , Years , Total_laid_offs) AS 
 (
 SELECT 	company ,
		YEAR(`Date`) AS laidoff_Year,
		SUM(total_laid_off) AS total_laid_ByCompany
 FROM layoffs_staging2 
 GROUP BY company ,YEAR(`Date`)
 ORDER BY company ASC
 ),
	Company_year_rank AS 
    (
 SELECT * ,
		DENSE_RANK() OVER(PARTITION BY Years ORDER BY total_laid_offs DESC) AS Ranking 
 FROM Company_Year
 WHERE Years IS NOT NULL )
 
 SELECT * 
 FROM Company_year_rank
 WHERE Ranking <=5
 ;
		