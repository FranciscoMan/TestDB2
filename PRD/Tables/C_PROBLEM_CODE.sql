﻿CREATE TABLE [PRD].[C_PROBLEM_CODE] (
    [ID_PROBLEM_CODE]      INT            IDENTITY (1, 1) NOT NULL,
    [KY_PROBLEM_CODE]      NVARCHAR (50)  NOT NULL,
    [NM_PROBLEM_CODE]      NVARCHAR (100) NOT NULL,
    [FG_ACTIVE]            BIT            NOT NULL,
    [ID_BRANCH_PLANT]      INT            NULL,
    [KY_CODE_TYPE]         NVARCHAR (10)  NULL,
    [ID_PROBLEM_AREA]      INT            NOT NULL,
    [DT_CREATION]          DATETIME       NOT NULL,
    [DT_UPDATE]            DATETIME       NULL,
    [KY_USER_APP_CREATION] NVARCHAR (50)  NOT NULL,
    [KY_USER_APP_UPDATE]   NVARCHAR (50)  NULL,
    [NM_PROGAM_CREATE]     NVARCHAR (50)  NOT NULL,
    [NM_PROGRAM_UPDATE]    NVARCHAR (50)  NULL,
    CONSTRAINT [PK_C_PROBLEM_CODE] PRIMARY KEY CLUSTERED ([ID_PROBLEM_CODE] ASC),
    CONSTRAINT [FK_C_PROBLEM_CODE_C_BRANCH_PLANT] FOREIGN KEY ([ID_BRANCH_PLANT]) REFERENCES [ADM].[C_BRANCH_PLANT] ([ID_BRANCH_PLANT]),
    CONSTRAINT [FK_C_PROBLEM_CODE_C_PROBLEM_AREA] FOREIGN KEY ([ID_PROBLEM_AREA]) REFERENCES [PRD].[C_PROBLEM_AREA] ([ID_PROBLEM_AREA])
);
