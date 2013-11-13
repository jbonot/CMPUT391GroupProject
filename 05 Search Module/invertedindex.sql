CREATE INDEX imageindex
ON images(description)
INDEXTYPE IS CTXSYS.CONTEXT;

set serveroutput on
declare
  job number;
begin
  dbms_job.submit(job, 'ctx_ddl.sync_index(''imageindex'');',
                  interval=>'SYSDATE+30/1440');
  commit;
  dbms_output.put_line('job '||job||' has been submitted.');
end;
