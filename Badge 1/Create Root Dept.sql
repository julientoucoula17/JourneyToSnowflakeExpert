create or replace table ROOT_DEPTH (
   ROOT_DEPTH_ID number(1), 
   ROOT_DEPTH_CODE text(1), 
   ROOT_DEPTH_NAME text(7), 
   UNIT_OF_MEASURE text(2),
   RANGE_MIN number(2),
   RANGE_MAX number(2)
   ); 

   insert into root_depth 
values
(2, 'M', 'Medium', 'cm',
    45,
    60
)
;
insert into root_depth 
values
(3, 'D', 'Deep', 'cm',
    60,
    90
)
;
select * FROM GARDEN_PLANTS.VEGGIES.ROOT_DEPTH;