CREATE TABLE [dbo].[testBug2] (
    [ID_ITEM]            INT              NULL,
    [KY_ITEM]            VARCHAR (25)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [NM_ITEM]            VARCHAR (61)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DS_ITEM]            VARCHAR (61)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [KY_UPC]             VARCHAR (13)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [NO_POUNDS_PER_ITEM] DECIMAL (20, 10) NULL,
    [NO_SKID_QTY]        INT              NULL,
    [DS_NOTES_JDEDWARDS] VARCHAR (1)      NOT NULL
);

