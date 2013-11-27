--Materialize the data cube into a view
create view sum_cube as 
select owner_name, subject, timing,TO_CHAR(timing, 'WW') as week,TO_CHAR(timing,'MM') as month,TO_CHAR(timing,'YYYY') as year, count(*) as count from images group by cube(owner_name,subject,timing);

--Add the default 
insert into users values('admin','adminpassword',sysdate);
