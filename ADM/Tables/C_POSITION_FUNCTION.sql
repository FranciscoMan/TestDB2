﻿CREATE TABLE [ADM].[C_POSITION_FUNCTION] (
    [ID_POSITION_FUNCTION] INT IDENTITY (1, 1) NOT NULL,
    [ID_POSITION]          INT NOT NULL,
    [ID_FUNCTION]          INT NOT NULL,
    CONSTRAINT [FK_C_POSITION_FUNCTION_C_POSITION] FOREIGN KEY ([ID_POSITION]) REFERENCES [ADM].[C_POSITION] ([ID_POSITION])
);

