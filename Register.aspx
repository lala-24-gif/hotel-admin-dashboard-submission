<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="HotelManagement.Register" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Hotel Management - Register</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .register-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
            width: 100%;
            max-width: 500px;
        }

        .register-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }

        .register-header i {
            font-size: 50px;
            margin-bottom: 15px;
        }

        .register-header h1 {
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .register-header p {
            font-size: 14px;
            opacity: 0.9;
        }

        .register-body {
            padding: 40px 30px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: #4a5568;
            margin-bottom: 8px;
        }

        .input-wrapper {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #a0aec0;
            font-size: 16px;
        }

        .form-input {
            width: 100%;
            padding: 12px 15px 12px 45px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .form-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .btn-register {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            margin-top: 10px;
        }

        .btn-register:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }

        .btn-register:active {
            transform: translateY(0);
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

        .alert-danger {
            background: #fed7d7;
            color: #742a2a;
            border-left: 4px solid #f56565;
        }

        .alert-success {
            background: #c6f6d5;
            color: #22543d;
            border-left: 4px solid #48bb78;
        }

        .login-link {
            text-align: center;
            margin-top: 25px;
            font-size: 14px;
            color: #718096;
        }

        .login-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }

        .login-link a:hover {
            text-decoration: underline;
        }

        .validator {
            color: #f56565;
            font-size: 12px;
            margin-top: 5px;
            display: block;
        }

        @media (max-width: 480px) {
            .register-container {
                max-width: 100%;
            }

            .register-header {
                padding: 30px 20px;
            }

            .register-body {
                padding: 30px 20px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="register-container">
            <div class="register-header">
                <i class="fas fa-user-plus"></i>
                <h1>アカウント作成</h1>
                <p>ホテル管理のために登録してください</p>
            </div>

            <div class="register-body">
                <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger" Visible="false">
                    <i class="fas fa-exclamation-circle"></i>
                    <asp:Label ID="lblError" runat="server"></asp:Label>
                </asp:Panel>

                <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert alert-success" Visible="false">
                    <i class="fas fa-check-circle"></i>
                    <asp:Label ID="lblSuccess" runat="server"></asp:Label>
                </asp:Panel>

                <div class="form-group">
                    <label class="form-label">氏名</label>
                    <div class="input-wrapper">
                        <i class="fas fa-user input-icon"></i>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-input" 
                            placeholder="氏名を入力してください" required></asp:TextBox>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" 
                        ControlToValidate="txtFullName" Display="Dynamic" 
                        ErrorMessage="氏名は必須です" CssClass="validator" 
                        ValidationGroup="RegisterGroup"></asp:RequiredFieldValidator>
                </div>

                <div class="form-group">
                    <label class="form-label">ユーザー名</label>
                    <div class="input-wrapper">
                        <i class="fas fa-at input-icon"></i>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-input" 
                            placeholder="ユーザー名を選択してください" required></asp:TextBox>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvUsername" runat="server" 
                        ControlToValidate="txtUsername" Display="Dynamic" 
                        ErrorMessage="ユーザー名は必須です" CssClass="validator" 
                        ValidationGroup="RegisterGroup"></asp:RequiredFieldValidator>
                </div>

                <div class="form-group">
                    <label class="form-label">メールアドレス</label>
                    <div class="input-wrapper">
                        <i class="fas fa-envelope input-icon"></i>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-input" 
                            TextMode="Email" placeholder="メールアドレスを入力してください" required></asp:TextBox>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" 
                        ControlToValidate="txtEmail" Display="Dynamic" 
                        ErrorMessage="メールアドレスは必須です" CssClass="validator" 
                        ValidationGroup="RegisterGroup"></asp:RequiredFieldValidator>
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" 
                        ControlToValidate="txtEmail" Display="Dynamic" 
                        ErrorMessage="無効なメールアドレス形式です" CssClass="validator"
                        ValidationExpression="^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"
                        ValidationGroup="RegisterGroup"></asp:RegularExpressionValidator>
                </div>

                <div class="form-group">
                    <label class="form-label">パスワード</label>
                    <div class="input-wrapper">
                        <i class="fas fa-lock input-icon"></i>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" 
                            CssClass="form-input" placeholder="パスワードを作成してください" required></asp:TextBox>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" 
                        ControlToValidate="txtPassword" Display="Dynamic" 
                        ErrorMessage="パスワードは必須です" CssClass="validator" 
                        ValidationGroup="RegisterGroup"></asp:RequiredFieldValidator>
                </div>

                <div class="form-group">
                    <label class="form-label">パスワード確認</label>
                    <div class="input-wrapper">
                        <i class="fas fa-lock input-icon"></i>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" 
                            CssClass="form-input" placeholder="パスワードを再入力してください" required></asp:TextBox>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" 
                        ControlToValidate="txtConfirmPassword" Display="Dynamic" 
                        ErrorMessage="パスワードを確認してください" CssClass="validator" 
                        ValidationGroup="RegisterGroup"></asp:RequiredFieldValidator>
                    <asp:CompareValidator ID="cvPassword" runat="server" 
                        ControlToValidate="txtConfirmPassword" ControlToCompare="txtPassword"
                        Display="Dynamic" ErrorMessage="パスワードが一致しません" CssClass="validator"
                        ValidationGroup="RegisterGroup"></asp:CompareValidator>
                </div>

                <asp:Button ID="btnRegister" runat="server" Text="アカウント作成" 
                    CssClass="btn-register" OnClick="btnRegister_Click" ValidationGroup="RegisterGroup" />

                <div class="login-link">
                    すでにアカウントをお持ちですか？ <a href="Login.aspx">サインイン</a>
                </div>
            </div>
        </div>
    </form>
</body>
</html>