CREATE TABLE [ADM].[C_SHIFT] (
    [ID_SHIFT]           INT          IDENTITY (1, 1) NOT NULL,
    [KY_SHIFT]           VARCHAR (50) NULL,
    [NM_SHIFT]           VARCHAR (50) NULL,
    [NO_SHIFT_TIME]      INT          NULL,
    [INITIAL_SHIFT_TIME] TIME (7)     NULL,
    [FINAL_SHIFT_TIME]   TIME (7)     NULL,
    [ID_BRANCH_PLANT]    INT          NULL,
    [TS_START_SHIFT]     TIME (7)     NULL,
    [TS_END_SHIFT]       TIME (7)     NULL,
    PRIMARY KEY CLUSTERED ([ID_SHIFT] ASC)
);

