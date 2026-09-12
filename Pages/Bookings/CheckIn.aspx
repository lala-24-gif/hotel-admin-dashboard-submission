<%@ Page Language="C#"
    AutoEventWireup="true"
    CodeBehind="CheckIn.aspx.cs"
    Inherits="HotelManagement.CheckIn" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport"
        content="width=device-width, initial-scale=1.0" />

    <title>チェックイン</title>

    <link
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
        rel="stylesheet" />

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
            max-width: 1100px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
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
        }

        .container {
            max-width: 1100px;
            margin: 35px auto;
            padding: 0 20px;
        }

        .page-title {
            font-size: 30px;
            font-weight: 700;
            color: #2d3748;
            margin-bottom: 8px;
        }

        .page-subtitle {
            color: #718096;
            margin-bottom: 30px;
        }

        .alert {
            padding: 14px 18px;
            border-radius: 8px;
            margin-bottom: 20px;
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

        .guest-options {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .option-card {
            background: white;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            padding: 25px;
            text-align: center;
            transition: all 0.2s ease;
        }

        .option-card.selected {
            border-color: #4facfe;
            box-shadow: 0 4px 15px rgba(79,172,254,0.2);
        }

        .option-card h3 {
            margin-bottom: 10px;
            color: #2d3748;
        }

        .option-card p {
            color: #718096;
            margin-bottom: 18px;
        }

        .select-btn {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
        }

        .form-section {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            margin-bottom: 25px;
        }

        .form-section h3 {
            margin-bottom: 20px;
            color: #2d3748;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 18px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 7px;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        .form-group label {
            font-weight: 600;
            color: #4a5568;
        }

        .input-control {
            width: 100%;
            padding: 11px 12px;
            border: 1px solid #cbd5e0;
            border-radius: 8px;
            font-size: 14px;
        }

        .summary-box {
            background: #f7fafc;
            border-radius: 10px;
            padding: 20px;
            margin-top: 20px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }

        .summary-row:last-child {
            margin-bottom: 0;
        }

        .total {
            font-size: 24px;
            font-weight: 700;
            color: #4facfe;
        }

        .actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 25px;
        }

        .btn-primary,
        .btn-secondary {
            border: none;
            padding: 12px 22px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
        }

        .btn-primary {
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
            color: white;
        }

        .btn-secondary {
            background: #e2e8f0;
            color: #4a5568;
        }

        .validation-error {
            color: #e53e3e;
            font-size: 12px;
        }

        @media (max-width: 768px) {
            .guest-options,
            .form-grid {
                grid-template-columns: 1fr;
            }

            .header {
                padding: 15px 20px;
            }

            .header-content {
                gap: 15px;
            }

            .actions {
                flex-direction: column;
            }

            .btn-primary,
            .btn-secondary {
                width: 100%;
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
                    <i class="fas fa-sign-in-alt"></i>
                    チェックイン
                </h1>

                <a
                    href="<%= ResolveUrl("~/Default.aspx") %>"
                    class="back-btn">

                    <i class="fas fa-arrow-left"></i>
                    ダッシュボードに戻る
                </a>

            </div>
        </div>


        <div class="container">

            <div class="page-title">
                ゲストチェックイン
            </div>

            <div class="page-subtitle">
                新規ゲストまたは既存ゲストを選択してチェックインします
            </div>


            <!-- 成功メッセージ -->
            <asp:Panel
                ID="pnlSuccess"
                runat="server"
                CssClass="alert alert-success"
                Visible="false">

                <asp:Label
                    ID="lblSuccess"
                    runat="server">
                </asp:Label>

            </asp:Panel>


            <!-- エラーメッセージ -->
            <asp:Panel
                ID="pnlError"
                runat="server"
                CssClass="alert alert-danger"
                Visible="false">

                <asp:Label
                    ID="lblError"
                    runat="server">
                </asp:Label>

            </asp:Panel>


            <!-- ゲスト選択 -->
            <div class="guest-options">

                <asp:Panel
                    ID="pnlNewGuest"
                    runat="server"
                    CssClass="option-card">

                    <h3>新規ゲスト</h3>

                    <p>
                        新しいゲスト情報を登録してチェックインします
                    </p>

                    <asp:Button
                        ID="btnSelectNew"
                        runat="server"
                        Text="新規ゲストを選択"
                        CssClass="select-btn"
                        OnClick="btnSelectNew_Click"
                        CausesValidation="false" />

                </asp:Panel>


                <asp:Panel
                    ID="pnlExistingGuest"
                    runat="server"
                    CssClass="option-card">

                    <h3>既存ゲスト</h3>

                    <p>
                        登録済みのゲストを選択してチェックインします
                    </p>

                    <asp:Button
                        ID="btnSelectExisting"
                        runat="server"
                        Text="既存ゲストを選択"
                        CssClass="select-btn"
                        OnClick="btnSelectExisting_Click"
                        CausesValidation="false" />

                </asp:Panel>

            </div>


            <!-- 新規ゲスト入力 -->
            <asp:Panel
                ID="pnlNewGuestForm"
                runat="server"
                CssClass="form-section"
                Visible="false">

                <h3>新規ゲスト情報</h3>

                <div class="form-grid">

                    <div class="form-group">
                        <label>姓</label>

                        <asp:TextBox
                            ID="txtLastName"
                            runat="server"
                            CssClass="input-control">
                        </asp:TextBox>
                    </div>


                    <div class="form-group">
                        <label>名</label>

                        <asp:TextBox
                            ID="txtFirstName"
                            runat="server"
                            CssClass="input-control">
                        </asp:TextBox>
                    </div>


                    <div class="form-group">
                        <label>メールアドレス</label>

                        <asp:TextBox
                            ID="txtEmail"
                            runat="server"
                            CssClass="input-control"
                            TextMode="Email">
                        </asp:TextBox>
                    </div>


                    <div class="form-group">
                        <label>電話番号</label>

                        <asp:TextBox
                            ID="txtPhone"
                            runat="server"
                            CssClass="input-control">
                        </asp:TextBox>
                    </div>


                    <div class="form-group">
                        <label>身分証明書番号</label>

                        <asp:TextBox
                            ID="txtIDNumber"
                            runat="server"
                            CssClass="input-control">
                        </asp:TextBox>
                    </div>


                    <div class="form-group">
                        <label>生年月日</label>

                        <asp:TextBox
                            ID="txtDateOfBirth"
                            runat="server"
                            CssClass="input-control"
                            TextMode="Date">
                        </asp:TextBox>
                    </div>

                </div>

            </asp:Panel>


            <!-- 既存ゲスト選択 -->
            <asp:Panel
                ID="pnlExistingGuestForm"
                runat="server"
                CssClass="form-section"
                Visible="false">

                <h3>既存ゲスト</h3>

                <div class="form-group">

                    <label>ゲスト</label>

                    <asp:DropDownList
                        ID="ddlGuest"
                        runat="server"
                        CssClass="input-control">
                    </asp:DropDownList>

                </div>

            </asp:Panel>


            <!-- 客室情報 -->
            <asp:Panel
                ID="pnlRoomSection"
                runat="server"
                CssClass="form-section"
                Visible="false">

                <h3>宿泊情報</h3>

                <div class="form-grid">

                    <div class="form-group full-width">

                        <label>客室</label>

                        <asp:DropDownList
                            ID="ddlRoom"
                            runat="server"
                            CssClass="input-control"
                            AutoPostBack="true"
                            OnSelectedIndexChanged="ddlRoom_SelectedIndexChanged">
                        </asp:DropDownList>

                    </div>


                    <div class="form-group">

                        <label>宿泊日数</label>

                        <asp:TextBox
                            ID="txtNights"
                            runat="server"
                            CssClass="input-control"
                            Text="1"
                            TextMode="Number"
                            AutoPostBack="true"
                            OnTextChanged="CalculateTotal">
                        </asp:TextBox>

                    </div>


                    <div class="form-group">

                        <label>宿泊人数</label>

                        <asp:TextBox
                            ID="txtNumberOfGuests"
                            runat="server"
                            CssClass="input-control"
                            Text="1"
                            TextMode="Number">
                        </asp:TextBox>

                    </div>


                    <div class="form-group full-width">

                        <label>チェックアウト予定</label>

                        <asp:TextBox
                            ID="txtCheckOut"
                            runat="server"
                            CssClass="input-control"
                            ReadOnly="true">
                        </asp:TextBox>

                    </div>

                </div>


                <div class="summary-box">

                    <div class="summary-row">
                        <span>合計金額</span>

                        <span class="total">
                            ¥<asp:Label
                                ID="lblTotalAmount"
                                runat="server"
                                Text="0">
                            </asp:Label>
                        </span>
                    </div>

                </div>


                <div class="actions">

                    <asp:Button
                        ID="btnCancel"
                        runat="server"
                        Text="キャンセル"
                        CssClass="btn-secondary"
                        CausesValidation="false"
                        OnClick="btnCancel_Click" />

                    <asp:Button
                        ID="btnCheckIn"
                        runat="server"
                        Text="チェックイン"
                        CssClass="btn-primary"
                        OnClick="btnCheckIn_Click" />

                </div>

            </asp:Panel>

        </div>

    </form>
</body>
</html>