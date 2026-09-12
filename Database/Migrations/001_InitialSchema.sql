/*
    ホテル管理ダッシュボード
    初期データベースマイグレーション

    作成対象:
      - hoteladmin データベース
      - AdminUser
      - Guests
      - RoomTypes
      - Rooms
      - Bookings

    複数回実行しても既存オブジェクトを重複作成しない構成
*/

USE master;
GO

/* hoteladmin データベースが存在しない場合のみ作成 */
IF DB_ID(N'hoteladmin') IS NULL
BEGIN
    CREATE DATABASE hoteladmin;
END
GO

USE hoteladmin;
GO


/* =========================================================
   管理者テーブル
   ========================================================= */

IF OBJECT_ID(N'dbo.AdminUser', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AdminUser
    (
        AdminID INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_AdminUser PRIMARY KEY,

        Username NVARCHAR(100) NOT NULL,
        Password NVARCHAR(256) NOT NULL,
        Email NVARCHAR(255) NOT NULL,
        FullName NVARCHAR(200) NOT NULL,

        Role NVARCHAR(50) NOT NULL
            CONSTRAINT DF_AdminUser_Role DEFAULT ('Admin'),

        IsActive BIT NOT NULL
            CONSTRAINT DF_AdminUser_IsActive DEFAULT (1),

        CreatedDate DATETIME NOT NULL
            CONSTRAINT DF_AdminUser_CreatedDate DEFAULT (GETDATE()),

        LastLogin DATETIME NULL,

        CONSTRAINT UQ_AdminUser_Username
            UNIQUE (Username),

        CONSTRAINT UQ_AdminUser_Email
            UNIQUE (Email)
    );
END
GO


/* =========================================================
   ゲストテーブル
   ========================================================= */

IF OBJECT_ID(N'dbo.Guests', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Guests
    (
        GuestID INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_Guests PRIMARY KEY,

        FirstName NVARCHAR(100) NOT NULL,
        LastName NVARCHAR(100) NOT NULL,

        Email NVARCHAR(255) NULL,
        Phone NVARCHAR(50) NULL,
        Address NVARCHAR(500) NULL,
        IDNumber NVARCHAR(100) NULL,

        DateOfBirth DATE NULL,

        CreatedDate DATETIME NOT NULL
            CONSTRAINT DF_Guests_CreatedDate DEFAULT (GETDATE()),

        IsActive BIT NOT NULL
            CONSTRAINT DF_Guests_IsActive DEFAULT (1)
    );
END
GO


/* =========================================================
   客室タイプテーブル
   ========================================================= */

IF OBJECT_ID(N'dbo.RoomTypes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoomTypes
    (
        RoomTypeID INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_RoomTypes PRIMARY KEY,

        TypeName NVARCHAR(100) NOT NULL,

        BasePrice DECIMAL(18,2) NOT NULL,

        Capacity INT NOT NULL,

        CONSTRAINT UQ_RoomTypes_TypeName
            UNIQUE (TypeName),

        CONSTRAINT CK_RoomTypes_BasePrice
            CHECK (BasePrice >= 0),

        CONSTRAINT CK_RoomTypes_Capacity
            CHECK (Capacity > 0)
    );
END
GO


/* =========================================================
   客室テーブル
   ========================================================= */

IF OBJECT_ID(N'dbo.Rooms', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Rooms
    (
        RoomID INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_Rooms PRIMARY KEY,

        RoomNumber NVARCHAR(20) NOT NULL,

        RoomTypeID INT NOT NULL,

        Floor INT NULL,

        Status NVARCHAR(50) NOT NULL
            CONSTRAINT DF_Rooms_Status DEFAULT ('Available'),

        CONSTRAINT UQ_Rooms_RoomNumber
            UNIQUE (RoomNumber),

        CONSTRAINT FK_Rooms_RoomTypes
            FOREIGN KEY (RoomTypeID)
            REFERENCES dbo.RoomTypes(RoomTypeID),

        CONSTRAINT CK_Rooms_Floor
            CHECK (Floor IS NULL OR Floor > 0),

        CONSTRAINT CK_Rooms_Status
            CHECK (
                Status IN (
                    'Available',
                    'Occupied',
                    'Reserved'
                )
            )
    );
END
GO


/* =========================================================
   予約テーブル
   ========================================================= */

IF OBJECT_ID(N'dbo.Bookings', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Bookings
    (
        BookingID INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_Bookings PRIMARY KEY,

        GuestID INT NOT NULL,
        RoomID INT NOT NULL,

        CheckInDate DATETIME NOT NULL,
        CheckOutDate DATETIME NOT NULL,

        BookingDate DATETIME NOT NULL
            CONSTRAINT DF_Bookings_BookingDate DEFAULT (GETDATE()),

        Status NVARCHAR(50) NOT NULL
            CONSTRAINT DF_Bookings_Status DEFAULT ('Confirmed'),

        TotalAmount DECIMAL(18,2) NOT NULL
            CONSTRAINT DF_Bookings_TotalAmount DEFAULT (0),

        AmountPaid DECIMAL(18,2) NOT NULL
            CONSTRAINT DF_Bookings_AmountPaid DEFAULT (0),

        NumberOfGuests INT NOT NULL
            CONSTRAINT DF_Bookings_NumberOfGuests DEFAULT (1),

        SpecialRequest NVARCHAR(MAX) NULL,

        CreatedBy INT NULL,

        CONSTRAINT FK_Bookings_Guests
            FOREIGN KEY (GuestID)
            REFERENCES dbo.Guests(GuestID),

        CONSTRAINT FK_Bookings_Rooms
            FOREIGN KEY (RoomID)
            REFERENCES dbo.Rooms(RoomID),

        CONSTRAINT FK_Bookings_AdminUser
            FOREIGN KEY (CreatedBy)
            REFERENCES dbo.AdminUser(AdminID),

        CONSTRAINT CK_Bookings_Dates
            CHECK (CheckOutDate > CheckInDate),

        CONSTRAINT CK_Bookings_TotalAmount
            CHECK (TotalAmount >= 0),

        CONSTRAINT CK_Bookings_AmountPaid
            CHECK (AmountPaid >= 0),

        CONSTRAINT CK_Bookings_NumberOfGuests
            CHECK (NumberOfGuests > 0),

        CONSTRAINT CK_Bookings_Status
            CHECK (
                Status IN (
                    'Confirmed',
                    'CheckedIn',
                    'CheckedOut',
                    'Cancelled'
                )
            )
    );
END
GO


/* =========================================================
   インデックス
   ========================================================= */

/* ゲストID検索用 */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Bookings_GuestID'
      AND object_id = OBJECT_ID(N'dbo.Bookings')
)
BEGIN
    CREATE INDEX IX_Bookings_GuestID
        ON dbo.Bookings(GuestID);
END
GO


/* 客室ID検索用 */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Bookings_RoomID'
      AND object_id = OBJECT_ID(N'dbo.Bookings')
)
BEGIN
    CREATE INDEX IX_Bookings_RoomID
        ON dbo.Bookings(RoomID);
END
GO


/* 予約ステータス検索用 */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Bookings_Status'
      AND object_id = OBJECT_ID(N'dbo.Bookings')
)
BEGIN
    CREATE INDEX IX_Bookings_Status
        ON dbo.Bookings(Status);
END
GO


/* チェックイン日検索用 */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Bookings_CheckInDate'
      AND object_id = OBJECT_ID(N'dbo.Bookings')
)
BEGIN
    CREATE INDEX IX_Bookings_CheckInDate
        ON dbo.Bookings(CheckInDate);
END
GO


/* チェックアウト日検索用 */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Bookings_CheckOutDate'
      AND object_id = OBJECT_ID(N'dbo.Bookings')
)
BEGIN
    CREATE INDEX IX_Bookings_CheckOutDate
        ON dbo.Bookings(CheckOutDate);
END
GO


PRINT N'ホテル管理ダッシュボードの初期スキーマ作成が完了しました。';
GO