SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET QUOTED_IDENTIFIER ON;
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('InteractionStudio.ActivityWaitQueue_staging_old')  AND [name] = N'IX_ActivityWaitQueue_staging_old_MidDefinitionID')
BEGIN
	CREATE NONCLUSTERED INDEX IX_ActivityWaitQueue_staging_old_MidDefinitionID ON InteractionStudio.ActivityWaitQueue_staging_old(Mid,DefinitionID)
		WITH (ONLINE=ON, DATA_COMPRESSION=PAGE);
END
GO


/*####################################################################
$$Sproc:  Create AWQ staging table temp with index
$$Author: Varun Batra
$$History:  
			2021-10-21 - VB	Created
#####################################################################*/