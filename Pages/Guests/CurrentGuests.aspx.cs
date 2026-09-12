using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace HotelManagement
{
    public partial class CurrentGuests : System.Web.UI.Page
    {
        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCurrentGuests();
                LoadStatistics();
            }
        }

        private void LoadCurrentGuests()
        {
            try
            {
                con.Open();

                // Get all current guests (checked in and staying today)
                SqlCommand cmd = new SqlCommand(@"
                    SELECT 
                        b.BookingID,
                        b.GuestID,
                        g.FirstName + ' ' + g.LastName AS GuestName,
                        r.RoomNumber,
                        rt.TypeName AS RoomType,
                        b.CheckInDate,
                        b.CheckOutDate,
                        b.NumberOfGuests,
                        b.TotalAmount,
                        b.AmountPaid,
                        b.Status,
                        b.SpecialRequests
                    FROM Bookings b
                    INNER JOIN Guests g ON b.GuestID = g.GuestID
                    INNER JOIN Rooms r ON b.RoomID = r.RoomID
                    INNER JOIN RoomTypes rt ON r.RoomTypeID = rt.RoomTypeID
                    WHERE CAST(b.CheckInDate AS DATE) <= CAST(GETDATE() AS DATE)
                        AND CAST(b.CheckOutDate AS DATE) >= CAST(GETDATE() AS DATE)
                        AND b.Status IN ('Confirmed', 'CheckedIn')
                    ORDER BY r.RoomNumber", con);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvCurrentGuests.DataSource = dt;
                gvCurrentGuests.DataBind();

                con.Close();
            }
            catch (Exception ex)
            {
                ShowError("Error loading current guests: " + ex.Message);
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

                // Get current guests statistics
                SqlCommand cmd = new SqlCommand(@"
                    SELECT 
                        COUNT(DISTINCT b.BookingID) AS TotalGuests,
                        COUNT(DISTINCT r.RoomID) AS OccupiedRooms,
                        SUM(CASE WHEN CAST(b.CheckOutDate AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS ExpectedCheckouts
                    FROM Bookings b
                    INNER JOIN Rooms r ON b.RoomID = r.RoomID
                    WHERE b.CheckInDate <= CAST(GETDATE() AS DATE)
                        AND b.CheckOutDate >= CAST(GETDATE() AS DATE)
                        AND b.Status IN ('Confirmed', 'CheckedIn')", con);

                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    lblTotalGuests.Text = reader["TotalGuests"].ToString();
                    lblOccupiedRooms.Text = reader["OccupiedRooms"].ToString();
                    lblExpectedCheckouts.Text = reader["ExpectedCheckouts"].ToString();
                }
                reader.Close();

                // Get TODAY'S revenue from checkouts that happened today
                SqlCommand revenueCmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(TotalAmount), 0) AS TodayRevenue
                    FROM Bookings
                    WHERE Status = 'CheckedOut'
                        AND CAST(CheckOutDate AS DATE) = CAST(GETDATE() AS DATE)", con);

                decimal todayRevenue = Convert.ToDecimal(revenueCmd.ExecuteScalar());
                lblTodayRevenue.Text = todayRevenue.ToString("N0");

                con.Close();
            }
            catch (Exception ex)
            {
                ShowError("Error loading statistics: " + ex.Message);
            }
            finally
            {
                if (con.State == ConnectionState.Open)
                    con.Close();
            }
        }

        //gridview for current guest 
        protected void gvCurrentGuests_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "CheckOut")
            {
                int bookingId = Convert.ToInt32(e.CommandArgument);
                CheckOutGuest(bookingId);
            }
        }


        private void CheckOutGuest(int bookingId)
        {
            try
            {
                con.Open();

                // Get room ID first
                SqlCommand getRoomCmd = new SqlCommand("SELECT RoomID FROM Bookings WHERE BookingID = @BookingID", con);
                getRoomCmd.Parameters.AddWithValue("@BookingID", bookingId);
                int roomId = Convert.ToInt32(getRoomCmd.ExecuteScalar());

                // Update booking status to CheckedOut
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

                ShowSuccess("Guest checked out successfully! Room is now available.");
                LoadCurrentGuests();
                LoadStatistics();
            }
            catch (Exception ex)
            {
                ShowError("Error checking out guest: " + ex.Message);
            }
            finally
            {
                if (con.State == ConnectionState.Open)
                    con.Close();
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