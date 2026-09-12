using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace HotelManagement
{
   
    public partial class BookingsList : System.Web.UI.Page
    {
      
        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString);

  
        protected void Page_Load(object sender, EventArgs e)
        {
         
            if (!IsPostBack)
            {
               
                ddlStatusFilter.SelectedValue = "Confirmed";

                LoadBookings();
                LoadStatistics();
            }
        }

       
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

                string statusFilter = ddlStatusFilter.SelectedValue; 
                string dateFilter = ddlDateFilter.SelectedValue;

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
                    WHERE 1=1"; // can make changes dynamically

              
                if (statusFilter != "All")
                {
                    query += " AND b.Status = @Status"; 
                }

             
                switch (dateFilter)
                {
                    case "Today":
                        query += " AND CAST(b.CheckInDate AS DATE) = CAST(GETDATE() AS DATE)";
                        break;
                    case "Week":
                        // from this week monday
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

                query += " ORDER BY b.CheckInDate DESC, b.BookingID DESC";

                SqlCommand cmd = new SqlCommand(query, con);

                if (statusFilter != "All")
                {
                    cmd.Parameters.AddWithValue("@Status", statusFilter);
                }

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

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

   
        private void LoadStatistics()
        {
            try
            {
                con.Open();

                string statusFilter = ddlStatusFilter.SelectedValue;
                string dateFilter = ddlDateFilter.SelectedValue;

                string query = @"
                    SELECT 
                        COUNT(*) AS TotalBookings,
                        SUM(CASE WHEN Status = 'Confirmed' THEN 1 ELSE 0 END) AS Confirmed,
                        SUM(CASE WHEN Status = 'CheckedIn' THEN 1 ELSE 0 END) AS CheckedIn,
                        SUM(CASE WHEN Status = 'CheckedOut' THEN 1 ELSE 0 END) AS CheckedOut
                       
                    FROM Bookings
                    WHERE 1=1";

                
                if (statusFilter != "All")
                {
                    query += " AND Status = @Status";
                }

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

    
        private void CheckOutGuest(int bookingId)
        {
            try
            {
                con.Open();

               
                SqlCommand getRoomCmd = new SqlCommand("SELECT RoomID FROM Bookings WHERE BookingID = @BookingID", con);
                getRoomCmd.Parameters.AddWithValue("@BookingID", bookingId);
                int roomId = Convert.ToInt32(getRoomCmd.ExecuteScalar());

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

   
        private void CancelBooking(int bookingId)
        {
            try
            {
                con.Open();

                SqlCommand getRoomCmd = new SqlCommand("SELECT RoomID FROM Bookings WHERE BookingID = @BookingID", con);
                getRoomCmd.Parameters.AddWithValue("@BookingID", bookingId);
                int roomId = Convert.ToInt32(getRoomCmd.ExecuteScalar());

             
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
