using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace HotelManagement
{
    public partial class OverdueCheckouts : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblCurrentTime.Text = DateTime.Now.ToString("yyyy年MM月dd日 HH:mm");
                LoadOverdueCheckouts();
            }
        }

        private void LoadOverdueCheckouts()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

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

                            gvOverdueCheckouts.DataSource = dt;
                            gvOverdueCheckouts.DataBind();

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

        protected string GetHoursOverdue(object checkOutDate)
        {
            if (checkOutDate == null || checkOutDate == DBNull.Value)
                return "不明";

            DateTime checkout = Convert.ToDateTime(checkOutDate);
            TimeSpan overdue = DateTime.Now - checkout;

            if (overdue.TotalHours < 1)
            {
                return $"{(int)overdue.TotalMinutes}分";
            }
            else if (overdue.TotalHours < 24)
            {
                return $"{(int)overdue.TotalHours}時間{overdue.Minutes}分";
            }
            else
            {
                return $"{(int)overdue.TotalDays}日";
            }
        }

        protected void gvOverdueCheckouts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "CheckOutNow")
            {
                int bookingId = Convert.ToInt32(e.CommandArgument);
                ProcessCheckout(bookingId);
            }
        }

        private void ProcessCheckout(int bookingId)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    string getRoomQuery = "SELECT RoomID FROM Bookings WHERE BookingID = @BookingID";
                    int roomId = 0;

                    using (SqlCommand getRoomCmd = new SqlCommand(getRoomQuery, con))
                    {
                        getRoomCmd.Parameters.AddWithValue("@BookingID", bookingId);
                        object result = getRoomCmd.ExecuteScalar();
                        if (result != null)
                            roomId = Convert.ToInt32(result);
                    }

                    string updateBookingQuery = @"
                        UPDATE Bookings 
                        SET Status = 'CheckedOut' 
                        WHERE BookingID = @BookingID";

                    using (SqlCommand cmd = new SqlCommand(updateBookingQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@BookingID", bookingId);
                        cmd.ExecuteNonQuery();
                    }

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

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
            lblError.Text = message;
        }

        private void ShowSuccess(string message)
        {
            pnlSuccess.Visible = true;
            pnlError.Visible = false;
            lblSuccess.Text = message;
        }
    }
}
