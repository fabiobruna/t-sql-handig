/* ==================================================================== <HEADER>
Source      : sys-show-all-processes-with-sql.sql
Description : Toon processen en eventueel de achterliggende SQL
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

select
    P.spid
,   right(convert(varchar,
            dateadd(ms, datediff(ms, P.last_batch, getdate()), '1900-01-01'),
            121), 12) as 'batch_duration'
,   P.program_name
,   P.hostname
,   P.loginame
from master.dbo.sysprocesses P
where P.spid > 50
and      P.status not in ('background', 'sleeping')
and      P.cmd not in ('AWAITING COMMAND'
                    ,'MIRROR HANDLER'
                    ,'LAZY WRITER'
                    ,'CHECKPOINT SLEEP'
                    ,'RA MANAGER')
order by batch_duration desc

return

declare
    @spid int
,   @stmt_start int
,   @stmt_end int
,   @sql_handle binary(20)

set @spid = XXX -- Fill this in

select  top 1
    @sql_handle = sql_handle
,   @stmt_start = case stmt_start when 0 then 0 else stmt_start / 2 end
,   @stmt_end = case stmt_end when -1 then -1 else stmt_end / 2 end
from    master.dbo.sysprocesses
where   spid = @spid
order by ecid

SELECT
    SUBSTRING(  text,
            COALESCE(NULLIF(@stmt_start, 0), 1),
            CASE @stmt_end
                WHEN -1
                    THEN DATALENGTH(text)
                ELSE
                    (@stmt_end - @stmt_start)
                END
        )
FROM ::fn_get_sql(@sql_handle)

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
