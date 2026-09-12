using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace HotelManagement
{
    public partial class Booking : System.Web.UI.Page
    {
        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadGuests();
                // Set today's date as default check-in
                txtCheckIn.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtCheckOut.Text = DateTime.Today.AddDays(1).ToString("yyyy-MM-dd");
                LoadRooms(); // Load rooms AFTER setting dates
            }
        }

        // Event handlers for date changes - reload rooms when dates change
        protected void txtCheckIn_TextChanged(object sender, EventArgs e)
        {
            LoadRooms();
            CalculateTotal(sender, e); // Recalculate total when dates change
        }

        protected void txtCheckOut_TextChanged(object sender, EventArgs e)
        {
            LoadRooms();
            CalculateTotal(sender, e); // Recalculate total when dates change
        }

        // FIXED: Changed method name to match ASPX button event
        protected void btnNewGuest_Click(object sender, EventArgs e)
        {
            // Show new guest form and booking details
            pnlNewGuestForm.CssClass = "form-card";
            pnlExistingGuestForm.CssClass = "form-card hidden";
            pnlBookingDetails.CssClass = "form-card";

            // Set the validation group for the create booking button
            btnCreateBooking.ValidationGroup = "NewGuestGroup";
        }


        protected void btnExistingGuest_Click(object sender, EventArgs e)
        {
            // Show existing guest form and booking details
            pnlNewGuestForm.CssClass = "form-card hidden";
            pnlExistingGuestForm.CssClass = "form-card";
            pnlBookingDetails.CssClass = "form-card";

            // Set the validation group for the create booking button
            btnCreateBooking.ValidationGroup = "ExistingGuestGroup";
        }

        private void LoadGuests()
        {
            try
            {
                con.Open();
                SqlCommand cmd = new SqlCommand(@"
                    SELECT GuestID, FirstName + ' ' + LastName AS FullName 
                    FROM Guests 
                    WHERE IsActive = 1 OR IsActive IS NULL
                    ORDER BY FirstName, LastName", con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlGuest.DataSource = dt;
                ddlGuest.DataTextField = "FullName";
                ddlGuest.DataValueField = "GuestID";
                ddlGuest.DataBind();

                ddlGuest.Items.Insert(0, new ListItem("-- ゲストを選択 --", "0"));
            }
            catch (Exception ex)
            {
                ShowError("ゲストの読み込みエラー: " + ex.Message);
            }
            finally
            {
                con.Close();
            }
        }

        private void LoadRooms()
        {
            try
            {
                // Validate dates exist before querying
                if (string.IsNullOrEmpty(txtCheckIn.Text) || string.IsNullOrEmpty(txtCheckOut.Text))
                {
                    return;
                }

                con.Open();

                // Get the selected check-in and check-out dates
                DateTime checkIn = DateTime.Parse(txtCheckIn.Text);
                DateTime checkOut = DateTime.Parse(txtCheckOut.Text);

                // Validate checkout is after checkin
                if (checkOut <= checkIn)
                {
                    ShowError("チェックアウト日はチェックイン日より後でなければなりません。");
                    ddlRoom.Items.Clear();
                    ddlRoom.Items.Insert(0, new ListItem("-- 客室を選択 --", "0"));
                    lblTotalAmount.Text = "0";
                    con.Close();
                    return;
                }

                // Load rooms that are NOT booked during the selected date range
                SqlCommand cmd = new SqlCommand(@"
                    SELECT 
                        r.RoomID, 
                        r.RoomNumber, 
                        r.Floor,
                        rt.TypeName, 
                        rt.BasePrice, 
                        rt.Capacity,
                        r.Status
                    FROM Rooms r
                    INNER JOIN RoomTypes rt ON r.RoomTypeID = rt.RoomTypeID
                    WHERE r.RoomID NOT IN (
                        -- Exclude rooms with overlapping bookings
                        SELECT b.RoomID 
                        FROM Bookings b
                        WHERE b.Status IN ('Confirmed', 'CheckedIn')
                        AND (
                            -- Check for date overlap: booking overlaps if it starts before our checkout AND ends after our checkin
                            b.CheckInDate < @CheckOutDate AND b.CheckOutDate > @CheckInDate
                        )
                    )
                    ORDER BY r.Floor, r.RoomNumber", con);

                cmd.Parameters.AddWithValue("@CheckInDate", checkIn);
                cmd.Parameters.AddWithValue("@CheckOutDate", checkOut);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                foreach (DataRow row in dt.Rows)
                {
                    string roomNum = row["RoomNumber"].ToString();
                    string floor = row["Floor"] == DBNull.Value ? "" : "F" + row["Floor"].ToString() + " - ";
                    string roomType = row["TypeName"].ToString();
                    decimal price = Convert.ToDecimal(row["BasePrice"]);
                    int capacity = Convert.ToInt32(row["Capacity"]);

                    // Format: F2 - 201 - Double (¥8,000/泊, 2名)
                    row["RoomNumber"] = floor + roomNum + " - " + roomType +
                                       " (¥" + price.ToString("N0") + "/泊, " +
                                       capacity + "名)";
                }

                ddlRoom.DataSource = dt;
                ddlRoom.DataTextField = "RoomNumber";
                ddlRoom.DataValueField = "RoomID";
                ddlRoom.DataBind();

                ddlRoom.Items.Insert(0, new ListItem("-- 客室を選択 --", "0"));

                // Show message if no rooms available
                if (dt.Rows.Count == 0)
                {
                    ShowError("選択された日付に利用可能な客室がありません。");
                }
                else
                {
                    pnlError.Visible = false; // Clear error if rooms are available
                }
            }
            catch (Exception ex)
            {
                ShowError("客室の読み込みエラー: " + ex.Message);
            }
            finally
            {
                if (con.State == ConnectionState.Open)
                    con.Close();
            }
        }

        protected void ddlRoom_SelectedIndexChanged(object sender, EventArgs e)
        {
            CalculateTotal(sender, e);
        }

        protected void CalculateTotal(object sender, EventArgs e)
        {
            try
            {
                if (ddlRoom.SelectedValue == "0" || string.IsNullOrEmpty(txtCheckIn.Text) || string.IsNullOrEmpty(txtCheckOut.Text))
                {
                    lblTotalAmount.Text = "0";
                    return;
                }

                DateTime checkIn = DateTime.Parse(txtCheckIn.Text);
                DateTime checkOut = DateTime.Parse(txtCheckOut.Text);

                if (checkOut <= checkIn)
                {
                    ShowError("チェックアウト日はチェックイン日より後でなければなりません。");
                    lblTotalAmount.Text = "0";
                    return;
                }

                int nights = (checkOut - checkIn).Days;

                con.Open();

                SqlCommand cmd = new SqlCommand(@"
                    SELECT rt.BasePrice 
                    FROM Rooms r 
                    INNER JOIN RoomTypes rt ON r.RoomTypeID = rt.RoomTypeID 
                    WHERE r.RoomID = @RoomID", con);
                cmd.Parameters.AddWithValue("@RoomID", ddlRoom.SelectedValue);

                object result = cmd.ExecuteScalar();
                decimal pricePerNight = 0;

                if (result != null)
                    pricePerNight = Convert.ToDecimal(result);

                con.Close();

                decimal total = pricePerNight * nights;
                lblTotalAmount.Text = total.ToString("N0");
                pnlError.Visible = false;
            }
            catch (Exception ex)
            {
                ShowError("合計金額の計算エラー: " + ex.Message);
            }
            finally
            {
                if (con.State == ConnectionState.Open)
                    con.Close();
            }
        }

        protected void btnCreateBooking_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate dates BEFORE processing
                if (string.IsNullOrEmpty(txtCheckIn.Text) || string.IsNullOrEmpty(txtCheckOut.Text))
                {
                    ShowError("チェックイン日とチェックアウト日を入力してください。");
                    return;
                }

                DateTime checkIn = DateTime.Parse(txtCheckIn.Text);
                DateTime checkOut = DateTime.Parse(txtCheckOut.Text);

                //Validate checkout date is after check-in date
                if (checkOut <= checkIn)
                {
                    ShowError("チェックアウト日はチェックイン日より後でなければなりません。");
                    return;
                }

                //  Validate at least 1 night
                int nights = (checkOut - checkIn).Days;
                if (nights <= 0)
                {
                    ShowError("無効な宿泊日数です。最低1泊以上必要です。");
                    return;
                }

                // CRITICAL FIX: Validate room is selected
                if (ddlRoom.SelectedValue == "0")
                {
                    ShowError("客室を選択してください。");
                    return;
                }

                //  Validate total amount is greater than 0
                decimal totalAmount = 0;
                if (!decimal.TryParse(lblTotalAmount.Text.Replace(",", ""), out totalAmount) || totalAmount <= 0)
                {
                    ShowError("合計金額が無効です。客室を選択し直してください。");
                    return;
                }

                int guestId = 0;

                // Determine if this is a new guest or existing guest
                if (btnCreateBooking.ValidationGroup == "NewGuestGroup")
                {
                    // Validate new guest fields
                    if (!Page.IsValid)
                        return;

                    // Create new guest first
                    guestId = CreateNewGuest();
                    if (guestId == 0)
                    {
                        ShowError("ゲストの作成に失敗しました。もう一度お試しください。");
                        return;
                    }
                }
                else if (btnCreateBooking.ValidationGroup == "ExistingGuestGroup")
                {
                    // Validate existing guest selection
                    if (!Page.IsValid)
                        return;

                    guestId = int.Parse(ddlGuest.SelectedValue);

                    if (guestId == 0)
                    {
                        ShowError("ゲストを選択してください。");
                        return;
                    }
                }
                else
                {
                    ShowError("新規ゲストまたは既存ゲストを選択してください。");
                    return;
                }

                // Now create the booking
                int roomId = int.Parse(ddlRoom.SelectedValue);

                // Set checkout time to 12:00 PM (noon)
                checkOut = checkOut.Date.AddHours(12);

                int numberOfGuests = string.IsNullOrEmpty(txtNumberOfGuests.Text) ? 1 : int.Parse(txtNumberOfGuests.Text);
                string specialRequests = txtSpecialRequests.Text.Trim();

                con.Open();

                // FIXED: Changed SpecialRequests to SpecialRequest (singular) to match database column
                SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO Bookings (GuestID, RoomID, CheckInDate, CheckOutDate, BookingDate, Status, TotalAmount, AmountPaid, NumberOfGuests, SpecialRequest)
                    VALUES (@GuestID, @RoomID, @CheckInDate, @CheckOutDate, GETDATE(), 'Confirmed', @TotalAmount, 0, @NumberOfGuests, @SpecialRequest);", con);

                cmd.Parameters.AddWithValue("@GuestID", guestId);
                cmd.Parameters.AddWithValue("@RoomID", roomId);
                cmd.Parameters.AddWithValue("@CheckInDate", checkIn);
                cmd.Parameters.AddWithValue("@CheckOutDate", checkOut);
                cmd.Parameters.AddWithValue("@TotalAmount", totalAmount);
                cmd.Parameters.AddWithValue("@NumberOfGuests", numberOfGuests);
                cmd.Parameters.AddWithValue("@SpecialRequest", string.IsNullOrEmpty(specialRequests) ? (object)DBNull.Value : specialRequests);

                cmd.ExecuteNonQuery();
                con.Close();

                ShowSuccess("予約が正常に完了しました！宿泊日数: " + nights + "泊、チェックアウト時間: " + checkOut.ToString("yyyy-MM-dd HH:mm") + "、合計金額: ¥" + totalAmount.ToString("N0"));
                ClearForm();
                LoadRooms();
                LoadGuests();
            }
            catch (Exception ex)
            {
                ShowError("予約作成エラー: " + ex.Message);
            }
            finally
            {
                if (con.State == ConnectionState.Open)
                    con.Close();
            }
        }

        private int CreateNewGuest()
        {
            try
            {
                con.Open();

                SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO Guests (FirstName, LastName, Email, Phone, Address, IDNumber, DateOfBirth, CreatedDate)
                    VALUES (@FirstName, @LastName, @Email, @Phone, @Address, @IDNumber, @DateOfBirth, GETDATE());
                    SELECT CAST(SCOPE_IDENTITY() AS INT);", con);

                cmd.Parameters.AddWithValue("@FirstName", txtFirstName.Text.Trim());
                cmd.Parameters.AddWithValue("@LastName", txtLastName.Text.Trim());
                cmd.Parameters.AddWithValue("@Email", string.IsNullOrEmpty(txtEmail.Text) ? (object)DBNull.Value : txtEmail.Text.Trim());
                cmd.Parameters.AddWithValue("@Phone", string.IsNullOrEmpty(txtPhone.Text) ? (object)DBNull.Value : txtPhone.Text.Trim());
                cmd.Parameters.AddWithValue("@Address", string.IsNullOrEmpty(txtAddress.Text) ? (object)DBNull.Value : txtAddress.Text.Trim());
                cmd.Parameters.AddWithValue("@IDNumber", string.IsNullOrEmpty(txtIDNumber.Text) ? (object)DBNull.Value : txtIDNumber.Text.Trim());

                if (string.IsNullOrEmpty(txtDateOfBirth.Text))
                    cmd.Parameters.AddWithValue("@DateOfBirth", DBNull.Value);
                else
                    cmd.Parameters.AddWithValue("@DateOfBirth", DateTime.Parse(txtDateOfBirth.Text));

                int newGuestId = (int)cmd.ExecuteScalar();
                con.Close();

                return newGuestId;
            }
            catch (Exception ex)
            {
                ShowError("ゲスト作成エラー: " + ex.Message);
                return 0;
            }
            finally
            {
                if (con.State == ConnectionState.Open)
                    con.Close();
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
			Response.Redirect("~/Default.aspx");
		}

        private void ClearForm()
        {
            // Clear new guest form
            txtFirstName.Text = "";
            txtLastName.Text = "";
            txtEmail.Text = "";
            txtPhone.Text = "";
            txtAddress.Text = "";
            txtIDNumber.Text = "";
            txtDateOfBirth.Text = "";

            // Clear existing guest selection
            ddlGuest.SelectedIndex = 0;

            // Clear booking details
            ddlRoom.SelectedIndex = 0;
            txtCheckIn.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtCheckOut.Text = DateTime.Today.AddDays(1).ToString("yyyy-MM-dd");
            txtNumberOfGuests.Text = "1";
            txtSpecialRequests.Text = "";
            lblTotalAmount.Text = "0";

            // Hide all forms
            pnlNewGuestForm.CssClass = "form-card hidden";
            pnlExistingGuestForm.CssClass = "form-card hidden";
            pnlBookingDetails.CssClass = "form-card hidden";
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