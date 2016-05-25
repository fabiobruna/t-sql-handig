SELECT
    D.name,
    F.Name AS FileType,
    F.physical_name AS PhysicalFile,
--    F.state_desc AS OnlineStatus,
    (F.size*8)/1024 AS FileSize,
    ((F.size*8)/1024)/1024 AS FileSizeGB
--    CAST(F.size*8 AS VARCHAR(32)) + ' Bytes' as SizeInBytes
FROM 
    sys.master_files F
    INNER JOIN sys.databases D ON D.database_id = F.database_id
ORDER BY
    FileSize desc