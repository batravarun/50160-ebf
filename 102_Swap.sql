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

IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'ActivityWaitQueue_staging_tmp' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'ActivityWaitQueue_staging_tmp does not exist', 1;
	RETURN;
END;

IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'ActivityWaitQueue_staging' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'ActivityWaitQueue_staging does not exist', 1;
	RETURN;
END;

exec sp_rename 'InteractionStudio.ActivityWaitQueue_staging' , 'ActivityWaitQueue_staging_old';
exec sp_rename 'InteractionStudio.ActivityWaitQueue_staging_tmp' , 'ActivityWaitQueue_staging';


IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'ActivityWaitQueue_staging_old' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'ActivityWaitQueue_staging_old does not exist', 1;
	RETURN;
END;

IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'ActivityWaitQueue_staging' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'ActivityWaitQueue_staging does not exist', 1;
	RETURN;
END;

/*####################################################################
$$Sproc:  Swap AWQ staging table with a temp table and rename 
$$Author: Varun Batra
$$History:  
			2021-10-21 - VB	Created
#####################################################################*/
