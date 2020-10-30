﻿CREATE TABLE [PRD].[K_LINE_METRICS_ACQUISITION] (
    [ID_LINE_METRICS_ACQUISITION] INT           IDENTITY (1, 1) NOT NULL,
    [ID_LINE_METRICS]             INT           NOT NULL,
    [ID_DEVICE_METRICS]           INT           NOT NULL,
    [DT_CREATION]                 DATETIME      NOT NULL,
    [DT_UPDATE]                   DATETIME      NULL,
    [KY_USER_APP_CREATION]        NVARCHAR (50) NOT NULL,
    [KY_USER_APP_UPDATE]          NVARCHAR (50) NULL,
    [NM_PROGAM_CREATE]            NVARCHAR (50) NOT NULL,
    [NM_PROGRAM_UPDATE]           NVARCHAR (50) NULL,
    CONSTRAINT [PK_K_LINE_METRICS_ACQUISITION] PRIMARY KEY CLUSTERED ([ID_LINE_METRICS_ACQUISITION] ASC),
    CONSTRAINT [FK_K_LINE_METRICS_ACQUISITION_C_DEVICE_METRICS] FOREIGN KEY ([ID_DEVICE_METRICS]) REFERENCES [PRD].[C_DEVICE_METRICS] ([ID_DEVICE_METRICS]),
    CONSTRAINT [FK_K_LINE_METRICS_ACQUISITION_C_LINE_METRIC] FOREIGN KEY ([ID_LINE_METRICS]) REFERENCES [PRD].[C_LINE_METRIC] ([ID_LINE_METRIC])
);
