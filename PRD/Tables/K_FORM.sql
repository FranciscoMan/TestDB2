﻿CREATE TABLE [PRD].[K_FORM] (
    [ID_K_FORM]                       INT            IDENTITY (1, 1) NOT NULL,
    [ID_BRANCH_PLANT]                 INT            NOT NULL,
    [ID_FORM]                         INT            NOT NULL,
    [ID_WORK_ORDER]                   INT            NULL,
    [ID_QA27]                         INT            NULL,
    [ID_PRODUCTION_LINE]              INT            NULL,
    [ID_PALLET]                       INT            NULL,
    [DT_FORM]                         DATETIME       NOT NULL,
    [DT_START]                        DATETIME       NULL,
    [DT_CLOSED]                       DATETIME       NULL,
    [KY_STATUS_FORM]                  NVARCHAR (100) NOT NULL,
    [KY_PROCESS_TYPE]                 NVARCHAR (20)  NULL,
    [ID_INSPECTION_SKID]              INT            NULL,
    [KY_USER_AUTHORIZED_CANCEL]       NVARCHAR (50)  NULL,
    [NM_USER_AUTHORIZED_CANCEL]       NVARCHAR (100) NULL,
    [DS_EXPLANATION_CANCEL]           NCHAR (500)    NULL,
    [KY_USER_AUTHORIZED_OUT_OF_RANGE] NVARCHAR (50)  NULL,
    [NM_USER_AUTHORIZED_OUT_OF_RANGE] NVARCHAR (100) NULL,
    [DS_EXPLANATION_OUT_OF_RANGE]     NVARCHAR (500) NULL,
    [DT_CREATION]                     DATETIME       NOT NULL,
    [DT_UPDATE]                       DATETIME       NULL,
    [KY_USER_APP_CREATION]            NVARCHAR (50)  NOT NULL,
    [KY_USER_APP_UPDATE]              NVARCHAR (50)  NULL,
    [NM_PROGAM_CREATE]                NVARCHAR (50)  NOT NULL,
    [NM_PROGRAM_UPDATE]               NVARCHAR (50)  NULL,
    CONSTRAINT [PK_K_FORM] PRIMARY KEY CLUSTERED ([ID_K_FORM] ASC),
    CONSTRAINT [FK_K_FORM_C_BRANCH_PLANT] FOREIGN KEY ([ID_BRANCH_PLANT]) REFERENCES [ADM].[C_BRANCH_PLANT] ([ID_BRANCH_PLANT]),
    CONSTRAINT [FK_K_FORM_C_FORM] FOREIGN KEY ([ID_FORM]) REFERENCES [PRD].[C_FORM] ([ID_FORM]),
    CONSTRAINT [FK_K_FORM_C_PRODUCTION_LINE] FOREIGN KEY ([ID_PRODUCTION_LINE]) REFERENCES [PRD].[C_PRODUCTION_LINE] ([ID_PRODUCTION_LINE]),
    CONSTRAINT [FK_K_FORM_K_INSPECTION_SKID] FOREIGN KEY ([ID_INSPECTION_SKID]) REFERENCES [PRD].[K_INSPECTION_SKID] ([ID_INSPECTION_SKID]),
    CONSTRAINT [FK_K_FORM_K_PALLET] FOREIGN KEY ([ID_PALLET]) REFERENCES [PRD].[K_PALLET] ([ID_PALLET]),
    CONSTRAINT [FK_K_FORM_K_QA27] FOREIGN KEY ([ID_QA27]) REFERENCES [PRD].[K_QA27] ([ID_QA27]),
    CONSTRAINT [FK_K_FORM_K_WORK_ORDER] FOREIGN KEY ([ID_WORK_ORDER]) REFERENCES [PRD].[K_WORK_ORDER] ([ID_WORK_ORDER])
);


GO
ALTER TABLE [PRD].[K_FORM] NOCHECK CONSTRAINT [FK_K_FORM_K_PALLET];


GO
ALTER TABLE [PRD].[K_FORM] NOCHECK CONSTRAINT [FK_K_FORM_K_QA27];


GO
CREATE NONCLUSTERED INDEX [IX_K_FORM_ID_PRODUCTION_LINE_KY_STATUS_FORM_KY_PROCESS_TYPE_ID_PALLET]
    ON [PRD].[K_FORM]([ID_PRODUCTION_LINE] ASC, [KY_STATUS_FORM] ASC, [KY_PROCESS_TYPE] ASC, [ID_PALLET] ASC)
    INCLUDE([ID_K_FORM], [DT_FORM]);


GO
CREATE NONCLUSTERED INDEX [IX_K_FORM_ID_WORK_ORDER_KY_STATUS_FORM]
    ON [PRD].[K_FORM]([ID_WORK_ORDER] ASC, [KY_STATUS_FORM] ASC);

