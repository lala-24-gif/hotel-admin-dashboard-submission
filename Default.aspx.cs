using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace HotelManagement
{
    public partial class Default : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AdminID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                if (Session["AdminName"] != null)
                {
                    lblUsername.Text = Session["AdminName"].ToString();
                }

               
                SetCurrentDateTime();

                LoadDashboardData();
                CheckOverdueCheckouts();
            }
        }

    
        private void SetCurrentDateTime()
        {
            DateTime now = DateTime.Now;

        
            lblCurrentDate.Text = now.ToString("yyyy年MM月dd日");

         
            lblCurrentDay.Text = GetJapaneseDayOfWeek(now.DayOfWeek);

        
        }

      
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

        private void LoadDashboardData()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    using (SqlCommand cmd = new SqlCommand("sp_GetDashboardStats", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblBookings.Text = reader["TotalBookings"].ToString();
                            }

                            if (reader.NextResult() && reader.Read())
                            {
                                lblCheckIns.Text = reader["TodayCheckIns"].ToString();
                            }

                            if (reader.NextResult() && reader.Read())
                            {
                                lblAvailableRooms.Text = reader["AvailableRooms"].ToString();
                                lblOccupiedRooms.Text = reader["OccupiedRooms"].ToString();
                                lblReservedRooms.Text = reader["ReservedRooms"].ToString();
                            }

                            if (reader.NextResult() && reader.Read())
                            {
                                decimal revenue = Convert.ToDecimal(reader["MonthlyRevenue"]);
                                lblMonthlyRevenue.Text = revenue.ToString("N0");
                                lblTransactionCount.Text = reader["TotalTransactions"].ToString();
                            }
                        }
                    }

                    LoadCurrentGuests(con);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ダッシュボードの読み込みエラー: " + ex.Message);
            }
        }

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

        private void CheckOverdueCheckouts()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    string query = @"
                        SELECT COUNT(*) 
                        FROM Bookings 
                        WHERE Status = 'CheckedIn' 
                        AND CheckOutDate <= GETDATE()";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        int overdueCount = Convert.ToInt32(cmd.ExecuteScalar());

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

        protected void btnViewSales_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Reports/SalesReport.aspx");
		}

        protected void btnViewRooms_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Rooms/Rooms.aspx");
		}

        protected void btnViewAvailableRooms_Click(object sender, EventArgs e)
        {
			Response.Redirect("~/Pages/Rooms/Rooms.aspx?status=available");
		}

        protected void btnViewOccupiedRooms_Click(object sender, EventArgs e)
        {
			Response.Redirect("~/Pages/Rooms/Rooms.aspx?status=occupied");
		}

        protected void btnViewReservedRooms_Click(object sender, EventArgs e)
        {
			Response.Redirect("~/Pages/Rooms/Rooms.aspx?status=reserved");
		}
    }
}