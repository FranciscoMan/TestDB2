﻿CREATE TABLE [PRD].[K_MEMBER_IN_LIST_DISTRIBUTION] (
    [ID_MEMBER]            INT          IDENTITY (1, 1) NOT NULL,
    [ID_DISTRIBUTION]      INT          NULL,
    [KY_USER]              VARCHAR (20) NULL,
    [FG_ACTIVE]            BIT          NULL,
    [KY_USER_APP_CREATION] VARCHAR (20) NOT NULL,
    [KY_USER_APP_UPDATE]   VARCHAR (20) NULL,
    [NM_PROGAM_CREATE]     VARCHAR (50) NOT NULL,
    [NM_PROGRAM_UPDATE]    VARCHAR (50) NULL,
    [ID_BRANCH_PLANT]      INT          NULL,
    PRIMARY KEY CLUSTERED ([ID_MEMBER] ASC)
);

