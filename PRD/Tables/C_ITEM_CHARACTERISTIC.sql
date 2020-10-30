﻿CREATE TABLE [PRD].[C_ITEM_CHARACTERISTIC] (
    [ID_ITEM_CHARACTERISTIC] INT           IDENTITY (1, 1) NOT NULL,
    [ID_ITEM]                INT           NOT NULL,
    [ID_METRICS]             INT           NOT NULL,
    [XML_FIELD_SETTINGS]     XML           NOT NULL,
    [DT_CREATION]            DATETIME      NOT NULL,
    [DT_UPDATE]              DATETIME      NULL,
    [KY_USER_APP_CREATION]   NVARCHAR (50) NOT NULL,
    [KY_USER_APP_UPDATE]     NVARCHAR (50) NULL,
    [NM_PROGAM_CREATE]       NVARCHAR (50) NOT NULL,
    [NM_PROGRAM_UPDATE]      NVARCHAR (50) NULL,
    CONSTRAINT [PK_C_ITEM_CHARACTERISTIC] PRIMARY KEY CLUSTERED ([ID_ITEM_CHARACTERISTIC] ASC),
    CONSTRAINT [FK_C_ITEM_CHARACTERISTIC_C_ITEM] FOREIGN KEY ([ID_ITEM]) REFERENCES [PRD].[C_ITEM] ([ID_ITEM]),
    CONSTRAINT [FK_C_ITEM_CHARACTERISTIC_C_METRICS] FOREIGN KEY ([ID_METRICS]) REFERENCES [PRD].[C_METRICS] ([ID_METRICS])
);


GO
CREATE NONCLUSTERED INDEX [IX_C_ITEM_CARACTERISTIC_ID_ITEM_ID_METRICS]
    ON [PRD].[C_ITEM_CHARACTERISTIC]([ID_ITEM] ASC, [ID_METRICS] ASC);
