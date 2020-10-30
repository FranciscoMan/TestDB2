﻿CREATE TABLE [PRD].[K_SHIFT] (
    [ID_SHIFT]             INT           IDENTITY (1, 1) NOT NULL,
    [ID_C_SHIFT]           INT           NULL,
    [KY_SHIFT]             NVARCHAR (50) NULL,
    [ID_SHIFT_TIME]        INT           NULL,
    [KY_SHIFT_TIME]        NVARCHAR (50) NULL,
    [ID_PRODUCTION_LINE]   INT           NOT NULL,
    [ID_BRANCH_PLANT]      INT           NOT NULL,
    [KY_USER]              NVARCHAR (50) NULL,
    [KY_AUTHORIZER_USER]   NVARCHAR (50) NULL,
    [FG_STATUS]            BIT           CONSTRAINT [DF_K_SHIFT_FG_STATUS] DEFAULT ((1)) NOT NULL,
    [DT_START_SHIFT]       DATETIME      NULL,
    [DT_END_SHIFT]         DATETIME      NULL,
    [DT_SHIFT_HISTORY]     DATETIME      NULL,
    [DT_CREATION]          DATETIME      NOT NULL,
    [DT_UPDATE]            DATETIME      NULL,
    [KY_USER_APP_CREATION] NVARCHAR (50) NOT NULL,
    [KY_USER_APP_UPDATE]   NVARCHAR (50) NULL,
    [NM_PROGAM_CREATE]     NVARCHAR (50) NOT NULL,
    [NM_PROGRAM_UPDATE]    NVARCHAR (50) NULL,
    CONSTRAINT [PK_K_SHIFT] PRIMARY KEY CLUSTERED ([ID_SHIFT] ASC),
    CONSTRAINT [FK_K_SHIFT_C_BRANCH_PLANT] FOREIGN KEY ([ID_BRANCH_PLANT]) REFERENCES [ADM].[C_BRANCH_PLANT] ([ID_BRANCH_PLANT]),
    CONSTRAINT [FK_K_SHIFT_C_PRODUCTION_LINE] FOREIGN KEY ([ID_PRODUCTION_LINE]) REFERENCES [PRD].[C_PRODUCTION_LINE] ([ID_PRODUCTION_LINE]),
    CONSTRAINT [FK_K_SHIFT_C_USER] FOREIGN KEY ([KY_USER]) REFERENCES [ADM].[C_USER] ([KY_USER])
);


GO
CREATE NONCLUSTERED INDEX [IX_K_SHIFT_DT_START_SHIFT]
    ON [PRD].[K_SHIFT]([DT_START_SHIFT] ASC)
    INCLUDE([ID_SHIFT], [ID_PRODUCTION_LINE]);

