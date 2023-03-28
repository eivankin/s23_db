-- Part A
DROP TABLE IF EXISTS Ledger;
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

drop procedure if exists transfer(from_account integer, to_account integer, amount integer);
create procedure transfer(from_account integer, to_account integer, amount integer)
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
call transfer(1, 3, 500);

savepoint t2;
call transfer(2, 1, 700);

savepoint t3;
call transfer(2, 3, 100);

rollback to t1;
commit;

select name, credit
from Account;

-- Part B
ALTER TABLE Account
    ADD COLUMN bank_name text;
UPDATE Account
SET bank_name = 'SberBank'
WHERE account_id = 1;
UPDATE Account
SET bank_name = 'Tinkoff'
WHERE account_id = 2;
UPDATE Account
SET bank_name = 'SberBank'
WHERE account_id = 3;

insert into account
values (4, 'Fee receiver', 0, 'RUB', 'Secret');

drop procedure if exists transfer(from_account integer, to_account integer, amount integer);
create procedure transfer(from_account integer, to_account integer, amount integer)
    language plpgsql
as
$$
declare
    balance         int;
    fee             int     = 0;
    fee_receiver_id integer = 4;
begin
    if from_account = to_account then
        raise exception 'Cannot transfer to the same account.';
    end if;
    select credit into balance from Account where account_id = from_account;
    if (select bank_name from Account where account_id = from_account) !=
       (select bank_name from Account where account_id = to_account) then
        fee = 30;
    end if;
    if balance < amount + fee then
        raise exception 'Insufficient funds.';
    end if;

    update Account set credit = credit - amount - fee where account_id = from_account;
    update Account set credit = credit + amount where account_id = to_account;
    update Account set credit = credit + fee where account_id = fee_receiver_id;
end;
$$;

begin;
savepoint t1;
call transfer(1, 3, 500);

savepoint t2;
call transfer(2, 1, 700);

savepoint t3;
call transfer(2, 3, 100);

rollback to t1;
commit;

select name, credit
from Account;


-- Part C
DROP TABLE IF EXISTS Ledger;
CREATE TABLE IF NOT EXISTS Ledger
(
    lid                   serial PRIMARY KEY,
    from_id               integer   NOT NULL,
    to_id                 integer   NOT NULL,
    fee                   integer   NOT NULL,
    amount                integer   NOT NULL,
    transaction_date_time timestamp NOT NULL,
    FOREIGN KEY (from_id) REFERENCES Account (account_id),
    FOREIGN KEY (to_id) REFERENCES Account (account_id)
);

drop procedure if exists transfer(from_account integer, to_account integer, amount integer);
create procedure transfer(from_account integer, to_account integer, amount integer)
    language plpgsql
as
$$
declare
    balance         int;
    fee             int     = 0;
    fee_receiver_id integer = 4;
begin
    if from_account = to_account then
        raise exception 'Cannot transfer to the same account.';
    end if;
    select credit into balance from Account where account_id = from_account;
    if (select bank_name from Account where account_id = from_account) !=
       (select bank_name from Account where account_id = to_account) then
        fee = 30;
    end if;
    if balance < amount + fee then
        raise exception 'Insufficient funds.';
    end if;

    update Account set credit = credit - amount - fee where account_id = from_account;
    update Account set credit = credit + amount where account_id = to_account;
    update Account set credit = credit + fee where account_id = fee_receiver_id;
    insert into Ledger(from_id, to_id, fee, amount, transaction_date_time)
    values (from_account, to_account, fee, amount, now());
end;
$$;

begin;
savepoint t1;
call transfer(1, 3, 500);

savepoint t2;
call transfer(2, 1, 700);

savepoint t3;
call transfer(2, 3, 100);
-- rollback to t1;
commit;

select name, credit
from Account;
select * from Ledger;