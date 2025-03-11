// 🥋 Use the ALTER Command to Add a New Column to Your Orders Table

alter table SMOOTHIES.PUBLIC.ORDERS add column name_on_order varchar(100);

insert into smoothies.public.orders(ingredients, name_on_order) values ('Dragon Fruit Honeydew Guava Apples Kiwi ', 'MellyMel');

select * from smoothies.public.orders;
//where name_on_order is not null;


// 1
// ajouter une colonne nommée ORDER_FILLED BOOLEAN, vous devez DEFAULT FALSE
// complete" or "filled.
ALTER TABLE SMOOTHIES.PUBLIC.ORDERS
ADD COLUMN ORDER_FILLED BOOLEAN DEFAULT FALSE;


// commande avant de remplir la base
update smoothies.public.orders
       set order_filled = true
       where name_on_order is null;