USE hoteladmin;
GO

/* =========================================================
   ダッシュボード統計取得
   ========================================================= */

CREATE OR ALTER PROCEDURE dbo.sp_GetDashboardStats
AS
BEGIN
    SET NOCOUNT ON;

    /* 全予約件数 */
    SELECT
        COUNT(*) AS TotalBookings
    FROM dbo.Bookings;

    /* 本日のチェックイン予定数 */
    SELECT
        COUNT(*) AS TodayCheckIns
    FROM dbo.Bookings
    WHERE CAST(CheckInDate AS DATE) = CAST(GETDATE() AS DATE)
      AND Status NOT IN ('CheckedOut', 'Cancelled');

    /* 客室状況 */
    SELECT
        ISNULL(
            SUM(CASE WHEN Status = 'Available' THEN 1 ELSE 0 END),
            0
        ) AS AvailableRooms,

        ISNULL(
            SUM(CASE WHEN Status = 'Occupied' THEN 1 ELSE 0 END),
            0
        ) AS OccupiedRooms,

        ISNULL(
            SUM(CASE WHEN Status = 'Reserved' THEN 1 ELSE 0 END),
            0
        ) AS ReservedRooms
    FROM dbo.Rooms;

    /* 今月の売上情報 */
    SELECT
        ISNULL(SUM(TotalAmount), 0) AS MonthlyRevenue,
        COUNT(*) AS TotalTransactions
    FROM dbo.Bookings
    WHERE Status = 'CheckedOut'
      AND YEAR(CheckOutDate) = YEAR(GETDATE())
      AND MONTH(CheckOutDate) = MONTH(GETDATE());
END;
GO


/* =========================================================
   現在宿泊中のゲスト取得
   ========================================================= */

CREATE OR ALTER PROCEDURE dbo.sp_GetCurrentGuests
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        g.FirstName + ' ' + g.LastName AS GuestName,
        r.RoomNumber,
        rt.TypeName AS RoomType,
        b.CheckInDate,
        b.CheckOutDate,
        DATEDIFF(
            DAY,
            b.CheckInDate,
            b.CheckOutDate
        ) AS NightsStay
    FROM dbo.Bookings b
    INNER JOIN dbo.Guests g
        ON b.GuestID = g.GuestID
    INNER JOIN dbo.Rooms r
        ON b.RoomID = r.RoomID
    INNER JOIN dbo.RoomTypes rt
        ON r.RoomTypeID = rt.RoomTypeID
    WHERE b.Status = 'CheckedIn'
      AND b.CheckInDate <= GETDATE()
      AND b.CheckOutDate >= GETDATE()
    ORDER BY r.RoomNumber;
END;
GO


PRINT N'ストアドプロシージャの作成が完了しました。';
GO