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
				// 本日の日付をデフォルトのチェックイン日に設定
				txtCheckIn.Text = DateTime.Today.ToString("yyyy-MM-dd");
				txtCheckOut.Text = DateTime.Today.AddDays(1).ToString("yyyy-MM-dd");
				LoadRooms(); // 日付設定後に客室を読み込む
			}
		}

		// 日付が変更された場合に、利用可能な客室一覧と合計金額を更新
		protected void txtCheckIn_TextChanged(object sender, EventArgs e)
		{
			LoadRooms();
			CalculateTotal(sender, e); // 日付変更時に合計金額を再計算
		}

		protected void txtCheckOut_TextChanged(object sender, EventArgs e)
		{
			LoadRooms();
			CalculateTotal(sender, e); // 日付変更時に合計金額を再計算
		}

		// 新規ゲストの入力フォームを表示
		protected void btnNewGuest_Click(object sender, EventArgs e)
		{
			// 新規ゲストフォームと予約詳細を表示
			pnlNewGuestForm.CssClass = "form-card";
			pnlExistingGuestForm.CssClass = "form-card hidden";
			pnlBookingDetails.CssClass = "form-card";

			// 新規ゲスト用の入力チェックを適用
			btnCreateBooking.ValidationGroup = "NewGuestGroup";
		}


		protected void btnExistingGuest_Click(object sender, EventArgs e)
		{
			// 既存ゲストフォームと予約詳細を表示
			pnlNewGuestForm.CssClass = "form-card hidden";
			pnlExistingGuestForm.CssClass = "form-card";
			pnlBookingDetails.CssClass = "form-card";

			// 既存ゲスト用の入力チェックを適用
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
				// 日付が入力されていない場合は客室検索を行わない
				if (string.IsNullOrEmpty(txtCheckIn.Text) || string.IsNullOrEmpty(txtCheckOut.Text))
				{
					return;
				}

				con.Open();

				// 選択されたチェックイン日とチェックアウト日を取得
				DateTime checkIn = DateTime.Parse(txtCheckIn.Text);
				DateTime checkOut = DateTime.Parse(txtCheckOut.Text);

				// チェックアウト日がチェックイン日より後であることを確認
				if (checkOut <= checkIn)
				{
					ShowError("チェックアウト日はチェックイン日より後でなければなりません。");
					ddlRoom.Items.Clear();
					ddlRoom.Items.Insert(0, new ListItem("-- 客室を選択 --", "0"));
					lblTotalAmount.Text = "0";
					con.Close();
					return;
				}

				// 選択された宿泊期間に空いている客室を取得
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
                        -- 予約期間が重複している客室を除外
                        SELECT b.RoomID 
                        FROM Bookings b
                        WHERE b.Status IN ('Confirmed', 'CheckedIn')
                        AND (
                            -- 既存予約と選択した宿泊期間が重なっているか確認
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

					// 客室情報を「階数・客室番号・タイプ・料金・定員」の形式で表示
					row["RoomNumber"] = floor + roomNum + " - " + roomType +
									   " (¥" + price.ToString("N0") + "/泊, " +
									   capacity + "名)";
				}

				ddlRoom.DataSource = dt;
				ddlRoom.DataTextField = "RoomNumber";
				ddlRoom.DataValueField = "RoomID";
				ddlRoom.DataBind();

				ddlRoom.Items.Insert(0, new ListItem("-- 客室を選択 --", "0"));

				// 利用可能な客室がない場合にメッセージを表示
				if (dt.Rows.Count == 0)
				{
					ShowError("選択された日付に利用可能な客室がありません。");
				}
				else
				{
					pnlError.Visible = false; // 利用可能な客室がある場合はエラー表示を非表示にする
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
				// 予約処理を行う前に宿泊日が入力されているか確認
				if (string.IsNullOrEmpty(txtCheckIn.Text) || string.IsNullOrEmpty(txtCheckOut.Text))
				{
					ShowError("チェックイン日とチェックアウト日を入力してください。");
					return;
				}

				DateTime checkIn = DateTime.Parse(txtCheckIn.Text);
				DateTime checkOut = DateTime.Parse(txtCheckOut.Text);

				// チェックアウト日がチェックイン日より後であることを確認
				if (checkOut <= checkIn)
				{
					ShowError("チェックアウト日はチェックイン日より後でなければなりません。");
					return;
				}

				// 宿泊日数が1泊以上であることを確認
				int nights = (checkOut - checkIn).Days;
				if (nights <= 0)
				{
					ShowError("無効な宿泊日数です。最低1泊以上必要です。");
					return;
				}

				// 予約する客室が選択されているか確認
				if (ddlRoom.SelectedValue == "0")
				{
					ShowError("客室を選択してください。");
					return;
				}

				// 計算された合計金額が有効か確認
				decimal totalAmount = 0;
				if (!decimal.TryParse(lblTotalAmount.Text.Replace(",", ""), out totalAmount) || totalAmount <= 0)
				{
					ShowError("合計金額が無効です。客室を選択し直してください。");
					return;
				}

				int guestId = 0;

				// 新規ゲストまたは既存ゲストのどちらで予約するか判定
				if (btnCreateBooking.ValidationGroup == "NewGuestGroup")
				{
					// 新規ゲストの入力内容を確認
					if (!Page.IsValid)
						return;

					// ゲスト情報を登録し、作成されたゲストIDを取得
					guestId = CreateNewGuest();
					if (guestId == 0)
					{
						ShowError("ゲストの作成に失敗しました。もう一度お試しください。");
						return;
					}
				}
				else if (btnCreateBooking.ValidationGroup == "ExistingGuestGroup")
				{
					// 既存ゲストが選択されているか確認
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

				// 選択された客室IDを取得
				int roomId = int.Parse(ddlRoom.SelectedValue);

				// チェックアウト時間を12:00（正午）に設定
				checkOut = checkOut.Date.AddHours(12);

				int numberOfGuests = string.IsNullOrEmpty(txtNumberOfGuests.Text) ? 1 : int.Parse(txtNumberOfGuests.Text);
				string specialRequests = txtSpecialRequests.Text.Trim();

				con.Open();

				// 予約情報をBookingsテーブルへ登録
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
			// 新規ゲストの入力内容をクリア
			txtFirstName.Text = "";
			txtLastName.Text = "";
			txtEmail.Text = "";
			txtPhone.Text = "";
			txtAddress.Text = "";
			txtIDNumber.Text = "";
			txtDateOfBirth.Text = "";

			// 既存ゲストの選択を初期状態に戻す
			ddlGuest.SelectedIndex = 0;

			// 予約内容を初期状態に戻す
			ddlRoom.SelectedIndex = 0;
			txtCheckIn.Text = DateTime.Today.ToString("yyyy-MM-dd");
			txtCheckOut.Text = DateTime.Today.AddDays(1).ToString("yyyy-MM-dd");
			txtNumberOfGuests.Text = "1";
			txtSpecialRequests.Text = "";
			lblTotalAmount.Text = "0";

			// 入力フォームをすべて非表示にする
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

