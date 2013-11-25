insert into users values('bob123', 'bobpassword', sysdate);
insert into users values('alice456', 'alicepassword', sysdate);
insert into users values('matwood', 'margaretpassword', sysdate);
insert into users values('admin', 'adminpassword', sysdate);

insert into persons values('bob123', 'Bob', 'Barker', '199 Right Price Drive', 'bob@priceisright.com', '555-1234');
insert into persons values('alice456', 'Alice', 'Munroe', '31 Wingham Street', 'amunro@books.ca', '555-1931');
insert into persons values('matwood', 'Margaret', 'Atwood', '18 Blind Court', 'matwood@margaretatwood.ca', '555-1939');
insert into persons values('admin', 'Administrator', '', '', 'admin@admin.ca', '555-5555');


select group_sequence.nextVal from dual;
insert into groups values(3, 'matwood', 'authors', sysdate);
select group_sequence.nextVal from dual;
insert into groups values(4, 'bob123', 'spies', sysdate);

insert into group_lists values(3, 'matwood', sysdate, 'notice');
insert into group_lists values(3, 'alice456', sysdate, 'notice');
insert into group_lists values(4, 'alice456', sysdate, 'notice');
insert into group_lists values(4, 'bob123', sysdate, 'notice');

select photo_id_sequence.nextVal from dual;
insert into images values(1, 'bob123', 1, 'fruit', 'the orchard', sysdate, 'a bunch of apples from the tree', EMPTY_BLOB(), EMPTY_BLOB());

select photo_id_sequence.nextVal from dual;
insert into images values(2, 'bob123', 2, 'animals', 'my house', sysdate, 'all my 27 kitty cats', EMPTY_BLOB(), EMPTY_BLOB());

select photo_id_sequence.nextVal from dual;
insert into images values(3, 'alice456', 1, 'vacation', 'hawaii', sysdate, 'vacation in hawaii', EMPTY_BLOB(), EMPTY_BLOB());

select photo_id_sequence.nextVal from dual;
insert into images values(4, 'alice456', 2, 'drinks', 'cafe', sysdate, 'cup of tea', EMPTY_BLOB(), EMPTY_BLOB());

select photo_id_sequence.nextVal from dual;
insert into images values(5, 'matwood', 3, 'books', 'library', sysdate, 'sample cover for books', EMPTY_BLOB(), EMPTY_BLOB());

select photo_id_sequence.nextVal from dual;
insert into images values(6, 'matwood', 3, 'books', 'store of books', sysdate, 'look at all these books', EMPTY_BLOB(), EMPTY_BLOB());

select photo_id_sequence.nextVal from dual;
insert into images values(7, 'matwood', 3, 'books books', 'store of books', sysdate, 'books look at all these books', EMPTY_BLOB(), EMPTY_BLOB());

select photo_id_sequence.nextVal from dual;
insert into images values(8, 'matwood', 3, 'where the wild books are', 'the store of books', sysdate, 'books look at all these books', EMPTY_BLOB(), EMPTY_BLOB());

select photo_id_sequence.nextVal from dual;
insert into images values(9, 'bob123', 1, 'furniture', 'my room', sysdate, 'I placed my books on the shelf', EMPTY_BLOB(), EMPTY_BLOB());
