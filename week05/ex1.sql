-- 1
select max(y.enrollment) as max_enrollment, min(y.enrollment) as min_enrollment
from (select count(distinct id) as enrollment
from takes
group by sec_id) y;

-- 2
select sec_id, enrollment
from (select sec_id, count(distinct id) as enrollment
from takes
group by sec_id) a
where enrollment = (
        select max(b.enrollment)
        from (select count(distinct id) as enrollment
              from takes
              group by sec_id) b
        )
group by sec_id, enrollment;

-- 3
-- insert test data
insert into section values ('BIO-101', '3', 'Summer', '2023', 'Painter', '514', 'B');
-- left outer join
select max(y.enrollment) as max_enrollment, min(y.enrollment) as min_enrollment
from (select count(distinct t.id) as enrollment from section s
left outer join takes t on s.sec_id = t.sec_id
group by s.sec_id) y;
-- scalar subquery
-- TODO

-- 4
select * from course
where course_id like 'CS-1%';

-- 5
select name from instructor
where dept_name = 'Biology';

-- 6

-- 7
