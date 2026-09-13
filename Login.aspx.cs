using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;

namespace HotelManagement
{
	public partial class Login : System.Web.UI.Page
	{
		// データベース接続文字列を取得
		private string connectionString = ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString;

		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				// すでにログインしている場合はダッシュボードへ移動
				if (Session["AdminID"] != null)
				{
					Response.Redirect("Default.aspx");
				}
			}
		}

		// 入力されたユーザー名とパスワードでログイン処理を実行
		protected void btnLogin_Click(object sender, EventArgs e)
		{
			if (Page.IsValid)
			{
				string username = txtUsername.Text.Trim();
				string password = txtPassword.Text;

				if (AuthenticateUser(username, password))
				{
					// ログイン成功後にダッシュボードへ移動
					Response.Redirect("Default.aspx");
				}
				else
				{
					// 認証に失敗した場合はエラーメッセージを表示
					ShowError("ユーザー名またはパスワードが間違っています。再度入力してください。");
				}
			}
		}

		// ユーザー名とパスワードを照合して管理者を認証
		private bool AuthenticateUser(string username, string password)
		{
			try
			{
				using (SqlConnection con = new SqlConnection(connectionString))
				{
					string query = @"SELECT AdminID, Username, FullName, Email, Role 
                                   FROM AdminUser 
                                   WHERE Username = @Username 
                                   AND Password = @Password 
                                   AND IsActive = 1";

					using (SqlCommand cmd = new SqlCommand(query, con))
					{
						cmd.Parameters.AddWithValue("@Username", username);
						cmd.Parameters.AddWithValue("@Password", HashPassword(password));

						con.Open();

						using (SqlDataReader reader = cmd.ExecuteReader())
						{
							if (reader.Read())
							{
								// 認証した管理者情報をセッションに保存
								Session["AdminID"] = reader["AdminID"];
								Session["AdminName"] = reader["FullName"];
								Session["AdminUsername"] = reader["Username"];
								Session["AdminEmail"] = reader["Email"];
								Session["AdminRole"] = reader["Role"];

								// 最終ログイン日時を更新
								UpdateLastLogin(Convert.ToInt32(reader["AdminID"]));

								return true;
							}
						}
					}
				}
			}
			catch (Exception ex)
			{
				System.Diagnostics.Debug.WriteLine("ログイン処理エラー: " + ex.Message);
			}

			return false;
		}

		// 管理者の最終ログイン日時を現在時刻に更新
		private void UpdateLastLogin(int adminID)
		{
			try
			{
				using (SqlConnection con = new SqlConnection(connectionString))
				{
					string query = "UPDATE AdminUser SET LastLogin = GETDATE() WHERE AdminID = @AdminID";

					using (SqlCommand cmd = new SqlCommand(query, con))
					{
						cmd.Parameters.AddWithValue("@AdminID", adminID);
						con.Open();
						cmd.ExecuteNonQuery();
					}
				}
			}
			catch (Exception ex)
			{
				System.Diagnostics.Debug.WriteLine("最終ログイン日時の更新エラー: " + ex.Message);
			}
		}

		// パスワードをSHA-256でハッシュ化
		private string HashPassword(string password)
		{
			using (SHA256 sha256 = SHA256.Create())
			{
				byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
				StringBuilder builder = new StringBuilder();

				foreach (byte b in bytes)
				{
					builder.Append(b.ToString("x2"));
				}

				return builder.ToString();
			}
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

