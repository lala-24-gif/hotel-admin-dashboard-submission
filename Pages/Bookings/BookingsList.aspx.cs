using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace HotelManagement
{
	public partial class BookingsList : System.Web.UI.Page
	{
		// データベース接続を設定
		SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString);

		protected void Page_Load(object sender, EventArgs e)
		{
			// 初回表示時のみ予約一覧と統計情報を読み込む
			if (!IsPostBack)
			{
				// 初期状態では確認済みの予約を表示
				ddlStatusFilter.SelectedValue = "Confirmed";

				LoadBookings();
				LoadStatistics();
			}
		}

		// 選択された条件で予約一覧と統計情報を更新
		protected void btnApplyFilter_Click(object sender, EventArgs e)
		{
			LoadBookings();
			LoadStatistics();
		}

		private void LoadBookings()
		{
			try
			{
				con.Open();

				// 選択されているステータスと日付の絞り込み条件を取得
				string statusFilter = ddlStatusFilter.SelectedValue;
				string dateFilter = ddlDateFilter.SelectedValue;

				// ゲスト情報と客室情報を含む予約一覧を取得
				string query = @"
                    SELECT 
                        b.BookingID,
                        g.FirstName + ' ' + g.LastName AS GuestName,
                        r.RoomNumber,
                        b.CheckInDate,
                        b.CheckOutDate,
                        b.NumberOfGuests,
                        b.TotalAmount,
                        b.Status
                    FROM Bookings b
                    INNER JOIN Guests g ON b.GuestID = g.GuestID
                    INNER JOIN Rooms r ON b.RoomID = r.RoomID
                    WHERE 1=1"; // 選択された条件に応じて検索条件を追加する

				// ステータスが「すべて」以外の場合は条件を追加
				if (statusFilter != "All")
				{
					query += " AND b.Status = @Status";
				}

				// 選択された期間に応じてチェックイン日を絞り込む
				switch (dateFilter)
				{
					case "Today":
						query += " AND CAST(b.CheckInDate AS DATE) = CAST(GETDATE() AS DATE)";
						break;
					case "Week":
						// 今週の期間を対象にする
						query += @" AND b.CheckInDate >= DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE))
                                 AND b.CheckInDate < DATEADD(DAY, 8 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE))";
						break;
					case "Month":
						query += " AND MONTH(b.CheckInDate) = MONTH(GETDATE()) AND YEAR(b.CheckInDate) = YEAR(GETDATE())";
						break;
					case "Future":
						query += " AND b.CheckInDate > CAST(GETDATE() AS DATE)";
						break;
				}

				// チェックイン日の新しい予約から順に表示
				query += " ORDER BY b.CheckInDate DESC, b.BookingID DESC";

				SqlCommand cmd = new SqlCommand(query, con);

				// ステータス条件が指定されている場合のみパラメータを追加
				if (statusFilter != "All")
				{
					cmd.Parameters.AddWithValue("@Status", statusFilter);
				}

				SqlDataAdapter da = new SqlDataAdapter(cmd);
				DataTable dt = new DataTable();
				da.Fill(dt);

				// 取得した予約情報を一覧に表示
				gvBookings.DataSource = dt;
				gvBookings.DataBind();

				con.Close();
			}
			catch (Exception ex)
			{
				ShowError("予約の読み込みエラー: " + ex.Message);
			}
			finally
			{
				if (con.State == ConnectionState.Open)
					con.Close();
			}
		}

		// 現在の絞り込み条件に基づいて予約件数を集計
		private void LoadStatistics()
		{
			try
			{
				con.Open();

				string statusFilter = ddlStatusFilter.SelectedValue;
				string dateFilter = ddlDateFilter.SelectedValue;

				// ステータスごとの予約件数を取得
				string query = @"
                    SELECT 
                        COUNT(*) AS TotalBookings,
                        SUM(CASE WHEN Status = 'Confirmed' THEN 1 ELSE 0 END) AS Confirmed,
                        SUM(CASE WHEN Status = 'CheckedIn' THEN 1 ELSE 0 END) AS CheckedIn,
                        SUM(CASE WHEN Status = 'CheckedOut' THEN 1 ELSE 0 END) AS CheckedOut
                       
                    FROM Bookings
                    WHERE 1=1";

				// ステータスが「すべて」以外の場合は条件を追加
				if (statusFilter != "All")
				{
					query += " AND Status = @Status";
				}

				// 選択された期間に応じて集計対象を絞り込む
				switch (dateFilter)
				{
					case "Today":
						query += " AND CAST(CheckInDate AS DATE) = CAST(GETDATE() AS DATE)";
						break;
					case "Week":
						query += " AND CheckInDate >= CAST(GETDATE() AS DATE) AND CheckInDate < DATEADD(DAY, 7, CAST(GETDATE() AS DATE))";
						break;
					case "Month":
						query += " AND MONTH(CheckInDate) = MONTH(GETDATE()) AND YEAR(CheckInDate) = YEAR(GETDATE())";
						break;
					case "Future":
						query += " AND CheckInDate > CAST(GETDATE() AS DATE)";
						break;
				}

				SqlCommand cmd = new SqlCommand(query, con);

				if (statusFilter != "All")
				{
					cmd.Parameters.AddWithValue("@Status", statusFilter);
				}

				// 集計結果を画面上の各項目に表示
				SqlDataReader reader = cmd.ExecuteReader();
				if (reader.Read())
				{
					lblTotalBookings.Text = reader["TotalBookings"].ToString();
					lblConfirmed.Text = reader["Confirmed"].ToString();
					lblCheckedIn.Text = reader["CheckedIn"].ToString();
				}
				reader.Close();
				con.Close();
			}
			catch (Exception ex)
			{
				ShowError("統計の読み込みエラー: " + ex.Message);
			}
			finally
			{
				if (con.State == ConnectionState.Open)
					con.Close();
			}
		}

		// 予約一覧から実行された操作に応じて処理を分ける
		protected void gvBookings_RowCommand(object sender, GridViewCommandEventArgs e)
		{
			int bookingId = Convert.ToInt32(e.CommandArgument);

			if (e.CommandName == "CheckOut")
			{
				CheckOutGuest(bookingId);
			}
			else if (e.CommandName == "CancelBooking")
			{
				CancelBooking(bookingId);
			}
		}

		// ゲストをチェックアウトし、使用していた客室を利用可能な状態に戻す
		private void CheckOutGuest(int bookingId)
		{
			try
			{
				con.Open();

				// 対象予約に割り当てられている客室IDを取得
				SqlCommand getRoomCmd = new SqlCommand("SELECT RoomID FROM Bookings WHERE BookingID = @BookingID", con);
				getRoomCmd.Parameters.AddWithValue("@BookingID", bookingId);
				int roomId = Convert.ToInt32(getRoomCmd.ExecuteScalar());

				// 予約をチェックアウト済みにし、客室を利用可能にする
				SqlCommand cmd = new SqlCommand(@"
                    UPDATE Bookings 
                    SET Status = 'CheckedOut'
                    WHERE BookingID = @BookingID;
                    
                    UPDATE Rooms 
                    SET Status = 'Available' 
                    WHERE RoomID = @RoomID;", con);

				cmd.Parameters.AddWithValue("@BookingID", bookingId);
				cmd.Parameters.AddWithValue("@RoomID", roomId);

				cmd.ExecuteNonQuery();
				con.Close();

				ShowSuccess("ゲストのチェックアウトが完了しました！客室は現在利用可能です。");
				LoadBookings();
				LoadStatistics();
			}
			catch (Exception ex)
			{
				ShowError("チェックアウトエラー: " + ex.Message);
			}
			finally
			{
				if (con.State == ConnectionState.Open)
					con.Close();
			}
		}

		// 予約をキャンセルし、割り当てられていた客室を利用可能な状態に戻す
		private void CancelBooking(int bookingId)
		{
			try
			{
				con.Open();

				// 対象予約に割り当てられている客室IDを取得
				SqlCommand getRoomCmd = new SqlCommand("SELECT RoomID FROM Bookings WHERE BookingID = @BookingID", con);
				getRoomCmd.Parameters.AddWithValue("@BookingID", bookingId);
				int roomId = Convert.ToInt32(getRoomCmd.ExecuteScalar());

				// 予約をキャンセル済みにし、客室を利用可能にする
				SqlCommand cmd = new SqlCommand(@"
                    UPDATE Bookings 
                    SET Status = 'Cancelled'
                    WHERE BookingID = @BookingID;
                    
                    UPDATE Rooms 
                    SET Status = 'Available' 
                    WHERE RoomID = @RoomID;", con);

				cmd.Parameters.AddWithValue("@BookingID", bookingId);
				cmd.Parameters.AddWithValue("@RoomID", roomId);

				cmd.ExecuteNonQuery();
				con.Close();

				ShowSuccess("予約がキャンセルされました！客室は現在利用可能です。");
				LoadBookings();
				LoadStatistics();
			}
			catch (Exception ex)
			{
				ShowError("予約キャンセルエラー: " + ex.Message);
			}
			finally
			{
				if (con.State == ConnectionState.Open)
					con.Close();
			}
		}

		// データベース上の予約ステータスを日本語表示に変換
		protected string GetStatusText(string status)
		{
			switch (status)
			{
				case "Confirmed":
					return "確認済み";
				case "CheckedIn":
					return "チェックイン済み";
				case "CheckedOut":
					return "チェックアウト済み";
				case "Cancelled":
					return "キャンセル済み";
				default:
					return status;
			}
		}

		// エラーメッセージを表示
		private void ShowError(string message)
		{
			pnlError.Visible = true;
			pnlSuccess.Visible = false;
			lblError.Text = message;
		}

		// 成功メッセージを表示
		private void ShowSuccess(string message)
		{
			pnlSuccess.Visible = true;
			pnlError.Visible = false;
			lblSuccess.Text = message;
		}
	}
}

