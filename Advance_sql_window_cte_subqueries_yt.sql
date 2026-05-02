-- using join

select employee_demographics.employee_id
from employee_demographics
join employee_salary on employee_demographics.employee_id = employee_salary.employee_id
where employee_salary.dept_id = 1;


--using subqueries

select *
from employee_demographics
where employee_id in 
                    (select employee_id
                      from employee_salary 
					  where dept_id=1);

-- adding columns using subqueries

select first_name, salary,
 (select avg(salary)
 from employee_salary)
from employee_salary;


--WINDOW

--window funtion - to get groupby but with additional columns

select first_name, dept_id, avg(salary) over(partition by dept_id)
from employee_salary;

--to just gt dept average we use group by

select dept_id, avg(salary)
from employee_salary
group by dept_id;

-- to calculate cumulative

select dept_id,salary, sum(salary) over (partition by dept_id order by employee_id)
from employee_salary;

-- to give row number
-- row number will give diff/random rank to similar salary. instead we use rank
-- using rank will skip the rank after giving two same rank , instead we use dense rank 
select employee_demographics.employee_id, dept_id, salary, row_number () over (partition by gender order by salary desc),
rank ()  over (partition by gender order by salary desc),
dense_rank () over (partition by gender order by salary desc)
from employee_demographics
join employee_salary on employee_demographics.employee_id = employee_salary.employee_id;



 --CTE COMMON TABLE EXPRESSION 
 -- this is cleaner version of subquerries
 -- BRACKETS OF CTE CAN BE USED TP GIVE ALIAS NAME TO COLUMNS

with CTE_EXAMPLE AS 
( 

select employee_id
from employee_salary 
where dept_id=1
)

select dem.employee_id, dept_id, salary
from employee_demographics as dem
JOIN Employee_salary on dem.employee_id = employee_salary.employee_id
where dem.employee_id in 
                    (select dem.employee_id
					 from CTE_EXAMPLE);


 
               

