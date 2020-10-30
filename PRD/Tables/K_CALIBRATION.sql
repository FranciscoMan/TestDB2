CREATE TABLE [PRD].[K_CALIBRATION] (
    [ID_CALIBRATION]       INT             IDENTITY (1, 1) NOT NULL,
    [ID_WORK_ORDER]        INT             NOT NULL,
    [ID_QA27]              INT             NULL,
    [ID_BRANCH_PLANT]      INT             NULL,
    [MICROMETER]           INT             NULL,
    [FIRST_VALUE]          DECIMAL (10, 5) NULL,
    [SECOND_VALUE]         DECIMAL (10, 5) NULL,
    [THIRD_VALUE]          DECIMAL (10, 5) NULL,
    [TAPE_NUMBER]          INT             NULL,
    [TAPE_VALUE]           DECIMAL (10, 5) NULL,
    [FG_OPERATOR]          NVARCHAR (40)   NULL,
    [DT_CREATION]          DATETIME        NOT NULL,
    [DT_UPDATE]            DATETIME        NULL,
    [KY_USER_APP_CREATION] NVARCHAR (80)   NOT NULL,
    [KY_USER_APP_UPDATE]   NVARCHAR (80)   NULL,
    [NM_PROGRAM_CREATE]    NVARCHAR (80)   NOT NULL,
    [NM_PROGRAM_UPDATE]    NVARCHAR (80)   NULL,
    PRIMARY KEY CLUSTERED ([ID_CALIBRATION] ASC)
);

