using System;
using System.Configuration;
using System.Data.SqlClient;

namespace HotelManagement
{
	public partial class AddGuest : System.Web.UI.Page
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
		}

		// 入力されたゲスト情報をデータベースに登録
		protected void btnSave_Click(object sender, EventArgs e)
		{
			if (Page.IsValid)
			{
				try
				{
					// フォームに入力された内容を取得
					string firstName = txtFirstName.Text.Trim();
					string lastName = txtLastName.Text.Trim();
					string email = txtEmail.Text.Trim();
					string phone = txtPhone.Text.Trim();
					string address = txtAddress.Value.Trim();
					string idNumber = txtIDNumber.Text.Trim();

					// 生年月日が入力されている場合のみ日付として取得
					DateTime? dateOfBirth = null;
					if (!string.IsNullOrEmpty(txtDateOfBirth.Text))
					{
						dateOfBirth = Convert.ToDateTime(txtDateOfBirth.Text);
					}

					using (SqlConnection con = new SqlConnection(connectionString))
					{
						// ゲスト情報をGuestsテーブルに登録
						string query = @"INSERT INTO Guests (FirstName, LastName, Email, Phone, Address, IDNumber, DateOfBirth, CreatedDate) 
                                       VALUES (@FirstName, @LastName, @Email, @Phone, @Address, @IDNumber, @DateOfBirth, GETDATE())";

						using (SqlCommand cmd = new SqlCommand(query, con))
						{
							// 入力された値をSQLパラメータに設定
							cmd.Parameters.AddWithValue("@FirstName", firstName);
							cmd.Parameters.AddWithValue("@LastName", lastName);
							cmd.Parameters.AddWithValue("@Email", string.IsNullOrEmpty(email) ? (object)DBNull.Value : email);
							cmd.Parameters.AddWithValue("@Phone", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone);
							cmd.Parameters.AddWithValue("@Address", string.IsNullOrEmpty(address) ? (object)DBNull.Value : address);
							cmd.Parameters.AddWithValue("@IDNumber", string.IsNullOrEmpty(idNumber) ? (object)DBNull.Value : idNumber);
							cmd.Parameters.AddWithValue("@DateOfBirth", dateOfBirth.HasValue ? (object)dateOfBirth.Value : DBNull.Value);

							con.Open();
							int rowsAffected = cmd.ExecuteNonQuery();

							// 登録結果に応じてメッセージを表示
							if (rowsAffected > 0)
							{
								ShowSuccess($"ゲスト {lastName} {firstName} 様が正常に登録されました！");
								ClearForm();
							}
							else
							{
								ShowError("ゲストの登録に失敗しました。もう一度お試しください。");
							}
						}
					}
				}
				catch (Exception ex)
				{
					System.Diagnostics.Debug.WriteLine("Error adding guest: " + ex.Message);
					ShowError("ゲストの登録中にエラーが発生しました。もう一度お試しください。");
				}
			}
		}

		// 入力をキャンセルしてトップページへ戻る
		protected void btnCancel_Click(object sender, EventArgs e)
		{
			Response.Redirect("~/Default.aspx");
		}

		// 入力フォームを初期状態に戻す
		private void ClearForm()
		{
			txtFirstName.Text = string.Empty;
			txtLastName.Text = string.Empty;
			txtEmail.Text = string.Empty;
			txtPhone.Text = string.Empty;
			txtAddress.Value = string.Empty;
			txtIDNumber.Text = string.Empty;
			txtDateOfBirth.Text = string.Empty;
		}

		// エラーメッセージを表示
		private void ShowError(string message)
		{
			pnlError.Visible = true;
			pnlSuccess.Visible = false;
			lblError.Text = message;
		}

		// 成功メッセージを表示
		private void ShowSuccess(string message)
		{
			pnlSuccess.Visible = true;
			pnlError.Visible = false;
			lblSuccess.Text = message;
		}
	}
}

