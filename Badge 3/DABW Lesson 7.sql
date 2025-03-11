set mystery_bag = 'This bag is empty!!';
select $mystery_bag;
set var1 = 2;
set var2 = 5;
set var3 = 7;
select $var1+$var2+$var3;



// 🥋 Create a Simple User Defined Function (UDF)
USE SMOO
create function sum_mystery_bag_vars(var1 number, var2 number, var3 number)
returns number as 'select var1+var2+var3';

select sum_mystery_bag_vars(12,36,204);

set eeny = 4;
set meeny = 67.2;
set miney_mo = -39;
select sum_mystery_bag_vars ($eeny, $meeny,$miney_mo);




//Combining UDFs with Snowflake Functions
/*🎯 CHALLENGE LAB:  Write a UDF that Neutralizes Alternating Caps Phrases!
Your function should be in the UTIL_DB.PUBLIC schema.
Your function should be named NEUTRALIZE_WHINING
Your function should accept a single variable of type TEXT. It won't matter what you name the variable.
Your function should return a TEXT value.
The value returned should be in formatted so that the first letter of each word is capitalized and all other letters are lower case. (HINT: Use INITCAP() in your function code with your variable name inside)
Test your code and make sure it works, because on the next page, you'll need to prove it works!*/

create function UTIL_DB.PUBLIC.NEUTRALIZE_WHINING(var1 text)
returns text as 'select INITCAP(var1)';



SELECT UTIL_DB.PUBLIC.NEUTRALIZE_WHINING('FKHDZFKZEHDKSLKC');



