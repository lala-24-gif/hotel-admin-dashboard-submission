using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace HotelManagement
{
	public partial class Register : System.Web.UI.Page
	{
		private readonly string connectionString =
			ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString;

		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				// ログイン済みの場合はダッシュボードへ移動する
				if (Session["AdminID"] != null)
				{
					Response.Redirect("~/Default.aspx");
					return;
				}

				// 既に管理者アカウントが存在する場合は
				// 新規登録画面へのアクセスを禁止する
				if (AdminAccountExists())
				{
					Response.Redirect("~/Login.aspx");
					return;
				}
			}
		}

		/// <summary>
		/// 管理者登録ボタン押下時の処理
		/// </summary>
		protected void btnRegister_Click(object sender, EventArgs e)
		{
			if (!Page.IsValid)
			{
				return;
			}

			// 二重登録防止のため、登録直前にも再確認する
			if (AdminAccountExists())
			{
				ShowError("管理者アカウントは既に作成されています。ログインしてください。");
				return;
			}

			string fullName = txtFullName.Text.Trim();
			string username = txtUsername.Text.Trim();
			string email = txtEmail.Text.Trim();
			string password = txtPassword.Text;

			if (UserExists(username, email))
			{
				ShowError(
					"ユーザー名またはメールアドレスは既に使用されています。"
					+ "別の情報を入力してください。"
				);

				return;
			}

			if (RegisterUser(fullName, username, email, password))
			{
				ShowSuccess(
					"管理者アカウントを作成しました。"
					+ "ログインページへ移動します。"
				);

				Response.AddHeader(
					"REFRESH",
					"2;URL=" + ResolveUrl("~/Login.aspx")
				);
			}
			else
			{
				ShowError(
					"登録に失敗しました。もう一度お試しください。"
				);
			}
		}

		/// <summary>
		/// 有効な管理者アカウントが存在するか確認する
		/// </summary>
		private bool AdminAccountExists()
		{
			try
			{
				const string query = @"
                    SELECT COUNT(*)
                    FROM dbo.AdminUser
                    WHERE IsActive = 1;
                ";

				using (SqlConnection con =
					new SqlConnection(connectionString))
				using (SqlCommand cmd =
					new SqlCommand(query, con))
				{
					con.Open();

					int count =
						Convert.ToInt32(cmd.ExecuteScalar());

					return count > 0;
				}
			}
			catch (Exception ex)
			{
				System.Diagnostics.Debug.WriteLine(
					"管理者存在確認エラー: " + ex.Message
				);

				// DBエラー時に新規管理者を作成させない
				return true;
			}
		}

		/// <summary>
		/// ユーザー名またはメールアドレスの重複を確認する
		/// </summary>
		private bool UserExists(string username, string email)
		{
			try
			{
				const string query = @"
                    SELECT COUNT(*)
                    FROM dbo.AdminUser
                    WHERE Username = @Username
                       OR Email = @Email;
                ";

				using (SqlConnection con =
					new SqlConnection(connectionString))
				using (SqlCommand cmd =
					new SqlCommand(query, con))
				{
					cmd.Parameters.Add(
						"@Username",
						SqlDbType.NVarChar,
						100
					).Value = username;

					cmd.Parameters.Add(
						"@Email",
						SqlDbType.NVarChar,
						255
					).Value = email;

					con.Open();

					int count =
						Convert.ToInt32(cmd.ExecuteScalar());

					return count > 0;
				}
			}
			catch (Exception ex)
			{
				System.Diagnostics.Debug.WriteLine(
					"ユーザー存在確認エラー: " + ex.Message
				);

				// エラー時は登録を中止する
				return true;
			}
		}

		/// <summary>
		/// 管理者アカウントを登録する
		/// </summary>
		private bool RegisterUser(
			string fullName,
			string username,
			string email,
			string password)
		{
			try
			{
				const string query = @"
                    INSERT INTO dbo.AdminUser
                    (
                        Username,
                        Password,
                        Email,
                        FullName,
                        Role,
                        IsActive,
                        CreatedDate
                    )
                    VALUES
                    (
                        @Username,
                        @Password,
                        @Email,
                        @FullName,
                        'Admin',
                        1,
                        GETDATE()
                    );
                ";

				using (SqlConnection con =
					new SqlConnection(connectionString))
				using (SqlCommand cmd =
					new SqlCommand(query, con))
				{
					cmd.Parameters.Add(
						"@Username",
						SqlDbType.NVarChar,
						100
					).Value = username;

					cmd.Parameters.Add(
						"@Password",
						SqlDbType.NVarChar,
						255
					).Value = HashPassword(password);

					cmd.Parameters.Add(
						"@Email",
						SqlDbType.NVarChar,
						255
					).Value = email;

					cmd.Parameters.Add(
						"@FullName",
						SqlDbType.NVarChar,
						200
					).Value = fullName;

					con.Open();

					int rowsAffected =
						cmd.ExecuteNonQuery();

					return rowsAffected > 0;
				}
			}
			catch (Exception ex)
			{
				System.Diagnostics.Debug.WriteLine(
					"登録エラー: " + ex.Message
				);

				return false;
			}
		}

		/// <summary>
		/// パスワードをSHA-256でハッシュ化する
		/// </summary>
		private string HashPassword(string password)
		{
			using (SHA256 sha256 = SHA256.Create())
			{
				byte[] bytes =
					sha256.ComputeHash(
						Encoding.UTF8.GetBytes(password)
					);

				StringBuilder builder =
					new StringBuilder();

				foreach (byte b in bytes)
				{
					builder.Append(
						b.ToString("x2")
					);
				}

				return builder.ToString();
			}
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