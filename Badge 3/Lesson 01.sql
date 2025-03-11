-- 🎯 Create a Smoothies Database
-- Create a new database in your trial account.
-- Call it SMOOTHIES.
-- Make sure it is owned by the SYSADMIN Role.
-- The PUBLIC schema will also need to be owned by SYSADMIN.

USE ROLE SYSADMIN;
CREATE DATABASE SMOOTHIES;

-- 🎯 Create a FRUIT_OPTIONS Table
-- Create a table called FRUIT_OPTIONS in the PUBLIC schema of your SMOOTHIES database.
-- Make sure it owned by the SYSADMIN Role.
-- The table should have two columns:
-- First column should be named FRUIT_ID and hold a number.
-- Second column should be named FRUIT_NAME and hold text up to 25 characters long.
USE ROLE SYSADMIN;
CREATE TABLE SMOOTHIES.public.FRUIT_OPTIONS(
FRUIT_ID number,
FRUIT_NAME varchar(25)
 );


 create file format smoothies.public.two_headerrow_pct_delim
   type = CSV,
   skip_header = 2,
   field_delimiter = '%',
   trim_space = TRUE
;




SELECT $1, $2
FROM @smoothies.public.my_uploaded_files/fruits_available_for_smoothies.txt
(FILE_FORMAT => smoothies.public.two_headerrow_pct_delim);


COPY INTO smoothies.public.fruit_options
from @smoothies.public.my_uploaded_files
files = ('fruits_available_for_smoothies.txt')
file_format = (format_name = smoothies.public.two_headerrow_pct_delim)
on_error = abort_statement
validation_mode = return_errors
purge = true;




COPY INTO smoothies.public.fruit_options
from ( select $2 as FRUIT_ID, $1 as FRUIT_NAME
from @smoothies.public.my_uploaded_files/fruits_available_for_smoothies.txt )
file_format = (format_name = smoothies.public.two_headerrow_pct_delim)
on_error = abort_statement
purge = true;



