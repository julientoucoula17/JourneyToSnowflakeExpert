use role SYSADMIN;

create database INTL_DB;

use schema INTL_DB.PUBLIC;




//🥋 Create a Warehouse for Loading INTL_DB

use role SYSADMIN;

create warehouse INTL_WH 
with 
warehouse_size = 'XSMALL' 
warehouse_type = 'STANDARD' 
auto_suspend = 600 --600 seconds/10 mins
auto_resume = TRUE;

use warehouse INTL_WH;


//🥋 Create Table INT_STDS_ORG_3166

create or replace table intl_db.public.INT_STDS_ORG_3166 
(iso_country_name varchar(100), 
 country_name_official varchar(200), 
 sovreignty varchar(40), 
 alpha_code_2digit varchar(2), 
 alpha_code_3digit varchar(3), 
 numeric_country_code integer,
 iso_subdivision varchar(15), 
 internet_domain_code varchar(10)
);



//🥋 Create a File Format to Load the Table

create or replace file format util_db.public.PIPE_DBLQUOTE_HEADER_CR 
  type = 'CSV' --use CSV for any flat file
  compression = 'AUTO' 
  field_delimiter = '|' --pipe or vertical bar
  record_delimiter = '\r' --carriage return
  skip_header = 1  --1 header row
  field_optionally_enclosed_by = '\042'  --double quotes
  trim_space = FALSE;




  // create stage Amazon S3

  create stage util_db.public.aws_s3_bucket url = 's3://uni-cmcw';

  // List files in bucket S3
  list @util_db.public.aws_s3_bucket;
        // s3://uni-cmcw/ISO_Countries_UTF8_pipe.csv
        // s3://uni-cmcw/Lotties_LotStock_Data.csv
        // ....


copy into INT_STDS_ORG_3166
from @util_db.public.aws_s3_bucket
files = ( 'ISO_Countries_UTF8_pipe.csv')
file_format = ( format_name='UTIL_DB.PUBLIC.PIPE_DBLQUOTE_HEADER_CR' );


//🥋 Check That You Created and Loaded the Table Properly
select count(*) as found, '249' as expected 
from INTL_DB.PUBLIC.INT_STDS_ORG_3166; 

// 📓  How to Test Whether You Set Up Your Table in the Right Place with the Right Name

select count(*) as OBJECTS_FOUND
from INTL_DB.INFORMATION_SCHEMA.TABLES 
where table_schema='PUBLIC'
and table_name= 'INT_STDS_ORG_3166';


// 📓  How to Test That You Loaded the Expected Number of Rows
select row_count
from INTL_DB.INFORMATION_SCHEMA.TABLES 
where table_schema='PUBLIC'
and table_name= 'INT_STDS_ORG_3166';




//🥋 Join Local Data with Shared Data
select  
     iso_country_name
    ,country_name_official,alpha_code_2digit
    ,r_name as region
from INTL_DB.PUBLIC.INT_STDS_ORG_3166 i
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
on upper(i.iso_country_name)= n.n_name
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
on n_regionkey = r_regionkey;


//🥋 Convert the Select Statement into a View
create view intl_db.public.NATIONS_SAMPLE_PLUS_ISO 
( iso_country_name
  ,country_name_official
  ,alpha_code_2digit
  ,region) AS
  select  
     iso_country_name
    ,country_name_official,alpha_code_2digit
    ,r_name as region
from INTL_DB.PUBLIC.INT_STDS_ORG_3166 i
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
on upper(i.iso_country_name)= n.n_name
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
on n_regionkey = r_regionkey;

//🥋 Run a SELECT on the View You Created
select *
from intl_db.public.NATIONS_SAMPLE_PLUS_ISO;








// Create a few more tables and load them
LIST @util_db.public.aws_s3_bucket;
    // s3://uni-cmcw/currencies.csv
    // s3://uni-cmcw/country_code_to_currency_code.csv

// create table currencies
create table intl_db.public.CURRENCIES 
(
  currency_ID integer, 
  currency_char_code varchar(3), 
  currency_symbol varchar(4), 
  currency_digital_code varchar(3), 
  currency_digital_name varchar(30)
)
  comment = 'Information about currencies including character codes, symbols, digital codes, etc.';

// create table country_code_to_currency_code
create table intl_db.public.COUNTRY_CODE_TO_CURRENCY_CODE 
  (
    country_char_code varchar(3), 
    country_numeric_code integer, 
    country_name varchar(100), 
    currency_name varchar(100), 
    currency_char_code varchar(3), 
    currency_numeric_code integer
  ) 
  comment = 'Mapping table currencies to countries';

// create file format
create file format util_db.public.CSV_COMMA_LF_HEADER
  type = 'CSV' 
  field_delimiter = ',' 
  record_delimiter = '\n' -- the n represents a Line Feed character
  skip_header = 1 
;

  
copy into intl_db.public.CURRENCIES 
from @util_db.public.aws_s3_bucket
files = ( 'currencies.csv')
file_format = ( format_name='UTIL_DB.PUBLIC.CSV_COMMA_LF_HEADER' );
// => 151 rows


copy into intl_db.public.COUNTRY_CODE_TO_CURRENCY_CODE 
from @util_db.public.aws_s3_bucket
files = ( 'country_code_to_currency_code.csv')
file_format = ( format_name='UTIL_DB.PUBLIC.CSV_COMMA_LF_HEADER' );
// => 265 rows




create view intl_db.public.SIMPLE_CURRENCY AS 
select COUNTRY_CHAR_CODE AS CTY_CODE, CURRENCY_CHAR_CODE AS CUR_CODE from intl_db.public.COUNTRY_CODE_TO_CURRENCY_CODE;


