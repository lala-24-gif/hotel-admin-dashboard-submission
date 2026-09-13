using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace HotelManagement
{
	public partial class OverdueCheckouts : System.Web.UI.Page
	{
		// データベース接続文字列を取得
		private string connectionString = ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString;

		protected void Page_Load(object sender, EventArgs e)
		{
			// 初回表示時に現在時刻とチェックアウト遅延一覧を表示
			if (!IsPostBack)
			{
				lblCurrentTime.Text = DateTime.Now.ToString("yyyy年MM月dd日 HH:mm");
				LoadOverdueCheckouts();
			}
		}

		// チェックアウト予定時刻を過ぎている宿泊中の予約を取得
		private void LoadOverdueCheckouts()
		{
			try
			{
				using (SqlConnection con = new SqlConnection(connectionString))
				{
					con.Open();

					// チェックアウト日時を過ぎてもチェックイン状態の予約を検索
					string query = @"
                        SELECT 
                            b.BookingID,
                            g.FirstName + ' ' + g.LastName AS GuestName,
                            r.RoomNumber,
                            b.CheckInDate,
                            b.CheckOutDate,
                            b.TotalAmount,
                            b.Status
                        FROM Bookings b
                        INNER JOIN Guests g ON b.GuestID = g.GuestID
                        INNER JOIN Rooms r ON b.RoomID = r.RoomID
                        WHERE b.Status = 'CheckedIn' 
                        AND b.CheckOutDate <= GETDATE()
                        ORDER BY b.CheckOutDate ASC";

					using (SqlCommand cmd = new SqlCommand(query, con))
					{
						using (SqlDataAdapter da = new SqlDataAdapter(cmd))
						{
							DataTable dt = new DataTable();
							da.Fill(dt);

							// 取得した遅延チェックアウト情報を一覧に表示
							gvOverdueCheckouts.DataSource = dt;
							gvOverdueCheckouts.DataBind();

							// チェックアウト遅延件数を表示
							lblOverdueCount.Text = dt.Rows.Count.ToString();
						}
					}

					con.Close();
				}
			}
			catch (Exception ex)
			{
				ShowError("チェックアウト遅延の読み込みエラー: " + ex.Message);
			}
		}

		// チェックアウト予定時刻からの経過時間を表示用の文字列に変換
		protected string GetHoursOverdue(object checkOutDate)
		{
			if (checkOutDate == null || checkOutDate == DBNull.Value)
				return "不明";

			DateTime checkout = Convert.ToDateTime(checkOutDate);
			TimeSpan overdue = DateTime.Now - checkout;

			// 1時間未満の場合は分単位で表示
			if (overdue.TotalHours < 1)
			{
				return $"{(int)overdue.TotalMinutes}分";
			}
			// 24時間未満の場合は時間と分で表示
			else if (overdue.TotalHours < 24)
			{
				return $"{(int)overdue.TotalHours}時間{overdue.Minutes}分";
			}
			// 24時間以上の場合は日数で表示
			else
			{
				return $"{(int)overdue.TotalDays}日";
			}
		}

		// 一覧から即時チェックアウトが選択された場合に処理を実行
		protected void gvOverdueCheckouts_RowCommand(object sender, GridViewCommandEventArgs e)
		{
			if (e.CommandName == "CheckOutNow")
			{
				int bookingId = Convert.ToInt32(e.CommandArgument);
				ProcessCheckout(bookingId);
			}
		}

		// 対象の予約をチェックアウトし、客室を利用可能な状態に戻す
		private void ProcessCheckout(int bookingId)
		{
			try
			{
				using (SqlConnection con = new SqlConnection(connectionString))
				{
					con.Open();

					// 対象予約に割り当てられている客室IDを取得
					string getRoomQuery = "SELECT RoomID FROM Bookings WHERE BookingID = @BookingID";
					int roomId = 0;

					using (SqlCommand getRoomCmd = new SqlCommand(getRoomQuery, con))
					{
						getRoomCmd.Parameters.AddWithValue("@BookingID", bookingId);
						object result = getRoomCmd.ExecuteScalar();

						if (result != null)
							roomId = Convert.ToInt32(result);
					}

					// 予約ステータスをチェックアウト済みに変更
					string updateBookingQuery = @"
                        UPDATE Bookings 
                        SET Status = 'CheckedOut' 
                        WHERE BookingID = @BookingID";

					using (SqlCommand cmd = new SqlCommand(updateBookingQuery, con))
					{
						cmd.Parameters.AddWithValue("@BookingID", bookingId);
						cmd.ExecuteNonQuery();
					}

					// 客室IDが取得できた場合は客室を利用可能な状態に戻す
					if (roomId > 0)
					{
						string updateRoomQuery = "UPDATE Rooms SET Status = 'Available' WHERE RoomID = @RoomID";

						using (SqlCommand cmd = new SqlCommand(updateRoomQuery, con))
						{
							cmd.Parameters.AddWithValue("@RoomID", roomId);
							cmd.ExecuteNonQuery();
						}
					}

					con.Close();

					ShowSuccess($"ゲストのチェックアウトが完了しました！部屋は利用可能になりました。");
					LoadOverdueCheckouts();
				}
			}
			catch (Exception ex)
			{
				ShowError("チェックアウト処理エラー: " + ex.Message);
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

