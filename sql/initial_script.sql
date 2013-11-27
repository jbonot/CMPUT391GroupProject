--Materialize the data cube into a view
DROP VIEW sum_cube;
create view sum_cube as 
select owner_name, subject, timing,TO_CHAR(timing, 'WW') as week,TO_CHAR(timing,'MM') as month,TO_CHAR(timing,'YYYY') as year, count(*) as count from images group by cube(owner_name,subject,timing);

--add sequences needed
DROP SEQUENCE photo_id_sequence;
DROP SEQUENCE group_sequence;
CREATE SEQUENCE photo_id_sequence;
CREATE SEQUENCE group_sequence MINVALUE 3;

--add indexes
DROP INDEX descriptionindex;
DROP INDEX subjectindex;
DROP INDEX placeindex;
CREATE INDEX descriptionindex
ON images(description)
INDEXTYPE IS CTXSYS.CONTEXT;

CREATE INDEX subjectindex
ON images(subject)
INDEXTYPE IS CTXSYS.CONTEXT;

CREATE INDEX placeindex
ON images(place)
INDEXTYPE IS CTXSYS.CONTEXT;

@drjobdml descriptionindex 1
@drjobdml subjectindex 1
@drjobdml placeindex 1

--Add image count table
DROP TABLE image_count;
CREATE TABLE image_count (
    photo_id    int,
    user_name   varchar(24),
    PRIMARY KEY(photo_id, user_name),
    FOREIGN KEY(photo_id) REFERENCES images,
    FOREIGN KEY(user_name) REFERENCES users
);

--Add image view table, counting distinct users for each photo_id
DROP VIEW image_view;
CREATE VIEW image_view AS
SELECT photo_id, COUNT(*) AS head_count, DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk FROM image_count GROUP BY photo_id;

--Add the default 
insert into users values('admin','adminpassword',sysdate);
