using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HotelManagement
{
	public partial class GuestList : System.Web.UI.Page
	{
		private readonly string connectionString =
			ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString;


		/// <summary>
		/// ページ初期表示処理
		/// </summary>
		protected void Page_Load(object sender, EventArgs e)
		{
			if (Session["AdminID"] == null)
			{
				Response.Redirect("~/Login.aspx");
				return;
			}

			if (!IsPostBack)
			{
				LoadGuests();
				LoadTotalGuests();
			}
		}


		/* =========================================================
           ゲスト一覧
           ========================================================= */

		/// <summary>
		/// 検索条件に一致するゲスト一覧を読み込む
		/// </summary>
		private void LoadGuests()
		{
			try
			{
				string searchTerm =
					txtSearch.Text.Trim();

				string query = @"
                    SELECT
                        g.GuestID,
                        g.FirstName + ' ' + g.LastName AS GuestName,
                        g.FirstName,
                        g.LastName,
                        g.Email,
                        g.Phone,
                        g.IDNumber,
                        g.CreatedDate,
                        COUNT(b.BookingID) AS TotalBookings
                    FROM dbo.Guests g
                    LEFT JOIN dbo.Bookings b
                        ON g.GuestID = b.GuestID
                    WHERE g.IsActive = 1
                ";

				if (!string.IsNullOrWhiteSpace(searchTerm))
				{
					query += @"
                        AND
                        (
                            g.FirstName LIKE @Search
                            OR g.LastName LIKE @Search
                            OR g.Email LIKE @Search
                            OR g.Phone LIKE @Search
                        )
                    ";
				}

				query += @"
                    GROUP BY
                        g.GuestID,
                        g.FirstName,
                        g.LastName,
                        g.Email,
                        g.Phone,
                        g.IDNumber,
                        g.CreatedDate
                    ORDER BY
                        g.CreatedDate DESC;
                ";


				using (SqlConnection con =
					new SqlConnection(connectionString))
				using (SqlCommand cmd =
					new SqlCommand(query, con))
				{
					if (!string.IsNullOrWhiteSpace(searchTerm))
					{
						cmd.Parameters.Add(
							"@Search",
							SqlDbType.NVarChar,
							300
						).Value =
							"%" + searchTerm + "%";
					}

					using (SqlDataAdapter da =
						new SqlDataAdapter(cmd))
					{
						DataTable dt =
							new DataTable();

						da.Fill(dt);

						gvGuests.DataSource = dt;
						gvGuests.DataBind();
					}
				}
			}
			catch (Exception ex)
			{
				ShowError(
					"ゲストの読み込みエラー: "
					+ ex.Message
				);
			}
		}


		/// <summary>
		/// 有効なゲスト数を取得する
		/// </summary>
		private void LoadTotalGuests()
		{
			try
			{
				const string query = @"
                    SELECT COUNT(*)
                    FROM dbo.Guests
                    WHERE IsActive = 1;
                ";

				using (SqlConnection con =
					new SqlConnection(connectionString))
				using (SqlCommand cmd =
					new SqlCommand(query, con))
				{
					con.Open();

					int totalGuests =
						Convert.ToInt32(
							cmd.ExecuteScalar()
						);

					lblTotalGuests.Text =
						totalGuests.ToString();
				}
			}
			catch (Exception ex)
			{
				ShowError(
					"ゲスト数の読み込みエラー: "
					+ ex.Message
				);
			}
		}


		/* =========================================================
           検索・ページネーション
           ========================================================= */

		/// <summary>
		/// 検索条件変更時にゲスト一覧を更新する
		/// </summary>
		protected void txtSearch_TextChanged(
			object sender,
			EventArgs e)
		{
			gvGuests.PageIndex = 0;

			LoadGuests();
		}


		/// <summary>
		/// ゲスト一覧のページを切り替える
		/// </summary>
		protected void gvGuests_PageIndexChanging(
			object sender,
			GridViewPageEventArgs e)
		{
			gvGuests.PageIndex =
				e.NewPageIndex;

			LoadGuests();
		}


		/* =========================================================
           一覧操作
           ========================================================= */

		/// <summary>
		/// ゲスト一覧の操作ボタンを処理する
		/// </summary>
		protected void gvGuests_RowCommand(
			object sender,
			GridViewCommandEventArgs e)
		{
			if (e.CommandName != "EditGuest"
				&& e.CommandName != "DeleteGuest")
			{
				return;
			}

			int guestId;

			if (!int.TryParse(
					e.CommandArgument.ToString(),
					out guestId))
			{
				ShowError(
					"ゲスト情報を取得できませんでした。"
				);

				return;
			}

			if (e.CommandName == "EditGuest")
			{
				LoadGuestForEdit(guestId);
			}
			else if (e.CommandName == "DeleteGuest")
			{
				DeleteGuest(guestId);
			}
		}


		/* =========================================================
           編集
           ========================================================= */

		/// <summary>
		/// 編集対象ゲストの情報を取得する
		/// </summary>
		private void LoadGuestForEdit(int guestId)
		{
			try
			{
				const string query = @"
                    SELECT
                        GuestID,
                        FirstName,
                        LastName,
                        Email,
                        Phone,
                        IDNumber
                    FROM dbo.Guests
                    WHERE GuestID = @GuestID;
                ";

				using (SqlConnection con =
					new SqlConnection(connectionString))
				using (SqlCommand cmd =
					new SqlCommand(query, con))
				{
					cmd.Parameters.Add(
						"@GuestID",
						SqlDbType.Int
					).Value = guestId;

					con.Open();

					using (SqlDataReader reader =
						cmd.ExecuteReader())
					{
						if (!reader.Read())
						{
							ShowError(
								"ゲスト情報が見つかりませんでした。"
							);

							return;
						}

						hfEditGuestID.Value =
							reader["GuestID"].ToString();

						txtEditFirstName.Text =
							reader["FirstName"].ToString();

						txtEditLastName.Text =
							reader["LastName"].ToString();

						txtEditEmail.Text =
							reader["Email"] == DBNull.Value
								? string.Empty
								: reader["Email"].ToString();

						txtEditPhone.Text =
							reader["Phone"] == DBNull.Value
								? string.Empty
								: reader["Phone"].ToString();

						txtEditIDNumber.Text =
							reader["IDNumber"] == DBNull.Value
								? string.Empty
								: reader["IDNumber"].ToString();
					}
				}

				ScriptManager.RegisterStartupScript(
					this,
					GetType(),
					"ShowEditModal",
					"showEditModal();",
					true
				);
			}
			catch (Exception ex)
			{
				ShowError(
					"ゲスト詳細の読み込みエラー: "
					+ ex.Message
				);
			}
		}


		/// <summary>
		/// 編集したゲスト情報を保存する
		/// </summary>
		protected void btnSaveEdit_Click(
			object sender,
			EventArgs e)
		{
			try
			{
				int guestId;

				if (!int.TryParse(
						hfEditGuestID.Value,
						out guestId))
				{
					ShowError(
						"ゲストIDが正しくありません。"
					);

					return;
				}

				string firstName =
					txtEditFirstName.Text.Trim();

				string lastName =
					txtEditLastName.Text.Trim();

				if (string.IsNullOrWhiteSpace(firstName)
					|| string.IsNullOrWhiteSpace(lastName))
				{
					ShowError(
						"姓と名を入力してください。"
					);

					return;
				}

				const string query = @"
                    UPDATE dbo.Guests
                    SET
                        FirstName = @FirstName,
                        LastName = @LastName,
                        Email = @Email,
                        Phone = @Phone,
                        IDNumber = @IDNumber
                    WHERE GuestID = @GuestID;
                ";

				using (SqlConnection con =
					new SqlConnection(connectionString))
				using (SqlCommand cmd =
					new SqlCommand(query, con))
				{
					cmd.Parameters.Add(
						"@GuestID",
						SqlDbType.Int
					).Value = guestId;

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
						GetNullableValue(
							txtEditEmail.Text
						);

					cmd.Parameters.Add(
						"@Phone",
						SqlDbType.NVarChar,
						50
					).Value =
						GetNullableValue(
							txtEditPhone.Text
						);

					cmd.Parameters.Add(
						"@IDNumber",
						SqlDbType.NVarChar,
						100
					).Value =
						GetNullableValue(
							txtEditIDNumber.Text
						);

					con.Open();
					cmd.ExecuteNonQuery();
				}

				ShowSuccess(
					"ゲスト情報を更新しました。"
				);

				LoadGuests();
				LoadTotalGuests();

				ScriptManager.RegisterStartupScript(
					this,
					GetType(),
					"HideEditModal",
					"hideEditModal();",
					true
				);
			}
			catch (Exception ex)
			{
				ShowError(
					"ゲスト更新エラー: "
					+ ex.Message
				);
			}
		}


		/* =========================================================
           削除・匿名化
           ========================================================= */

		/// <summary>
		/// ゲストを削除または匿名化する
		/// </summary>
		private void DeleteGuest(int guestId)
		{
			try
			{
				using (SqlConnection con =
					new SqlConnection(connectionString))
				{
					con.Open();

					const string activeQuery = @"
                        SELECT COUNT(*)
                        FROM dbo.Bookings
                        WHERE GuestID = @GuestID
                          AND Status IN ('Confirmed', 'CheckedIn');
                    ";

					using (SqlCommand cmd =
						new SqlCommand(activeQuery, con))
					{
						cmd.Parameters.Add(
							"@GuestID",
							SqlDbType.Int
						).Value = guestId;

						int activeBookings =
							Convert.ToInt32(
								cmd.ExecuteScalar()
							);

						if (activeBookings > 0)
						{
							ShowError(
								"確認済みまたはチェックイン中の予約があるため、"
								+ "このゲストは削除できません。"
							);

							return;
						}
					}


					const string countQuery = @"
                        SELECT COUNT(*)
                        FROM dbo.Bookings
                        WHERE GuestID = @GuestID;
                    ";

					int totalBookings;

					using (SqlCommand cmd =
						new SqlCommand(countQuery, con))
					{
						cmd.Parameters.Add(
							"@GuestID",
							SqlDbType.Int
						).Value = guestId;

						totalBookings =
							Convert.ToInt32(
								cmd.ExecuteScalar()
							);
					}


					const string anonymizeQuery = @"
                        UPDATE dbo.Guests
                        SET
                            FirstName = N'削除済み',
                            LastName = N'ゲスト',
                            Email =
                                'deleted_'
                                + CAST(@GuestID AS VARCHAR(20))
                                + '@removed.local',
                            Phone = NULL,
                            IDNumber = NULL,
                            IsActive = 0
                        WHERE GuestID = @GuestID;
                    ";

					using (SqlCommand cmd =
						new SqlCommand(
							anonymizeQuery,
							con))
					{
						cmd.Parameters.Add(
							"@GuestID",
							SqlDbType.Int
						).Value = guestId;

						cmd.ExecuteNonQuery();
					}


					if (totalBookings > 0)
					{
						ShowSuccess(
							"ゲスト情報を匿名化しました。"
							+ totalBookings
							+ "件の過去予約は会計・履歴確認のため保持されます。"
						);
					}
					else
					{
						ShowSuccess(
							"ゲストを削除しました。"
						);
					}
				}

				if (gvGuests.PageIndex > 0)
				{
					gvGuests.PageIndex = 0;
				}

				LoadGuests();
				LoadTotalGuests();
			}
			catch (Exception ex)
			{
				ShowError(
					"ゲスト削除エラー: "
					+ ex.Message
				);
			}
		}


		/* =========================================================
           共通処理
           ========================================================= */

		/// <summary>
		/// 空文字をNULLへ変換する
		/// </summary>
		private object GetNullableValue(string value)
		{
			if (string.IsNullOrWhiteSpace(value))
			{
				return DBNull.Value;
			}

			return value.Trim();
		}


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