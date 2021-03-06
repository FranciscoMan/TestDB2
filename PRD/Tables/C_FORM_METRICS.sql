﻿CREATE TABLE [PRD].[C_FORM_METRICS] (
    [ID_FORM_METRICS]              INT           IDENTITY (1, 1) NOT NULL,
    [ID_FORM]                      INT           NOT NULL,
    [ID_METRICS]                   INT           NOT NULL,
    [FG_VALIDATE_METRICS]          BIT           CONSTRAINT [DF_C_FORM_METRICS_FG_VALIDATE_METRICS] DEFAULT ((0)) NOT NULL,
    [KY_VARIABLE_ACQUISITION_TYPE] NVARCHAR (10) CONSTRAINT [DF_C_FORM_METRICS_KY_ACQUISITION_VARIABLE_TYPE] DEFAULT (N'ALWAYS') NOT NULL,
    [DT_CREATION]                  DATETIME      NOT NULL,
    [DT_UPDATE]                    DATETIME      NULL,
    [KY_USER_APP_CREATION]         NVARCHAR (50) NOT NULL,
    [KY_USER_APP_UPDATE]           NVARCHAR (50) NULL,
    [NM_PROGAM_CREATE]             NVARCHAR (50) NOT NULL,
    [NM_PROGRAM_UPDATE]            NVARCHAR (50) NULL,
    CONSTRAINT [PK_C_FORM_METRICS] PRIMARY KEY CLUSTERED ([ID_FORM_METRICS] ASC),
    CONSTRAINT [FK_C_FORM_METRICS_C_FORM] FOREIGN KEY ([ID_FORM]) REFERENCES [PRD].[C_FORM] ([ID_FORM]),
    CONSTRAINT [FK_C_FORM_METRICS_C_METRICS] FOREIGN KEY ([ID_METRICS]) REFERENCES [PRD].[C_METRICS] ([ID_METRICS])
);

