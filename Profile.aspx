<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="HotelManagement.Profile" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ユーザープロフィール</title>
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 1200px;
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
            max-width: 800px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .profile-card {
            background: white;
            border-radius: 12px;
            padding: 40px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }

        .profile-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .profile-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 48px;
            color: white;
        }

        .profile-name {
            font-size: 28px;
            font-weight: 700;
            color: #2d3748;
            margin-bottom: 5px;
        }

        .profile-role {
            font-size: 14px;
            color: #718096;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .info-group {
            margin-bottom: 25px;
        }

        .info-label {
            font-size: 14px;
            font-weight: 600;
            color: #4a5568;
            margin-bottom: 8px;
            display: block;
        }

        .info-value {
            font-size: 16px;
            color: #2d3748;
            padding: 12px;
            background: #f7fafc;
            border-radius: 8px;
        }

        .actions-section {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }

        .section-title {
            font-size: 18px;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 20px;
        }

        .btn {
            width: 100%;
            padding: 14px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-logout {
            background: #667eea;
            color: white;
        }

        .btn-logout:hover {
            background: #5568d3;
            transform: translateY(-2px);
        }

        .btn-delete {
            background: #f56565;
            color: white;
        }

        .btn-delete:hover {
            background: #e53e3e;
            transform: translateY(-2px);
        }

        .alert {
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
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

        .delete-warning {
            background: #fef5e7;
            border: 1px solid #f39c12;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 20px;
        }

        .delete-warning i {
            color: #f39c12;
            margin-right: 10px;
        }

        .delete-warning-text {
            font-size: 14px;
            color: #856404;
            line-height: 1.5;
        }

        @media (max-width: 768px) {
            .profile-card {
                padding: 30px 20px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Header -->
        <div class="header">
            <div class="header-content">
                <h1><i class="fas fa-user-circle"></i> ユーザープロフィール</h1>
                <a href="Default.aspx" class="back-btn">
                    <i class="fas fa-arrow-left"></i>
                    <span>ダッシュボードに戻る</span>
                </a>
            </div>
        </div>

        <!-- Main Container -->
        <div class="container">
            <!-- Success/Error Messages -->
            <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert alert-success" Visible="false">
                <asp:Label ID="lblSuccess" runat="server"></asp:Label>
            </asp:Panel>

            <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger" Visible="false">
                <asp:Label ID="lblError" runat="server"></asp:Label>
            </asp:Panel>

            <!-- Profile Card -->
            <div class="profile-card">
                <div class="profile-header">
                    <div class="profile-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                    <div class="profile-name">
                        <asp:Label ID="lblFullName" runat="server"></asp:Label>
                    </div>
                    <div class="profile-role">
                        <asp:Label ID="lblRole" runat="server"></asp:Label>
                    </div>
                </div>

                <div class="info-group">
                    <span class="info-label">ユーザー名</span>
                    <div class="info-value">
                        <asp:Label ID="lblUsername" runat="server"></asp:Label>
                    </div>
                </div>

                <div class="info-group">
                    <span class="info-label">メールアドレス</span>
                    <div class="info-value">
                        <asp:Label ID="lblEmail" runat="server"></asp:Label>
                    </div>
                </div>

                <div class="info-group">
                    <span class="info-label">アカウント作成日</span>
                    <div class="info-value">
                        <asp:Label ID="lblCreatedDate" runat="server"></asp:Label>
                    </div>
                </div>

                <div class="info-group">
                    <span class="info-label">最終ログイン</span>
                    <div class="info-value">
                        <asp:Label ID="lblLastLogin" runat="server"></asp:Label>
                    </div>
                </div>
            </div>

            <!-- Actions Section -->
            <div class="actions-section">
                <div class="section-title">アカウント操作</div>

                <asp:Button ID="btnLogout" runat="server" Text="ログアウト" CssClass="btn btn-logout" OnClick="btnLogout_Click" />

                <div class="delete-warning">
                    <div class="delete-warning-text">
                        <i class="fas fa-exclamation-triangle"></i>
                        <strong>警告：</strong> アカウントの削除は永久的であり、元に戻すことはできません。すべてのデータが削除されます。
                    </div>
                </div>

                <asp:Button ID="btnDeleteAccount" runat="server" Text="アカウント削除" CssClass="btn btn-delete" 
                    OnClick="btnDeleteAccount_Click" OnClientClick="return confirm('アカウントを削除してもよろしいですか？この操作は元に戻せません！');" />
            </div>
        </div>
    </form>
</body>
</html>
