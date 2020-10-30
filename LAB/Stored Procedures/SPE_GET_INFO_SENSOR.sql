﻿CREATE PROCEDURE   [LAB].[SPE_GET_INFO_SENSOR]
--@PIN_TYPE AS NVARCHAR(100),
--@PIN_LOCATION AS NVARCHAR(100)
AS
BEGIN

CREATE TABLE #ACTIVE_SENSORS(
ID_ROW INT PRIMARY KEY IDENTITY(1,1),
ID_SENSOR INT,
NM_SENSOR NVARCHAR(100),
KY_SENSOR NVARCHAR(100),
IP_ADDRESS NVARCHAR(100),
FG_ACTIVE BIT,
LOCATION NVARCHAR(100),
TYPE NVARCHAR(100),
PORT NVARCHAR(50),
FG_STATUS BIT
)
-- seleccionar el ultimo toledo activo en el lab sur
INSERT INTO #ACTIVE_SENSORS(ID_SENSOR,NM_SENSOR,KY_SENSOR,IP_ADDRESS,FG_ACTIVE,LOCATION,TYPE,PORT,FG_STATUS) 
SELECT TOP (1) ID_SENSOR, NM_SENSOR, KY_SENSOR, IP_ADDRESS, FG_ACTIVE, LOCATION, TYPE, PORT, FG_STATUS FROM LAB.K_SENSORS 
WHERE 
TYPE = 'Toledo' AND 
LOCATION = 'South' AND 
FG_ACTIVE = 1 ORDER BY ID_SENSOR DESC

-- seleccionar el ultimo toledo activo en el lab norte
INSERT INTO #ACTIVE_SENSORS(ID_SENSOR,NM_SENSOR,KY_SENSOR,IP_ADDRESS,FG_ACTIVE,LOCATION,TYPE,PORT,FG_STATUS) 
SELECT TOP (1) ID_SENSOR, NM_SENSOR, KY_SENSOR, IP_ADDRESS, FG_ACTIVE, LOCATION, TYPE, PORT, FG_STATUS FROM LAB.K_SENSORS 
WHERE 
TYPE = 'Toledo' AND 
LOCATION = 'North' AND 
FG_ACTIVE = 1 ORDER BY ID_SENSOR DESC

-- seleccionar el ultimo micro gloss activo en el lab sur
INSERT INTO #ACTIVE_SENSORS(ID_SENSOR,NM_SENSOR,KY_SENSOR,IP_ADDRESS,FG_ACTIVE,LOCATION,TYPE,PORT,FG_STATUS) 
SELECT TOP (1) ID_SENSOR, NM_SENSOR, KY_SENSOR, IP_ADDRESS, FG_ACTIVE, LOCATION, TYPE, PORT, FG_STATUS FROM LAB.K_SENSORS 
WHERE 
TYPE = 'Micro gloss' AND 
LOCATION = 'South' AND 
FG_ACTIVE = 1 ORDER BY ID_SENSOR DESC

-- seleccionar el ultimo micro gloss activo en el lab norte
INSERT INTO #ACTIVE_SENSORS(ID_SENSOR,NM_SENSOR,KY_SENSOR,IP_ADDRESS,FG_ACTIVE,LOCATION,TYPE,PORT,FG_STATUS) 
SELECT TOP (1) ID_SENSOR, NM_SENSOR, KY_SENSOR, IP_ADDRESS, FG_ACTIVE, LOCATION, TYPE, PORT, FG_STATUS FROM LAB.K_SENSORS 
WHERE 
TYPE = 'Micro gloss' AND 
LOCATION = 'North' AND 
FG_ACTIVE = 1 ORDER BY ID_SENSOR DESC

-- seleccionar el ultimo haze gard plus activo en el lab sur
INSERT INTO #ACTIVE_SENSORS(ID_SENSOR,NM_SENSOR,KY_SENSOR,IP_ADDRESS,FG_ACTIVE,LOCATION,TYPE,PORT,FG_STATUS) 
SELECT TOP (1) ID_SENSOR, NM_SENSOR, KY_SENSOR, IP_ADDRESS, FG_ACTIVE, LOCATION, TYPE, PORT, FG_STATUS FROM LAB.K_SENSORS 
WHERE 
TYPE = 'Haze gard plus' AND 
LOCATION = 'South' AND 
FG_ACTIVE = 1 ORDER BY ID_SENSOR DESC

-- seleccionar el ultimo haze gard plus activo en el lab norte
INSERT INTO #ACTIVE_SENSORS(ID_SENSOR,NM_SENSOR,KY_SENSOR,IP_ADDRESS,FG_ACTIVE,LOCATION,TYPE,PORT,FG_STATUS) 
SELECT TOP (1) ID_SENSOR, NM_SENSOR, KY_SENSOR, IP_ADDRESS, FG_ACTIVE, LOCATION, TYPE, PORT, FG_STATUS FROM LAB.K_SENSORS 
WHERE 
TYPE = 'Haze gard plus' AND 
LOCATION = 'North' AND 
FG_ACTIVE = 1 ORDER BY ID_SENSOR DESC

-- seleccionar el ultimo protable activo en el lab sur
INSERT INTO #ACTIVE_SENSORS(ID_SENSOR,NM_SENSOR,KY_SENSOR,IP_ADDRESS,FG_ACTIVE,LOCATION,TYPE,PORT,FG_STATUS) 
SELECT TOP (1) ID_SENSOR, NM_SENSOR, KY_SENSOR, IP_ADDRESS, FG_ACTIVE, LOCATION, TYPE, PORT, FG_STATUS FROM LAB.K_SENSORS 
WHERE 
TYPE = 'Protable' AND 
LOCATION = 'South' AND 
FG_ACTIVE = 1 ORDER BY ID_SENSOR DESC

-- seleccionar el ultimo protable activo en el lab norte
INSERT INTO #ACTIVE_SENSORS(ID_SENSOR,NM_SENSOR,KY_SENSOR,IP_ADDRESS,FG_ACTIVE,LOCATION,TYPE,PORT,FG_STATUS) 
SELECT TOP (1) ID_SENSOR, NM_SENSOR, KY_SENSOR, IP_ADDRESS, FG_ACTIVE, LOCATION, TYPE, PORT, FG_STATUS FROM LAB.K_SENSORS 
WHERE 
TYPE = 'Protable' AND 
LOCATION = 'North' AND 
FG_ACTIVE = 1 ORDER BY ID_SENSOR DESC

SELECT * FROM #ACTIVE_SENSORS
END

--update PlaskoliteQA.LAB.K_SENSORS set FG_ACTIVE = 1 WHERE ID_SENSOR = 1




--------------------------------------------------- procedimiento para registrar los sensores


