// How many of my deliveries will be delayed due to snowfall?
/*
When it snows in excess of six inches per day, my company experiences delivery delays. How many of my deliveries were impacted during the third week of January for the previous year?
*/
WITH timestamps AS
(   
    SELECT
        DATE_TRUNC(year,DATEADD(year,-1,CURRENT_DATE())) AS ref_timestamp,
        LAST_DAY(DATEADD(week,2 + CAST(WEEKISO(ref_timestamp) != 1 AS INTEGER),ref_timestamp),week) AS end_week,
        DATEADD(day, day_num - 7, end_week) AS date_valid_std
    FROM
    (   
        SELECT
            ROW_NUMBER() OVER (ORDER BY SEQ1()) AS day_num
        FROM
            TABLE(GENERATOR(rowcount => 7))
    ) 
)
SELECT
    country,
    postal_code,
    date_valid_std,
    tot_snowfall_in 
FROM 
    standard_tile.history_day
NATURAL INNER JOIN
    timestamps
WHERE
    country='US' AND
    tot_snowfall_in > 6.0 
ORDER BY 
    postal_code,date_valid_std
;

// Determine if an event will be impacted by rain.
/*
I am hosting an outdoor event in seven days. How can I utilize your forecast data to determine if my event will be impacted by rain?
*/
SELECT COUNTRY,DATE_VALID_STD, POSTAL_CODE, DATEDIFF(day,current_date(),DATE_VALID_STD) AS DAY, HOUR(TIME_INIT_UTC) AS HOUR, TOT_PRECIPITATION_IN FROM STANDARD_TILE.FORECAST_DAY WHERE POSTAL_CODE='32333' AND DAY=7;

// Use temperature data to create sales forecast.
/*
Our company sells 70% more product when the temperature is in excess of 80 degrees and I am trying to create a product sales forecast for this upcoming July. How can we use your climatology data to quickly ascertain how many days “normally” exceed 80 degrees during the month of July?
*/
SELECT COUNTRY, POSTAL_CODE, SUM(IFF(AVG_OF__DAILY_MAX_TEMPERATURE_AIR_F>80, 1, 0)) DaysAbove80 FROM STANDARD_TILE.CLIMATOLOGY_DAY WHERE DOY_STD>=182 AND DOY_STD<=212 AND COUNTRY='US' GROUP BY COUNTRY,POSTAL_CODE ORDER BY DaysAbove80 DESC, COUNTRY, POSTAL_CODE;

//  Can my restaurant use weather to determine the amount of footfall traffic that we will have in the next week?
/*
Our restaurant has a significant amount of outdoor dining space. We need to determine staffing and demand based on the forecasted weather for next week.
*/
SELECT
    postal_code,
    country,
    date_valid_std,
    avg_temperature_air_2m_f,
    avg_humidity_relative_2m_pct,
    avg_wind_speed_10m_mph,
    tot_precipitation_in,
    tot_snowfall_in,
    avg_cloud_cover_tot_pct,
    probability_of_precipitation_pct,
    probability_of_snow_pct
FROM
(
    SELECT
        postal_code,
        country,
        date_valid_std,
        avg_temperature_air_2m_f,
        avg_humidity_relative_2m_pct,
        avg_wind_speed_10m_mph,
        tot_precipitation_in,
        tot_snowfall_in,
        avg_cloud_cover_tot_pct,
        probability_of_precipitation_pct,
        probability_of_snow_pct,
        DATEADD(DAY,1,CURRENT_DATE()) AS skip_date,
        DATEADD(DAY,7 - DAYOFWEEKISO(skip_date),skip_date) AS next_sunday
    FROM
        standard_tile.forecast_day
)
WHERE
    date_valid_std BETWEEN next_sunday AND DATEADD(DAY,6,next_sunday)
ORDER BY
    date_valid_std
;



alter database GLOBAL_WEATHER__CLIMATE_DATA_FOR_BI
rename to WEATHERSOURCE;

select distinct country, postal_code  from HISTORY_DAY where postal_code LIKE '481%' or postal_code LIKE '482%';



// 🎯 Convert Your Postal Code Query to a View
CREATE DATABASE MARKETING;
CREATE SCHEMA MAILERS;

CREATE VIEW MARKETING.MAILERS.DETROIT_ZIPS AS
select distinct postal_code
from WEATHERSOURCE.STANDARD_TILE.history_day
where country = 'US'
and left(postal_code,3) in ('481' , '482' );



SELECT COUNT(*) FROM WEATHERSOURCE.standard_tile.history_day WHERE left(postal_code,3) in ('481' , '482' 

SELECT count(*)
FROM WEATHERSOURCE.standard_tile.history_day hd
JOIN MARKETING.MAILERS.detroit_zips dz
ON hd.postal_code=dz.postal_code;

SELECT MIN(DATE_VALID_STD) FROM WEATHERSOURCE.standard_tile.history_day;
// MIN: 3 mars 2023
// MAX : 2 mars 2025


SELECT MIN(DATE_VALID_STD) FROM WEATHERSOURCE.standard_tile.FORECAST_DAY;
//MIN 2 mars 2025
// MAX : 18 mars 2025

SELECT MIN(DATE_VALID_STD), MAX(DATE_VALID_STD) FROM WEATHERSOURCE.standard_tile.CLIMATOLOGY_DAY;
//MIN 2 mars 2025
// MAX : 18 mars 2025



select POSTAL_CODE, DATE_VALID_STD, AVG_CLOUD_COVER_TOT_PCT  from WEATHERSOURCE.standard_tile.FORECAST_DAY 
where left(postal_code,3) in ('481' , '482' );
//group by postal_code, DATE_VALID_STD ORDER BY POSTAL_CODE, DATE_VALID_STD;



SELECT 
    fd.DATE_VALID_STD,
    fd.POSTAL_CODE,
    AVG(fd.AVG_CLOUD_COVER_TOT_PCT) AS AVG_CLOUD_COVER
FROM WEATHERSOURCE.standard_tile.FORECAST_DAY fd
JOIN marketing.mailers.detroit_zips dz
on fd.postal_code=dz.postal_code
GROUP BY fd.DATE_VALID_STD, fd.POSTAL_CODE
ORDER BY AVG_CLOUD_COVER ASC
LIMIT 1;







WITH DailyCloudCover AS (
    SELECT 
        fd.DATE_VALID_STD,
        fd.POSTAL_CODE,
        AVG(fd.AVG_CLOUD_COVER_TOT_PCT) AS AVG_CLOUD_COVER
    FROM WEATHERSOURCE.standard_tile.FORECAST_DAY fd
    JOIN marketing.mailers.detroit_zips dz
        ON fd.postal_code = dz.postal_code
    GROUP BY fd.DATE_VALID_STD, fd.POSTAL_CODE
),
RankedData AS (
    SELECT 
        DATE_VALID_STD,
        POSTAL_CODE,
        AVG_CLOUD_COVER,
        ROW_NUMBER() OVER (PARTITION BY DATE_VALID_STD ORDER BY AVG_CLOUD_COVER DESC, POSTAL_CODE ASC) AS rn
    FROM DailyCloudCover
)
SELECT 
    DATE_VALID_STD,
    POSTAL_CODE,
    AVG_CLOUD_COVER
FROM RankedData
WHERE rn = 1
ORDER BY DATE_VALID_STD;



SELECT date_valid_std, AVG(avg_cloud_cover_tot_pct)
FROM weathersource.standard_tile.forecast_day fd
JOIN marketing.mailers.detroit_zips dz
ON fd.postal_code=dz.postal_code
GROUP BY date_valid_std
ORDER BY date_valid_std, AVG(avg_cloud_cover_tot_pct) ;



