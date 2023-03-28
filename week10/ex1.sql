-- Part A
DROP TABLE IF EXISTS Account;
CREATE TABLE IF NOT EXISTS Account
(
    account_id integer PRIMARY KEY,
    name       varchar(255) NOT NULL,
    credit     int          NOT NULL,
    currency   varchar(5)   NOT NULL
);


INSERT INTO Account
VALUES (1, 'Account 1', 1000, 'RUB'),
       (2, 'Account 2', 1000, 'RUB'),
       (3, 'Account 3', 1000, 'RUB');

drop function if exists transfer(from_account integer, to_account integer, amount integer);
create function transfer(from_account integer, to_account integer, amount integer) returns void
    language plpgsql
as
$$
declare
    balance int;
begin
    if from_account = to_account then
        raise exception 'Cannot transfer to the same account.';
    end if;
    select credit into balance from Account where account_id = from_account;
    if balance < amount then
        raise exception 'Insufficient funds.';
    end if;
    update Account set credit = credit - amount where account_id = from_account;
    update Account set credit = credit + amount where account_id = to_account;
end;
$$;

begin;
savepoint t1;
select transfer(1, 3, 500);
-- rollback to t1;
commit;

begin;
savepoint t2;
select transfer(2, 1, 700);
-- rollback to t2;
commit;

begin;
savepoint t3;
select transfer(2, 3, 100);
-- rollback to t3;
commit;

select name, credit
from Account;