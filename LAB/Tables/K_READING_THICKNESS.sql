﻿CREATE TABLE [LAB].[K_READING_THICKNESS] (
    [ID_READING_THICKNESS] INT             IDENTITY (1, 1) NOT NULL,
    [ID_K_FORM]            INT             NOT NULL,
    [ID_K_SAMPLE]          INT             NOT NULL,
    [ID_WORK_ORDER]        INT             NOT NULL,
    [NO_PALLET]            INT             NOT NULL,
    [NO_READING]           DECIMAL (13, 6) NOT NULL,
    [DT_CREATION]          DATETIME        NOT NULL,
    [DT_UPDATE]            DATETIME        NULL,
    [KY_USER_APP_CREATION] NVARCHAR (50)   NOT NULL,
    [KY_USER_APP_UPDATE]   NVARCHAR (50)   NULL,
    [NM_PROGAM_CREATE]     NVARCHAR (50)   NOT NULL,
    [NM_PROGRAM_UPDATE]    NVARCHAR (50)   NULL,
    CONSTRAINT [PK_K_READING_THICKNESS] PRIMARY KEY CLUSTERED ([ID_READING_THICKNESS] ASC),
    CONSTRAINT [FK_K_READING_THICKNESS_K_FORM] FOREIGN KEY ([ID_K_FORM]) REFERENCES [PRD].[K_FORM] ([ID_K_FORM]),
    CONSTRAINT [FK_K_READING_THICKNESS_K_WORK_ORDER] FOREIGN KEY ([ID_WORK_ORDER]) REFERENCES [PRD].[K_WORK_ORDER] ([ID_WORK_ORDER])
);

