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
	
	DECLARE @BatchSize		INT = 500,
	@ShowReport		BIT = 1;

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

	DECLARE @TotalRecordsInserted INT = 0, @RecordsInserted INT = 0;
	DECLARE @ErrorCode INT, @Continue BIT = 1;

	
	DECLARE @ImportedFromAWQStaging BIT = 1;

	--Create the Temp table, with schema same as [InteractionStudio].[ActivityWaitQueue_staging], except all fields are NULLable
	CREATE TABLE #ActivityWaitQueue_staging_Batch
    (
		ActivityWaitQueue_staging_Id UNIQUEIDENTIFIER,
        --QueueID BIGINT  IDENTITY,
        DefinitionID UNIQUEIDENTIFIER,
        ActivityID UNIQUEIDENTIFIER ,
        InstanceDefinitionID UNIQUEIDENTIFIER ,
        InstanceActivityID UNIQUEIDENTIFIER ,
        ContactID BIGINT  ,
        ContactKey NVARCHAR(200) ,
        ContactType TINYINT  ,
		TimesProcessed INT   ,
        WaitStartDate DATETIME ,
        WaitEndDate DATETIME ,
        ProcessingID UNIQUEIDENTIFIER ,
        --Stamp TIMESTAMP ,
        IsProcessed BIT  ,
        IsLocked BIT  ,
        IsActive BIT  ,
        Status TINYINT  ,
        CreateDate DATETIME ,
        ModifyDate DATETIME ,
        MID BIGINT ,
        EID BIGINT ,
		SourceId UNIQUEIDENTIFIER ,
		SourceType SMALLINT ,
		SourceInstanceID UNIQUEIDENTIFIER ,
		ExitCriteriaLastChecked DATETIME ,
		--RequestObject NVARCHAR(max) ,
		WaitingForEventID UNIQUEIDENTIFIER ,
		--StatusFlags AS 
		--	 [IsProcessed]*POWER(2,2)
		--	+[IsLocked]*POWER(2,1)
		--	+[IsActive]
		--PERSISTED ,
		Q1RequestObjectId UNIQUEIDENTIFIER ,		--  since we only accept AWQ records that have RequestObject BLOB stored in Q1RequestObject table
		Q1RequestObjectIsOutOfRow BIT ,				--  for same reason as above. This value should be always 1 in this staging table

		AdditionalDetails NVARCHAR(250) ,
		EventSource	SMALLINT ,
		WaitType SMALLINT 
    )
	WITH(DATA_COMPRESSION=ROW);

	DECLARE @ActivityWaitQueue_staging_Batch TABLE (
		InstanceDefinitionID			UNIQUEIDENTIFIER,
		ActivityWaitQueue_staging_Id	UNIQUEIDENTIFIER		
	
		PRIMARY KEY ( InstanceDefinitionID, ActivityWaitQueue_staging_Id )
	);


	BEGIN TRY
		WHILE(@Continue = 1)
		BEGIN		
			--cleanup
			TRUNCATE TABLE #ActivityWaitQueue_staging_Batch;

			BEGIN TRANSACTION;

			DELETE TOP (@BatchSize) 
			FROM [InteractionStudio].[ActivityWaitQueue_staging_old]	
			OUTPUT
					 deleted.[ActivityWaitQueue_staging_Id]
					,deleted.[DefinitionID]   ,deleted.[ActivityID]   ,deleted.[InstanceDefinitionID]   ,deleted.[InstanceActivityID]   ,deleted.[ContactID]   ,deleted.[ContactKey]   ,deleted.[ContactType]
					,deleted.[TimesProcessed]      ,deleted.[WaitStartDate]	  ,deleted.[WaitEndDate]      ,deleted.[ProcessingID]      ,deleted.[IsProcessed]      ,deleted.[IsLocked]      ,deleted.[IsActive]
					,deleted.[Status]      ,deleted.[CreateDate]      ,deleted.[ModifyDate]      ,deleted.[MID]      ,deleted.[EID]     ,deleted.[SourceId]      ,deleted.[SourceType]
					,deleted.[SourceInstanceID]      ,deleted.[ExitCriteriaLastChecked]      ,deleted.[WaitingForEventID]      ,deleted.[Q1RequestObjectId]      ,deleted.[Q1RequestObjectIsOutOfRow]
					,deleted.[AdditionalDetails]	 ,deleted.[EventSource], deleted.[WaitType]
			INTO #ActivityWaitQueue_staging_Batch
				(
					 [ActivityWaitQueue_staging_Id]
					,[DefinitionID]   ,[ActivityID]   ,[InstanceDefinitionID]   ,[InstanceActivityID]   ,[ContactID]   ,[ContactKey]   ,[ContactType]
					,[TimesProcessed]      ,[WaitStartDate]	  ,[WaitEndDate]      ,[ProcessingID]      ,[IsProcessed]      ,[IsLocked]      ,[IsActive]
					,[Status]      ,[CreateDate]      ,[ModifyDate]      ,[MID]      ,[EID]     ,[SourceId]      ,[SourceType]
					,[SourceInstanceID]      ,[ExitCriteriaLastChecked]      ,[WaitingForEventID]      ,[Q1RequestObjectId]      ,[Q1RequestObjectIsOutOfRow]
					,[AdditionalDetails]	 ,[EventSource], [WaitType]
				)
			WHERE MID!=510004599;
	
			INSERT INTO [InteractionStudio].[ActivityWaitQueue]
					([DefinitionID]      ,[ActivityID]      ,[InstanceDefinitionID]      ,[InstanceActivityID]      ,[ContactID]      ,[ContactKey]      ,[ContactType]      ,[TimesProcessed]      ,[WaitStartDate]
					,[WaitEndDate]      ,[ProcessingID]      ,[IsProcessed]      ,[IsLocked]      ,[IsActive]      ,[Status]      ,[CreateDate]      ,[ModifyDate]      ,[MID]      ,[EID]     ,[SourceId]      ,[SourceType]
					,[SourceInstanceID]      ,[ExitCriteriaLastChecked]      ,[WaitingForEventID]      ,[Q1RequestObjectId]      ,[Q1RequestObjectIsOutOfRow]	,[ImportedFromAWQStaging]	,[ImportedDate]		
					,[AdditionalDetails]	,[EventSource]	,[WaitType])	
			SELECT [DefinitionID]      ,[ActivityID]      ,[InstanceDefinitionID]      ,[InstanceActivityID]      ,[ContactID]      ,[ContactKey]      ,[ContactType]      ,[TimesProcessed]      ,[WaitStartDate]
					,[WaitEndDate]      ,[ProcessingID]      ,[IsProcessed]      ,[IsLocked]      ,[IsActive]      ,[Status]      ,[CreateDate]      ,[ModifyDate]      ,[MID]      ,[EID]     ,[SourceId]      ,[SourceType]
					,[SourceInstanceID]      ,[ExitCriteriaLastChecked]      ,[WaitingForEventID]      ,[Q1RequestObjectId]      ,[Q1RequestObjectIsOutOfRow]	,@ImportedFromAWQStaging	, GETDATE()
					,[AdditionalDetails]	,[EventSource]	,[WaitType]
			FROM #ActivityWaitQueue_staging_Batch;

			SELECT @RecordsInserted = @@ROWCOUNT;

			COMMIT TRANSACTION;

			SELECT @TotalRecordsInserted = @TotalRecordsInserted + @RecordsInserted;
			IF (@RecordsInserted = 0)
			BEGIN
				SELECT @Continue = 0;
			END;
		END;			--WHILE
		
		IF (@ShowReport = 1)
		BEGIN
			SELECT @TotalRecordsInserted AS TotalRecordsInserted;
		END;

	END TRY
	BEGIN CATCH
		SELECT @ErrorCode = @@ERROR;

		-- Unique index violation situation - save data before rollback
		IF (@ErrorCode = 2601)
		BEGIN
			--cleanup
			DELETE FROM @ActivityWaitQueue_staging_Batch;

			--Store the ActivityWaitQueue_staging_Id, InstanceDefinitionID involved in the exception to a table variable. # temp table will be rolled back when Transaction rolls back.
			INSERT INTO @ActivityWaitQueue_staging_Batch (InstanceDefinitionID, ActivityWaitQueue_staging_Id) SELECT InstanceDefinitionID, ActivityWaitQueue_staging_Id FROM #ActivityWaitQueue_staging_Batch;
		END;

		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		--Handle AWQ [InstanceDefinitionID] Unique index violation situation. 
		IF (@ErrorCode = 2601)
		BEGIN
			--ensure records in the Batch selected from [InteractionStudio].[ActivityWaitQueue_staging_old] table has no active (IsActive = 1) InstanceDefinitionID duplicates based on 
			--	[InteractionStudio].[ActivityWaitQueue] : InstanceDefinitionID , IsActive ( =1) AND IsProcessed ( =0)
			UPDATE [InteractionStudio].[ActivityWaitQueue_staging_old] WITH (ROWLOCK)
				SET IsActive = 0,
					AdditionalDetails = 'Duplicate Active & UnProcessed InstanceDefinitionID found between AWQ staging & AWQ table. This record was set IsActive=0 in AWQ staging table on ' + CONVERT(NVARCHAR(30), GETDATE(), 113)
			WHERE ActivityWaitQueue_staging_Id IN 
					(
						SELECT batch.ActivityWaitQueue_staging_Id
						FROM [InteractionStudio].[ActivityWaitQueue] (NOLOCK) awq
							INNER JOIN @ActivityWaitQueue_staging_Batch batch 
								ON awq.InstanceDefinitionID = batch.InstanceDefinitionID AND awq.IsActive = 1 AND awq.IsProcessed = 0
					);
		END;
	
		-- Throw the original exception, so we can log in splunk
		THROW;
	END CATCH;
GO



/*####################################################################
$$Sproc:  Migrate from AWQ_old to AWQ
$$Author: Varun Batra
$$History:  
			2021-10-21 - VB	Created
#####################################################################*/