CREATE DATABASE HR;

select*
from hr_data
----Cleaning dataset
---Calling the termdate column 

select termdate
from hr_data 
order by termdate desc;

---Changing the termdate colum to datetime format with 120 being the date format  

update hr_data
set termdate = format(convert(datetime, left(termdate,19),120),'yyy-MM-dd');

---Adding a new column to the table called newtermdate 
alter table hr_data 
add new_termdate date;

----copying the new date format into it 
update hr_data
set new_termdate= case
when termdate is not null and isdate(termdate)= 1 then cast(termdate as datetime)else null end;

----Create age column and calculate age using birthdate column
alter table hr_data
add age nvarchar(50);
update hr_data
set age= datediff(YEAR,birthdate,getdate())

----Insights and questions based on data 

--1) whats the age distribution in the company 
---age distribution 
select min (age) as youngest,
       max (age) as oldest 
	   from hr_data;
	
	----age group 
	select age_group,
	count(*) as count
	from
	(select 
	 case
	 when age <=22 and age<=30 then '22 to 30'
	 when age <=31 and age<=40 then '31 to 40'
	 when age <=41 and age<=50 then '41 to 50'
	 else '50+' 
	 end as age_group
	   from hr_data
	   where new_termdate is null
)as subquery
group by age_group
order by age_group;


---distribution based on gender 
select age_group,gender,
	count(*) as count
	from
	(select 
	 case
	 when age <=22 and age<=30 then '22 to 30'
	 when age <=31 and age<=40 then '31 to 40'
	 when age <=41 and age<=50 then '41 to 50'
	 else '50+' 
	 end as age_group,gender
	   from hr_data
	   where new_termdate is null
)as subquery
group by age_group,gender
order by age_group,gender;


-----What is the gender breakdown in the company
select gender,
count (gender) as count
from hr_data
where new_termdate is null
group by gender 
order by gender asc;


----Varriation of gender accross departments and job roles 
select department,gender,
count (gender) as count
from hr_data
where new_termdate is null
group by department, gender 
order by department, gender asc;

-----via job titles 
select department,jobtitle,gender,
count (gender) as count
from hr_data
where new_termdate is null
group by department,jobtitle, gender 
order by department,jobtitle, gender asc;

-----Race distribution within the company
select race,
count(*) as count
from hr_data
where new_termdate is null
group by race  
order by count desc;


----Average term of employment within the company
select 
avg(datediff(year,hire_date,new_termdate))as tenure
from hr_data
where new_termdate is not null and new_termdate <=getdate();

-----Highest departmental turnover rate 
---total count 
---terminated total count 
---terminated total count / total count 
----turnover rate has been coverted to percentge to make more consice 
select department,
total_count,
terminated_count,
(round((cast(terminated_count as float)/total_count),2))*100 as turnover_rate
from
(Select
department,
count(*) as total_count,
sum(case 
    when new_termdate is not null and new_termdate<=getdate() then 1 else 0
	end
	) as terminated_count
	from hr_data
	group by department
	)
	as subquery 
	order by turnover_rate desc;

	----Tenure distribution for each department 
select department, 
avg(datediff(year,hire_date,new_termdate))as tenure
from hr_data
where new_termdate is not null and new_termdate <=getdate()
group by department 
order by tenure;

----Nummber of remote employees in each department
select location,
count(*) as count
from hr_data
where new_termdate is null
group by location;

-----distribution of employees accross different states 
select location_state,
count(*)as count
from hr_data
where new_termdate is null 
group by location_state
order by count desc;

-----Job title distribution in the company 
select jobtitle,
count(*)as count 
from hr_data
where new_termdate is null 
group by jobtitle
order by count desc;

---Employee hire count variation over time 
---calculate hires
----calculate terminations 
----(hires-terminations)/hires percentge hire change
select
hire_year,
hires,
terminations,
hires-terminations as net_change,
(round(cast(hires-terminations as float)/hires,2))*100 as percent_hire_change 
from
(select 
year(hire_date)as hire_year,
count(*)as hires,
sum(case
    when new_termdate is not null and new_termdate <= getdate() then 1 else 0
	end 
	) as terminations
	from hr_data
	group by year(hire_date)
	)as subquery
	order by percent_hire_change asc;

