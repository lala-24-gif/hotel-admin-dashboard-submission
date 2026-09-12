<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="HotelManagement.Login" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Hotel Management - Login</title>
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

        .login-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
            width: 100%;
            max-width: 450px;
        }

        .login-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }

        .login-header i {
            font-size: 60px;
            margin-bottom: 15px;
        }

        .login-header h1 {
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .login-header p {
            font-size: 14px;
            opacity: 0.9;
        }

        .login-body {
            padding: 40px 30px;
        }

        .form-group {
            margin-bottom: 25px;
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

        .btn-login {
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

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }

        .btn-login:active {
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

        .register-link {
            text-align: center;
            margin-top: 25px;
            font-size: 14px;
            color: #718096;
        }

        .register-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }

        .register-link a:hover {
            text-decoration: underline;
        }

        .remember-me {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 15px;
        }

        .remember-me input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
        }

        .remember-me label {
            font-size: 14px;
            color: #4a5568;
            cursor: pointer;
        }

        @media (max-width: 480px) {
            .login-container {
                max-width: 100%;
            }

            .login-header {
                padding: 30px 20px;
            }

            .login-body {
                padding: 30px 20px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <div class="login-container">

            <!-- ログイン画面ヘッダー -->
            <div class="login-header">

                <i class="fas fa-hotel"></i>

                <h1>ホテル管理</h1>

                <p>
                    ダッシュボードにアクセスするには
                    サインインしてください
                </p>

            </div>


            <!-- ログインフォーム -->
            <div class="login-body">

                <!-- エラーメッセージ -->
                <asp:Panel
                    ID="pnlError"
                    runat="server"
                    CssClass="alert alert-danger"
                    Visible="false">

                    <i class="fas fa-exclamation-circle"></i>

                    <asp:Label
                        ID="lblError"
                        runat="server">
                    </asp:Label>

                </asp:Panel>


                <!-- 成功メッセージ -->
                <asp:Panel
                    ID="pnlSuccess"
                    runat="server"
                    CssClass="alert alert-success"
                    Visible="false">

                    <i class="fas fa-check-circle"></i>

                    <asp:Label
                        ID="lblSuccess"
                        runat="server">
                    </asp:Label>

                </asp:Panel>


                <!-- ユーザー名 -->
                <div class="form-group">

                    <label class="form-label">
                        ユーザー名
                    </label>

                    <div class="input-wrapper">

                        <i class="fas fa-user input-icon"></i>

                        <asp:TextBox
                            ID="txtUsername"
                            runat="server"
                            CssClass="form-input"
                            placeholder="ユーザー名を入力してください"
                            required>
                        </asp:TextBox>

                    </div>

                    <asp:RequiredFieldValidator
                        ID="rfvUsername"
                        runat="server"
                        ControlToValidate="txtUsername"
                        Display="Dynamic"
                        ErrorMessage="ユーザー名は必須です"
                        ForeColor="#f56565"
                        Font-Size="12px"
                        ValidationGroup="LoginGroup">
                    </asp:RequiredFieldValidator>

                </div>


                <!-- パスワード -->
                <div class="form-group">

                    <label class="form-label">
                        パスワード
                    </label>

                    <div class="input-wrapper">

                        <i class="fas fa-lock input-icon"></i>

                        <asp:TextBox
                            ID="txtPassword"
                            runat="server"
                            TextMode="Password"
                            CssClass="form-input"
                            placeholder="パスワードを入力してください"
                            required>
                        </asp:TextBox>

                    </div>

                    <asp:RequiredFieldValidator
                        ID="rfvPassword"
                        runat="server"
                        ControlToValidate="txtPassword"
                        Display="Dynamic"
                        ErrorMessage="パスワードは必須です"
                        ForeColor="#f56565"
                        Font-Size="12px"
                        ValidationGroup="LoginGroup">
                    </asp:RequiredFieldValidator>

                </div>


                <!-- ログイン状態保持 -->
                <div class="remember-me">

                    <asp:CheckBox
                        ID="chkRememberMe"
                        runat="server" />

                    <label for="<%= chkRememberMe.ClientID %>">
                        ログイン状態を保持する
                    </label>

                </div>


                <!-- ログインボタン -->
                <asp:Button
                    ID="btnLogin"
                    runat="server"
                    Text="サインイン"
                    CssClass="btn-login"
                    OnClick="btnLogin_Click"
                    ValidationGroup="LoginGroup" />

            </div>

        </div>

    </form>
</body>
</html>