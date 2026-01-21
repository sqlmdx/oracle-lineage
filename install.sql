@./src/expand_query

column script new_value script

select case when version like '12%' then 'parse_query_12.sql' else 'parse_query_23.sql' end script
from v$instance;

@./src/&script

@./src/format_parse_query