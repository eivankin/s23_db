-- Normalized form
create table school (
    id int primary key,
    name varchar(255)
);

create table teacher (
    id int primary key,
    name varchar(255)
);

create table publisher (
    id int primary key,
    name varchar(255)
);

create table book (
    id int primary key,
    name varchar(255),
    publisherId int,
    foreign key (publisherId) references publisher (id)
);

create table room (
    id int primary key,
    name varchar(255),
    schoolId int,
    foreign key (schoolId) references school (id)
);

create table grade (
    id int primary key,
    name varchar(255)
);

create table course (
    id int primary key,
    name varchar(255)
);

create table loan_book (
    teacherId int,
    roomId int,
    courseId int,
    gradeId int,
    bookId int,
    loanDate date,
    foreign key (teacherId) references teacher (id),
    foreign key (roomId) references room (id),
    foreign key (courseId) references course (id),
    foreign key (gradeId) references grade (id),
    foreign key (bookId) references book (id),
    primary key (teacherId, roomId, courseId, gradeId, bookId)
);

-- Add data
insert into school(id, name)
values (1, 'Horizon Education Institute'),
       (2, 'Bright Institution');

insert into teacher(id, name)
values (1, 'Chad Russell'),
       (2, 'E.F.Codd'),
       (3, 'Jones Smith'),
       (4, 'Adam Baker');

insert into course(id, name)
values (1, 'Logical Thinking'),
       (2, 'Writing'),
       (3, 'Numerical Thinking'),
       (4, 'Spatial, Temporal and Causal Thinking'),
       (5, 'English');

insert into room(id, name, schoolId)
values (1, '1.A01', 1),
       (2, '1.B01', 1),
       (3, '2.B01', 2);

insert into publisher(id, name)
values (1, 'BOA Editions'),
       (2, 'Taylor & Francis Publishing'),
       (3, 'Prentice Hall'),
       (4, 'McGraw Hill');

insert into book(id, name, publisherId)
values (1, 'Learning and teaching in early childhood education', 1),
       (2, 'Preschool, N56', 2),
       (3, 'Early Childhood Education N9', 3),
       (4, 'Know how to educate: guide for Parents and Teachers', 4);

insert into grade(id, name)
values (1, '1st grade'),
       (2, '2nd grade');

insert into loan_book(teacherId, courseId, roomId, gradeId, bookId, loanDate)
values (1, 1, 1, 1, 1, '2010-09-09'),
       (1, 2, 1, 1, 2, '2010-05-05'),
       (1, 3, 1, 1, 1, '2010-05-05'),
       (2, 4, 2, 1, 3, '2010-05-06'),
       (2, 3, 2, 1, 1, '2010-05-06'),
       (3, 2, 1, 2, 1, '2010-09-09'),
       (3, 5, 1, 2, 4, '2010-05-05'),
       (4, 1, 3, 1, 4, '2010-12-18'),
       (4, 3, 3, 1, 1, '2010-05-06');

-- Queries
-- 1
select p.id, p.name, b.id, b.name, s.id, s.name from publisher p
join book b on p.id = b.publisherId
join loan_book lb on b.id = lb.bookId
join room r on lb.roomId = r.id
join school s on r.schoolId = s.id;

-- 2
select distinct s.*, b.*, p.* from school s
join room r on s.id = r.schoolId
join loan_book lb on r.id = lb.roomId
inner join (select s.id as schoolId, max(lb.loanDate) as max from school s
join room r on s.id = r.schoolId
join loan_book lb on r.id = lb.roomId group by s.id) y on s.id = y.schoolId and lb.loanDate = y.max
inner join book b on lb.bookId = b.id
inner join publisher p on b.publisherId = p.id;