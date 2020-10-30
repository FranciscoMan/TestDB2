﻿CREATE TABLE [ADM].[C_BRANCH_PLANT_TRANSITION] (
    [ID_BRANCH_PLANT_TRANSITION] INT            IDENTITY (1, 1) NOT NULL,
    [ID_BRANCH_PLANT]            INT            NOT NULL,
    [ID_TRANSITION]              INT            NOT NULL,
    [DT_CREATION]                DATE           NULL,
    [DT_UPDATE]                  DATE           NULL,
    [KY_USER_APP_CREATION]       NVARCHAR (50)  NULL,
    [KY_USER_APP_UPDATE]         NVARCHAR (50)  NULL,
    [NM_PROGRAM_CREATE]          NVARCHAR (100) NULL,
    [NM_PROGRAM_UPDATE]          NVARCHAR (100) NULL,
    CONSTRAINT [PK_C_BRANCH_PLANT_TRASITION] PRIMARY KEY CLUSTERED ([ID_BRANCH_PLANT_TRANSITION] ASC),
    CONSTRAINT [FK_C_BRANCH_PLANT_TRASITION_C_BRANCH_PLANT] FOREIGN KEY ([ID_BRANCH_PLANT]) REFERENCES [ADM].[C_BRANCH_PLANT] ([ID_BRANCH_PLANT]),
    CONSTRAINT [FK_C_BRANCH_PLANT_TRASITION_C_TRANSITION] FOREIGN KEY ([ID_TRANSITION]) REFERENCES [PRD].[C_TRANSITION] ([ID_TRANSITION])
);
