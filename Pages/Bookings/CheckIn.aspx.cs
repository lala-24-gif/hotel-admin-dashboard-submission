using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace HotelManagement
{
	public partial class CheckIn : System.Web.UI.Page
	{
		private readonly string connectionString =
			ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString;


		/// <summary>
		/// ページ初期表示処理
		/// </summary>
		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				LoadAvailableRooms();
				LoadGuests();
			}
		}


		/* =========================================================
           ゲスト選択
           ========================================================= */

		/// <summary>
		/// 新規ゲスト入力フォームを表示する
		/// </summary>
		protected void btnSelectNew_Click(object sender, EventArgs e)
		{
			pnlNewGuest.CssClass = "option-card selected";
			pnlExistingGuest.CssClass = "option-card";

			pnlNewGuestForm.Visible = true;
			pnlExistingGuestForm.Visible = false;
			pnlRoomSection.Visible = true;
		}


		/// <summary>
		/// 既存ゲスト選択フォームを表示する
		/// </summary>
		protected void btnSelectExisting_Click(object sender, EventArgs e)
		{
			pnlExistingGuest.CssClass = "option-card selected";
			pnlNewGuest.CssClass = "option-card";

			pnlExistingGuestForm.Visible = true;
			pnlNewGuestForm.Visible = false;
			pnlRoomSection.Visible = true;
		}


		/* =========================================================
           ゲスト一覧
           ========================================================= */

		/// <summary>
		/// 有効なゲストをドロップダウンリストへ読み込む
		/// </summary>
		private void LoadGuests()
		{
			try
			{
				const string query = @"
                    SELECT
                        GuestID,
                        FirstName + ' ' + LastName AS GuestName
                    FROM dbo.Guests
                    WHERE IsActive = 1
                       OR IsActive IS NULL
                    ORDER BY FirstName, LastName;
                ";

				using (SqlConnection con = new SqlConnection(connectionString))
				using (SqlCommand cmd = new SqlCommand(query, con))
				{
					con.Open();

					using (SqlDataReader reader = cmd.ExecuteReader())
					{
						ddlGuest.Items.Clear();

						ddlGuest.Items.Add(
							new ListItem(
								"-- ゲストを選択 --",
								"0"
							)
						);

						while (reader.Read())
						{
							ddlGuest.Items.Add(
								new ListItem(
									reader["GuestName"].ToString(),
									reader["GuestID"].ToString()
								)
							);
						}
					}
				}
			}
			catch (Exception ex)
			{
				ShowError(
					"ゲスト一覧の読み込み中にエラーが発生しました: "
					+ ex.Message
				);
			}
		}


		/* =========================================================
           客室一覧
           ========================================================= */

		/// <summary>
		/// 利用可能な客室をドロップダウンリストへ読み込む
		/// </summary>
		private void LoadAvailableRooms()
		{
			try
			{
				const string query = @"
                    SELECT
                        r.RoomID,
                        r.RoomNumber,
                        r.Floor,
                        rt.TypeName,
                        rt.BasePrice,
                        rt.Capacity
                    FROM dbo.Rooms r
                    INNER JOIN dbo.RoomTypes rt
                        ON r.RoomTypeID = rt.RoomTypeID
                    WHERE r.Status = 'Available'
                    ORDER BY r.Floor, r.RoomNumber;
                ";

				using (SqlConnection con = new SqlConnection(connectionString))
				using (SqlCommand cmd = new SqlCommand(query, con))
				{
					con.Open();

					using (SqlDataReader reader = cmd.ExecuteReader())
					{
						ddlRoom.Items.Clear();

						ddlRoom.Items.Add(
							new ListItem(
								"-- 客室を選択 --",
								"0"
							)
						);

						while (reader.Read())
						{
							string floorText =
								reader["Floor"] == DBNull.Value
									? string.Empty
									: reader["Floor"] + "階 - ";

							string roomNumber =
								reader["RoomNumber"].ToString();

							string roomType =
								reader["TypeName"].ToString();

							decimal price =
								Convert.ToDecimal(
									reader["BasePrice"]
								);

							int capacity =
								Convert.ToInt32(
									reader["Capacity"]
								);

							string roomText =
								string.Format(
									"{0}{1} - {2} (¥{3:N0}/泊・定員{4}名)",
									floorText,
									roomNumber,
									roomType,
									price,
									capacity
								);

							ddlRoom.Items.Add(
								new ListItem(
									roomText,
									reader["RoomID"].ToString()
								)
							);
						}
					}
				}
			}
			catch (Exception ex)
			{
				ShowError(
					"客室一覧の読み込み中にエラーが発生しました: "
					+ ex.Message
				);
			}
		}


		/* =========================================================
           宿泊料金計算
           ========================================================= */

		/// <summary>
		/// 客室変更時に合計金額を再計算する
		/// </summary>
		protected void ddlRoom_SelectedIndexChanged(
			object sender,
			EventArgs e)
		{
			CalculateTotal(sender, e);
		}


		/// <summary>
		/// 宿泊料金とチェックアウト日時を計算する
		/// </summary>
		protected void CalculateTotal(
			object sender,
			EventArgs e)
		{
			try
			{
				if (ddlRoom.SelectedValue == "0")
				{
					lblTotalAmount.Text = "0";
					return;
				}

				int nights;

				if (!int.TryParse(txtNights.Text, out nights)
					|| nights <= 0)
				{
					lblTotalAmount.Text = "0";
					return;
				}

				int roomId =
					Convert.ToInt32(
						ddlRoom.SelectedValue
					);

				decimal roomPrice =
					GetRoomPrice(roomId);

				decimal totalAmount =
					roomPrice * nights;

				lblTotalAmount.Text =
					totalAmount.ToString("N0");

				DateTime checkOut =
					DateTime.Today
						.AddDays(nights)
						.AddHours(12);

				txtCheckOut.Text =
					checkOut.ToString(
						"yyyy-MM-dd HH:mm"
					);
			}
			catch (Exception ex)
			{
				ShowError(
					"料金計算中にエラーが発生しました: "
					+ ex.Message
				);
			}
		}


		/// <summary>
		/// 指定客室の1泊料金を取得する
		/// </summary>
		private decimal GetRoomPrice(int roomId)
		{
			try
			{
				const string query = @"
                    SELECT
                        rt.BasePrice
                    FROM dbo.Rooms r
                    INNER JOIN dbo.RoomTypes rt
                        ON r.RoomTypeID = rt.RoomTypeID
                    WHERE r.RoomID = @RoomID;
                ";

				using (SqlConnection con = new SqlConnection(connectionString))
				using (SqlCommand cmd = new SqlCommand(query, con))
				{
					cmd.Parameters.Add(
						"@RoomID",
						SqlDbType.Int
					).Value = roomId;

					con.Open();

					object result =
						cmd.ExecuteScalar();

					if (result == null
						|| result == DBNull.Value)
					{
						return 0;
					}

					return Convert.ToDecimal(result);
				}
			}
			catch (Exception ex)
			{
				System.Diagnostics.Debug.WriteLine(
					"客室料金取得エラー: "
					+ ex.Message
				);

				return 0;
			}
		}


		/* =========================================================
           チェックイン処理
           ========================================================= */

		/// <summary>
		/// ゲストをチェックインする
		/// </summary>
		protected void btnCheckIn_Click(
			object sender,
			EventArgs e)
		{
			if (!Page.IsValid)
			{
				return;
			}

			try
			{
				int guestId;

				/* 新規ゲストまたは既存ゲストを取得 */
				if (pnlNewGuestForm.Visible)
				{
					guestId = CreateNewGuest();

					if (guestId == 0)
					{
						ShowError(
							"ゲスト情報を登録できませんでした。"
						);

						return;
					}
				}
				else
				{
					if (ddlGuest.SelectedValue == "0")
					{
						ShowError(
							"ゲストを選択してください。"
						);

						return;
					}

					guestId =
						Convert.ToInt32(
							ddlGuest.SelectedValue
						);
				}


				/* 客室確認 */
				if (ddlRoom.SelectedValue == "0")
				{
					ShowError(
						"客室を選択してください。"
					);

					return;
				}

				int roomId =
					Convert.ToInt32(
						ddlRoom.SelectedValue
					);


				/* 宿泊日数確認 */
				int nights;

				if (!int.TryParse(
						txtNights.Text,
						out nights)
					|| nights <= 0)
				{
					ShowError(
						"宿泊日数を正しく入力してください。"
					);

					return;
				}


				/* 宿泊人数確認 */
				int numberOfGuests;

				if (!int.TryParse(
						txtNumberOfGuests.Text,
						out numberOfGuests)
					|| numberOfGuests <= 0)
				{
					ShowError(
						"宿泊人数を正しく入力してください。"
					);

					return;
				}


				DateTime checkIn =
					DateTime.Today;

				DateTime checkOut =
					checkIn
						.AddDays(nights)
						.AddHours(12);


				decimal totalAmount =
					GetRoomPrice(roomId)
					* nights;


				using (SqlConnection con =
					new SqlConnection(connectionString))
				{
					con.Open();

					using (SqlTransaction transaction =
						con.BeginTransaction())
					{
						try
						{
							InsertBooking(
								con,
								transaction,
								guestId,
								roomId,
								checkIn,
								checkOut,
								totalAmount,
								numberOfGuests
							);

							UpdateRoomStatus(
								con,
								transaction,
								roomId,
								"Occupied"
							);

							transaction.Commit();
						}
						catch
						{
							transaction.Rollback();
							throw;
						}
					}
				}


				string guestName =
					pnlNewGuestForm.Visible
						? txtFirstName.Text.Trim()
						  + " "
						  + txtLastName.Text.Trim()
						: ddlGuest.SelectedItem.Text;


				ShowSuccess(
					guestName
					+ " 様のチェックインが完了しました。"
					+ " チェックアウト予定: "
					+ checkOut.ToString(
						"yyyy年MM月dd日 HH:mm"
					)
				);


				ClearForm();
				LoadAvailableRooms();
				LoadGuests();
			}
			catch (Exception ex)
			{
				ShowError(
					"チェックイン処理中にエラーが発生しました: "
					+ ex.Message
				);
			}
		}


		/// <summary>
		/// チェックイン済み予約を登録する
		/// </summary>
		private void InsertBooking(
			SqlConnection con,
			SqlTransaction transaction,
			int guestId,
			int roomId,
			DateTime checkIn,
			DateTime checkOut,
			decimal totalAmount,
			int numberOfGuests)
		{
			const string query = @"
                INSERT INTO dbo.Bookings
                (
                    GuestID,
                    RoomID,
                    CheckInDate,
                    CheckOutDate,
                    BookingDate,
                    Status,
                    TotalAmount,
                    AmountPaid,
                    NumberOfGuests,
                    SpecialRequest
                )
                VALUES
                (
                    @GuestID,
                    @RoomID,
                    @CheckInDate,
                    @CheckOutDate,
                    GETDATE(),
                    'CheckedIn',
                    @TotalAmount,
                    0,
                    @NumberOfGuests,
                    NULL
                );
            ";

			using (SqlCommand cmd =
				new SqlCommand(
					query,
					con,
					transaction))
			{
				cmd.Parameters.Add(
					"@GuestID",
					SqlDbType.Int
				).Value = guestId;

				cmd.Parameters.Add(
					"@RoomID",
					SqlDbType.Int
				).Value = roomId;

				cmd.Parameters.Add(
					"@CheckInDate",
					SqlDbType.DateTime
				).Value = checkIn;

				cmd.Parameters.Add(
					"@CheckOutDate",
					SqlDbType.DateTime
				).Value = checkOut;

				cmd.Parameters.Add(
					"@TotalAmount",
					SqlDbType.Decimal
				).Value = totalAmount;

				cmd.Parameters[
					"@TotalAmount"
				].Precision = 18;

				cmd.Parameters[
					"@TotalAmount"
				].Scale = 2;

				cmd.Parameters.Add(
					"@NumberOfGuests",
					SqlDbType.Int
				).Value = numberOfGuests;

				cmd.ExecuteNonQuery();
			}
		}


		/// <summary>
		/// 客室ステータスを更新する
		/// </summary>
		private void UpdateRoomStatus(
			SqlConnection con,
			SqlTransaction transaction,
			int roomId,
			string status)
		{
			const string query = @"
                UPDATE dbo.Rooms
                SET Status = @Status
                WHERE RoomID = @RoomID;
            ";

			using (SqlCommand cmd =
				new SqlCommand(
					query,
					con,
					transaction))
			{
				cmd.Parameters.Add(
					"@Status",
					SqlDbType.NVarChar,
					50
				).Value = status;

				cmd.Parameters.Add(
					"@RoomID",
					SqlDbType.Int
				).Value = roomId;

				cmd.ExecuteNonQuery();
			}
		}


		/* =========================================================
           新規ゲスト登録
           ========================================================= */

		/// <summary>
		/// 新規ゲストを登録し、GuestIDを返す
		/// </summary>
		private int CreateNewGuest()
		{
			try
			{
				string firstName =
					txtFirstName.Text.Trim();

				string lastName =
					txtLastName.Text.Trim();

				string email =
					txtEmail.Text.Trim();

				string phone =
					txtPhone.Text.Trim();

				string idNumber =
					txtIDNumber.Text.Trim();


				if (string.IsNullOrWhiteSpace(firstName)
					|| string.IsNullOrWhiteSpace(lastName))
				{
					ShowError(
						"姓と名を入力してください。"
					);

					return 0;
				}


				DateTime? dateOfBirth = null;

				if (!string.IsNullOrWhiteSpace(
					txtDateOfBirth.Text))
				{
					DateTime parsedDate;

					if (!DateTime.TryParse(
						txtDateOfBirth.Text,
						out parsedDate))
					{
						ShowError(
							"生年月日を正しく入力してください。"
						);

						return 0;
					}

					dateOfBirth = parsedDate;
				}


				const string query = @"
                    INSERT INTO dbo.Guests
                    (
                        FirstName,
                        LastName,
                        Email,
                        Phone,
                        IDNumber,
                        DateOfBirth,
                        CreatedDate,
                        IsActive
                    )
                    OUTPUT INSERTED.GuestID
                    VALUES
                    (
                        @FirstName,
                        @LastName,
                        @Email,
                        @Phone,
                        @IDNumber,
                        @DateOfBirth,
                        GETDATE(),
                        1
                    );
                ";


				using (SqlConnection con =
					new SqlConnection(connectionString))
				using (SqlCommand cmd =
					new SqlCommand(query, con))
				{
					cmd.Parameters.Add(
						"@FirstName",
						SqlDbType.NVarChar,
						100
					).Value = firstName;

					cmd.Parameters.Add(
						"@LastName",
						SqlDbType.NVarChar,
						100
					).Value = lastName;


					cmd.Parameters.Add(
						"@Email",
						SqlDbType.NVarChar,
						255
					).Value =
						string.IsNullOrWhiteSpace(email)
							? (object)DBNull.Value
							: email;


					cmd.Parameters.Add(
						"@Phone",
						SqlDbType.NVarChar,
						50
					).Value =
						string.IsNullOrWhiteSpace(phone)
							? (object)DBNull.Value
							: phone;


					cmd.Parameters.Add(
						"@IDNumber",
						SqlDbType.NVarChar,
						100
					).Value =
						string.IsNullOrWhiteSpace(idNumber)
							? (object)DBNull.Value
							: idNumber;


					cmd.Parameters.Add(
						"@DateOfBirth",
						SqlDbType.Date
					).Value =
						dateOfBirth.HasValue
							? (object)dateOfBirth.Value.Date
							: DBNull.Value;


					con.Open();

					object result =
						cmd.ExecuteScalar();

					if (result == null
						|| result == DBNull.Value)
					{
						return 0;
					}

					return Convert.ToInt32(result);
				}
			}
			catch (Exception ex)
			{
				ShowError(
					"ゲスト登録中にエラーが発生しました: "
					+ ex.Message
				);

				return 0;
			}
		}


		/* =========================================================
           キャンセル
           ========================================================= */

		/// <summary>
		/// ダッシュボードへ戻る
		/// </summary>
		protected void btnCancel_Click(
			object sender,
			EventArgs e)
		{
			Response.Redirect(
				"~/Default.aspx"
			);
		}


		/* =========================================================
           フォーム初期化
           ========================================================= */

		/// <summary>
		/// 入力フォームを初期状態へ戻す
		/// </summary>
		private void ClearForm()
		{
			txtFirstName.Text =
				string.Empty;

			txtLastName.Text =
				string.Empty;

			txtEmail.Text =
				string.Empty;

			txtPhone.Text =
				string.Empty;

			txtIDNumber.Text =
				string.Empty;

			txtDateOfBirth.Text =
				string.Empty;


			if (ddlGuest.Items.Count > 0)
			{
				ddlGuest.SelectedIndex = 0;
			}


			if (ddlRoom.Items.Count > 0)
			{
				ddlRoom.SelectedIndex = 0;
			}


			txtNights.Text = "1";

			txtNumberOfGuests.Text = "1";

			txtCheckOut.Text =
				string.Empty;

			lblTotalAmount.Text = "0";


			pnlNewGuestForm.Visible = false;
			pnlExistingGuestForm.Visible = false;
			pnlRoomSection.Visible = false;

			pnlNewGuest.CssClass =
				"option-card";

			pnlExistingGuest.CssClass =
				"option-card";
		}


		/* =========================================================
           メッセージ表示
           ========================================================= */

		/// <summary>
		/// エラーメッセージを表示する
		/// </summary>
		private void ShowError(string message)
		{
			pnlError.Visible = true;
			pnlSuccess.Visible = false;

			lblError.Text = message;
		}


		/// <summary>
		/// 成功メッセージを表示する
		/// </summary>
		private void ShowSuccess(string message)
		{
			pnlSuccess.Visible = true;
			pnlError.Visible = false;

			lblSuccess.Text = message;
		}
	}
}