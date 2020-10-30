﻿




CREATE  VIEW [ADM].[VW_C_PALLET_STATUS] AS (
SELECT 1 ID_PALLET_STATUS, 'ACCEPTED' KY_PALLET_STATUS, 'Accepted' NM_PALLET_STATUS, CAST(1 AS BIT) AS FG_FOR_SAVE, 'A' AS KY_TEMP_STATUS UNION ALL
SELECT 2 ID_PALLET_STATUS, 'REJECTED' KY_PALLET_STATUS, 'Rejected' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'R' AS KY_TEMP_STATUS UNION ALL
SELECT 3 ID_PALLET_STATUS, 'HOLD_ON' KY_PALLET_STATUS, 'On hold' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'H' AS KY_TEMP_STATUS UNION ALL
SELECT 4 ID_PALLET_STATUS, 'WORKING' KY_PALLET_STATUS, 'Working' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'W' AS KY_TEMP_STATUS UNION ALL
SELECT 5 ID_PALLET_STATUS, 'INSPECTED' KY_PALLET_STATUS, 'Inspected' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'L' AS KY_TEMP_STATUS UNION ALL
SELECT 6 ID_PALLET_STATUS, 'NON_CONFORMANCE' KY_PALLET_STATUS, 'Non conformance' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'H' AS KY_TEMP_STATUS UNION ALL
SELECT 7 ID_PALLET_STATUS, 'MRB_RESOLUTION' KY_PALLET_STATUS, 'MRB Resolution' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'H' AS KY_TEMP_STATUS UNION ALL
SELECT 8 ID_PALLET_STATUS, 'SAVE_AS_IS' KY_PALLET_STATUS, 'Save as is' NM_PALLET_STATUS, CAST(1 AS BIT) AS FG_FOR_SAVE, 'A' AS KY_TEMP_STATUS UNION ALL
SELECT 9 ID_PALLET_STATUS, 'GRIND' KY_PALLET_STATUS, 'Grind' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'R' AS KY_TEMP_STATUS UNION ALL
SELECT 10 ID_PALLET_STATUS, 'SCRAP' KY_PALLET_STATUS, 'Scrap' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'R' AS KY_TEMP_STATUS UNION ALL
SELECT 11 ID_PALLET_STATUS, 'FLIP_TO_DIFFERENT_EPN' KY_PALLET_STATUS, 'Flip to different epn' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'R' AS KY_TEMP_STATUS UNION ALL
SELECT 12 ID_PALLET_STATUS, 'INSPECTING' KY_PALLET_STATUS, 'Inspecting' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'L' AS KY_TEMP_STATUS UNION ALL
SELECT 13 ID_PALLET_STATUS, 'NON_INSPECTED' KY_PALLET_STATUS, 'Non inspected' NM_PALLET_STATUS, CAST(1 AS BIT) AS FG_FOR_SAVE, 'A' AS KY_TEMP_STATUS UNION ALL
SELECT 14 ID_PALLET_STATUS, 'REWORK' KY_PALLET_STATUS, 'Rework' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'R' AS KY_TEMP_STATUS UNION ALL
SELECT 15 ID_PALLET_STATUS, 'CUSTOMER_WAIVER' KY_PALLET_STATUS, 'Customer''s waiver' NM_PALLET_STATUS, CAST(1 AS BIT) AS FG_FOR_SAVE, 'A' AS KY_TEMP_STATUS UNION ALL
SELECT 16 ID_PALLET_STATUS, 'RECLASSIFY' KY_PALLET_STATUS, 'Reclassify' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'R' AS KY_TEMP_STATUS UNION ALL
SELECT 17 ID_PALLET_STATYS, 'BACK_TO_REVIEW' KY_PALLET_STATUS, 'Back to review' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'H' AS KY_TEMP_STATUS UNION ALL
SELECT 18 ID_PALLET_STATYS, 'NON_CREATED' KY_PALLET_STATUS, 'Non created' NM_PALLET_STATUS, CAST(0 AS BIT) AS FG_FOR_SAVE, 'L' AS KY_TEMP_STATUS 
)