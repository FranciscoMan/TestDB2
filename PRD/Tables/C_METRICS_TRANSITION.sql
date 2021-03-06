﻿CREATE TABLE [PRD].[C_METRICS_TRANSITION] (
    [ID_METRICS_TRANSITION] INT           IDENTITY (1, 1) NOT NULL,
    [ID_METRICS]            INT           NOT NULL,
    [ID_TRANSITION]         INT           NOT NULL,
    [DT_CREATION]           DATETIME      NOT NULL,
    [DT_UPDATE]             DATETIME      NULL,
    [KY_USER_APP_CREATION]  NVARCHAR (50) NOT NULL,
    [KY_USER_APP_UPDATE]    NVARCHAR (50) NULL,
    [NM_PROGRAM_CREATE]     NVARCHAR (50) NOT NULL,
    [NM_PROGRAM_UPDATE]     NVARCHAR (50) NULL,
    CONSTRAINT [PK_C_METRICS_TRANSITION] PRIMARY KEY CLUSTERED ([ID_METRICS_TRANSITION] ASC),
    CONSTRAINT [FK_C_METRICS_TRANSITION_C_METRICS] FOREIGN KEY ([ID_METRICS]) REFERENCES [PRD].[C_METRICS] ([ID_METRICS]),
    CONSTRAINT [FK_C_METRICS_TRANSITION_C_TRANSITION] FOREIGN KEY ([ID_TRANSITION]) REFERENCES [PRD].[C_TRANSITION] ([ID_TRANSITION])
);

