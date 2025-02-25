//🥋 Create a Table & File Format for Nested JSON Data


// Create an Ingestion Table for the NESTED JSON Data
create or replace table library_card_catalog.public.nested_ingest_json 
(
  raw_nested_book VARIANT
);


COPY INTO library_card_catalog.public.nested_ingest_json FROM (
select $1
from @util_db.public.my_internal_stage/json_book_author_nested.txt
(file_format => library_card_catalog.public.json_file_format));

select raw_nested_book
from library_card_catalog.public.nested_ingest_json;


select raw_nested_book:year_published
from library_card_catalog.public.nested_ingest_json;

select raw_nested_book:authors
from library_card_catalog.public.nested_ingest_json;



/////////////////////////

//🥋 Use the FLATTEN COMMAND on Nested Data



//Use these example flatten commands to explore flattening the nested book and author data
select value:first_name
from nested_ingest_json
,lateral flatten(input => raw_nested_book:authors);

select value:first_name
from nested_ingest_json
,table(flatten(raw_nested_book:authors));

//Add a CAST command to the fields returned
SELECT value:first_name::varchar, value:last_name::varchar
from nested_ingest_json
,lateral flatten(input => raw_nested_book:authors);

//Assign new column  names to the columns using "AS"
select value:first_name::varchar as first_nm
, value:last_name::varchar as last_nm
from nested_ingest_json
,lateral flatten(input => raw_nested_book:authors);



//🎯 Create the Tweets Database Infrastructure 
//Create a database named SOCIAL_MEDIA_FLOODGATES
use role sysadmin;
create database SOCIAL_MEDIA_FLOODGATES;

//Create a table called TWEET_INGEST in the PUBLIC schema of your new database. The new table only needs 1 column (you should know the datatype, since this is JSON data). Name the column RAW_STATUS
create or replace table SOCIAL_MEDIA_FLOODGATES.public.TWEET_INGEST 
(
  RAW_STATUS VARIANT
);

//Create a FILE FORMAT that is type JSON that you can use to load the file.
// Write a COPY INTO statement that loads the tweet data into the table. You will probably need to stage the file somewhere - you can decide where.
// After loading the file, you should end up with 9 separate rows. One tweet per row.
use role ACCOUNTADMIN;
COPY INTO SOCIAL_MEDIA_FLOODGATES.public.TWEET_INGEST FROM(
select $1
from @util_db.public.my_internal_stage/nutrition_tweets.json
(file_format => library_card_catalog.public.json_file_format));

select raw_status
from tweet_ingest;

select raw_status:entities
from tweet_ingest;

select raw_status:entities:hashtags
from tweet_ingest;


//Explore looking at specific hashtags by adding bracketed numbers
//This query returns just the first hashtag in each tweet
select raw_status:entities:hashtags[0].text
from tweet_ingest;

//This version adds a WHERE clause to get rid of any tweet that 
//doesn't include any hashtags
select raw_status:entities:hashtags[0].text
from tweet_ingest
where raw_status:entities:hashtags[0].text is not null;

//Perform a simple CAST on the created_at key
//Add an ORDER BY clause to sort by the tweet's creation date
select raw_status:created_at::date
from tweet_ingest
order by raw_status:created_at::date;

 
//Flatten statements can return nested entities only (and ignore the higher level objects)
select value
from tweet_ingest
,lateral flatten
(input => raw_status:entities:urls);

select value
from tweet_ingest
,table(flatten(raw_status:entities:urls));


//Flatten and return just the hashtag text, CAST the text as VARCHAR
select value:text::varchar as hashtag_used
from tweet_ingest
,lateral flatten
(input => raw_status:entities:hashtags);


//Add the Tweet ID and User ID to the returned table so we could join the hashtag back to it's source tweet
select raw_status:user:name::text as user_name
,raw_status:id as tweet_id
,value:text::varchar as hashtag_used
from tweet_ingest
,lateral flatten
(input => raw_status:entities:hashtags);


create or replace view social_media_floodgates.public.urls_normalized as
(select raw_status:user:name::text as user_name
,raw_status:id as tweet_id
,value:display_url::text as url_used
from tweet_ingest
,lateral flatten
(input => raw_status:entities:urls)
);

select * from social_media_floodgates.public.urls_normalized;


create or replace view social_media_floodgates.public.HASHTAGS_NORMALIZED as 
(select raw_status:user:name::text as user_name
,raw_status:id as tweet_id
,value:text::varchar as hashtag_used
from tweet_ingest
,lateral flatten
(input => raw_status:entities:hashtags));

select * from social_media_floodgates.public.HASHTAGS_NORMALIZED;
