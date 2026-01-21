create or replace function expand_query(sql_text in clob) return clob as
  result clob;
begin
  dbms_utility.expand_sql_text(sql_text, result);
  return result;
end;
/