﻿CREATE TABLE [PRD].[C_FORM_PRODUCTION_LINE] (
    [ID_FORM_PRODUCTION_LINE] INT           IDENTITY (1, 1) NOT NULL,
    [ID_FORM]                 INT           NOT NULL,
    [ID_PRODUCTION_LINE]      INT           NOT NULL,
    [DT_CREATION]             DATETIME      NOT NULL,
    [DT_UPDATE]               DATETIME      NULL,
    [KY_USER_APP_CREATION]    NVARCHAR (50) NOT NULL,
    [KY_USER_APP_UPDATE]      NVARCHAR (50) NULL,
    [NM_PROGRAM_CREATE]       NVARCHAR (50) NOT NULL,
    [NM_PROGRAM_UPDATE]       NVARCHAR (50) NULL,
    CONSTRAINT [PK_C_FORM_PRODUCTION_LINE] PRIMARY KEY CLUSTERED ([ID_FORM_PRODUCTION_LINE] ASC),
    CONSTRAINT [FK_C_FORM_PRODUCTION_LINE_C_FORM] FOREIGN KEY ([ID_FORM]) REFERENCES [PRD].[C_FORM] ([ID_FORM]),
    CONSTRAINT [FK_C_FORM_PRODUCTION_LINE_C_PRODUCTION_LINE] FOREIGN KEY ([ID_PRODUCTION_LINE]) REFERENCES [PRD].[C_PRODUCTION_LINE] ([ID_PRODUCTION_LINE])
);

