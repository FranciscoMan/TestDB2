﻿CREATE TABLE [ADM].[C_DOCUMENT_ROLE] (
    [ID_DOCUMENT_ROLE]     INT              IDENTITY (1, 1) NOT NULL,
    [ID_STREAM]            UNIQUEIDENTIFIER NOT NULL,
    [ID_ROLE]              INT              NOT NULL,
    [DT_CREATION]          DATETIME         NOT NULL,
    [DT_UPDATE]            DATETIME         NULL,
    [KY_USER_APP_CREATION] NVARCHAR (50)    NOT NULL,
    [KY_USER_APP_UPDATE]   NVARCHAR (50)    NULL,
    [NM_PROGRAM_CREATE]    NVARCHAR (50)    NOT NULL,
    [NM_PROGRAM_UPDATE]    NVARCHAR (50)    NULL,
    CONSTRAINT [PK_C_DOCUMENT_ROLE] PRIMARY KEY CLUSTERED ([ID_DOCUMENT_ROLE] ASC),
    CONSTRAINT [FK_C_DOCUMENT_ROLE_C_ROLE] FOREIGN KEY ([ID_ROLE]) REFERENCES [ADM].[C_ROLE] ([ID_ROLE])
);
