﻿CREATE TABLE [PRD].[K_WORK_ORDER_TRANSITIONS] (
    [ID_WORK_ORDER_TRANSITION] INT            IDENTITY (1, 1) NOT NULL,
    [ID_WORK_ORDER]            INT            NOT NULL,
    [ID_TRANSITION]            INT            NOT NULL,
    [KY_TRANSITION]            NVARCHAR (50)  NOT NULL,
    [NM_TRANSITION]            NVARCHAR (100) NOT NULL,
    [NO_STANDARD_TIME]         INT            NOT NULL,
    [DT_CREATION]              DATETIME       NOT NULL,
    [DT_UPDATE]                DATETIME       NULL,
    [KY_USER_APP_CREATION]     NVARCHAR (50)  NOT NULL,
    [KY_USER_APP_UPDATE]       NVARCHAR (50)  NULL,
    [NM_PROGAM_CREATE]         NVARCHAR (50)  NOT NULL,
    [NM_PROGRAM_UPDATE]        NVARCHAR (50)  NULL,
    CONSTRAINT [PK_K_WORK_ORDER_TRANSITIONS] PRIMARY KEY CLUSTERED ([ID_WORK_ORDER_TRANSITION] ASC),
    CONSTRAINT [FK_K_WORK_ORDER_TRANSITIONS_C_TRANSITION] FOREIGN KEY ([ID_TRANSITION]) REFERENCES [PRD].[C_TRANSITION] ([ID_TRANSITION]),
    CONSTRAINT [FK_K_WORK_ORDER_TRANSITIONS_K_WORK_ORDER] FOREIGN KEY ([ID_WORK_ORDER]) REFERENCES [PRD].[K_WORK_ORDER] ([ID_WORK_ORDER])
);

