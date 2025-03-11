USE ROLE SYSADMIN;

//🥋 Create a Place to Store Order Data
//Create a table in your SMOOTHIES database.
//Make sure it is owned by SYSADMIN.
//Name it ORDERS.
//Give it a single 200 character-limit text column named INGREDIENTS.

create table SMOOTHIES.PUBLIC.ORDERS(
ingredients varchar(200)
);

insert into smoothies.public.orders(ingredients) values ('Cantaloupe Blueberries Guava Jackfruit ');

truncate table smoothies.public.orders;