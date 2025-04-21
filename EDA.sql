-- Exploratory Data Analysis

select * from layoffs_staging2;

-- Cumulative sum by month
with rolling_total as
(select substring(`date`,1,7)  as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7)  is not null
group by `month`
order by 1 asc)
select `month`,total_off,sum(total_off)
over(order by `month`) as rolling_total from rolling_total;

-- Max no of people laid off by company
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- Max no of people laid off by company and in which year
select company,year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
order by 3 desc;

-- Top 5 highest layoffs in each year and which company
with company_year (company, years,total_laid_off)as (
select company,year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
),
company_year_rank as(
select * ,dense_rank() over(partition by years order by total_laid_off desc) as ranking from company_year
where years is not null)
select * from company_year_rank 
where ranking<=5