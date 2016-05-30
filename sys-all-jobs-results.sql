/* ==================================================================== <HEADER>
Source      : sys-all-jobs-results.sql
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

SELECT
    [sJOB].[job_id] AS [JobID]
    , [sJOB].[name] AS [JobName]
    , CASE
        WHEN [sJOBH].[run_date] IS NULL OR [sJOBH].[run_time] IS NULL THEN NULL
        ELSE CAST(
                CAST([sJOBH].[run_date] AS CHAR(8))
                + ' '
                + STUFF(
                    STUFF(RIGHT('000000' + CAST([sJOBH].[run_time] AS VARCHAR(6)),  6)
                        , 3, 0, ':')
                    , 6, 0, ':')
                AS DATETIME)
      END AS [LastRunDateTime]
    , CASE [sJOBH].[run_status]
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'Running' -- In Progress
      END AS [LastRunStatus]
    , STUFF(
            STUFF(RIGHT('000000' + CAST([sJOBH].[run_duration] AS VARCHAR(6)),  6)
                , 3, 0, ':')
            , 6, 0, ':')
        AS [LastRunDuration (HH:MM:SS)]
    , [sJOBH].[message] AS [LastRunStatusMessage]
    , CASE [sJOBSCH].[NextRunDate]
        WHEN 0 THEN NULL
        ELSE CAST(
                CAST([sJOBSCH].[NextRunDate] AS CHAR(8))
                + ' '
                + STUFF(
                    STUFF(RIGHT('000000' + CAST([sJOBSCH].[NextRunTime] AS VARCHAR(6)),  6)
                        , 3, 0, ':')
                    , 6, 0, ':')
                AS DATETIME)
      END AS [NextRunDateTime]
FROM
    [msdb].[dbo].[sysjobs] AS [sJOB]
    LEFT JOIN (
                SELECT
                    [job_id]
                    , MIN([next_run_date]) AS [NextRunDate]
                    , MIN([next_run_time]) AS [NextRunTime]
                FROM [msdb].[dbo].[sysjobschedules]
                GROUP BY [job_id]
            ) AS [sJOBSCH]
        ON [sJOB].[job_id] = [sJOBSCH].[job_id]
    LEFT JOIN (
                SELECT
                    [job_id]
                    , [run_date]
                    , [run_time]
                    , [run_status]
                    , [run_duration]
                    , [message]
                    , ROW_NUMBER() OVER (
                                            PARTITION BY [job_id]
                                            ORDER BY [run_date] DESC, [run_time] DESC
                      ) AS RowNumber
                FROM [msdb].[dbo].[sysjobhistory]
                WHERE [step_id] = 0
            ) AS [sJOBH]
        ON [sJOB].[job_id] = [sJOBH].[job_id]
        AND [sJOBH].[RowNumber] = 1
ORDER BY [JobName]


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
