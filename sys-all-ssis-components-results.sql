use ssisdb

declare @id int
select @id = max(execution_id) from catalog.executables where executable_name = '%%'

print @id

select
    e.executable_id,
    e.execution_id,
    e.executable_name,
    e.package_name,
    e.package_path,
  CONVERT(datetime, es.start_time) AS start_time
, CONVERT(datetime, es.end_time) AS end_time
, datediff(mi, es.start_time, es.end_time) [looptijd in minuten]
, es.execution_result
, case es.execution_result
when 0 then 'Success'
when 1 then 'Failure'
     when 2 then 'Completion'
    when 3 then 'Cancelled'
  end  as execution_result_description
from catalog.executables e
join catalog.executable_statistics es
on  e.executable_id = es.executable_id
 and e.execution_id = es.execution_id
where e.execution_id = @id
 and package_path <> '\Package'
 and package_name not in ( 'XX' )
 and datediff(mi, es.start_time, es.end_time) > 5
order by es.execution_duration desc

-- where package_path  =  '\Package’


go
