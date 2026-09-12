using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;

namespace HotelManagement
{
	public partial class SalesReport : System.Web.UI.Page
	{
		private readonly string connectionString =
			ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString;

		/// <summary>
		/// ページ初期表示処理
		/// </summary>
		protected void Page_Load(object sender, EventArgs e)
		{
			int selectedYear = GetSelectedYear();

			lblCurrentYear.Text = selectedYear.ToString();

			if (!IsPostBack)
			{
				LoadSalesReport(selectedYear);
			}
		}


		/* =========================================================
           表示年度
           ========================================================= */

		/// <summary>
		/// クエリ文字列から表示対象年度を取得する
		/// </summary>
		private int GetSelectedYear()
		{
			int year;

			if (int.TryParse(Request.QueryString["year"], out year))
			{
				// 不正な年度指定を防止
				if (year >= 2000 && year <= 2100)
				{
					return year;
				}
			}

			return DateTime.Now.Year;
		}


		/// <summary>
		/// 前年度を表示する
		/// </summary>
		protected void btnPreviousYear_Click(object sender, EventArgs e)
		{
			int year = GetSelectedYear() - 1;

			Response.Redirect(
				"SalesReport.aspx?year=" + year
			);
		}


		/// <summary>
		/// 翌年度を表示する
		/// </summary>
		protected void btnNextYear_Click(object sender, EventArgs e)
		{
			int year = GetSelectedYear() + 1;

			Response.Redirect(
				"SalesReport.aspx?year=" + year
			);
		}


		/* =========================================================
           売上レポート読み込み
           ========================================================= */

		/// <summary>
		/// 指定年度の売上レポートを読み込む
		/// </summary>
		private void LoadSalesReport(int year)
		{
			try
			{
				DateTime startDate = new DateTime(year, 1, 1);
				DateTime endDate = startDate.AddYears(1);

				DateTime previousStartDate = startDate.AddYears(-1);
				DateTime previousEndDate = startDate;

				using (SqlConnection con = new SqlConnection(connectionString))
				{
					con.Open();

					AnnualSummary currentSummary =
						GetAnnualSummary(
							con,
							startDate,
							endDate
						);

					AnnualSummary previousSummary =
						GetAnnualSummary(
							con,
							previousStartDate,
							previousEndDate
						);

					LoadSummaryCards(
						currentSummary,
						previousSummary
					);

					LoadMonthlyData(
						con,
						year,
						startDate,
						endDate
					);
				}
			}
			catch (Exception ex)
			{
				System.Diagnostics.Debug.WriteLine(
					"売上レポートの読み込みエラー: "
					+ ex.Message
				);

				ResetReport();
			}
		}


		/* =========================================================
           年間集計
           ========================================================= */

		/// <summary>
		/// 指定期間の年間集計情報を取得する
		/// </summary>
		private AnnualSummary GetAnnualSummary(
			SqlConnection con,
			DateTime startDate,
			DateTime endDate)
		{
			AnnualSummary summary = new AnnualSummary();

			string sql = @"
                SELECT
                    ISNULL(SUM(TotalAmount), 0) AS TotalRevenue,
                    COUNT(*) AS TotalTransactions,
                    ISNULL(SUM(NumberOfGuests), 0) AS TotalGuests
                FROM dbo.Bookings
                WHERE Status = 'CheckedOut'
                  AND CheckOutDate >= @StartDate
                  AND CheckOutDate < @EndDate;
            ";

			using (SqlCommand cmd = new SqlCommand(sql, con))
			{
				cmd.Parameters.Add(
					"@StartDate",
					SqlDbType.DateTime
				).Value = startDate;

				cmd.Parameters.Add(
					"@EndDate",
					SqlDbType.DateTime
				).Value = endDate;

				using (SqlDataReader reader = cmd.ExecuteReader())
				{
					if (reader.Read())
					{
						summary.TotalRevenue =
							Convert.ToDecimal(
								reader["TotalRevenue"]
							);

						summary.TotalTransactions =
							Convert.ToInt32(
								reader["TotalTransactions"]
							);

						summary.TotalGuests =
							Convert.ToInt32(
								reader["TotalGuests"]
							);
					}
				}
			}

			return summary;
		}


		/// <summary>
		/// 年間集計カードを表示する
		/// </summary>
		private void LoadSummaryCards(
			AnnualSummary current,
			AnnualSummary previous)
		{
			lblTotalRevenue.Text =
				current.TotalRevenue.ToString("N0");

			lblTotalTransactions.Text =
				current.TotalTransactions.ToString("N0");

			lblTotalGuests.Text =
				current.TotalGuests.ToString("N0");


			/* 平均取引額 */
			decimal averageTransaction = 0;

			if (current.TotalTransactions > 0)
			{
				averageTransaction =
					current.TotalRevenue
					/ current.TotalTransactions;
			}

			lblAverageTransaction.Text =
				averageTransaction.ToString("N0");


			/* 予約あたりの平均ゲスト数 */
			decimal averageGuests = 0;

			if (current.TotalTransactions > 0)
			{
				averageGuests =
					(decimal)current.TotalGuests
					/ current.TotalTransactions;
			}

			lblAvgGuests.Text =
				averageGuests.ToString("N1");


			/* 前年比 */
			decimal revenueChange =
				CalculateChangePercentage(
					current.TotalRevenue,
					previous.TotalRevenue
				);

			decimal transactionChange =
				CalculateChangePercentage(
					current.TotalTransactions,
					previous.TotalTransactions
				);

			lblRevenueChange.Text =
				revenueChange.ToString("N1");

			lblTransactionChange.Text =
				transactionChange.ToString("N1");
		}


		/// <summary>
		/// 前年比を計算する
		/// </summary>
		private decimal CalculateChangePercentage(
			decimal currentValue,
			decimal previousValue)
		{
			if (previousValue == 0)
			{
				if (currentValue == 0)
				{
					return 0;
				}

				return 100;
			}

			return
				((currentValue - previousValue)
				/ previousValue)
				* 100;
		}


		/* =========================================================
           月次集計
           ========================================================= */

		/// <summary>
		/// 指定年度の月次データを取得して表示する
		/// </summary>
		private void LoadMonthlyData(
			SqlConnection con,
			int year,
			DateTime startDate,
			DateTime endDate)
		{
			string sql = @"
                SELECT
                    MONTH(CheckOutDate) AS SalesMonth,

                    ISNULL(
                        SUM(TotalAmount),
                        0
                    ) AS Revenue,

                    COUNT(*) AS Transactions,

                    ISNULL(
                        SUM(NumberOfGuests),
                        0
                    ) AS Guests

                FROM dbo.Bookings

                WHERE Status = 'CheckedOut'
                  AND CheckOutDate >= @StartDate
                  AND CheckOutDate < @EndDate

                GROUP BY
                    MONTH(CheckOutDate)

                ORDER BY
                    SalesMonth;
            ";


			Dictionary<int, MonthlySalesData> monthlySales =
				new Dictionary<int, MonthlySalesData>();


			using (SqlCommand cmd = new SqlCommand(sql, con))
			{
				cmd.Parameters.Add(
					"@StartDate",
					SqlDbType.DateTime
				).Value = startDate;

				cmd.Parameters.Add(
					"@EndDate",
					SqlDbType.DateTime
				).Value = endDate;


				using (SqlDataReader reader = cmd.ExecuteReader())
				{
					while (reader.Read())
					{
						int month =
							Convert.ToInt32(
								reader["SalesMonth"]
							);

						MonthlySalesData data =
							new MonthlySalesData();

						data.Month = month;

						data.Revenue =
							Convert.ToDecimal(
								reader["Revenue"]
							);

						data.Transactions =
							Convert.ToInt32(
								reader["Transactions"]
							);

						data.Guests =
							Convert.ToInt32(
								reader["Guests"]
							);

						monthlySales[month] = data;
					}
				}
			}


			BuildMonthlyTable(
				monthlySales
			);

			BuildChartData(
				monthlySales
			);

			SetBestMonth(
				monthlySales
			);
		}


		/* =========================================================
           月次内訳テーブル
           ========================================================= */

		/// <summary>
		/// 1月から12月までの月次内訳を作成する
		/// </summary>
		private void BuildMonthlyTable(
			Dictionary<int, MonthlySalesData> monthlySales)
		{
			DataTable table = new DataTable();

			table.Columns.Add(
				"Month",
				typeof(string)
			);

			table.Columns.Add(
				"Revenue",
				typeof(decimal)
			);

			table.Columns.Add(
				"Transactions",
				typeof(int)
			);

			table.Columns.Add(
				"AverageTransaction",
				typeof(decimal)
			);

			table.Columns.Add(
				"Bookings",
				typeof(int)
			);

			table.Columns.Add(
				"Guests",
				typeof(int)
			);


			for (int month = 1; month <= 12; month++)
			{
				decimal revenue = 0;
				int transactions = 0;
				int guests = 0;


				if (monthlySales.ContainsKey(month))
				{
					revenue =
						monthlySales[month].Revenue;

					transactions =
						monthlySales[month].Transactions;

					guests =
						monthlySales[month].Guests;
				}


				decimal averageTransaction = 0;

				if (transactions > 0)
				{
					averageTransaction =
						revenue / transactions;
				}


				DataRow row = table.NewRow();

				/*
                    Unicodeエスケープを使用し、
                    文字コードによる「1?」表示を防止する
                */
				row["Month"] =
					month.ToString()
					+ "\u6708";

				row["Revenue"] =
					revenue;

				row["Transactions"] =
					transactions;

				row["AverageTransaction"] =
					averageTransaction;

				row["Bookings"] =
					transactions;

				row["Guests"] =
					guests;

				table.Rows.Add(row);
			}


			gvMonthlyBreakdown.DataSource = table;
			gvMonthlyBreakdown.DataBind();
		}


		/* =========================================================
           グラフデータ
           ========================================================= */

		/// <summary>
		/// 収益グラフおよびゲスト数グラフのデータを作成する
		/// </summary>
		private void BuildChartData(
			Dictionary<int, MonthlySalesData> monthlySales)
		{
			List<string> labels =
				new List<string>();

			List<decimal> revenues =
				new List<decimal>();

			List<int> guests =
				new List<int>();


			for (int month = 1; month <= 12; month++)
			{
				labels.Add(
					month.ToString()
					+ "\u6708"
				);


				if (monthlySales.ContainsKey(month))
				{
					revenues.Add(
						monthlySales[month].Revenue
					);

					guests.Add(
						monthlySales[month].Guests
					);
				}
				else
				{
					revenues.Add(0);
					guests.Add(0);
				}
			}


			JavaScriptSerializer serializer =
				new JavaScriptSerializer();


			ChartData revenueChart =
				new ChartData();

			revenueChart.labels = labels;
			revenueChart.data = revenues;


			GuestChartData guestChart =
				new GuestChartData();

			guestChart.labels = labels;
			guestChart.data = guests;


			hfChartData.Value =
				serializer.Serialize(
					revenueChart
				);

			hfGuestData.Value =
				serializer.Serialize(
					guestChart
				);
		}


		/* =========================================================
           最高収益月
           ========================================================= */

		/// <summary>
		/// 年間で最も収益が高い月を表示する
		/// </summary>
		private void SetBestMonth(
			Dictionary<int, MonthlySalesData> monthlySales)
		{
			int bestMonth = 0;
			decimal bestRevenue = 0;


			foreach (
				KeyValuePair<int, MonthlySalesData> item
				in monthlySales)
			{
				if (item.Value.Revenue > bestRevenue)
				{
					bestRevenue =
						item.Value.Revenue;

					bestMonth =
						item.Key;
				}
			}


			if (bestMonth > 0)
			{
				lblBestMonth.Text =
					bestMonth.ToString()
					+ "\u6708";
			}
			else
			{
				lblBestMonth.Text = "-";
			}
		}


		/* =========================================================
           エラー時初期化
           ========================================================= */

		/// <summary>
		/// レポート表示内容を初期化する
		/// </summary>
		private void ResetReport()
		{
			lblTotalRevenue.Text = "0";
			lblTotalTransactions.Text = "0";
			lblAverageTransaction.Text = "0";
			lblBestMonth.Text = "-";
			lblTotalGuests.Text = "0";
			lblAvgGuests.Text = "0";
			lblRevenueChange.Text = "0";
			lblTransactionChange.Text = "0";

			hfChartData.Value =
				"{\"labels\":[],\"data\":[]}";

			hfGuestData.Value =
				"{\"labels\":[],\"data\":[]}";

			gvMonthlyBreakdown.DataSource =
				new DataTable();

			gvMonthlyBreakdown.DataBind();
		}


		/* =========================================================
           内部データクラス
           ========================================================= */

		private class AnnualSummary
		{
			public decimal TotalRevenue { get; set; }

			public int TotalTransactions { get; set; }

			public int TotalGuests { get; set; }
		}


		private class MonthlySalesData
		{
			public int Month { get; set; }

			public decimal Revenue { get; set; }

			public int Transactions { get; set; }

			public int Guests { get; set; }
		}


		private class ChartData
		{
			public List<string> labels { get; set; }

			public List<decimal> data { get; set; }
		}


		private class GuestChartData
		{
			public List<string> labels { get; set; }

			public List<int> data { get; set; }
		}
	}
}