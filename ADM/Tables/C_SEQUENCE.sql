﻿CREATE TABLE [ADM].[C_SEQUENCE] (
    [KY_SEQUENCE]          NVARCHAR (20) NOT NULL,
    [KY_PREFIX]            NVARCHAR (5)  NULL,
    [NO_LAST_VALUE]        INT           CONSTRAINT [DF_C_SEQUENCE_NO_LAST_VALUE] DEFAULT ((0)) NOT NULL,
    [NO_MAXIMUN_VALUE]     INT           CONSTRAINT [DF_C_SEQUENCE_NO_MAXIMUN_VALUE] DEFAULT ((9999999)) NOT NULL,
    [KY_SUFFIX]            NVARCHAR (5)  NULL,
    [NO_DIGITS]            TINYINT       CONSTRAINT [DF_C_SEQUENCE_NO_DIGITS] DEFAULT ((5)) NOT NULL,
    [ID_BRANCH_PLANT]      INT           NULL,
    [DT_CREATION]          DATETIME      NOT NULL,
    [DT_UPDATE]            DATETIME      NULL,
    [KY_USER_APP_CREATION] NVARCHAR (50) NOT NULL,
    [KY_USER_APP_UPDATE]   NVARCHAR (50) NULL,
    [NM_PROGAM_CREATE]     NVARCHAR (50) NOT NULL,
    [NM_PROGRAM_UPDATE]    NVARCHAR (50) NULL,
    CONSTRAINT [PK_C_SEQUENCE] PRIMARY KEY CLUSTERED ([KY_SEQUENCE] ASC),
    CONSTRAINT [FK_C_SEQUENCE_C_BRANCH_PLANT] FOREIGN KEY ([ID_BRANCH_PLANT]) REFERENCES [ADM].[C_BRANCH_PLANT] ([ID_BRANCH_PLANT])
);
