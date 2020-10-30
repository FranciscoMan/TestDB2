﻿CREATE VIEW [ADM].[VW_C_MODBUS_DATATYPE] AS (
SELECT 1 ID_MODBUS_DATATYPE, 'U16' KY_MODBUS_DATATYPE, 'Unsigned 16 bytes' NM_MODBUS_DATATYPE UNION ALL
SELECT 2 ID_MODBUS_DATATYPE, 'U32' KY_MODBUS_DATATYPE, 'Unsigned 32 bytes' NM_MODBUS_DATATYPE UNION ALL
SELECT 3 ID_MODBUS_DATATYPE, 'I16' KY_MODBUS_DATATYPE, 'Signing 16 bytes' NM_MODBUS_DATATYPE UNION ALL
SELECT 4 ID_MODBUS_DATATYPE, 'I32' KY_MODBUS_DATATYPE, 'Signing 32 bytes' NM_MODBUS_DATATYPE UNION ALL
SELECT 5 ID_MODBUS_DATATYPE, 'FLOAT' KY_MODBUS_DATATYPE, 'Float type' NM_MODBUS_DATATYPE UNION ALL
SELECT 6 ID_MODBUS_DATATYPE, 'REAL' KY_MODBUS_DATATYPE, 'Real Type' NM_MODBUS_DATATYPE UNION ALL
SELECT 7 ID_MODBUS_DATATYPE, 'BIT' KY_MODBUS_DATATYPE, 'Bit Type' NM_MODBUS_DATATYPE UNION ALL
SELECT 8 ID_MODBUS_DATATYPE, 'BOOLEAN' KY_MODBUS_DATATYPE, 'Boolean Type' NM_MODBUS_DATATYPE)
