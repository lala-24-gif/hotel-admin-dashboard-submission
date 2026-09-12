<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="HotelManagement.Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ホテル管理ダッシュボード</title>
    
    <!-- モバイル端末のセーフエリアに対応するための viewport 設定 -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
    
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f7fa;
            color: #333;
            
            /* モバイル端末のセーフエリアを考慮して余白を設定 */
            padding-top: env(safe-area-inset-top);
            padding-bottom: env(safe-area-inset-bottom);
            padding-left: env(safe-area-inset-left);
            padding-right: env(safe-area-inset-right);
        }

        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            
            /* ノッチ領域を考慮して上部余白を調整 */
            padding-top: calc(20px + env(safe-area-inset-top));
        }

        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 1400px;
            margin: 0 auto;
        }

        .header h1 {
            font-size: 28px;
            font-weight: 600;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .user-info a {
            color: white;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 8px 15px;
            border-radius: 8px;
            transition: background 0.3s;
        }

        .user-info a:hover {
            background: rgba(255,255,255,0.2);
        }

        .user-info i {
            font-size: 24px;
        }

        /* 日付表示エリア */
        .date-banner {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.08) 0%, rgba(118, 75, 162, 0.08) 100%);
            padding: 15px 40px;
            border-bottom: 1px solid #e2e8f0;
            box-shadow: 0 2px 5px rgba(0,0,0,0.03);
            
            /* 左右のセーフエリアを考慮して余白を設定 */
            padding-left: max(40px, env(safe-area-inset-left));
            padding-right: max(40px, env(safe-area-inset-right));
        }

        .date-banner-content {
            max-width: 1400px;
            margin: 0 auto;
            display: flex;
            justify-content: flex-start;
            align-items: center;
        }

        .date-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .date-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 18px;
        }

        .date-text {
            display: flex;
            flex-direction: column;
        }

        .date-main {
            font-size: 18px;
            font-weight: 600;
            color: #2d3748;
        }

        .date-day {
            font-size: 13px;
            color: #718096;
            margin-top: 2px;
        }

        .dashboard-container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 40px;
            
            /* 左右のセーフエリアを考慮して余白を設定 */
            padding-left: max(40px, env(safe-area-inset-left));
            padding-right: max(40px, env(safe-area-inset-right));
            
            /* ホームインジケーター領域を考慮して下部余白を設定 */
            padding-bottom: calc(40px + env(safe-area-inset-bottom));
        }

        .section-title {
            font-size: 20px;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .section-title i {
            color: #667eea;
        }

        /* チェックアウト遅延警告バナー */
        .overdue-alert {
            background: linear-gradient(135deg, #fc5c7d 0%, #6a82fb 100%);
            border-radius: 12px;
            padding: 20px 30px;
            color: white;
            box-shadow: 0 4px 15px rgba(252, 92, 125, 0.3);
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
            transition: transform 0.3s, box-shadow 0.3s;
            animation: pulse 2s ease-in-out infinite;
        }

        .overdue-alert:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(252, 92, 125, 0.4);
        }

        @keyframes pulse {
            0%, 100% { box-shadow: 0 4px 15px rgba(252, 92, 125, 0.3); }
            50% { box-shadow: 0 4px 25px rgba(252, 92, 125, 0.5); }
        }

        .overdue-content {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .overdue-icon {
            width: 60px;
            height: 60px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
        }

        .overdue-text h3 {
            font-size: 22px;
            margin-bottom: 5px;
        }

        .overdue-text p {
            font-size: 14px;
            opacity: 0.9;
        }

        .overdue-action {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 16px;
            font-weight: 600;
        }

        .overdue-badge {
            background: rgba(255, 255, 255, 0.3);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 18px;
            font-weight: 700;
        }

        /* ダッシュボード各行のレイアウト */
        .dashboard-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }

        /* 統計カード */
        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            transition: transform 0.3s, box-shadow 0.3s;
            border-left: 4px solid;
            cursor: pointer;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.12);
        }

        .stat-card.guests { border-color: #667eea; }
        .stat-card.bookings { border-color: #f093fb; }
        .stat-card.checkins { border-color: #4facfe; }

        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .stat-title {
            font-size: 14px;
            color: #718096;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: white;
        }

        .stat-card.guests .stat-icon {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .stat-card.bookings .stat-icon {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }

        .stat-card.checkins .stat-icon {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }

        .stat-value {
            font-size: 36px;
            font-weight: 700;
            color: #2d3748;
            margin-bottom: 5px;
        }

        .stat-label {
            font-size: 13px;
            color: #a0aec0;
        }

        .room-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            transition: transform 0.3s;
            text-align: center;
        }

        .room-card:hover {
            transform: translateY(-5px);
        }

        .room-card.available {
            border-top: 4px solid #48bb78;
        }

        .room-card.occupied {
            border-top: 4px solid #f56565;
        }

        .room-card.reserved {
            border-top: 4px solid #ed8936;
        }

        .room-icon {
            width: 60px;
            height: 60px;
            margin: 0 auto 15px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            color: white;
        }

        .room-card.available .room-icon {
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
        }

        .room-card.occupied .room-icon {
            background: linear-gradient(135deg, #f56565 0%, #c53030 100%);
        }

        .room-card.reserved .room-icon {
            background: linear-gradient(135deg, #ed8936 0%, #dd6b20 100%);
        }

        .room-value {
            font-size: 36px;
            font-weight: 700;
            color: #2d3748;
            margin-bottom: 5px;
        }

        .room-label {
            font-size: 14px;
            color: #718096;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* 売上カード */
        .sales-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
            transition: transform 0.3s, box-shadow 0.3s;
            cursor: pointer;
            color: white;
        }

        .sales-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
        }

        .sales-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .sales-info h3 {
            font-size: 18px;
            margin-bottom: 15px;
            opacity: 0.95;
        }

        .sales-amount {
            font-size: 42px;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .sales-label {
            font-size: 14px;
            opacity: 0.9;
            margin-bottom: 20px;
        }

        .view-details {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 16px;
            font-weight: 600;
        }

        .sales-icon-large {
            font-size: 120px;
            opacity: 0.15;
        }

        /* データ一覧テーブル */
        .data-table {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            overflow-x: auto;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
        }

        .table thead {
            background: #f7fafc;
        }

        .table th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #4a5568;
            border-bottom: 2px solid #e2e8f0;
        }

        .table td {
            padding: 15px;
            border-bottom: 1px solid #e2e8f0;
            color: #2d3748;
        }

        .table tr:hover {
            background: #f7fafc;
        }

        /* クイック操作 */
        .quick-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 30px;
        }

        .action-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 24px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
        }

        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }

        .action-btn i {
            font-size: 18px;
        }

        /* カード全体をクリック可能にするためのリンク設定 */
        .card-link {
            text-decoration: none;
            color: inherit;
            display: block;
        }

        @media (max-width: 768px) {
            .header {
                padding: 15px 20px;

                /* モバイル表示でも上部のセーフエリアを維持 */
                padding-top: calc(15px + env(safe-area-inset-top));
            }

            .dashboard-container {
                padding: 0 20px;

                /* モバイル端末の左右セーフエリアを考慮 */
                padding-left: max(20px, env(safe-area-inset-left));
                padding-right: max(20px, env(safe-area-inset-right));
                padding-bottom: calc(20px + env(safe-area-inset-bottom));
            }
            
            .date-banner {
                padding: 12px 20px;
                padding-left: max(20px, env(safe-area-inset-left));
                padding-right: max(20px, env(safe-area-inset-right));
            }

            .date-banner-content {
                justify-content: center;
            }
            
            .dashboard-row {
                grid-template-columns: 1fr;
            }

            .sales-content {
                flex-direction: column;
                text-align: center;
            }

            .sales-icon-large {
                display: none;
            }

            .quick-actions {
                flex-direction: column;
            }

            .action-btn {
                width: 100%;
                justify-content: center;
            }

            .overdue-alert {
                flex-direction: column;
                text-align: center;
                gap: 15px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- ヘッダー -->
        <div class="header">
            <div class="header-content">
                <h1><i class="fas fa-hotel"></i> ホテル管理ダッシュボード</h1>
                <div class="user-info">
                    <a href="Profile.aspx">
                        <span>
                            <asp:Label ID="lblUsername" runat="server" Text="管理者"></asp:Label>
                        </span>
                        <i class="fas fa-user-circle"></i>
                    </a>
                </div>
            </div>
        </div>

        <!-- 日付表示 -->
        <div class="date-banner">
            <div class="date-banner-content">
                <div class="date-info">
                    <div class="date-icon">
                        <i class="fas fa-calendar-day"></i>
                    </div>

                    <div class="date-text">
                        <div class="date-main">
                            <asp:Label ID="lblCurrentDate" runat="server" Text=""></asp:Label>
                        </div>

                        <div class="date-day">
                            <asp:Label ID="lblCurrentDay" runat="server" Text=""></asp:Label>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ダッシュボード本体 -->
        <div class="dashboard-container">
            
		<!-- チェックアウト遅延警告 -->
		<asp:Panel
		    ID="pnlOverdueWarning"
		    runat="server"
		    CssClass="overdue-alert"
		    Visible="false">
                onclick="window.location.href='<%= ResolveUrl("~/Pages/Bookings/OverdueCheckouts.aspx") %>'"

                <div class="overdue-content">
                    <div class="overdue-icon">
                        <i class="fas fa-exclamation-triangle"></i>
                    </div>

                    <div class="overdue-text">
                        <h3>⚠️ 遅延チェックアウト検出！</h3>
                        <p>一部のゲストが12時のチェックアウト時間を過ぎています</p>
                    </div>
                </div>

                <div class="overdue-action">
                    <span class="overdue-badge">
                        <asp:Label
                            ID="lblOverdueCount"
                            runat="server"
                            Text="0">
                        </asp:Label>
                    </span>

                    <span>詳細を表示 →</span>
                </div>
            </asp:Panel>

            <!-- クイック操作 -->
            <div class="quick-actions">

                <a href="<%= ResolveUrl("~/Pages/Bookings/Booking.aspx") %>" class="action-btn">
                    <i class="fas fa-calendar-check"></i>
                    <span>予約作成</span>
                </a>

                <a
                    href="<%= ResolveUrl("~/Pages/Guests/GuestList.aspx") %>"
                    class="action-btn"
                    style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">

                    <i class="fas fa-address-book"></i>
                    <span>全ゲストを表示</span>
                </a>
            </div>
            
            <!-- 1行目：チェックイン・予約状況 -->
            <div class="section-title">
                <i class="fas fa-chart-line"></i>
                概要
            </div>

            <div class="dashboard-row">

                <!-- チェックイン状況カード -->
                <a href="<%= ResolveUrl("~/Pages/Bookings/CheckInsList.aspx") %>" class="card-link">
                    <div class="stat-card checkins">
                        <div class="stat-header">
                            <span class="stat-title">チェックイン</span>

                            <div class="stat-icon">
                                <i class="fas fa-sign-in-alt"></i>
                            </div>
                        </div>

                        <div class="stat-value">
                            <asp:Label
                                ID="lblCheckIns"
                                runat="server"
                                Text="0">
                            </asp:Label>
                        </div>

                        <div class="stat-label">
                            本日予定
                        </div>
                    </div>
                </a>

                <!-- 予約状況カード -->
                <a href="<%= ResolveUrl("~/Pages/Bookings/BookingsList.aspx") %>" class="card-link">
                    <div class="stat-card bookings">
                        <div class="stat-header">
                            <span class="stat-title">全体のゲストデータ</span>

                            <div class="stat-icon">
                                <i class="fas fa-calendar-check"></i>
                            </div>
                        </div>

                        <div class="stat-value">
                            <asp:Label
                                ID="lblBookings"
                                runat="server"
                                Text="0">
                            </asp:Label>
                        </div>

                        <div class="stat-label">
                            総予約数
                        </div>
                    </div>
                </a>
            </div>

            <!-- 2行目：客室状況 -->
            <div class="section-title">
                <i class="fas fa-door-open"></i>
                客室
            </div>

            <div
                class="dashboard-row"
                style="cursor: pointer;"
                onclick="window.location.href='<%= ResolveUrl("~/Pages/Rooms/Rooms.aspx") %>'">

                <div class="room-card available">
                    <div class="room-icon">
                        <i class="fas fa-bed"></i>
                    </div>

                    <div class="room-value">
                        <asp:Label
                            ID="lblAvailableRooms"
                            runat="server"
                            Text="0">
                        </asp:Label>
                    </div>

                    <div class="room-label">
                        空室
                    </div>
                </div>

                <div class="room-card occupied">
                    <div class="room-icon">
                        <i class="fas fa-user-check"></i>
                    </div>

                    <div class="room-value">
                        <asp:Label
                            ID="lblOccupiedRooms"
                            runat="server"
                            Text="0">
                        </asp:Label>
                    </div>

                    <div class="room-label">
                        使用中
                    </div>
                </div>

                <div class="room-card reserved">
                    <div class="room-icon">
                        <i class="fas fa-bookmark"></i>
                    </div>

                    <div class="room-value">
                        <asp:Label
                            ID="lblReservedRooms"
                            runat="server"
                            Text="0">
                        </asp:Label>
                    </div>

                    <div class="room-label">
                        予約済み
                    </div>
                </div>
            </div>

            <!-- 3行目：売上・収益 -->
            <div class="section-title">
                <i class="fas fa-chart-bar"></i>
                財務概要
            </div>

            <div class="dashboard-row">

                <asp:LinkButton
                    ID="btnViewSales"
                    runat="server"
                    OnClick="btnViewSales_Click"
                    CssClass="sales-card"
                    style="text-decoration: none; color: white;">

                    <div class="sales-content">

                        <div class="sales-info">
                            <h3>月間収益</h3>

                            <div class="sales-amount">
                                ¥<asp:Label
                                    ID="lblMonthlyRevenue"
                                    runat="server"
                                    Text="0">
                                </asp:Label>
                            </div>

                            <div class="sales-label">
                                今月の取引数:
                                <asp:Label
                                    ID="lblTransactionCount"
                                    runat="server"
                                    Text="0">
                                </asp:Label>
                                件
                            </div>

                            <div class="view-details">
                                <span>詳細レポートを表示</span>
                                <i class="fas fa-arrow-right"></i>
                            </div>
                        </div>

                        <div class="sales-icon-large">
                            <i class="fas fa-yen-sign"></i>
                        </div>
                    </div>
                </asp:LinkButton>
            </div>

            <!-- 現在宿泊中のゲスト一覧 -->
            <div class="section-title">
                <i class="fas fa-list"></i>
                現在のゲスト
            </div>

            <div class="data-table">
                <asp:GridView
                    ID="gvCurrentGuests"
                    runat="server"
                    AutoGenerateColumns="False"
                    GridLines="None"
                    CssClass="table"
                    ShowHeaderWhenEmpty="True"
                    EmptyDataText="現在のゲストはいません">

                    <Columns>
                        <asp:BoundField
                            DataField="GuestName"
                            HeaderText="ゲスト名" />

                        <asp:BoundField
                            DataField="RoomNumber"
                            HeaderText="客室番号" />

                        <asp:BoundField
                            DataField="RoomType"
                            HeaderText="客室タイプ" />

                        <asp:BoundField
                            DataField="CheckInDate"
                            HeaderText="チェックイン"
                            DataFormatString="{0:yyyy年MM月dd日}" />

                        <asp:BoundField
                            DataField="CheckOutDate"
                            HeaderText="チェックアウト"
                            DataFormatString="{0:yyyy年MM月dd日 HH:mm}" />

                        <asp:BoundField
                            DataField="NightsStay"
                            HeaderText="宿泊数" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </form>
</body>
</html>