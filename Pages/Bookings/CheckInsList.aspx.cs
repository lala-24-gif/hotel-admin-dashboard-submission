using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace HotelManagement
{
	public partial class CheckInsList : System.Web.UI.Page
	{
		// データベース接続を設定
		SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString);

		protected void Page_Load(object sender, EventArgs e)
		{
			// 初回表示時のみチェックイン一覧と統計情報を読み込む
			if (!IsPostBack)
			{
				LoadCheckIns();
				LoadStatistics();
			}
		}


		private void LoadCheckIns()
		{
			try
			{
				con.Open();

				// 本日チェックイン予定の予約情報と特別リクエストを取得
				SqlCommand cmd = new SqlCommand(@"
                    SELECT 
                        b.BookingID,
                        b.GuestID,
                        g.FirstName + ' ' + g.LastName AS GuestName,
                        g.Phone,
                        r.RoomNumber,
                        rt.TypeName AS RoomType,
                        '12:00' AS ExpectedTime,
                        b.CheckOutDate,
                        b.NumberOfGuests,
                        b.TotalAmount,
                        b.Status,
                        ISNULL(b.SpecialRequest, N'なし') AS SpecialRequest
                    FROM Bookings b
                    INNER JOIN Guests g ON b.GuestID = g.GuestID
                    INNER JOIN Rooms r ON b.RoomID = r.RoomID
                    INNER JOIN RoomTypes rt ON r.RoomTypeID = rt.RoomTypeID
                    WHERE CAST(b.CheckInDate AS DATE) = CAST(GETDATE() AS DATE)
                        AND b.Status NOT IN ('CheckedOut', 'Cancelled')
                    ORDER BY b.CheckInDate, r.RoomNumber", con);

				SqlDataAdapter da = new SqlDataAdapter(cmd);
				DataTable dt = new DataTable();
				da.Fill(dt);

				// 取得したチェックイン情報を一覧に表示
				gvCheckIns.DataSource = dt;
				gvCheckIns.DataBind();

				con.Close();
			}
			catch (Exception ex)
			{
				ShowError("チェックインの読み込みエラー: " + ex.Message);
			}
			finally
			{
				if (con.State == ConnectionState.Open)
					con.Close();
			}
		}


		// 本日のチェックイン予定数と進捗状況を集計
		private void LoadStatistics()
		{
			try
			{
				con.Open();

				SqlCommand cmd = new SqlCommand(@"
                    SELECT 
                        COUNT(*) AS TotalExpected,
                        SUM(CASE WHEN Status = 'CheckedIn' THEN 1 ELSE 0 END) AS CheckedIn,
                        SUM(CASE WHEN Status NOT IN ('CheckedIn', 'CheckedOut', 'Cancelled') THEN 1 ELSE 0 END) AS Pending
                    FROM Bookings
                    WHERE CAST(CheckInDate AS DATE) = CAST(GETDATE() AS DATE)
                        AND Status NOT IN ('CheckedOut', 'Cancelled')", con);

				SqlDataReader reader = cmd.ExecuteReader();

				// 集計結果を画面上の各項目に表示
				if (reader.Read())
				{
					lblTotalExpected.Text = reader["TotalExpected"].ToString();
					lblAlreadyCheckedIn.Text = reader["CheckedIn"].ToString();
					lblPending.Text = reader["Pending"].ToString();
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


		// 一覧から選択された操作に応じて処理を実行
		protected void gvCheckIns_RowCommand(object sender, GridViewCommandEventArgs e)
		{
			int bookingId = Convert.ToInt32(e.CommandArgument);

			if (e.CommandName == "CheckInGuest")
			{
				CheckInGuest(bookingId);
			}
			else if (e.CommandName == "CheckOutGuest")
			{
				CheckOutGuest(bookingId);
			}
			else if (e.CommandName == "CancelBooking")
			{
				CancelBooking(bookingId);
			}
		}


		// ゲストをチェックインし、客室を使用中の状態に変更
		private void CheckInGuest(int bookingId)
		{
			try
			{
				con.Open();

				// 対象予約に割り当てられている客室IDを取得
				SqlCommand getRoomCmd = new SqlCommand("SELECT RoomID FROM Bookings WHERE BookingID = @BookingID", con);
				getRoomCmd.Parameters.AddWithValue("@BookingID", bookingId);
				int roomId = Convert.ToInt32(getRoomCmd.ExecuteScalar());

				// 予約をチェックイン済みにし、客室を使用中にする
				SqlCommand cmd = new SqlCommand(@"
                    UPDATE Bookings 
                    SET Status = 'CheckedIn'
                    WHERE BookingID = @BookingID;
                    
                    UPDATE Rooms 
                    SET Status = 'Occupied' 
                    WHERE RoomID = @RoomID;", con);

				cmd.Parameters.AddWithValue("@BookingID", bookingId);
				cmd.Parameters.AddWithValue("@RoomID", roomId);

				cmd.ExecuteNonQuery();
				con.Close();

				ShowSuccess("ゲストのチェックインが完了しました！客室は現在使用中です。");
				LoadCheckIns();
				LoadStatistics();
			}
			catch (Exception ex)
			{
				ShowError("チェックインエラー: " + ex.Message);
			}
			finally
			{
				if (con.State == ConnectionState.Open)
					con.Close();
			}
		}

		// ゲストをチェックアウトし、客室を利用可能な状態に戻す
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

				ShowSuccess("ゲストのチェックアウトが完了しました！");
				LoadCheckIns();
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

		// 予約をキャンセルし、客室を利用可能な状態に戻す
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

				ShowSuccess("予約がキャンセルされました！");
				LoadCheckIns();
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
				case "Pending":
					return "保留中";
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

