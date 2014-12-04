/* ==================================================================== <HEADER>
Source      : sys-running-agent-steps.sql
Description :
============================================================== <PROGRAM HISTORY>
Date       Vers Name         Changes (Incident/Change Number)
---------- ---- ------------ --------------------------------------------------
  1       Created
======================================================================== <NOTES>

==================================================================== <SOURCE> */

set nocount on -- Stop de melding over aantal regels
set ansi_warnings on -- ISO foutmeldingen(NULL in aggregraat bv)
set ansi_nulls on -- ISO NULLL gedrag(field = null returns null, ook als field null is)

SELECT
    ja.job_id,
    j.name AS job_name,
    ja.start_execution_date,      
    ISNULL(last_executed_step_id,0)+1 AS current_executed_step_id,
    js.step_id,
    Js.step_name
FROM msdb.dbo.sysjobactivity ja 
LEFT JOIN msdb.dbo.sysjobhistory jh 
    ON ja.job_history_id = jh.instance_id
JOIN msdb.dbo.sysjobs j 
    ON ja.job_id = j.job_id
JOIN msdb.dbo.sysjobsteps js
    ON ja.job_id = js.job_id
--    AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
WHERE ja.session_id = (SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC)
AND start_execution_date is not null
AND stop_execution_date is null
and ja.job_id = 'EB1B7B74-011E-4666-8B81-CE2D9851829C'
order by js.step_id

/*
=====================================================================<KLADBLOK>


===============================================================================
*/
