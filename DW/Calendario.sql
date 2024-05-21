IF OBJECT_ID('dbo.[Calendar]', 'U') IS NOT NULL 
  DROP TABLE dbo.[Calendar]; 
CREATE TABLE [dbo].[Calendar](
			   		[DateKey] [int] NOT NULL,
   					[Date] [date] NOT NULL,
   					[Year] [int] NOT NULL,
   					[MatrixYear] [int] NOT NULL,
   					[Month] [int] NOT NULL,
   					[MonthName] [nvarchar](20) NOT NULL,
   					[MonthName3] [nvarchar](3) NOT NULL,
   					[Day] [int] NOT NULL,
   					[Week] [int] NOT NULL,
   					[MonthDay] [int] NOT NULL,
   					[DayMonth] [nvarchar](5) NOT NULL,
                    [DayName] [nvarchar](20),
					[DayName3] [nvarchar](3)
	CONSTRAINT [PK_Calendar] PRIMARY KEY CLUSTERED 
		(
   		[DateKey] ASC
		)WITH 
		(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY])

-- Load Calendar Table ==========================================================================
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @FromYear int = 0
    DECLARE @ToYear int = 0

    -------------------------------------------------------------------

    -- Insert statements for procedure here
    -- SET @FromYear = (SELECT YEAR(MIN([dbo].[SalesLine].[PostingDate])) FROM [dbo].[SalesLine])
    -- SET @ToYear = (SELECT YEAR(MAX([dbo].[SalesLine].[PostingDate])) FROM [dbo].[SalesLine]) + 1
    SET @FromYear = 1985
    SET @ToYear = 2050

    -------------------------------------------------------------------

    -- prevent set or regional settings from interfering with 
    -- interpretation of dates / literals
    SET DATEFIRST  1, -- 1 = Monday, 7 = Sunday

    --    DATEFORMAT dmy, 
    LANGUAGE   SPANISH;

    -- assume the above is here in all subsequent code blocks.
    DECLARE @StartDate  date = '20010101';
    SET @StartDate = CAST(CAST(@FromYear AS nvarchar) + '0101' AS date)

    DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 30, @StartDate));
    SET @CutoffDate =  DATEADD(DAY, 1, CAST(CAST(@ToYear AS nvarchar) + '1231' AS date))

    -------------------------------------------------------------------
    DELETE FROM [dbo].[Calendar]
    INSERT INTO [dbo].[Calendar]

    SELECT (YEAR(d)*10000) + (MONTH(d)*100) + DAY(d), 
            d, 
			YEAR(d), 
			YEAR(d), 
			MONTH(d), 
			UPPER(DATENAME(MONTH, d)), 
			SUBSTRING(UPPER(DATENAME(MONTH, d)), 1, 3),
			DAY(d), 
			DATEPART(WEEK,[d]), 
			MONTH(d) * 100 +  DAY(d),
			RIGHT('0' + CAST(DAY(d) as nvarchar), 2) + '/' + RIGHT('0' + CAST(MONTH(d) as nvarchar), 2),
			UPPER((SELECT FORMAT(d, 'dddd'))),
			UPPER((SUBSTRING((SELECT FORMAT(d, 'dddd')),1,3)))
    FROM
    (
        SELECT d = DATEADD(DAY, rn-1, @StartDate)
        FROM 
        (
        SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
                rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
        FROM    sys.all_objects AS s1
                CROSS JOIN sys.all_objects AS s2
                -- on my system this would support > 5 million days
        ORDER BY s1.[object_id]
        ) AS x
    ) AS y;
