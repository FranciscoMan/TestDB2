﻿CREATE TABLE [PRD].[K_DOCUMENT_HISTORY] (
    [ID_DOCUMENT_HISTORY]  INT              IDENTITY (1, 1) NOT NULL,
    [ID_DOCUMENT]          UNIQUEIDENTIFIER NOT NULL,
    [NM_DOCUMENT]          NVARCHAR (200)   NOT NULL,
    [KY_USER_SENDED]       NVARCHAR (50)    NOT NULL,
    [NM_USER_SENDED]       NVARCHAR (300)   NOT NULL,
    [DT_SENDED]            DATETIME         NOT NULL,
    [DT_CONFIRM]           DATETIME         NULL,
    [ID_BRANCH_PLANT]      INT              NULL,
    [ID_NOTIFICATION]      INT              NULL,
    [DT_CREATION]          DATETIME         NOT NULL,
    [DT_UPDATE]            DATETIME         NULL,
    [KY_USER_APP_CREATION] NVARCHAR (50)    NOT NULL,
    [KY_USER_APP_UPDATE]   NVARCHAR (50)    NULL,
    [NM_PROGAM_CREATE]     NVARCHAR (50)    NOT NULL,
    [NM_PROGRAM_UPDATE]    NVARCHAR (50)    NULL
);
