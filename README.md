`oracle-lineage` – generic column lineage for Oracle
=============================================================

Introduction
------------

Oracle does not provide lineage functionality out of the box
but it has all the necessary components to build it.

* If we want to see all column dependencies for a given object we can get that by re-using logic from `dba_dependencies`.
This view relies on `sys.dependency$` which has a column `d.d_attrs` containing bit mask for all columns used from a referenced table.
With this knowledge we can create view `dba_column_dependencies` in `sys` schema.

* `dba_column_dependencies` shows all columns referenced for a particular object.
If we want to get all column dependencies for a given query we can create a view and utilize `dba_column_dependencies`.
But this does not help to answer - which source columns are used for specific target columns.
In order to get this we can leverage the following:
    * `dbms_utility.expand_sql_text`
    * `utl_xml.parsequery` which is based on libray `UTL_XML_LIB`.

Installation
------------

This was tested on Oracle 12 and Oracle 23. In order to install objects in user schema it must have `execute` privilege on `UTL_XML_LIB`.

    $ git clone https://github.com/sqlmdx/oracle-lineage.git
    $ cd oracle-lineage

Connect with sqlplus and run

    SQL> @install

In order to deploy `dba_column_dependencies` you need to connect as `sysdba`.

Usage
-----

Let's create sample objects

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

We can see all columns referenced in `vvv` with `dba_column_dependencies`.

    SQL> column name format a20
    SQL> column referenced_name format a20
    SQL> column referenced_column format a20
    SQL> select name, referenced_name, referenced_column
      2  from dba_column_dependencies
      3  where name = 'VVV';

    NAME                 REFERENCED_NAME      REFERENCED_COLUMN
    -------------------- -------------------- --------------------
    VVV                  TT1                  A1
    VVV                  TT1                  B1
    VVV                  TT2                  A2
    VVV                  TT2                  B2
    VVV                  TT2                  C2
    VVV                  TT3                  A3
    VVV                  TT3                  B3
    VVV                  TT3                  C3
    VVV                  TT4                  A4
    VVV                  TT4                  C4

    10 rows selected.

Above shows columns referenced in any part of the query. For example, `tt2.a2` appears in join condition but never used in `select list`.

Now, if we want to see what source columns contribute to specific target columns we can do the following.

    SQL> column tbl format a20
    SQL> column src_col format a20
    SQL> column dst_col format a20
    SQL> select tbl, src_col, connect_by_root dst_col dst_col
      2  from table(format_parse_query('select * from vvv')) t
      3  where tbl is not null
      4  start with is_top = 1
      5  connect by prior src_col = dst_col and prior alias != alias
      6  order by 1, 2, 3;

    TBL                  SRC_COL              DST_COL
    -------------------- -------------------- --------------------
    TT1                  A1                   X1
    TT1                  B1                   X1
    TT1                  B1                   X2
    TT2                  B2                   X2
    TT2                  C2                   X1
    TT3                  A3                   X1
    TT3                  B3                   X2
    TT3                  C3                   X1
    TT4                  A4                   X2
    TT4                  C4                   X2

    10 rows selected.

Contribution
------------

If you're lacking some functionality in `oracle-lineage` then you're welcome to make pull requests.