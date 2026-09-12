<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddGuest.aspx.cs" Inherits="HotelManagement.AddGuest" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>新規ゲスト登録</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', 'Yu Gothic', 'Meiryo', sans-serif;
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
            max-width: 900px;
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

        .form-card {
            background: white;
            border-radius: 12px;
            padding: 40px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
            margin-bottom: 25px;
        }

        .form-row.full {
            grid-template-columns: 1fr;
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

        .required {
            color: #f56565;
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
            font-family: 'Segoe UI', 'Yu Gothic', 'Meiryo', sans-serif;
        }

        .form-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .form-input.no-icon {
            padding-left: 15px;
        }

        textarea.form-input {
            min-height: 100px;
            resize: vertical;
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

        .validator {
            color: #f56565;
            font-size: 12px;
            margin-top: 5px;
            display: block;
        }

        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            padding-top: 30px;
            border-top: 1px solid #e2e8f0;
        }

        .btn {
            flex: 1;
            padding: 14px;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }

        .btn-secondary {
            background: #e2e8f0;
            color: #4a5568;
        }

        .btn-secondary:hover {
            background: #cbd5e0;
        }

        .section-title {
            font-size: 18px;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e2e8f0;
        }

        .section-title i {
            color: #667eea;
        }

        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }

            .form-card {
                padding: 30px 20px;
            }

            .form-actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- ヘッダー -->
        <div class="header">
            <div class="header-content">
                <h1><i class="fas fa-user-plus"></i> 新規ゲスト登録</h1>
                <a href="<%= ResolveUrl("~/Default.aspx") %>" class="back-btn">
                    <i class="fas fa-arrow-left"></i>
                    <span>ダッシュボードに戻る</span>
                </a>
            </div>
        </div>

        <!-- メインコンテンツ -->
        <div class="container">
            <div class="page-intro">
                <h2>新規ゲスト登録</h2>
                <p>ゲスト情報を入力して、新しいお客様プロフィールを作成します</p>
            </div>

            <!-- 成功・エラーメッセージ -->
            <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert alert-success" Visible="false">
                <i class="fas fa-check-circle"></i>
                <asp:Label ID="lblSuccess" runat="server"></asp:Label>
            </asp:Panel>

            <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger" Visible="false">
                <i class="fas fa-exclamation-circle"></i>
                <asp:Label ID="lblError" runat="server"></asp:Label>
            </asp:Panel>

            <!-- ゲスト登録フォーム -->
            <div class="form-card">

                <!-- 個人情報入力欄 -->
                <div class="section-title">
                    <i class="fas fa-user"></i> 個人情報
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">
                            名前 <span class="required">*</span>
                        </label>

                        <div class="input-wrapper">
                            <i class="fas fa-user input-icon"></i>
                            <asp:TextBox
                                ID="txtFirstName"
                                runat="server"
                                CssClass="form-input"
                                placeholder="名前を入力"
                                MaxLength="50">
                            </asp:TextBox>
                        </div>

                        <asp:RequiredFieldValidator
                            ID="rfvFirstName"
                            runat="server"
                            ControlToValidate="txtFirstName"
                            Display="Dynamic"
                            ErrorMessage="名前は必須です"
                            CssClass="validator"
                            ValidationGroup="GuestGroup">
                        </asp:RequiredFieldValidator>
                    </div>

                    <div class="form-group">
                        <label class="form-label">
                            苗字 <span class="required">*</span>
                        </label>

                        <div class="input-wrapper">
                            <i class="fas fa-user input-icon"></i>
                            <asp:TextBox
                                ID="txtLastName"
                                runat="server"
                                CssClass="form-input"
                                placeholder="苗字を入力"
                                MaxLength="50">
                            </asp:TextBox>
                        </div>

                        <asp:RequiredFieldValidator
                            ID="rfvLastName"
                            runat="server"
                            ControlToValidate="txtLastName"
                            Display="Dynamic"
                            ErrorMessage="苗字は必須です"
                            CssClass="validator"
                            ValidationGroup="GuestGroup">
                        </asp:RequiredFieldValidator>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">生年月日</label>

                        <div class="input-wrapper">
                            <i class="fas fa-calendar input-icon"></i>
                            <asp:TextBox
                                ID="txtDateOfBirth"
                                runat="server"
                                TextMode="Date"
                                CssClass="form-input">
                            </asp:TextBox>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">ID番号</label>

                        <div class="input-wrapper">
                            <i class="fas fa-id-card input-icon"></i>
                            <asp:TextBox
                                ID="txtIDNumber"
                                runat="server"
                                CssClass="form-input"
                                placeholder="パスポートまたはID番号"
                                MaxLength="50">
                            </asp:TextBox>
                        </div>
                    </div>
                </div>

                <!-- 連絡先情報入力欄 -->
                <div class="section-title" style="margin-top: 30px;">
                    <i class="fas fa-address-book"></i> 連絡先情報
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">メールアドレス</label>

                        <div class="input-wrapper">
                            <i class="fas fa-envelope input-icon"></i>
                            <asp:TextBox
                                ID="txtEmail"
                                runat="server"
                                TextMode="Email"
                                CssClass="form-input"
                                placeholder="guest@example.com"
                                MaxLength="100">
                            </asp:TextBox>
                        </div>

                        <asp:RegularExpressionValidator
                            ID="revEmail"
                            runat="server"
                            ControlToValidate="txtEmail"
                            Display="Dynamic"
                            ErrorMessage="無効なメール形式です"
                            CssClass="validator"
                            ValidationExpression="^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"
                            ValidationGroup="GuestGroup">
                        </asp:RegularExpressionValidator>
                    </div>

                    <div class="form-group">
                        <label class="form-label">電話番号</label>

                        <div class="input-wrapper">
                            <i class="fas fa-phone input-icon"></i>
                            <asp:TextBox
                                ID="txtPhone"
                                runat="server"
                                CssClass="form-input"
                                placeholder="+81-90-1234-5678"
                                MaxLength="20">
                            </asp:TextBox>
                        </div>
                    </div>
                </div>

                <div class="form-row full">
                    <div class="form-group">
                        <label class="form-label">住所</label>

                        <textarea
                            ID="txtAddress"
                            runat="server"
                            class="form-input no-icon"
                            placeholder="住所を入力"
                            maxlength="255">
                        </textarea>
                    </div>
                </div>

                <!-- フォーム操作ボタン -->
                <div class="form-actions">
                    <asp:Button
                        ID="btnCancel"
                        runat="server"
                        Text="キャンセル"
                        CssClass="btn btn-secondary"
                        OnClick="btnCancel_Click"
                        CausesValidation="false" />

                    <asp:Button
                        ID="btnSave"
                        runat="server"
                        Text="ゲストを登録"
                        CssClass="btn btn-primary"
                        OnClick="btnSave_Click"
                        ValidationGroup="GuestGroup" />
                </div>

            </div>
        </div>
    </form>
</body>
</html>