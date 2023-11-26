create database ds;
use ds;

select * from ds_salaries;

-- CASE 1 : Apakah ada data yang NULL?
select * from ds_salaries
where work_year is null
or experience_level is null
or employment_type is null
or job_title is null
or salary is null
or salary_currency is null
or salary_in_usd is null
or employee_residence is null
or remote_ratio is null
or company_location is null
or company_size is null;

-- CASE 2 : Job title apa saja yang tersedia ?
select distinct job_title from ds_salaries
order by job_title;

-- CASE 3 : Job title apa saja yang berkaitan dengan data analyst ?
select distinct job_title from ds_salaries
where job_title like '%data analyst%';

-- CASE 4 : Berapa gaji job title yang berkaitan dengan data analyst ?
select (avg(salary_in_usd) * 15000) / 12 as avg_da_salary_rp_monthly from ds_salaries
where job_title like '%data analyst%';

-- CASE 4.1 : Berapa gaji job title yang berkaitan dengan data analyst berdasarkan experiencenya ?
select experience_level, 
	(avg(salary_in_usd) * 15000) / 12 as avg_da_salary_rp_monthly 
from ds_salaries
where job_title like '%data analyst%'
group by experience_level;

-- CASE 4.2 : Berapa gaji job title yang berkaitan dengan data analyst berdasarkan experiencenya dan jenis employment ?
select experience_level, 
	employment_type, 
	(avg(salary_in_usd) * 15000) / 12 as avg_da_salary_rp_monthly 
from ds_salaries
where job_title like '%data analyst%'
group by experience_level, employment_type
order by experience_level, employment_type;

-- CASE 5 : Negara mana yang memiliki gaji yang menarik (lebih dari $20,000) untuk posisi data analyst, namun full time dan masih entry level/mid ?
select company_location, 
	avg(salary_in_usd) as avg_salary
from ds_salaries
where job_title like '%data analyst%' 
	and employment_type = 'FT'
    and experience_level in ('MI','EN')
group by company_location
having avg_salary >= 20000
order by avg_salary desc;

-- CASE 6 : Pada tahun berapa kenaikan gaji dari mid menuju ke senior memiliki kenaikan yang tertinggi ?
-- Berkaitan dengan job title data analyst, employment type penuh waktu (Full Time)
with ds_1 as (
	select work_year,
		avg(salary_in_usd) sal_in_usd_ex
	from ds_salaries
    where employment_type = 'FT'
		and experience_level = 'EX'
        and job_title like '%data analyst%'
	group by work_year
), ds_2 as (
	select work_year,
		avg(salary_in_usd) sal_in_usd_mi
	from ds_salaries
    where employment_type = 'FT'
		and experience_level = 'MI'
        and job_title like '%data analyst%'
	group by work_year
), year as (
	select distinct work_year from ds_salaries
)

select year.work_year, 
	ds_1.sal_in_usd_ex,
    ds_2.sal_in_usd_mi,
    ds_1.sal_in_usd_ex - ds_2.sal_in_usd_mi salary_gap
from year
left join ds_1
on ds_1.work_year = year.work_year
left join ds_2
on ds_2.work_year = year.work_year;