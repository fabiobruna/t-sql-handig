/* ==================================================================== <HEADER>
Source      : sys-all-jobs.sql
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
--    , [sDBP].[name] AS [JobOwner]
--    , [sCAT].[name] AS [JobCategory]
    , [sJOB].[description] AS [JobDescription]
    , CASE [sJOB].[enabled]
        WHEN 1 THEN 'Yes'
        WHEN 0 THEN 'No'
      END AS [IsEnabled]
    , [sJOB].[date_created] AS [JobCreatedOn]
    , [sJOB].[date_modified] AS [JobLastModifiedOn]
    , [sSVR].[name] AS [OriginatingServerName]
    , [sJSTP].[step_id] AS [JobStartStepNo]
    , [sJSTP].[step_name] AS [JobStartStepName]
    , CASE
        WHEN [sSCH].[schedule_uid] IS NULL THEN 'No'
        ELSE 'Yes'
      END AS [IsScheduled]
    , [sSCH].[schedule_uid] AS [JobScheduleID]
    , [sSCH].[name] AS [JobScheduleName]
/*    , CASE [sJOB].[delete_level]
        WHEN 0 THEN 'Never'
        WHEN 1 THEN 'On Success'
        WHEN 2 THEN 'On Failure'
        WHEN 3 THEN 'On Completion'
      END AS [JobDeletionCriterion] */
FROM
    [msdb].[dbo].[sysjobs] AS [sJOB]
    LEFT JOIN [msdb].[sys].[servers] AS [sSVR]
        ON [sJOB].[originating_server_id] = [sSVR].[server_id]
    LEFT JOIN [msdb].[dbo].[syscategories] AS [sCAT]
        ON [sJOB].[category_id] = [sCAT].[category_id]
    LEFT JOIN [msdb].[dbo].[sysjobsteps] AS [sJSTP]
        ON [sJOB].[job_id] = [sJSTP].[job_id]
        AND [sJOB].[start_step_id] = [sJSTP].[step_id]
    LEFT JOIN [msdb].[sys].[database_principals] AS [sDBP]
        ON [sJOB].[owner_sid] = [sDBP].[sid]
    LEFT JOIN [msdb].[dbo].[sysjobschedules] AS [sJOBSCH]
        ON [sJOB].[job_id] = [sJOBSCH].[job_id]
    LEFT JOIN [msdb].[dbo].[sysschedules] AS [sSCH]
        ON [sJOBSCH].[schedule_id] = [sSCH].[schedule_id]
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
