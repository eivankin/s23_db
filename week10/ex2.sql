drop table if exists Account cascade;
create table Account
(
    id       serial primary key,
    username varchar(255) not null,
    fullname varchar(255) not null,
    balance  int          not null,
    group_id int not null
);

insert into Account (username, fullname, balance, group_id)
values ('jones', 'Alice Jones', 82, 1);
insert into Account (username, fullname, balance, group_id)
values ('bitdiddl', 'Ben Bitdiddle', 65, 1);
insert into Account (username, fullname, balance, group_id)
values ('mike', 'Michael Dole', 73, 2);
insert into Account (username, fullname, balance, group_id)
values ('alyssa', 'Alyssa P. Hacker', 79, 3);
insert into Account (username, fullname, balance, group_id)
values ('bbrown', 'Bob Brown', 100, 3);


set transaction isolation level read uncommitted;

-- Session 1
begin;
select * from Account;
-- Compare results x2


update Account set balance = balance + 10 where username = 'ajones';
-- Compare results
commit;


-- Session 2
begin;
update Account set username = 'ajones' where fullname = 'Alice Jones';
select * from Account;
-- In the second terminal username is updated, but stays the same in the first one
commit;
-- Username is updated in the first session after commit

begin;
update Account set balance = balance + 20 where username = 'ajones';
-- In the second session operation is not executed until the transaction in the first session is committed
rollback;

