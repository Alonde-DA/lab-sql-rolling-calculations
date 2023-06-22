-- Get number of monthly active customers
with cte_transactions as (
	select account_id, convert(date, date) as Activity_date,
		date_format(convert(date,date), '%m') as Activity_Month,
		date_format(convert(date,date), '%Y') as Activity_year
	from bank.trans
)
select Activity_year, Activity_Month, count(distinct account_id) as Active_users
from cte_transactions
group by Activity_year, Activity_Month;

-- Active users in the previous month

with cte_transactions as (
	select account_id, convert(date, date) as Activity_date,
		date_format(convert(date,date), '%m') as Activity_Month,
		date_format(convert(date,date), '%Y') as Activity_year
	from bank.trans
), cte_active_users as (
	select Activity_year, Activity_Month, count(distinct account_id) as Active_users
	from cte_transactions
	group by Activity_year, Activity_Month
)
select Activity_year, Activity_month, Active_users, 
   lag(Active_users) over (order by Activity_year, Activity_Month) as Last_month
from cte_active_users;

-- Percentage change in the number of active customers

with cte_transactions as (
	select account_id, convert(date, date) as Activity_date,
		date_format(convert(date,date), '%m') as Activity_Month,
		date_format(convert(date,date), '%Y') as Activity_year
	from bank.trans
), cte_active_users as (
	select Activity_year, Activity_Month, count(distinct account_id) as Active_users
	from cte_transactions
	group by Activity_year, Activity_Month
), cte_active_users_prev as (
	select Activity_year, Activity_month, Active_users, 
	   lag(Active_users) over (order by Activity_year, Activity_Month) as Last_month
	from cte_active_users)
select *,
	(Active_users - Last_month) as Difference,
    concat(round((Active_users - Last_month)/Active_users*100), "%") as Percent_Difference
from cte_active_users_prev;

-- Retained customers every month

-- same as above as we already have the column with the difference of customers compared to last month in number and in percentage 
