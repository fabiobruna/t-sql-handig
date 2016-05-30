/* ==================================================================== <HEADER>
Source      : sys-all-ssis-components-results.sql
Description :
============================================================== <PROGRAM HISTORY>
Date       Vers Name         Changes (Incident/Change Number)
---------- ---- ------------ --------------------------------------------------
  1       Created
Mutaties: http://dwh.mchaaglanden.local/gitphp/?sort=age
======================================================================== <NOTES>

select format ( getdate(), 'yyyy-MM-dd' ) AS FormattedDate;
SELECT FORMAT(getdate(), N'yyyy-MM-dd hh:mm') AS FormattedDateTime;
[NT-DK-CCPRO-P].[CCPro].[dbo].
[nt-vm-dwh-p3].dwh_ezis.dbo.
[HIXR.mchbrv.nl].[HIX_PRODUCTIE].[dbo].

==================================================================== <SOURCE> */

set nocount on -- Stop de melding over aantal regels
set ansi_warnings on -- ISO foutmeldingen(NULL in aggregraat bv)
set ansi_nulls on -- ISO NULLL gedrag(field = null returns null, ook als field null is)


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

/*
=====================================================================<KLADBLOK>

select distinct
 tabel,
 kolomnaam,
 length
from
(
select distinct
  t2.name as tabel,
  t3.rows,
  t1.name as kolomnaam,
  t1.length
from dbo.syscolumns t1
  join dbo.sysobjects t2
   on t2.id = t1.id
  left join dbo.sysindexes t3
   on t3.id = t1.id and t3.name = t2.name
where upper(t2.name) like '%%'        -- tabel
and upper(t1.name) like '%%'        -- kolom
) t0 group by tabel, kolomnaam, length
order by 1

===============================================================================
*/

