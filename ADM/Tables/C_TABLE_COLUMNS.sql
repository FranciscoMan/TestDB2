﻿CREATE TABLE [ADM].[C_TABLE_COLUMNS] (
    [ID_TABLE_COLUMN] INT            IDENTITY (1, 1) NOT NULL,
    [NAME]            VARCHAR (100)  NULL,
    [COLUMNS]         VARCHAR (1000) NULL,
    PRIMARY KEY CLUSTERED ([ID_TABLE_COLUMN] ASC)
);
