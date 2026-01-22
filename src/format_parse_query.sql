create or replace type to_lineage as object
(
    schema  varchar2(30),
    tbl     varchar2(30),
    alias   varchar2(30),
    src_col varchar2(30),
    tgt_col varchar2(30),
    depth   int
)
/

create or replace type tt_lineage as table of to_lineage
/

create or replace function format_parse_query(sql_text clob) return tt_lineage as
    result tt_lineage;
begin
    select to_lineage(schema, tbl, alias, src_col, tgt_col, is_top)
    bulk collect into result
    from xmltable('//SELECT_LIST_ITEM' 
                  passing parse_query(expand_query(sql_text))
                  columns 
                    tgt_col varchar2(30) path 'COLUMN_ALIAS',
                    is_top  varchar2(30) path 'count(ancestor::*)',
                    orig    xmltype      path '.'
         ) sel,
         xmltable('//COLUMN_REF' 
                  passing sel.orig
                  columns
                    schema  varchar2(30) path 'SCHEMA',
                    tbl     varchar2(30) path 'TABLE',
                    alias   varchar2(30) path 'TABLE_ALIAS',
                    src_col varchar2(30) path 'COLUMN'
         ) col;
    return result;
end;
/