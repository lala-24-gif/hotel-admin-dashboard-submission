<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OverdueCheckouts.aspx.cs" Inherits="HotelManagement.OverdueCheckouts" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>チェックアウト遅延 - ホテル管理システム</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif, 'メイリオ', Meiryo, 'ヒラギノ角ゴ Pro', 'Hiragino Kaku Gothic Pro', sans-serif;
            background: #f5f7fa;
            color: #333;
        }

        .header {
            background: linear-gradient(135deg, #fc5c7d 0%, #6a82fb 100%);
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
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
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
            padding: 0 40px;
        }

        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 15px;
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

        .info-banner {
            background: white;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .info-content h2 {
            font-size: 24px;
            color: #2d3748;
            margin-bottom: 10px;
        }

        .info-content p {
            color: #718096;
            font-size: 14px;
        }

        .info-stats {
            text-align: center;
            padding: 15px 30px;
            background: linear-gradient(135deg, #fc5c7d 0%, #6a82fb 100%);
            border-radius: 10px;
            color: white;
        }

        .info-stats .count {
            font-size: 48px;
            font-weight: 700;
        }

        .info-stats .label {
            font-size: 14px;
            opacity: 0.9;
        }

        .checkout-grid {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
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
        }

        .gridview td {
            padding: 15px;
            border-bottom: 1px solid #e2e8f0;
        }

        .gridview tr:hover {
            background: #fff5f5;
        }

        .overdue-row {
            background: #fff5f5 !important;
            animation: pulse-red 2s ease-in-out infinite;
        }

        @keyframes pulse-red {
            0%, 100% { background: #fff5f5; }
            50% { background: #fed7d7; }
        }

        .status-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .status-overdue {
            background: #fed7d7;
            color: #742a2a;
            animation: blink 1.5s ease-in-out infinite;
        }

        @keyframes blink {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.6; }
        }

        .btn-action {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .btn-checkout {
            background: #48bb78;
            color: white;
        }

        .btn-checkout:hover {
            background: #38a169;
            transform: translateY(-2px);
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
        }

        .empty-icon {
            font-size: 64px;
            color: #48bb78;
            margin-bottom: 20px;
        }

        .empty-title {
            font-size: 24px;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 10px;
        }

        .empty-desc {
            font-size: 16px;
            color: #718096;
        }

        .time-info {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 13px;
            color: #e53e3e;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="header">
            <div class="header-content">
                <h1>
                    <i class="fas fa-exclamation-triangle"></i>
                    チェックアウト遅延
                </h1>
                <a href="<%= ResolveUrl("~/Default.aspx") %>" class="back-btn">
                    <i class="fas fa-arrow-left"></i>
                    ダッシュボードに戻る
                </a>
            </div>
        </div>

        <div class="container">
            <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert alert-success" Visible="false">
                <i class="fas fa-check-circle" style="font-size: 24px;"></i>
                <asp:Label ID="lblSuccess" runat="server"></asp:Label>
            </asp:Panel>

            <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger" Visible="false">
                <i class="fas fa-exclamation-circle" style="font-size: 24px;"></i>
                <asp:Label ID="lblError" runat="server"></asp:Label>
            </asp:Panel>

            <div class="info-banner">
                <div class="info-content">
                    <h2>⚠️ チェックアウト遅延管理</h2>
                    <p>以下のゲストは12:00 PMのチェックアウト時刻を過ぎています。チェックアウト手続きを行うか、ご連絡ください。</p>
                    <p style="margin-top: 10px; font-weight: 600; color: #fc5c7d;">
                        <i class="fas fa-clock"></i> 現在時刻: <asp:Label ID="lblCurrentTime" runat="server"></asp:Label>
                    </p>
                </div>
                <div class="info-stats">
                    <div class="count"><asp:Label ID="lblOverdueCount" runat="server">0</asp:Label></div>
                    <div class="label">チェックアウト遅延</div>
                </div>
            </div>

            <div class="checkout-grid">
                <asp:GridView ID="gvOverdueCheckouts" runat="server" 
                    CssClass="gridview" 
                    AutoGenerateColumns="False"
                    OnRowCommand="gvOverdueCheckouts_RowCommand"
                    EmptyDataText="チェックアウト遅延はありません">
                    <Columns>
                        <asp:BoundField DataField="BookingID" HeaderText="予約ID" />
                        <asp:BoundField DataField="GuestName" HeaderText="ゲスト名" />
                        <asp:BoundField DataField="RoomNumber" HeaderText="部屋番号" />
                        <asp:BoundField DataField="CheckInDate" HeaderText="チェックイン" DataFormatString="{0:yyyy年MM月dd日}" />
                        <asp:BoundField DataField="CheckOutDate" HeaderText="予定チェックアウト" DataFormatString="{0:yyyy年MM月dd日 HH:mm}" />
                        <asp:TemplateField HeaderText="遅延時間">
                            <ItemTemplate>
                                <div class="time-info">
                                    <i class="fas fa-clock"></i>
                                    <%# GetHoursOverdue(Eval("CheckOutDate")) %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="TotalAmount" HeaderText="金額" DataFormatString="¥{0:N0}" />
                        <asp:TemplateField HeaderText="ステータス">
                            <ItemTemplate>
                                <span class="status-badge status-overdue">
                                    遅延中
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="操作">
                            <ItemTemplate>
                                <asp:Button ID="btnCheckOut" runat="server" 
                                    Text="今すぐチェックアウト" 
                                    CommandName="CheckOutNow" 
                                    CommandArgument='<%# Eval("BookingID") %>'
                                    CssClass="btn-action btn-checkout"
                                    OnClientClick="return confirm('このゲストをチェックアウトしますか？');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="empty-state">
                            <div class="empty-icon">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <div class="empty-title">問題なし！ 🎉</div>
                            <div class="empty-desc">現在、チェックアウト遅延はありません。すべてのゲストが予定通りです。</div>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </form>
</body>
</html>
