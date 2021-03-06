﻿CREATE TABLE [PRD].[K_PALLET] (
    [ID_PALLET]                          INT            IDENTITY (1, 1) NOT NULL,
    [ID_QA27]                            INT            NOT NULL,
    [ID_WORK_ORDER]                      INT            NOT NULL,
    [NO_PALLET]                          INT            NOT NULL,
    [NO_QUANTITY]                        INT            NULL,
    [DT_INITIAL_TIME]                    DATETIME       NOT NULL,
    [DT_FINAL_TIME]                      DATETIME       NULL,
    [DT_FINAL_OPERATION_TIME]            DATETIME       NULL,
    [KY_STATUS]                          NVARCHAR (50)  NOT NULL,
    [KY_USER_INSPECTOR]                  NVARCHAR (50)  NULL,
    [ID_QUALITY_INSPECTOR_AGREEMENT]     INT            NULL,
    [NM_QUALITY_INSPECTOR_AGREEMENT]     NVARCHAR (200) NULL,
    [FG_INSPECTOR_AGREEMENT]             BIT            CONSTRAINT [DF_K_PALLET_FG_INSPECTOR_AGREEMENT] DEFAULT ((1)) NOT NULL,
    [DT_INSPECTOR_AGREEMENT]             DATETIME       NULL,
    [DS_EXPLANATION_AGREEMENT]           TEXT           NULL,
    [KY_USER_LEADMAN]                    NVARCHAR (50)  NULL,
    [ID_LEADMAN]                         INT            NULL,
    [NM_LEADMAN]                         NVARCHAR (200) NULL,
    [FG_LEADMAN]                         BIT            CONSTRAINT [DF_K_PALLET_FG_LEADMAN] DEFAULT ((1)) NOT NULL,
    [DT_LEADMAN]                         DATETIME       NULL,
    [KY_FIRST_LEVEL_USER]                NVARCHAR (50)  NULL,
    [ID_FIRST_LEVEL_EMPLOYEE]            INT            NULL,
    [NM_FIRST_LEVEL_EMPLOYEE]            NVARCHAR (200) NULL,
    [FG_FIRST_LEVEL_EMPLOYEE]            BIT            CONSTRAINT [DF_K_PALLET_FG_FIRST_LEVEL_EMPLOYEE] DEFAULT ((1)) NOT NULL,
    [DT_FIRST_LEVEL_EMPLOYEE]            DATETIME       NULL,
    [KY_SECOND_LEVEL_USER_REJECTION]     NVARCHAR (50)  NULL,
    [ID_SECOND_LEVEL_EMPLOYEE_REJECTION] INT            NULL,
    [NM_SECOND_LEVEL_EMPLOYEE_REJECTION] NVARCHAR (200) NULL,
    [FG_SECOND_LEVEL_EMPLOYEE_REJECTION] BIT            CONSTRAINT [DF_K_PALLET_FG_SECOND_LEVEL_EMPLOYEE_REJECTION] DEFAULT ((1)) NOT NULL,
    [DT_SECOND_LEVEL_EMPLOYEE_REJECTION] DATETIME       NULL,
    [KY_THIRD_LEVEL_USER_REJECTION]      NVARCHAR (50)  NULL,
    [ID_THIRD_LEVEL_EMPLOYEE_REJECTION]  INT            NULL,
    [NM_THIRD_LEVEL_EMPLOYEE_REJECTION]  NVARCHAR (200) NULL,
    [FG_THIRD_LEVEL_EMPLOYEE_REJECTION]  BIT            CONSTRAINT [DF_K_PALLET_FG_THIRD_LEVEL_EMPLOYEE_REJECTION] DEFAULT ((1)) NOT NULL,
    [DT_THIRD_LEVEL_EMPLOYEE_REJECTION]  DATETIME       NULL,
    [FG_SEND_FORM]                       BIT            NULL,
    [NO_PALLETS_OPENED]                  INT            NULL,
    [DT_CREATION]                        DATETIME       NOT NULL,
    [DT_UPDATE]                          DATETIME       NULL,
    [KY_USER_APP_CREATION]               NVARCHAR (50)  NOT NULL,
    [KY_USER_APP_UPDATE]                 NVARCHAR (50)  NULL,
    [NM_PROGAM_CREATE]                   NVARCHAR (50)  NOT NULL,
    [NM_PROGRAM_UPDATE]                  NVARCHAR (50)  NULL,
    CONSTRAINT [PK_K_PALLET] PRIMARY KEY CLUSTERED ([ID_PALLET] ASC),
    CONSTRAINT [FK_K_PALLET_C_POSITION] FOREIGN KEY ([ID_QUALITY_INSPECTOR_AGREEMENT]) REFERENCES [ADM].[C_POSITION] ([ID_POSITION]),
    CONSTRAINT [FK_K_PALLET_C_POSITION_ID_FIRST_LEVEL_EMPLOYEE] FOREIGN KEY ([ID_FIRST_LEVEL_EMPLOYEE]) REFERENCES [ADM].[C_POSITION] ([ID_POSITION]),
    CONSTRAINT [FK_K_PALLET_C_POSITION_ID_SECOND_LEVEL_EMPLOYEE_REJECTION] FOREIGN KEY ([ID_SECOND_LEVEL_EMPLOYEE_REJECTION]) REFERENCES [ADM].[C_POSITION] ([ID_POSITION]),
    CONSTRAINT [FK_K_PALLET_C_POSITION_ID_THIRD_LEVEL_EMPLOYEE_REJECTION] FOREIGN KEY ([ID_THIRD_LEVEL_EMPLOYEE_REJECTION]) REFERENCES [ADM].[C_POSITION] ([ID_POSITION]),
    CONSTRAINT [FK_K_PALLET_C_POSITION_LEADMAN] FOREIGN KEY ([ID_LEADMAN]) REFERENCES [ADM].[C_POSITION] ([ID_POSITION]),
    CONSTRAINT [FK_K_PALLET_C_USER] FOREIGN KEY ([KY_USER_INSPECTOR]) REFERENCES [ADM].[C_USER] ([KY_USER]),
    CONSTRAINT [FK_K_PALLET_C_USER_FIRST_LEVEL_USER] FOREIGN KEY ([KY_FIRST_LEVEL_USER]) REFERENCES [ADM].[C_USER] ([KY_USER]),
    CONSTRAINT [FK_K_PALLET_C_USER_LEADMAN] FOREIGN KEY ([KY_USER_LEADMAN]) REFERENCES [ADM].[C_USER] ([KY_USER]),
    CONSTRAINT [FK_K_PALLET_C_USER_SECOND_LEVEL_USER_REJECTION] FOREIGN KEY ([KY_SECOND_LEVEL_USER_REJECTION]) REFERENCES [ADM].[C_USER] ([KY_USER]),
    CONSTRAINT [FK_K_PALLET_C_USER_THIRD_LEVEL_USER_REJECTION] FOREIGN KEY ([KY_THIRD_LEVEL_USER_REJECTION]) REFERENCES [ADM].[C_USER] ([KY_USER]),
    CONSTRAINT [FK_K_PALLET_K_QA27] FOREIGN KEY ([ID_QA27]) REFERENCES [PRD].[K_QA27] ([ID_QA27]),
    CONSTRAINT [FK_K_PALLET_K_WORK_ORDER] FOREIGN KEY ([ID_WORK_ORDER]) REFERENCES [PRD].[K_WORK_ORDER] ([ID_WORK_ORDER])
);


GO
CREATE NONCLUSTERED INDEX [IX_K_PALLET_ID_QA27]
    ON [PRD].[K_PALLET]([ID_QA27] ASC)
    INCLUDE([ID_PALLET], [NO_QUANTITY], [KY_STATUS]);


GO
CREATE NONCLUSTERED INDEX [IX_K_PALLET_KY_STATUS]
    ON [PRD].[K_PALLET]([KY_STATUS] ASC)
    INCLUDE([ID_PALLET], [ID_QA27], [NO_QUANTITY]);


GO
CREATE NONCLUSTERED INDEX [IX_K_PALLET_ID_WORK_ORDER_NO_PALLET]
    ON [PRD].[K_PALLET]([ID_WORK_ORDER] ASC, [NO_PALLET] ASC)
    INCLUDE([ID_PALLET]);

