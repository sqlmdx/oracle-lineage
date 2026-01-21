create or replace view dba_column_dependencies as
select d.owner, d.name, d.referenced_owner, d.referenced_name, c.column_name referenced_column
from (select u.name owner
            ,o.name
            ,decode(po.linkname, null, pu.name, po.remoteowner) referenced_owner
            ,po.name referenced_name
            ,substr(d.d_attrs, 5) col_mask
      from sys."_CURRENT_EDITION_OBJ" o, sys.disk_and_fixed_objects po, sys.dependency$ d, sys.user$ u, sys.user$ pu
      where o.obj# = d.d_obj# and o.owner# = u.user# and po.obj# = d.p_obj# and po.owner# = pu.user#) d
     join dba_tab_cols c
         on d.referenced_owner = c.owner
        and d.referenced_name = c.table_name
        and bitand(to_number(d.col_mask default 0 on conversion error, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'), power(2, c.column_id)) > 0;

grant select on dba_column_dependencies to public;

create or replace public synonym dba_column_dependencies for sys.dba_column_dependencies;