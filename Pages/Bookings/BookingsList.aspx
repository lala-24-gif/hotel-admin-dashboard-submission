<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BookingsList.aspx.cs" Inherits="HotelManagement.BookingsList" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>全体のゲストデータ</title>

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
        }

        /* ヘッダー */
        .header {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            padding: 20px 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
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

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(255,255,255,0.2);
            padding: 10px 20px;
            border-radius: 8px;
            color: white;
            text-decoration: none;
            transition: background 0.3s;
        }

        .back-btn:hover {
            background: rgba(255,255,255,0.3);
        }

        /* メインコンテンツ */
        .container {
            max-width: 1400px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .page-intro {
            text-align: center;
            margin-bottom: 40px;
        }

        .page-intro h2 {
            font-size: 32px;
            font-weight: 700;
            color: #2d3748;
            margin-bottom: 10px;
        }

        .page-intro p {
            font-size: 16px;
            color: #718096;
        }

        /* 検索・絞り込み条件 */
        .filter-section {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            margin-bottom: 30px;
            display: flex;
            gap: 15px;
            align-items: end;
            flex-wrap: wrap;
        }

        .filter-group {
            flex: 1;
            min-width: 200px;
        }

        .filter-label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: #4a5568;
            margin-bottom: 8px;
        }

        .filter-select {
            width: 100%;
            padding: 10px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
        }

        .btn-filter {
            padding: 10px 20px;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-filter:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(240, 147, 251, 0.4);
        }

        /* 予約状況の集計カード */
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }

        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            border-left: 4px solid #f093fb;
        }

        .stat-label {
            font-size: 14px;
            color: #718096;
            margin-bottom: 8px;
        }

        .stat-value {
            font-size: 32px;
            font-weight: 700;
            color: #f093fb;
        }

        /* 成功・エラーメッセージ */
        .alert {
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .alert-success {
            background: #c6f6d5;
            color: #22543d;
            border-left: 4px solid #48bb78;
        }

        .alert-danger {
            background: #fed7d7;
            color: #742a2a;
            border-left: 4px solid #f56565;
        }

        /* 予約一覧 */
        .bookings-grid {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            overflow: hidden;
        }

        .grid-header {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .grid-header h3 {
            font-size: 20px;
            font-weight: 600;
        }

        .gridview-wrapper {
            overflow-x: auto;
        }

        .gridview {
            width: 100%;
            border-collapse: collapse;
        }

        .gridview th {
            background: #f7fafc;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #4a5568;
            border-bottom: 2px solid #e2e8f0;
            white-space: nowrap;
        }

        .gridview td {
            padding: 15px;
            border-bottom: 1px solid #e2e8f0;
        }

        .gridview tr:hover {
            background: #f7fafc;
        }

        /* 予約ステータス表示 */
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }

        .status-confirmed {
            background: #bee3f8;
            color: #2c5282;
        }

        .status-checkedin {
            background: #c6f6d5;
            color: #22543d;
        }

        .status-checkedout {
            background: #e2e8f0;
            color: #4a5568;
        }

        .status-cancelled {
            background: #fed7d7;
            color: #742a2a;
        }

        /* 一覧内の操作ボタン */
        .btn-action {
            padding: 6px 12px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.3s;
            margin-right: 5px;
        }

        .btn-checkout {
            background: #48bb78;
            color: white;
        }

        .btn-checkout:hover {
            background: #38a169;
        }

        .btn-cancel {
            background: #f56565;
            color: white;
        }

        .btn-cancel:hover {
            background: #e53e3e;
        }

        .btn-view {
            background: #e2e8f0;
            color: #4a5568;
        }

        .btn-view:hover {
            background: #cbd5e0;
        }

        /* データが存在しない場合の表示 */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
        }

        .empty-icon {
            font-size: 64px;
            color: #cbd5e0;
            margin-bottom: 20px;
        }

        .empty-title {
            font-size: 24px;
            font-weight: 600;
            color: #4a5568;
            margin-bottom: 10px;
        }

        .empty-desc {
            font-size: 16px;
            color: #718096;
        }

        /* モバイル表示 */
        @media (max-width: 768px) {
            .filter-section {
                flex-direction: column;
            }

            .filter-group {
                width: 100%;
            }

            .stats-cards {
                grid-template-columns: 1fr;
            }

            .gridview th,
            .gridview td {
                padding: 10px;
            }
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">

        <!-- ヘッダー -->
        <div class="header">
            <div class="header-content">
                <h1>
                    <i class="fas fa-users-cog"></i>
                    全体のゲストデータ
                </h1>

                <a href="<%= ResolveUrl("~/Default.aspx") %>" class="back-btn">
                    <i class="fas fa-arrow-left"></i>
                    <span>ダッシュボードに戻る</span>
                </a>
            </div>
        </div>

        <!-- メインコンテンツ -->
        <div class="container">

            <!-- ページ説明 -->
            <div class="page-intro">
                <h2>ゲストデータ管理</h2>
                <p>すべてのゲストの予約と滞在を表示・管理</p>
            </div>

            <!-- 成功メッセージ -->
            <asp:Panel
                ID="pnlSuccess"
                runat="server"
                CssClass="alert alert-success"
                Visible="false">

                <i class="fas fa-check-circle"></i>
                <asp:Label ID="lblSuccess" runat="server"></asp:Label>
            </asp:Panel>

            <!-- エラーメッセージ -->
            <asp:Panel
                ID="pnlError"
                runat="server"
                CssClass="alert alert-danger"
                Visible="false">

                <i class="fas fa-exclamation-circle"></i>
                <asp:Label ID="lblError" runat="server"></asp:Label>
            </asp:Panel>

            <!-- 絞り込み条件 -->
            <div class="filter-section">

                <!-- ステータスによる絞り込み -->
                <div class="filter-group">
                    <label class="filter-label">
                        ステータスでフィルター
                    </label>

                    <asp:DropDownList
                        ID="ddlStatusFilter"
                        runat="server"
                        CssClass="filter-select">

                        <asp:ListItem Value="All">
                            全ゲスト
                        </asp:ListItem>

                        <asp:ListItem Value="Confirmed" Selected="True">
                            確認済み
                        </asp:ListItem>

                        <asp:ListItem Value="CheckedIn">
                            チェックイン済み
                        </asp:ListItem>

                        <asp:ListItem Value="CheckedOut">
                            チェックアウト済み
                        </asp:ListItem>

                        <asp:ListItem Value="Cancelled">
                            キャンセル済み
                        </asp:ListItem>

                    </asp:DropDownList>
                </div>

                <!-- 日付による絞り込み -->
                <div class="filter-group">
                    <label class="filter-label">
                        日付範囲
                    </label>

                    <asp:DropDownList
                        ID="ddlDateFilter"
                        runat="server"
                        CssClass="filter-select">

                        <asp:ListItem Value="All" Selected="True">
                            すべての日付
                        </asp:ListItem>

                        <asp:ListItem Value="Today">
                            本日
                        </asp:ListItem>

                        <asp:ListItem Value="Week">
                            今週
                        </asp:ListItem>

                        <asp:ListItem Value="Month">
                            今月
                        </asp:ListItem>

                        <asp:ListItem Value="Future">
                            今後のゲスト
                        </asp:ListItem>

                    </asp:DropDownList>
                </div>

                <!-- フィルター適用ボタン -->
                <div>
                    <asp:Button
                        ID="btnApplyFilter"
                        runat="server"
                        Text="フィルター適用"
                        CssClass="btn-filter"
                        OnClick="btnApplyFilter_Click" />
                </div>

            </div>

            <!-- 予約状況集計 -->
            <div class="stats-cards">

                <div class="stat-card">
                    <div class="stat-label">
                        総レコード数
                    </div>

                    <div class="stat-value">
                        <asp:Label
                            ID="lblTotalBookings"
                            runat="server"
                            Text="0">
                        </asp:Label>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-label">
                        確認済み
                    </div>

                    <div class="stat-value">
                        <asp:Label
                            ID="lblConfirmed"
                            runat="server"
                            Text="0">
                        </asp:Label>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-label">
                        チェックイン済み
                    </div>

                    <div class="stat-value">
                        <asp:Label
                            ID="lblCheckedIn"
                            runat="server"
                            Text="0">
                        </asp:Label>
                    </div>
                </div>

            </div>

            <!-- ゲスト予約一覧 -->
            <div class="bookings-grid">

                <div class="grid-header">
                    <h3>
                        <i class="fas fa-database"></i>
                        ゲストデータリスト
                    </h3>
                </div>

                <div class="gridview-wrapper">
                    <asp:GridView
                        ID="gvBookings"
                        runat="server"
                        CssClass="gridview"
                        AutoGenerateColumns="False"
                        OnRowCommand="gvBookings_RowCommand"
                        EmptyDataText="予約が見つかりません">

						<Columns>

						    <asp:BoundField
						        DataField="BookingID"
						        HeaderText="ID" />

						    <asp:BoundField
						        DataField="GuestName"
						        HeaderText="ゲスト名" />

                           
                            <asp:BoundField
                                DataField="RoomNumber"
                                HeaderText="客室番号" />

                            <asp:BoundField
                                DataField="CheckInDate"
                                HeaderText="チェックイン"
                                DataFormatString="{0:yyyy-MM-dd}" />

                            <asp:BoundField
                                DataField="CheckOutDate"
                                HeaderText="チェックアウト"
                                DataFormatString="{0:yyyy-MM-dd}" />

                            <asp:BoundField
                                DataField="NumberOfGuests"
                                HeaderText="人数" />


                            <asp:BoundField
                                DataField="TotalAmount"
                                HeaderText="金額"
                                DataFormatString="¥{0:N0}" />

                            
                            <asp:TemplateField HeaderText="ステータス">
                                <ItemTemplate>
                                    <span class='status-badge status-<%# Eval("Status").ToString().ToLower() %>'>
                                        <%# GetStatusText(Eval("Status").ToString()) %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>


                            <asp:TemplateField HeaderText="操作">
                                <ItemTemplate>


                                    <asp:Button
                                        ID="btnCheckOut"
                                        runat="server"
                                        Text="チェックアウト"
                                        CommandName="CheckOut"
                                        CommandArgument='<%# Eval("BookingID") %>'
                                        CssClass="btn-action btn-checkout"
                                        Visible='<%# Eval("Status").ToString() == "CheckedIn" %>'
                                        OnClientClick="return confirm('このゲストをチェックアウトしますか？');" />

                                    <!-- チェックアウト済み・キャンセル済み以外の予約をキャンセル可能 -->
                                    <asp:Button
                                        ID="btnCancel"
                                        runat="server"
                                        Text="キャンセル"
                                        CommandName="CancelBooking"
                                        CommandArgument='<%# Eval("BookingID") %>'
                                        CssClass="btn-action btn-cancel"
                                        Visible='<%# Eval("Status").ToString() != "CheckedOut" && Eval("Status").ToString() != "Cancelled" %>'
                                        OnClientClick="return confirm('この予約をキャンセルしますか？');" />

                                </ItemTemplate>
                            </asp:TemplateField>

                        </Columns>

                       
                        <EmptyDataTemplate>
                            <div class="empty-state">
                                <div class="empty-icon">
                                    <i class="fas fa-calendar-times"></i>
                                </div>

                                <div class="empty-title">
                                    ゲストデータが見つかりません
                                </div>

                                <div class="empty-desc">
                                    フィルターを調整するか、新しい予約を作成してください
                                </div>
                            </div>
                        </EmptyDataTemplate>

                    </asp:GridView>
                </div>
            </div>

        </div>
    </form>
</body>
</html>