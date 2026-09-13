using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace HotelManagement
{
	public partial class Default : System.Web.UI.Page
	{
		// データベース接続文字列を取得
		private string connectionString = ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString;

		protected void Page_Load(object sender, EventArgs e)
		{
			// 管理者がログインしているか確認
			if (Session["AdminID"] == null)
			{
				Response.Redirect("Login.aspx");
				return;
			}

			// 初回表示時のみダッシュボード情報を読み込む
			if (!IsPostBack)
			{
				// ログイン中の管理者名を表示
				if (Session["AdminName"] != null)
				{
					lblUsername.Text = Session["AdminName"].ToString();
				}

				// 現在の日付と曜日を表示
				SetCurrentDateTime();

				// ダッシュボード情報と遅延チェックアウトを確認
				LoadDashboardData();
				CheckOverdueCheckouts();
			}
		}

		// 現在の日付と曜日を画面に表示
		private void SetCurrentDateTime()
		{
			DateTime now = DateTime.Now;

			// 現在の日付を表示
			lblCurrentDate.Text = now.ToString("yyyy年MM月dd日");

			// 曜日を日本語で表示
			lblCurrentDay.Text = GetJapaneseDayOfWeek(now.DayOfWeek);
		}

		// 曜日を日本語表記に変換
		private string GetJapaneseDayOfWeek(DayOfWeek day)
		{
			switch (day)
			{
				case DayOfWeek.Sunday: return "日曜日";
				case DayOfWeek.Monday: return "月曜日";
				case DayOfWeek.Tuesday: return "火曜日";
				case DayOfWeek.Wednesday: return "水曜日";
				case DayOfWeek.Thursday: return "木曜日";
				case DayOfWeek.Friday: return "金曜日";
				case DayOfWeek.Saturday: return "土曜日";
				default: return "";
			}
		}

		// ダッシュボードに表示する予約・客室・売上情報を取得
		private void LoadDashboardData()
		{
			try
			{
				using (SqlConnection con = new SqlConnection(connectionString))
				{
					con.Open();

					// ダッシュボード用の統計情報をストアドプロシージャから取得
					using (SqlCommand cmd = new SqlCommand("sp_GetDashboardStats", con))
					{
						cmd.CommandType = CommandType.StoredProcedure;

						using (SqlDataReader reader = cmd.ExecuteReader())
						{
							// 予約件数を表示
							if (reader.Read())
							{
								lblBookings.Text = reader["TotalBookings"].ToString();
							}

							// 本日のチェックイン件数を表示
							if (reader.NextResult() && reader.Read())
							{
								lblCheckIns.Text = reader["TodayCheckIns"].ToString();
							}

							// 客室ステータスごとの件数を表示
							if (reader.NextResult() && reader.Read())
							{
								lblAvailableRooms.Text = reader["AvailableRooms"].ToString();
								lblOccupiedRooms.Text = reader["OccupiedRooms"].ToString();
								lblReservedRooms.Text = reader["ReservedRooms"].ToString();
							}

							// 月間売上と取引件数を表示
							if (reader.NextResult() && reader.Read())
							{
								decimal revenue = Convert.ToDecimal(reader["MonthlyRevenue"]);
								lblMonthlyRevenue.Text = revenue.ToString("N0");
								lblTransactionCount.Text = reader["TotalTransactions"].ToString();
							}
						}
					}

					// 現在宿泊中のゲスト一覧を読み込む
					LoadCurrentGuests(con);
				}
			}
			catch (Exception ex)
			{
				System.Diagnostics.Debug.WriteLine("ダッシュボードの読み込みエラー: " + ex.Message);
			}
		}

		// 現在宿泊中のゲスト情報を取得して一覧に表示
		private void LoadCurrentGuests(SqlConnection con)
		{
			try
			{
				using (SqlCommand cmd = new SqlCommand("sp_GetCurrentGuests", con))
				{
					cmd.CommandType = CommandType.StoredProcedure;

					using (SqlDataAdapter da = new SqlDataAdapter(cmd))
					{
						DataTable dt = new DataTable();
						da.Fill(dt);

						gvCurrentGuests.DataSource = dt;
						gvCurrentGuests.DataBind();
					}
				}
			}
			catch (Exception ex)
			{
				System.Diagnostics.Debug.WriteLine("現在のゲストの読み込みエラー: " + ex.Message);
			}
		}

		// チェックアウト予定時刻を過ぎている予約があるか確認
		private void CheckOverdueCheckouts()
		{
			try
			{
				using (SqlConnection con = new SqlConnection(connectionString))
				{
					con.Open();

					// チェックイン中でチェックアウト日時を過ぎている予約件数を取得
					string query = @"
                        SELECT COUNT(*) 
                        FROM Bookings 
                        WHERE Status = 'CheckedIn' 
                        AND CheckOutDate <= GETDATE()";

					using (SqlCommand cmd = new SqlCommand(query, con))
					{
						int overdueCount = Convert.ToInt32(cmd.ExecuteScalar());

						// 遅延している予約がある場合は警告を表示
						if (overdueCount > 0)
						{
							pnlOverdueWarning.Visible = true;
							lblOverdueCount.Text = overdueCount.ToString();
						}
						else
						{
							pnlOverdueWarning.Visible = false;
						}
					}

					con.Close();
				}
			}
			catch (Exception ex)
			{
				System.Diagnostics.Debug.WriteLine("遅延チェックアウトの確認エラー: " + ex.Message);
				pnlOverdueWarning.Visible = false;
			}
		}

		// 売上レポート画面へ移動
		protected void btnViewSales_Click(object sender, EventArgs e)
		{
			Response.Redirect("~/Pages/Reports/SalesReport.aspx");
		}

		// 客室一覧画面へ移動
		protected void btnViewRooms_Click(object sender, EventArgs e)
		{
			Response.Redirect("~/Pages/Rooms/Rooms.aspx");
		}

		// 利用可能な客室を表示
		protected void btnViewAvailableRooms_Click(object sender, EventArgs e)
		{
			Response.Redirect("~/Pages/Rooms/Rooms.aspx?status=available");
		}

		// 使用中の客室を表示
		protected void btnViewOccupiedRooms_Click(object sender, EventArgs e)
		{
			Response.Redirect("~/Pages/Rooms/Rooms.aspx?status=occupied");
		}

		// 予約済みの客室を表示
		protected void btnViewReservedRooms_Click(object sender, EventArgs e)
		{
			Response.Redirect("~/Pages/Rooms/Rooms.aspx?status=reserved");
		}
	}
}

