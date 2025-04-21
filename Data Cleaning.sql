
use world_layoffs;
select  * from layoffs;

/* 1.Remove Duplicates
2. Standardize the Data
3. Null Values or blank values
4. Remove any Columns
*/

create table layoffs_staging Like layoffs;

select * from layoffs_staging;

insert into layoffs_staging
select * from layoffs;


-- Use of CTE
with duplicate_cte as
(select *,row_number() over(partition by company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging)
select * from duplicate_cte where row_num>1;

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



-- Removing duplicates
insert into layoffs_staging2
select *,row_number() over(partition by company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;
delete from layoffs_staging2 where row_num>1;
select * from layoffs_staging2;


-- Standardizing data
select company,trim(company) from layoffs_staging2;
update layoffs_staging2
set company=trim(company);

select distinct(industry) from layoffs_staging2 order by industry;
update layoffs_staging2 
set industry='Crypto'
where industry like 'Crypto%';


select distinct country from layoffs_staging2 order by 1;
update layoffs_staging2 
set country='United States'
where country like 'United States%';

update layoffs_staging2
set `date`=STR_TO_DATE(`date`,'%m/%d/%Y');
alter table layoffs_staging2
modify column `date` date;

-- check for null and blank values
select * from layoffs_staging2
where industry is null
or industry='';


select * from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select * from layoffs_staging2
where company='Airbnb';

select t1.industry,t2.industry from layoffs_staging2 t1
join layoffs_staging2 t2 
on t1.company=t2.company
where (t1.industry is null or t1.industry='')
and t2.industry is not null;


update layoffs_staging2 t1
join layoffs_staging2 t2 
on t1.company=t2.company
set t1.industry=t2.industry
where t1.industry is null or t1.industry=''
and t2.industry is not null;

select * from layoffs_staging2 t1
join layoffs_staging2 t2 
on t1.company=t2.company and t1.country=t2.country and t1.industry=t2.industry and t1.stage=t2.stage
where t1.total_laid_off is null
and t1.percentage_laid_off is null
and t1.funds_raised_millions is null;

-- Delete null values
delete from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null
and funds_raised_millions is null;

-- Remove column
alter table layoffs_staging2
drop column row_num;

select * from layoffs_staging2;
