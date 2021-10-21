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
    CREATE TABLE InteractionStudio.ActivityWaitQueue_staging_tmp
    (
		ActivityWaitQueue_staging_Id UNIQUEIDENTIFIER NOT NULL DEFAULT(NEWID()),
        --QueueID BIGINT NOT NULL IDENTITY,
        DefinitionID UNIQUEIDENTIFIER NOT NULL,
        ActivityID UNIQUEIDENTIFIER NOT NULL,
        InstanceDefinitionID UNIQUEIDENTIFIER NOT NULL,
        InstanceActivityID UNIQUEIDENTIFIER NOT NULL,
        ContactID BIGINT NOT NULL DEFAULT ((0)),
        ContactKey NVARCHAR(200) NULL,
        ContactType TINYINT NOT NULL DEFAULT ((0)),
		TimesProcessed INT NULL  DEFAULT ((0)),
        WaitStartDate DATETIME NOT NULL,
        WaitEndDate DATETIME NULL,
        ProcessingID UNIQUEIDENTIFIER NOT NULL DEFAULT ('00000000-0000-0000-0000-000000000000'),
        --Stamp TIMESTAMP NOT NULL,
        IsProcessed BIT NOT NULL DEFAULT ((0)),
        IsLocked BIT NOT NULL DEFAULT ((0)),
        IsActive BIT NOT NULL DEFAULT ((1)),
        Status TINYINT NOT NULL DEFAULT ((1)),
        CreateDate DATETIME NOT NULL DEFAULT (GETDATE()),
        ModifyDate DATETIME NOT NULL DEFAULT (GETDATE()),
        MID BIGINT NOT NULL,
        EID BIGINT NOT NULL,
		SourceId UNIQUEIDENTIFIER NULL,
		SourceType SMALLINT NULL,
		SourceInstanceID UNIQUEIDENTIFIER NULL,
		ExitCriteriaLastChecked DATETIME NULL,
		--RequestObject NVARCHAR(max) NULL,
		WaitingForEventID UNIQUEIDENTIFIER NULL,
		--StatusFlags AS 
		--	 [IsProcessed]*POWER(2,2)
		--	+[IsLocked]*POWER(2,1)
		--	+[IsActive]
		--PERSISTED NOT NULL,
		Q1RequestObjectId UNIQUEIDENTIFIER NOT NULL,		-- NOT NULL since we only accept AWQ records that have RequestObject BLOB stored in Q1RequestObject table
		Q1RequestObjectIsOutOfRow BIT NOT NULL,				-- NOT NULL for same reason as above. This value should be always 1 in this staging table

		AdditionalDetails NVARCHAR(250) NULL,
		EventSource	SMALLINT NULL,
		WaitType SMALLINT NULL,

		CONSTRAINT PK_ActivityWaitQueue_staging_tmp_Id_cl 
			PRIMARY KEY CLUSTERED (ActivityWaitQueue_staging_Id) 
			WITH FILLFACTOR = 70							--FF = 70 since this table is highly volatile & we want to avoid page splits
    )
	WITH(DATA_COMPRESSION=ROW);
END;
GO

/*####################################################################
$$Table:  InteractionStudio.ActivityWaitQueue_staging_tmp 
$$Author: Varun Batra
$$History:  
			2021-10-21 - VB	Created
#####################################################################*/
