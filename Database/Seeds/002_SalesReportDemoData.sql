USE hoteladmin;
GO

/*
    売上レポート確認用デモデータ

    対象期間:
      2024年9月 ～ 2026年8月

    内容:
      - 架空の日本人ゲストを登録
      - 過去24か月分のチェックアウト済み予約を登録
      - 月ごとに売上金額・宿泊人数・予約件数に変化を持たせる

    注意:
      本データは開発・画面確認専用の架空データです。
*/


/* =========================================================
   既存デモデータの削除
   ========================================================= */

/*
    このスクリプトを複数回実行してもデータが重複しないよう、
    sales.demo ドメインのゲストに関連する予約を削除する。
*/

DELETE FROM dbo.Bookings
WHERE GuestID IN
(
    SELECT GuestID
    FROM dbo.Guests
    WHERE Email LIKE '%@sales.demo'
);

DELETE FROM dbo.Guests
WHERE Email LIKE '%@sales.demo';

GO


/* =========================================================
   デモ用ゲストデータ
   ========================================================= */

INSERT INTO dbo.Guests
(
    FirstName,
    LastName,
    Email,
    Phone,
    Address,
    IDNumber,
    DateOfBirth,
    CreatedDate,
    IsActive
)
VALUES
(N'太郎', N'佐藤',  'taro.sato@sales.demo',       '090-1000-0001', N'東京都新宿区',     'DEMO001', '1988-04-12', '2024-08-01', 1),
(N'美咲', N'鈴木',  'misaki.suzuki@sales.demo',  '090-1000-0002', N'神奈川県横浜市',   'DEMO002', '1992-07-24', '2024-08-02', 1),
(N'翔太', N'高橋',  'shota.takahashi@sales.demo','090-1000-0003', N'大阪府大阪市',     'DEMO003', '1985-11-08', '2024-08-03', 1),
(N'結衣', N'田中',  'yui.tanaka@sales.demo',      '090-1000-0004', N'愛知県名古屋市',   'DEMO004', '1995-02-16', '2024-08-04', 1),
(N'大輔', N'伊藤',  'daisuke.ito@sales.demo',     '090-1000-0005', N'北海道札幌市',     'DEMO005', '1981-09-30', '2024-08-05', 1),

(N'さくら', N'渡辺','sakura.watanabe@sales.demo','090-1000-0006', N'福岡県福岡市',     'DEMO006', '1998-03-05', '2024-08-06', 1),
(N'健太', N'山本',  'kenta.yamamoto@sales.demo',  '090-1000-0007', N'兵庫県神戸市',     'DEMO007', '1989-06-21', '2024-08-07', 1),
(N'愛', N'中村',    'ai.nakamura@sales.demo',     '090-1000-0008', N'京都府京都市',     'DEMO008', '1993-12-14', '2024-08-08', 1),
(N'拓也', N'小林',  'takuya.kobayashi@sales.demo','090-1000-0009', N'広島県広島市',     'DEMO009', '1986-01-27', '2024-08-09', 1),
(N'奈々', N'加藤',  'nana.kato@sales.demo',       '090-1000-0010', N'宮城県仙台市',     'DEMO010', '1997-08-19', '2024-08-10', 1),

(N'悠斗', N'吉田',  'yuto.yoshida@sales.demo',    '090-1000-0011', N'埼玉県さいたま市', 'DEMO011', '1991-05-03', '2024-08-11', 1),
(N'彩花', N'山田',  'ayaka.yamada@sales.demo',    '090-1000-0012', N'千葉県千葉市',     'DEMO012', '1994-10-11', '2024-08-12', 1),
(N'直樹', N'佐々木','naoki.sasaki@sales.demo',   '090-1000-0013', N'静岡県静岡市',     'DEMO013', '1983-07-07', '2024-08-13', 1),
(N'恵', N'山口',    'megumi.yamaguchi@sales.demo','090-1000-0014', N'新潟県新潟市',     'DEMO014', '1990-02-28', '2024-08-14', 1),
(N'亮介', N'松本',  'ryosuke.matsumoto@sales.demo','090-1000-0015', N'長野県長野市',    'DEMO015', '1987-04-25', '2024-08-15', 1),

(N'葵', N'井上',    'aoi.inoue@sales.demo',       '090-1000-0016', N'沖縄県那覇市',     'DEMO016', '1999-06-17', '2024-08-16', 1),
(N'雄一', N'木村',  'yuichi.kimura@sales.demo',   '090-1000-0017', N'岡山県岡山市',     'DEMO017', '1980-03-09', '2024-08-17', 1),
(N'玲奈', N'林',    'rena.hayashi@sales.demo',    '090-1000-0018', N'熊本県熊本市',     'DEMO018', '1996-11-22', '2024-08-18', 1),
(N'誠', N'清水',    'makoto.shimizu@sales.demo',  '090-1000-0019', N'石川県金沢市',     'DEMO019', '1984-08-01', '2024-08-19', 1),
(N'陽菜', N'斎藤',  'hina.saito@sales.demo',      '090-1000-0020', N'群馬県高崎市',     'DEMO020', '2000-01-15', '2024-08-20', 1);

GO


/* =========================================================
   月別売上計画
   ========================================================= */

/*
    RevenueFactor:
      月ごとの売上傾向を調整する係数

    BookingCount:
      月ごとの予約件数

    夏季・年末などは少し売上が高くなるよう設定
*/

DECLARE @MonthlyPlan TABLE
(
    MonthStart DATE,
    BookingCount INT,
    RevenueFactor DECIMAL(5,2)
);

INSERT INTO @MonthlyPlan
(
    MonthStart,
    BookingCount,
    RevenueFactor
)
VALUES
('2024-09-01', 4, 1.00),
('2024-10-01', 4, 1.05),
('2024-11-01', 5, 1.10),
('2024-12-01', 6, 1.35),

('2025-01-01', 4, 0.95),
('2025-02-01', 4, 0.90),
('2025-03-01', 5, 1.05),
('2025-04-01', 5, 1.10),
('2025-05-01', 6, 1.30),
('2025-06-01', 5, 1.15),
('2025-07-01', 6, 1.35),
('2025-08-01', 7, 1.50),
('2025-09-01', 5, 1.15),
('2025-10-01', 5, 1.20),
('2025-11-01', 5, 1.25),
('2025-12-01', 7, 1.55),

('2026-01-01', 5, 1.05),
('2026-02-01', 5, 1.00),
('2026-03-01', 6, 1.20),
('2026-04-01', 6, 1.25),
('2026-05-01', 7, 1.45),
('2026-06-01', 6, 1.30),
('2026-07-01', 7, 1.50),
('2026-08-01', 8, 1.65);


/* =========================================================
   予約生成
   ========================================================= */

DECLARE
    @MonthStart DATE,
    @BookingCount INT,
    @RevenueFactor DECIMAL(5,2),
    @BookingIndex INT,
    @GuestID INT,
    @RoomID INT,
    @RoomPrice DECIMAL(18,2),
    @CheckInDate DATETIME,
    @CheckOutDate DATETIME,
    @Nights INT,
    @Guests INT,
    @TotalAmount DECIMAL(18,2),
    @GuestOffset INT,
    @RoomOffset INT;


/* 月別計画を順番に処理 */
DECLARE MonthlyCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT
    MonthStart,
    BookingCount,
    RevenueFactor
FROM @MonthlyPlan
ORDER BY MonthStart;

OPEN MonthlyCursor;

FETCH NEXT FROM MonthlyCursor
INTO
    @MonthStart,
    @BookingCount,
    @RevenueFactor;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @BookingIndex = 1;

    WHILE @BookingIndex <= @BookingCount
    BEGIN

        /* =====================================================
           ゲストを順番に割り当て
           ===================================================== */

        SET @GuestOffset =
            (
                (DATEDIFF(MONTH, '2024-09-01', @MonthStart) * 7)
                + @BookingIndex
            ) % 20;


        SELECT @GuestID = GuestID
        FROM
        (
            SELECT
                GuestID,
                ROW_NUMBER() OVER (ORDER BY GuestID) - 1 AS RowNum
            FROM dbo.Guests
            WHERE Email LIKE '%@sales.demo'
        ) g
        WHERE RowNum = @GuestOffset;


        /* =====================================================
           客室を順番に割り当て
           ===================================================== */

        SET @RoomOffset =
            (
                DATEDIFF(MONTH, '2024-09-01', @MonthStart)
                + @BookingIndex
            );


        SELECT
            @RoomID = RoomID,
            @RoomPrice = BasePrice
        FROM
        (
            SELECT
                r.RoomID,
                rt.BasePrice,
                ROW_NUMBER() OVER (
                    ORDER BY r.Floor, r.RoomNumber
                ) AS RowNum,
                COUNT(*) OVER () AS TotalRooms
            FROM dbo.Rooms r
            INNER JOIN dbo.RoomTypes rt
                ON r.RoomTypeID = rt.RoomTypeID
        ) rooms
        WHERE RowNum =
            (@RoomOffset % TotalRooms) + 1;


        /* =====================================================
           宿泊情報を生成
           ===================================================== */

        SET @Nights =
            CASE
                WHEN @BookingIndex % 4 = 0 THEN 3
                WHEN @BookingIndex % 3 = 0 THEN 2
                ELSE 1
            END;


        SET @Guests =
            CASE
                WHEN @BookingIndex % 5 = 0 THEN 3
                WHEN @BookingIndex % 2 = 0 THEN 2
                ELSE 1
            END;


        /*
            月内で日付を分散させる。
            すべて過去のチェックアウト済みデータとする。
        */
        SET @CheckInDate =
            DATEADD(
                HOUR,
                15,
                CAST(
                    DATEADD(
                        DAY,
                        (@BookingIndex * 3) % 20,
                        @MonthStart
                    )
                    AS DATETIME
                )
            );


        SET @CheckOutDate =
            DATEADD(
                HOUR,
                12,
                CAST(
                    DATEADD(
                        DAY,
                        @Nights,
                        CAST(@CheckInDate AS DATE)
                    )
                    AS DATETIME
                )
            );


        /* =====================================================
           売上金額を算出
           ===================================================== */

        SET @TotalAmount =
            ROUND(
                @RoomPrice
                * @Nights
                * @RevenueFactor,
                0
            );


        /* =====================================================
           予約データ登録
           ===================================================== */

        INSERT INTO dbo.Bookings
        (
            GuestID,
            RoomID,
            CheckInDate,
            CheckOutDate,
            BookingDate,
            Status,
            TotalAmount,
            AmountPaid,
            NumberOfGuests,
            SpecialRequest,
            CreatedBy
        )
        VALUES
        (
            @GuestID,
            @RoomID,
            @CheckInDate,
            @CheckOutDate,

            /* 予約日はチェックイン日の約1か月前 */
            DATEADD(
                DAY,
                -30 - (@BookingIndex * 2),
                @CheckInDate
            ),

            'CheckedOut',
            @TotalAmount,
            @TotalAmount,
            @Guests,
            NULL,
            NULL
        );


        SET @BookingIndex = @BookingIndex + 1;
    END;


    FETCH NEXT FROM MonthlyCursor
    INTO
        @MonthStart,
        @BookingCount,
        @RevenueFactor;
END;


CLOSE MonthlyCursor;
DEALLOCATE MonthlyCursor;

GO


/* =========================================================
   作成結果確認
   ========================================================= */

SELECT
    YEAR(CheckOutDate) AS SalesYear,
    MONTH(CheckOutDate) AS SalesMonth,
    COUNT(*) AS BookingCount,
    SUM(NumberOfGuests) AS GuestCount,
    SUM(TotalAmount) AS Revenue
FROM dbo.Bookings
WHERE Status = 'CheckedOut'
  AND GuestID IN
  (
      SELECT GuestID
      FROM dbo.Guests
      WHERE Email LIKE '%@sales.demo'
  )
GROUP BY
    YEAR(CheckOutDate),
    MONTH(CheckOutDate)
ORDER BY
    SalesYear,
    SalesMonth;

GO


PRINT N'売上レポート確認用のデモデータ作成が完了しました。';
GO