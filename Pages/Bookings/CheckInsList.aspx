<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CheckInsList.aspx.cs" Inherits="HotelManagement.CheckInsList" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>本日のチェックイン</title>
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

        .header {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
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
            border-left: 4px solid #4facfe;
        }

        .stat-label {
            font-size: 14px;
            color: #718096;
            margin-bottom: 8px;
        }

        .stat-value {
            font-size: 32px;
            font-weight: 700;
            color: #4facfe;
        }

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

        .checkins-grid {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            overflow: hidden;
        }

        .grid-header {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
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

        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }

        .status-pending {
            background: #fbd38d;
            color: #744210;
        }

        .status-confirmed {
            background: #bee3f8;
            color: #2c5282;
        }

        .status-checkedin {
            background: #c6f6d5;
            color: #22543d;
        }

        .btn-checkin {
            background: #48bb78;
            color: white;
            padding: 6px 14px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            transition: background 0.2s;
            margin-right: 4px;
        }

        .btn-checkin:hover {
            background: #38a169;
        }

        .btn-checkout {
            background: #48bb78;
            color: white;
            padding: 6px 14px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            transition: background 0.2s;
            margin-right: 4px;
        }

        .btn-checkout:hover {
            background: #38a169;
        }

        .btn-cancel {
            background: #f56565;
            color: white;
            padding: 6px 14px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            transition: background 0.2s;
        }

        .btn-cancel:hover {
            background: #e53e3e;
        }

        .action-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 4px;
            align-items: center;
        }

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

        /* Special Request styling */
        .request-cell {
            max-width: 200px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .request-cell:hover {
            white-space: normal;
            overflow: visible;
        }

        @media (max-width: 768px) {
            .stats-cards {
                grid-template-columns: 1fr;
            }

            .gridview-wrapper {
                font-size: 14px;
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
        <div class="header">
            <div class="header-content">
                <h1><i class="fas fa-sign-in-alt"></i> 本日のチェックイン</h1>
                <a href="<%= ResolveUrl("~/Default.aspx") %>" class="back-btn">
                    <i class="fas fa-arrow-left"></i>
                    <span>ダッシュボードに戻る</span>
                </a>
            </div>
        </div>

        <div class="container">
            <div class="page-intro">
                <h2>予定されているチェックイン</h2>
                <p>本日チェックイン予定のゲスト</p>
            </div>

            <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert alert-success" Visible="false">
                <i class="fas fa-check-circle"></i>
                <asp:Label ID="lblSuccess" runat="server"></asp:Label>
            </asp:Panel>

            <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger" Visible="false">
                <i class="fas fa-exclamation-circle"></i>
                <asp:Label ID="lblError" runat="server"></asp:Label>
            </asp:Panel>

            <div class="stats-cards">
                <div class="stat-card">
                    <div class="stat-label">予定総数</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalExpected" runat="server" Text="0"></asp:Label>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">チェックイン済み</div>
                    <div class="stat-value">
                        <asp:Label ID="lblAlreadyCheckedIn" runat="server" Text="0"></asp:Label>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">チェックイン待ち</div>
                    <div class="stat-value">
                        <asp:Label ID="lblPending" runat="server" Text="0"></asp:Label>
                    </div>
                </div>
            </div>

            <div class="checkins-grid">
                <div class="grid-header">
                    <h3><i class="fas fa-calendar-check"></i> チェックインリスト</h3>
                </div>
                <div class="gridview-wrapper">
                    <asp:GridView ID="gvCheckIns" runat="server" 
                        CssClass="gridview" 
                        AutoGenerateColumns="False"
                        OnRowCommand="gvCheckIns_RowCommand"
                        EmptyDataText="本日のチェックインはありません">
                        <Columns>
                            <asp:BoundField DataField="RoomNumber" HeaderText="客室番号" />
                            <asp:BoundField DataField="GuestName" HeaderText="ゲスト名" />
                           
                            <asp:BoundField DataField="ExpectedTime" HeaderText="予定時刻" />
                            <asp:BoundField DataField="CheckOutDate" HeaderText="チェックアウト" DataFormatString="{0:yyyy-MM-dd}" />
                            <asp:BoundField DataField="NumberOfGuests" HeaderText="人数" />
                            <asp:BoundField DataField="TotalAmount" HeaderText="金額" DataFormatString="¥{0:N0}" />
                            <asp:TemplateField HeaderText="特別なリクエスト">
                                <ItemTemplate>
                                    <div class="request-cell" title='<%# Eval("SpecialRequest") %>'>
                                        <%# Eval("SpecialRequest") %>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="ステータス">
                                <ItemTemplate>
                                    <span class='status-badge status-<%# Eval("Status").ToString().ToLower() %>'>
                                        <%# GetStatusText(Eval("Status").ToString()) %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="操作">
                                <ItemTemplate>
                                    <div class="action-buttons">
                                        <asp:Button ID="btnCheckIn" runat="server" 
                                            Text="チェックイン" 
                                            CommandName="CheckInGuest" 
                                            CommandArgument='<%# Eval("BookingID") %>'
                                            CssClass="btn-checkin"
                                            Visible='<%# Eval("Status").ToString() != "CheckedIn" %>' />
                                        <asp:Button ID="btnCheckOut" runat="server" 
                                            Text="チェックアウト" 
                                            CommandName="CheckOutGuest" 
                                            CommandArgument='<%# Eval("BookingID") %>'
                                            CssClass="btn-checkout"
                                            Visible='<%# Eval("Status").ToString() == "CheckedIn" %>'
                                            OnClientClick="return confirm('このゲストをチェックアウトしますか？');" />
                                        <asp:Button ID="btnCancel" runat="server" 
                                            Text="キャンセル" 
                                            CommandName="CancelBooking" 
                                            CommandArgument='<%# Eval("BookingID") %>'
                                            CssClass="btn-cancel"
                                            OnClientClick="return confirm('この予約をキャンセルしますか？');" />
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="empty-state">
                                <div class="empty-icon">
                                    <i class="fas fa-calendar-times"></i>
                                </div>
                                <div class="empty-title">本日のチェックインなし</div>
                                <div class="empty-desc">本日チェックイン予定のゲストはいません</div>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
