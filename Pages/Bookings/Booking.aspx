<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Booking.aspx.cs" Inherits="HotelManagement.Booking" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>予約作成</title>
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
            max-width: 1200px;
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

        /* ゲスト選択カード */
        .option-cards {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 40px;
        }

        .option-card {
            background: white;
            border-radius: 12px;
            padding: 40px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            transition: all 0.3s;
            cursor: pointer;
            border: 3px solid transparent;
        }

        .option-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.2);
            border-color: #667eea;
        }

        .option-card.active {
            border-color: #667eea;
            background: #f7fafc;
        }

        .option-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 32px;
            color: white;
        }

        .option-title {
            font-size: 24px;
            font-weight: 700;
            color: #2d3748;
            margin-bottom: 10px;
        }

        .option-desc {
            font-size: 14px;
            color: #718096;
        }

        .form-card {
            background: white;
            border-radius: 12px;
            padding: 40px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            margin-bottom: 30px;
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
            z-index: 1;
        }

        .form-input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .form-input.with-icon {
            padding-left: 45px;
        }

        .form-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .form-select {
            width: 100%;
            padding: 12px 15px;
            padding-left: 45px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: white;
            cursor: pointer;
        }

        .form-select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .form-textarea {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            resize: vertical;
        }

        .form-textarea:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .validator {
            color: #f56565;
            font-size: 12px;
            margin-top: 5px;
            display: block;
        }

        .info-box {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 25px;
            text-align: center;
        }

        .info-box-title {
            font-size: 14px;
            opacity: 0.9;
            margin-bottom: 5px;
        }

        .info-box-value {
            font-size: 32px;
            font-weight: 700;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 30px;
        }

        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(102, 126, 234, 0.3);
        }

        .btn-secondary {
            background: #e2e8f0;
            color: #4a5568;
        }

        .btn-secondary:hover {
            background: #cbd5e0;
        }

        .hidden {
            display: none;
        }

        .alert {
            padding: 15px 20px;
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

        @media (max-width: 768px) {
            .option-cards {
                grid-template-columns: 1fr;
            }

            .form-row {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- ヘッダー -->
        <div class="header">
            <div class="header-content">
                <h1>予約作成</h1>
                <a href="<%= ResolveUrl("~/Default.aspx") %>" class="back-btn">
                    <i class="fas fa-arrow-left"></i> ダッシュボードに戻る
                </a>
            </div>
        </div>

        <!-- メインコンテンツ -->
        <div class="container">

            <div class="page-intro">
                <h2>新規予約作成</h2>
                <p>予約の作成方法を選択してください</p>
            </div>

            <!-- エラーメッセージ -->
            <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger" Visible="false">
                <i class="fas fa-exclamation-circle"></i>
                <asp:Label ID="lblError" runat="server"></asp:Label>
            </asp:Panel>

            <!-- 成功メッセージ -->
            <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert alert-success" Visible="false">
                <i class="fas fa-check-circle"></i>
                <asp:Label ID="lblSuccess" runat="server"></asp:Label>
            </asp:Panel>

            <!-- ゲスト種別選択 -->
            <div class="option-cards">
                <div class="option-card" id="cardNewGuest" onclick="selectNewGuest();">
                    <div class="option-icon">
                        <i class="fas fa-user-plus"></i>
                    </div>

                    <div class="option-title">新規ゲスト</div>
                    <div class="option-desc">初めてのゲストの予約を作成</div>

                    <asp:Button
                        ID="btnNewGuest"
                        runat="server"
                        Text="新規ゲスト"
                        OnClick="btnNewGuest_Click"
                        CausesValidation="false"
                        style="display:none;" />
                </div>

                <div class="option-card" id="cardExistingGuest" onclick="selectExistingGuest();">
                    <div class="option-icon">
                        <i class="fas fa-user-check"></i>
                    </div>

                    <div class="option-title">既存ゲスト</div>
                    <div class="option-desc">既存ゲストの客室を予約</div>

                    <asp:Button
                        ID="btnExistingGuest"
                        runat="server"
                        Text="既存ゲスト"
                        OnClick="btnExistingGuest_Click"
                        CausesValidation="false"
                        style="display:none;" />
                </div>
            </div>

            <!-- 新規ゲスト情報入力フォーム -->
            <asp:Panel ID="pnlNewGuestForm" runat="server" CssClass="form-card hidden">

                <div class="section-title">
                    <i class="fas fa-user"></i> ゲスト情報
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">
                            名 <span class="required">*</span>
                        </label>

                        <div class="input-wrapper">
                            <i class="fas fa-user input-icon"></i>
                            <asp:TextBox
                                ID="txtFirstName"
                                runat="server"
                                CssClass="form-input with-icon"
                                placeholder="名を入力してください">
                            </asp:TextBox>
                        </div>

                        <asp:RequiredFieldValidator
                            ID="rfvFirstName"
                            runat="server"
                            ControlToValidate="txtFirstName"
                            Display="Dynamic"
                            ErrorMessage="名は必須です"
                            CssClass="validator"
                            ValidationGroup="NewGuestGroup">
                        </asp:RequiredFieldValidator>
                    </div>

                    <div class="form-group">
                        <label class="form-label">
                            姓 <span class="required">*</span>
                        </label>

                        <div class="input-wrapper">
                            <i class="fas fa-user input-icon"></i>
                            <asp:TextBox
                                ID="txtLastName"
                                runat="server"
                                CssClass="form-input with-icon"
                                placeholder="姓を入力してください">
                            </asp:TextBox>
                        </div>

                        <asp:RequiredFieldValidator
                            ID="rfvLastName"
                            runat="server"
                            ControlToValidate="txtLastName"
                            Display="Dynamic"
                            ErrorMessage="姓は必須です"
                            CssClass="validator"
                            ValidationGroup="NewGuestGroup">
                        </asp:RequiredFieldValidator>
                    </div>
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
                                CssClass="form-input with-icon"
                                placeholder="guest@example.com">
                            </asp:TextBox>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">
                            電話番号 <span class="required">*</span>
                        </label>

                        <div class="input-wrapper">
                            <i class="fas fa-phone input-icon"></i>
                            <asp:TextBox
                                ID="txtPhone"
                                runat="server"
                                CssClass="form-input with-icon"
                                placeholder="09012345678">
                            </asp:TextBox>
                        </div>

                        <asp:RequiredFieldValidator
                            ID="rfvPhone"
                            runat="server"
                            ControlToValidate="txtPhone"
                            Display="Dynamic"
                            ErrorMessage="電話番号は必須です"
                            CssClass="validator"
                            ValidationGroup="NewGuestGroup">
                        </asp:RequiredFieldValidator>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">ID番号</label>

                        <div class="input-wrapper">
                            <i class="fas fa-id-card input-icon"></i>
                            <asp:TextBox
                                ID="txtIDNumber"
                                runat="server"
                                CssClass="form-input with-icon"
                                placeholder="パスポートまたはID番号">
                            </asp:TextBox>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">生年月日</label>

                        <div class="input-wrapper">
                            <i class="fas fa-calendar input-icon"></i>
                            <asp:TextBox
                                ID="txtDateOfBirth"
                                runat="server"
                                TextMode="Date"
                                CssClass="form-input with-icon">
                            </asp:TextBox>
                        </div>
                    </div>
                </div>

                <div class="form-row full">
                    <div class="form-group">
                        <label class="form-label">住所</label>

                        <asp:TextBox
                            ID="txtAddress"
                            runat="server"
                            TextMode="MultiLine"
                            CssClass="form-textarea"
                            Rows="2"
                            placeholder="住所を入力してください">
                        </asp:TextBox>
                    </div>
                </div>
            </asp:Panel>

            <!-- 既存ゲスト選択フォーム -->
            <asp:Panel ID="pnlExistingGuestForm" runat="server" CssClass="form-card hidden">

                <div class="section-title">
                    <i class="fas fa-user"></i> ゲストを選択
                </div>

                <div class="form-row full">
                    <div class="form-group">
                        <label class="form-label">
                            ゲストを選択 <span class="required">*</span>
                        </label>

                        <div class="input-wrapper">
                            <i class="fas fa-user-friends input-icon"></i>

                            <asp:DropDownList
                                ID="ddlGuest"
                                runat="server"
                                CssClass="form-select">
                            </asp:DropDownList>
                        </div>

                        <asp:RequiredFieldValidator
                            ID="rfvGuest"
                            runat="server"
                            ControlToValidate="ddlGuest"
                            Display="Dynamic"
                            InitialValue="0"
                            ErrorMessage="ゲストを選択してください"
                            CssClass="validator"
                            ValidationGroup="ExistingGuestGroup">
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
            </asp:Panel>

            <!-- 新規・既存ゲスト共通の予約詳細フォーム -->
            <asp:Panel ID="pnlBookingDetails" runat="server" CssClass="form-card hidden">

                <div class="section-title">
                    <i class="fas fa-bed"></i> 客室と日程
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">
                            チェックイン日 <span class="required">*</span>
                        </label>

                        <div class="input-wrapper">
                            <i class="fas fa-calendar-alt input-icon"></i>

                            <asp:TextBox
                                ID="txtCheckIn"
                                runat="server"
                                TextMode="Date"
                                CssClass="form-input with-icon"
                                AutoPostBack="True"
                                OnTextChanged="txtCheckIn_TextChanged">
                            </asp:TextBox>
                        </div>

                        <asp:RequiredFieldValidator
                            ID="rfvCheckIn"
                            runat="server"
                            ControlToValidate="txtCheckIn"
                            Display="Dynamic"
                            ErrorMessage="チェックイン日は必須です"
                            CssClass="validator"
                            ValidationGroup="NewGuestGroup">
                        </asp:RequiredFieldValidator>

                        <asp:RequiredFieldValidator
                            ID="rfvCheckIn2"
                            runat="server"
                            ControlToValidate="txtCheckIn"
                            Display="Dynamic"
                            ErrorMessage="チェックイン日は必須です"
                            CssClass="validator"
                            ValidationGroup="ExistingGuestGroup">
                        </asp:RequiredFieldValidator>
                    </div>

                    <div class="form-group">
                        <label class="form-label">
                            チェックアウト日 <span class="required">*</span>
                        </label>

                        <div class="input-wrapper">
                            <i class="fas fa-calendar-check input-icon"></i>

                            <asp:TextBox
                                ID="txtCheckOut"
                                runat="server"
                                TextMode="Date"
                                CssClass="form-input with-icon"
                                AutoPostBack="True"
                                OnTextChanged="txtCheckOut_TextChanged">
                            </asp:TextBox>
                        </div>

                        <asp:RequiredFieldValidator
                            ID="rfvCheckOut"
                            runat="server"
                            ControlToValidate="txtCheckOut"
                            Display="Dynamic"
                            ErrorMessage="チェックアウト日は必須です"
                            CssClass="validator"
                            ValidationGroup="NewGuestGroup">
                        </asp:RequiredFieldValidator>

                        <asp:RequiredFieldValidator
                            ID="rfvCheckOut2"
                            runat="server"
                            ControlToValidate="txtCheckOut"
                            Display="Dynamic"
                            ErrorMessage="チェックアウト日は必須です"
                            CssClass="validator"
                            ValidationGroup="ExistingGuestGroup">
                        </asp:RequiredFieldValidator>

                        <asp:CompareValidator
                            ID="cvCheckOut"
                            runat="server"
                            ControlToValidate="txtCheckOut"
                            ControlToCompare="txtCheckIn"
                            Operator="GreaterThan"
                            Type="Date"
                            Display="Dynamic"
                            ErrorMessage="チェックアウト日はチェックイン日より後でなければなりません"
                            CssClass="validator"
                            ValidationGroup="NewGuestGroup">
                        </asp:CompareValidator>

                        <asp:CompareValidator
                            ID="cvCheckOut2"
                            runat="server"
                            ControlToValidate="txtCheckOut"
                            ControlToCompare="txtCheckIn"
                            Operator="GreaterThan"
                            Type="Date"
                            Display="Dynamic"
                            ErrorMessage="チェックアウト日はチェックイン日より後でなければなりません"
                            CssClass="validator"
                            ValidationGroup="ExistingGuestGroup">
                        </asp:CompareValidator>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">
                            客室 <span class="required">*</span>
                        </label>

                        <div class="input-wrapper">
                            <i class="fas fa-door-open input-icon"></i>

                            <asp:DropDownList
                                ID="ddlRoom"
                                runat="server"
                                CssClass="form-select"
                                AutoPostBack="True"
                                OnSelectedIndexChanged="ddlRoom_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>

                        <asp:RequiredFieldValidator
                            ID="rfvRoom"
                            runat="server"
                            ControlToValidate="ddlRoom"
                            Display="Dynamic"
                            InitialValue="0"
                            ErrorMessage="客室を選択してください"
                            CssClass="validator"
                            ValidationGroup="NewGuestGroup">
                        </asp:RequiredFieldValidator>

                        <asp:RequiredFieldValidator
                            ID="rfvRoom2"
                            runat="server"
                            ControlToValidate="ddlRoom"
                            Display="Dynamic"
                            InitialValue="0"
                            ErrorMessage="客室を選択してください"
                            CssClass="validator"
                            ValidationGroup="ExistingGuestGroup">
                        </asp:RequiredFieldValidator>
                    </div>

                    <div class="form-group">
                        <label class="form-label">ゲスト数</label>

                        <div class="input-wrapper">
                            <i class="fas fa-users input-icon"></i>

                            <asp:TextBox
                                ID="txtNumberOfGuests"
                                runat="server"
                                TextMode="Number"
                                CssClass="form-input with-icon"
                                Text="1"
                                min="1">
                            </asp:TextBox>
                        </div>
                    </div>
                </div>

                <div class="form-row full">
                    <div class="form-group">
                        <label class="form-label">特別なリクエスト</label>

                        <asp:TextBox
                            ID="txtSpecialRequests"
                            runat="server"
                            TextMode="MultiLine"
                            CssClass="form-textarea"
                            Rows="3"
                            placeholder="特別な要望やメモ">
                        </asp:TextBox>
                    </div>
                </div>

                <!-- 予約金額 -->
                <div class="info-box">
                    <div class="info-box-title">合計金額</div>
                    <div class="info-box-value">
                        ¥<asp:Label ID="lblTotalAmount" runat="server" Text="0"></asp:Label>
                    </div>
                </div>

                <!-- 予約操作ボタン -->
                <div class="form-actions">
                    <asp:Button
                        ID="btnCancel"
                        runat="server"
                        Text="キャンセル"
                        CssClass="btn btn-secondary"
                        OnClick="btnCancel_Click"
                        CausesValidation="false" />

                    <asp:Button
                        ID="btnCreateBooking"
                        runat="server"
                        Text="予約を完了"
                        CssClass="btn btn-primary"
                        OnClick="btnCreateBooking_Click" />
                </div>

            </asp:Panel>
        </div>

        <script type="text/javascript">

			// 選択されたゲスト種別カードをアクティブ表示に切り替える
			function setActiveCard(cardId) {
				document.querySelectorAll('.option-card').forEach(card => {
					card.classList.remove('active');
				});

				document.getElementById(cardId).classList.add('active');
			}

			// 新規ゲスト選択時の処理
			function selectNewGuest() {
				setActiveCard('cardNewGuest');
				document.getElementById('<%= btnNewGuest.ClientID %>').click();
            }

            // 既存ゲスト選択時の処理
            function selectExistingGuest() {
                setActiveCard('cardExistingGuest');
                document.getElementById('<%= btnExistingGuest.ClientID %>').click();
			}

		</script>
    </form>
</body>
</html>