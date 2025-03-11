
/*Add the column SEARCH_ON, which will be what we use in the API call, instead of the fruit label seen in the GUI.
To add values to the new column you can use an UPDATE statement. UPDATE <table name> set SEARCH_ON = <search value> where FRUIT_NAME = 'Apple':
For any fruit already that already returns results, you can just copy the value into the new field. So for "Kiwi" the SEARCH_ON column will also say "Kiwi." An update statement could be written to set the SEARCH_ON = FRUIT_NAME for any row where SEARCH_ON is empty (or null). You could do this either before or after adding the custom values.

*/


select * from FRUIT_OPTIONS;

alter table fruit_options add column SEARCH_ON VARCHAR(25);


update fruit_options
set search_on = fruit_name;


// Apples, Blueberries, Jack Fruit, Raspberries and Strawberries
update fruit_options
set search_on = 'Apple'
where search_on = 'Apples';

update fruit_options
set search_on = 'Blueberry'
where search_on = 'Blueberries';

update fruit_options
set search_on = 'Jackfruit'
where search_on = 'Jack Fruit';

update fruit_options
set search_on = 'Dragonfruit'
where search_on = 'Dragon Fruit';

update fruit_options
set search_on = 'Raspberry'
where search_on = 'Raspberries';

update fruit_options
set search_on = 'Strawberry'
where search_on = 'Strawberries';




