<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Rooms.aspx.cs" Inherits="HotelManagement.Rooms" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>客室管理 - ホテルシステム</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
          rel="stylesheet" />

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
            padding: 20px;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
        }

        /* ヘッダー */
        .header {
            background: white;
            padding: 25px 30px;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h1 {
            color: #667eea;
            font-size: 32px;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .header-icon {
            font-size: 40px;
        }

        .back-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            transition: transform 0.2s;
            text-decoration: none;
            display: inline-block;
        }

        .back-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        /* 客室統計 */
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            text-align: center;
        }

        .stat-card h3 {
            font-size: 14px;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 10px;
        }

        .stat-card .number {
            font-size: 36px;
            font-weight: bold;
            color: #333;
        }

        .stat-card.available .number {
            color: #10b981;
        }

        .stat-card.occupied .number {
            color: #ef4444;
        }

        .stat-card.reserved .number {
            color: #f59e0b;
        }

        /* フロア表示 */
        .floor-section {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            margin-bottom: 25px;
        }

        .floor-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
        }

        .floor-title {
            font-size: 24px;
            font-weight: 600;
            color: #333;
        }

        .floor-stats {
            display: flex;
            gap: 20px;
            font-size: 14px;
        }

        .floor-stat {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .floor-stat .dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
        }

        .dot.available {
            background: #10b981;
        }

        .dot.occupied {
            background: #ef4444;
        }

        .dot.reserved {
            background: #f59e0b;
        }

        /* 客室一覧 */
        .rooms-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 15px;
        }

        .room-card {
            background: white;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            padding: 20px;
            cursor: pointer;
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
        }

        .room-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
        }

        .room-card.available {
            border-color: #10b981;
            background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
        }

        .room-card.occupied {
            border-color: #ef4444;
            background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
        }

        .room-card.reserved {
            border-color: #f59e0b;
            background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
        }

        .room-number {
            font-size: 28px;
            font-weight: bold;
            color: #333;
            margin-bottom: 8px;
        }

        .room-type {
            font-size: 14px;
            color: #666;
            margin-bottom: 5px;
        }

        .room-status {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            margin-top: 8px;
        }

        .room-status.available {
            background: #10b981;
            color: white;
        }

        .room-status.occupied {
            background: #ef4444;
            color: white;
        }

        .room-status.reserved {
            background: #f59e0b;
            color: white;
        }

        .room-price {
            font-size: 16px;
            font-weight: 600;
            color: #667eea;
            margin-top: 8px;
        }

        /* ルーフトップダイニング */
        .rooftop-dining {
            grid-column: span 4;
            min-height: 180px;
            border-radius: 14px;
            padding: 28px 32px;
            background:
                linear-gradient(
                    135deg,
                    #1f2937 0%,
                    #374151 42%,
                    #4f46e5 100%
                );
            color: white;
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 6px 20px rgba(0,0,0,0.16);
        }

        .rooftop-dining::before {
            content: "";
            position: absolute;
            width: 260px;
            height: 260px;
            border-radius: 50%;
            background: rgba(255,255,255,0.07);
            top: -120px;
            right: -60px;
        }

        .rooftop-dining::after {
            content: "";
            position: absolute;
            width: 160px;
            height: 160px;
            border-radius: 50%;
            background: rgba(255,255,255,0.04);
            bottom: -80px;
            right: 160px;
        }

        .dining-info {
            position: relative;
            z-index: 2;
        }

        .rooftop-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            margin-bottom: 12px;
            border-radius: 20px;
            background: rgba(255,255,255,0.18);
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 1px;
        }

        .dining-title {
            font-size: 26px;
            font-weight: 700;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .dining-subtitle {
            font-size: 14px;
            opacity: 0.85;
            margin-bottom: 20px;
        }

        .dining-details {
            display: flex;
            gap: 24px;
            flex-wrap: wrap;
            font-size: 13px;
        }

        .dining-detail {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .dining-icon {
            position: relative;
            z-index: 2;
            font-size: 90px;
            opacity: 0.22;
            padding-right: 20px;
        }

        /* モーダル */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            animation: fadeIn 0.3s;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
            }

            to {
                opacity: 1;
            }
        }

        .modal-content {
            background-color: white;
            margin: 5% auto;
            padding: 0;
            border-radius: 15px;
            width: 90%;
            max-width: 600px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            animation: slideUp 0.3s;
        }

        @keyframes slideUp {
            from {
                transform: translateY(50px);
                opacity: 0;
            }

            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        .modal-header {
            padding: 25px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px 15px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h2 {
            margin: 0;
            font-size: 24px;
        }

        .close {
            color: white;
            font-size: 35px;
            font-weight: bold;
            cursor: pointer;
            line-height: 1;
        }

        .close:hover {
            opacity: 0.8;
        }

        .modal-body {
            padding: 30px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 15px 0;
            border-bottom: 1px solid #e5e7eb;
        }

        .detail-row:last-child {
            border-bottom: none;
        }

        .detail-label {
            font-weight: 600;
            color: #666;
        }

        .detail-value {
            font-weight: 500;
            color: #333;
        }

        .action-buttons {
            display: flex;
            gap: 10px;
            margin-top: 25px;
        }

        .btn {
            flex: 1;
            padding: 12px 20px;
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
            box-shadow: 0 5px 15px rgba(102,126,234,0.4);
        }

        .btn-secondary {
            background: #f3f4f6;
            color: #333;
        }

        .btn-secondary:hover {
            background: #e5e7eb;
        }

        .empty-floor {
            text-align: center;
            padding: 40px;
            color: #999;
            font-style: italic;
        }

        @keyframes pulse {
            0%, 100% {
                transform: scale(1);
                box-shadow: 0 5px 15px rgba(102,126,234,0.3);
            }

            50% {
                transform: scale(1.05);
                box-shadow: 0 10px 30px rgba(102,126,234,0.5);
            }
        }

        /* モバイル表示 */
        @media (max-width: 768px) {
            body {
                padding: 10px;
            }

            .header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }

            .header h1 {
                font-size: 25px;
            }

            .floor-section {
                padding: 20px;
            }

            .floor-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 12px;
            }

            .rooms-grid {
                grid-template-columns: 1fr;
            }

            .rooftop-dining {
                grid-column: 1 / -1;
                width: 100%;
            }

            .dining-icon {
                display: none;
            }

            .dining-details {
                flex-direction: column;
                gap: 10px;
            }
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div class="container">

            <!-- ヘッダー -->
            <div class="header">
                <h1>
                    <span class="header-icon">🏨</span>
                    客室管理
                </h1>

                <asp:LinkButton
                    ID="btnBack"
                    runat="server"
                    CssClass="back-btn"
                    OnClick="btnBack_Click">
                    ← ダッシュボードに戻る
                </asp:LinkButton>
            </div>

            <!-- 客室統計 -->
            <div class="stats-container">

                <div class="stat-card available">
                    <h3>利用可能</h3>
                    <div class="number">
                        <asp:Label
                            ID="lblAvailable"
                            runat="server">
                            0
                        </asp:Label>
                    </div>
                </div>

                <div class="stat-card occupied">
                    <h3>使用中</h3>
                    <div class="number">
                        <asp:Label
                            ID="lblOccupied"
                            runat="server">
                            0
                        </asp:Label>
                    </div>
                </div>

                <div class="stat-card reserved">
                    <h3>予約済み</h3>
                    <div class="number">
                        <asp:Label
                            ID="lblReserved"
                            runat="server">
                            0
                        </asp:Label>
                    </div>
                </div>

            </div>

            <!-- 各フロアの客室一覧 -->
            <asp:Literal
                ID="litFloors"
                runat="server">
            </asp:Literal>

        </div>

        <!-- 客室詳細モーダル -->
        <div id="roomModal" class="modal">
            <div class="modal-content">

                <div class="modal-header">
                    <h2 id="modalTitle">客室詳細</h2>
                    <span class="close" onclick="closeModal()">
                        &times;
                    </span>
                </div>

                <div class="modal-body">

                    <div class="detail-row">
                        <span class="detail-label">客室番号：</span>
                        <span class="detail-value" id="modalRoomNumber"></span>
                    </div>

                    <div class="detail-row">
                        <span class="detail-label">フロア：</span>
                        <span class="detail-value" id="modalFloor"></span>
                    </div>

                    <div class="detail-row">
                        <span class="detail-label">客室タイプ：</span>
                        <span class="detail-value" id="modalRoomType"></span>
                    </div>

                    <div class="detail-row">
                        <span class="detail-label">収容人数：</span>
                        <span class="detail-value" id="modalCapacity"></span>
                    </div>

                    <div class="detail-row">
                        <span class="detail-label">1泊料金：</span>
                        <span class="detail-value" id="modalPrice"></span>
                    </div>

                    <div class="detail-row">
                        <span class="detail-label">ステータス：</span>
                        <span class="detail-value" id="modalStatus"></span>
                    </div>

                    <div class="action-buttons">

                        <button
                            type="button"
                            class="btn btn-primary"
                            id="btnViewBooking"
                            onclick="viewBooking()">
                            全体のゲストデータを表示
                        </button>

                        <button
                            type="button"
                            class="btn btn-secondary"
                            onclick="closeModal()">
                            閉じる
                        </button>

                    </div>
                </div>
            </div>
        </div>

    </form>

    <script type="text/javascript">

		// 客室詳細をモーダルに表示
		function showRoomDetails(
			roomId,
			roomNumber,
			floor,
			roomType,
			capacity,
			price,
			status
		) {
			document.getElementById('modalRoomNumber').innerText = roomNumber;

			document.getElementById('modalFloor').innerText =
				floor ? floor + '階' : 'N/A';

			document.getElementById('modalRoomType').innerText = roomType;

			document.getElementById('modalCapacity').innerText =
				capacity + '名';

			document.getElementById('modalPrice').innerText =
				'¥' + parseFloat(price).toLocaleString();

			// ステータスを日本語表記に変換
			let statusText = status;

			if (status === 'Available') {
				statusText = '利用可能';
			}
			else if (status === 'Occupied') {
				statusText = '使用中';
			}
			else if (status === 'Reserved') {
				statusText = '予約済み';
			}

			document.getElementById('modalStatus').innerText = statusText;

			// 利用可能な客室では予約表示ボタンを非表示
			const viewBookingBtn =
				document.getElementById('btnViewBooking');

			if (status === 'Available') {
				viewBookingBtn.style.display = 'none';
			}
			else {
				viewBookingBtn.style.display = 'block';

				viewBookingBtn.onclick = function () {
					viewBooking(roomId);
				};
			}

			document.getElementById('roomModal').style.display = 'block';
		}

		// モーダルを閉じる
		function closeModal() {
			document.getElementById('roomModal').style.display = 'none';
		}

		// 選択した客室の予約情報ページへ移動
		function viewBooking(roomId) {
			window.location.href =
			'<%= ResolveUrl("~/Pages/Bookings/BookingsList.aspx") %>?roomId=' + roomId;
        }

		// URL指定されたステータスを強調表示
		function highlightStatus(status) {

			const statCards =
				document.querySelectorAll('.stat-card');

			statCards.forEach(card => {

				if (card.classList.contains(status.toLowerCase())) {
					card.style.transform = 'scale(1.05)';

					card.style.boxShadow =
						'0 10px 30px rgba(102,126,234,0.3)';
				}
			});

			// 該当ステータスの最初の客室までスクロール
			const firstRoomCard =
				document.querySelector(
					'.room-card.' + status.toLowerCase()
				);

			if (firstRoomCard) {

				firstRoomCard.scrollIntoView({
					behavior: 'smooth',
					block: 'center'
				});

				firstRoomCard.style.animation =
					'pulse 1s ease-in-out 3';
			}
		}

		// モーダルの外側をクリックした場合は閉じる
		window.onclick = function (event) {

			const modal =
				document.getElementById('roomModal');

			if (event.target === modal) {
				closeModal();
			}
		};

	</script>
</body>
</html>