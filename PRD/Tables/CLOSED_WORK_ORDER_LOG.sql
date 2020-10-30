CREATE TABLE [PRD].[CLOSED_WORK_ORDER_LOG] (
    [ID_CLOSED_WORK_ORDER_LOG] INT            IDENTITY (1, 1) NOT NULL,
    [ID_WORK_ORDER]            INT            NOT NULL,
    [DS_EXPLANATION]           NVARCHAR (512) NOT NULL,
    [ID_ISSUE]                 INT            NULL,
    [KY_AUTHORIZER_USER]       NVARCHAR (50)  NOT NULL,
    [ID_QA27]                  INT            NOT NULL,
    [DT_CREATION]              DATETIME       NOT NULL,
    [DT_UPDATE]                DATETIME       NULL,
    [KY_USER_APP_CREATION]     NVARCHAR (50)  NOT NULL,
    [KY_USER_APP_UPDATE]       NVARCHAR (50)  NULL,
    [NM_PROGAM_CREATE]         NVARCHAR (50)  NOT NULL,
    [NM_PROGRAM_UPDATE]        NVARCHAR (50)  NULL
);

