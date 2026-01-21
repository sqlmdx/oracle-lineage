create or replace procedure parsequery(user in varchar2, sqltext in clob, lobloc in out nocopy clob) is
external
name "kuxParseQuery"
language c
library sys.utl_xml_lib
with context
parameters(context
          ,user ocistring
          ,user indicator sb4
          ,sqltext ociloblocator
          ,sqltext indicator sb4
          ,lobloc ociloblocator
          ,lobloc indicator sb4);
/

create or replace function parse_query(sql_text in clob) return xmltype is
    l_clob   clob;
    result   xmltype;
begin
    dbms_lob.createtemporary(l_clob, true);
    parsequery(user, sql_text, l_clob);
    result   := xmltype.createxml(l_clob);
    dbms_lob.freetemporary(l_clob);
    return result;
end;
/