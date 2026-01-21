/*
drop table tt1;
drop table tt2;
drop table tt3;
drop table tt4;
*/

create table tt1(a1, b1, c1) as select 1, 1, 1 from dual;

create table tt2(a2, b2, c2) as select 1, 1, 1 from dual;

create table tt3(a3, b3, c3) as select 1, 1, 1 from dual;

create table tt4(a4, b4, c4) as select 1, 1, 1 from dual;

create or replace view vvv as
select (x + c3) * tt3.a3 x1, t0.l - sign(b3) + (select max(c4+a4) from tt4) x2
  from (select tt1.b1 + (tt1.a1 + 1) * tt2.c2 x,
               length(substr('dummy', tt1.b1, tt2.b2)) l
          from tt1
          join tt2
            on tt1.a1 = tt2.a2) t0
 cross join tt3;