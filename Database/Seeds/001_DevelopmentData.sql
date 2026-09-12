USE hoteladmin;
GO

/* =========================================================
   客室タイプデータ
   ========================================================= */

IF NOT EXISTS (
    SELECT 1
    FROM dbo.RoomTypes
    WHERE TypeName = 'Single'
)
BEGIN
    INSERT INTO dbo.RoomTypes (TypeName, BasePrice, Capacity)
    VALUES ('Single', 8000, 1);
END

IF NOT EXISTS (
    SELECT 1
    FROM dbo.RoomTypes
    WHERE TypeName = 'Double'
)
BEGIN
    INSERT INTO dbo.RoomTypes (TypeName, BasePrice, Capacity)
    VALUES ('Double', 12000, 2);
END

IF NOT EXISTS (
    SELECT 1
    FROM dbo.RoomTypes
    WHERE TypeName = 'Twin'
)
BEGIN
    INSERT INTO dbo.RoomTypes (TypeName, BasePrice, Capacity)
    VALUES ('Twin', 14000, 2);
END

IF NOT EXISTS (
    SELECT 1
    FROM dbo.RoomTypes
    WHERE TypeName = 'Deluxe'
)
BEGIN
    INSERT INTO dbo.RoomTypes (TypeName, BasePrice, Capacity)
    VALUES ('Deluxe', 20000, 3);
END

IF NOT EXISTS (
    SELECT 1
    FROM dbo.RoomTypes
    WHERE TypeName = 'Suite'
)
BEGIN
    INSERT INTO dbo.RoomTypes (TypeName, BasePrice, Capacity)
    VALUES ('Suite', 30000, 4);
END

GO


/* =========================================================
   1階
   ========================================================= */

IF NOT EXISTS (
    SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '101'
)
BEGIN
    INSERT INTO dbo.Rooms
        (RoomNumber, RoomTypeID, Floor, Status)
    SELECT
        '101',
        RoomTypeID,
        1,
        'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Single';
END

GO


/* =========================================================
   2階
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '201')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '201', RoomTypeID, 2, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Double';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '202')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '202', RoomTypeID, 2, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Double';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '203')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '203', RoomTypeID, 2, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Twin';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '204')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '204', RoomTypeID, 2, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Twin';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '205')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '205', RoomTypeID, 2, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Deluxe';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '206')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '206', RoomTypeID, 2, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Deluxe';
END

GO


/* =========================================================
   3階
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '301')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '301', RoomTypeID, 3, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Double';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '302')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '302', RoomTypeID, 3, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Double';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '303')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '303', RoomTypeID, 3, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Twin';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '304')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '304', RoomTypeID, 3, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Twin';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '305')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '305', RoomTypeID, 3, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Deluxe';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '306')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '306', RoomTypeID, 3, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Deluxe';
END

GO


/* =========================================================
   4階
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '401')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '401', RoomTypeID, 4, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Double';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '402')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '402', RoomTypeID, 4, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Double';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '403')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '403', RoomTypeID, 4, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Twin';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '404')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '404', RoomTypeID, 4, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Twin';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '405')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '405', RoomTypeID, 4, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Deluxe';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '406')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '406', RoomTypeID, 4, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Deluxe';
END

GO


/* =========================================================
   5階
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomNumber = '501')
BEGIN
    INSERT INTO dbo.Rooms (RoomNumber, RoomTypeID, Floor, Status)
    SELECT '501', RoomTypeID, 5, 'Available'
    FROM dbo.RoomTypes
    WHERE TypeName = 'Suite';
END

GO


/* =========================================================
   登録結果確認
   ========================================================= */

SELECT
    Floor,
    COUNT(*) AS RoomCount
FROM dbo.Rooms
GROUP BY Floor
ORDER BY Floor;

SELECT
    COUNT(*) AS TotalRooms
FROM dbo.Rooms;

GO