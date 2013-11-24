/*
 *  File name:  setup.sql
 *  Function:   to create the intial database schema for the CMPUT 391 project,
 *              Fall, 2013
 *  Author:     Prof. Li-Yan Yuan
 */
DROP TABLE images;
DROP TABLE group_lists;
DROP TABLE groups;
DROP TABLE persons;
DROP TABLE users;


CREATE TABLE users (
   user_name varchar(24),
   password  varchar(24),
   date_registered date,
   primary key(user_name)
);

CREATE TABLE persons (
   user_name  varchar(24),
   first_name varchar(24),
   last_name  varchar(24),
   address    varchar(128),
   email      varchar(128),
   phone      char(10),
   PRIMARY KEY(user_name),
   UNIQUE (email),
   FOREIGN KEY (user_name) REFERENCES users
);


CREATE TABLE groups (
   group_id   int,
   user_name  varchar(24),
   group_name varchar(24),
   date_created date,
   PRIMARY KEY (group_id),
   UNIQUE (user_name, group_name),
   FOREIGN KEY(user_name) REFERENCES users
);

INSERT INTO groups values(1,null,'public', sysdate);
INSERT INTO groups values(2,null,'private',sysdate);

CREATE TABLE group_lists (
   group_id    int,
   friend_id   varchar(24),
   date_added  date,
   notice      varchar(1024),
   PRIMARY KEY(group_id, friend_id),
   FOREIGN KEY(group_id) REFERENCES groups,
   FOREIGN KEY(friend_id) REFERENCES users
);

CREATE TABLE images (
   photo_id    int,
   owner_name  varchar(24),
   permitted   int,
   subject     varchar(128),
   place       varchar(128),
   timing      date,
   description varchar(2048),
   thumbnail   blob,
   photo       blob,
   PRIMARY KEY(photo_id),
   FOREIGN KEY(owner_name) REFERENCES users,
   FOREIGN KEY(permitted) REFERENCES groups
);

/* End of original code. */
DROP SEQUENCE photo_id_sequence;
DROP SEQUENCE group_sequence;
DROP INDEX descriptionindex;
DROP INDEX subjectindex;
DROP INDEX placeindex;
DROP VIEW sum_cube;

/* Use this for generating photo_id sequence */
CREATE SEQUENCE photo_id_sequence;
CREATE SEQUENCE group_sequence MINVALUE 3;

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

create view sum_cube as 
select owner_name, subject, timing,TO_CHAR(timing, 'WW') as week,TO_CHAR(timing,'MM') as month,TO_CHAR(timing,'YYYY') as year, count(*) as count from images group by cube(owner_name,subject,timing);


