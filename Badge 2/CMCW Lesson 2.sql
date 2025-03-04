alter database THAT_REALLY_COOL_SAMPLE_STUFF
rename to snowflake_sample_data;

grant imported privileges
on database SNOWFLAKE_SAMPLE_DATA
to role SYSADMIN;


--Check the range of values in the Market Segment Column
select distinct c_mktsegment
from snowflake_sample_data.tpch_sf1.customer;

--Find out which Market Segments have the most customers
select c_mktsegment, count(*)
from snowflake_sample_data.tpch_sf1.customer
group by c_mktsegment
order by count(*);


//🥋 Join and Aggregate Shared Data

-- Nations Table
select n_nationkey, n_name, n_regionkey
from snowflake_sample_data.tpch_sf1.nation;


-- Regions Table
select r_regionkey, r_name
from snowflake_sample_data.tpch_sf1.region;


-- Join the Tables and Sort
select r_name as region, n_name as nation
from snowflake_sample_data.tpch_sf1.nation
join snowflake_sample_data.tpch_sf1.region
on n_regionkey = r_regionkey
order by r_name, n_name asc;

--Group and Count Rows Per Region
select r_name as region, count(n_name) as num_countries
from snowflake_sample_data.tpch_sf1.nation
join snowflake_sample_data.tpch_sf1.region
on n_regionkey = r_regionkey
group by r_name;



-- Dora we meet again

-- where did you put the function?
show user functions in account;

-- did you put it here?
select * 
from util_db.information_schema.functions
where function_name = 'GRADER'
and function_catalog = 'UTIL_DB'
and function_owner = 'ACCOUNTADMIN';