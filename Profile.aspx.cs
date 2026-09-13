using System;
using System.Configuration;
using System.Data.SqlClient;

namespace HotelManagement
{
	public partial class Profile : System.Web.UI.Page
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

			// 初回表示時のみプロフィール情報を読み込む
			if (!IsPostBack)
			{
				LoadUserProfile();
			}
		}


		// ログイン中の管理者プロフィールをデータベースから取得
		private void LoadUserProfile()
		{
			try
			{
				int adminID = Convert.ToInt32(Session["AdminID"]);

				using (SqlConnection con = new SqlConnection(connectionString))
				{
					string query = @"SELECT Username, Email, FullName, Role, CreatedDate, LastLogin 
                                   FROM AdminUser 
                                   WHERE AdminID = @AdminID";

					using (SqlCommand cmd = new SqlCommand(query, con))
					{
						cmd.Parameters.AddWithValue("@AdminID", adminID);

						con.Open();

						using (SqlDataReader reader = cmd.ExecuteReader())
						{
							if (reader.Read())
							{
								// 基本プロフィール情報を画面に表示
								lblFullName.Text = reader["FullName"].ToString();
								lblUsername.Text = reader["Username"].ToString();
								lblEmail.Text = reader["Email"].ToString();

								// 権限名を日本語表記に変換して表示
								string role = reader["Role"].ToString();
								lblRole.Text = ConvertRoleToJapanese(role);

								// アカウント作成日を表示
								DateTime createdDate = Convert.ToDateTime(reader["CreatedDate"]);
								lblCreatedDate.Text = createdDate.ToString("yyyy年MM月dd日");

								// 最終ログイン日時が登録されている場合は表示
								if (reader["LastLogin"] != DBNull.Value)
								{
									DateTime lastLogin = Convert.ToDateTime(reader["LastLogin"]);
									lblLastLogin.Text = lastLogin.ToString("yyyy年MM月dd日 HH:mm");
								}
								else
								{
									lblLastLogin.Text = "なし";
								}
							}
						}
					}
				}
			}
			catch (Exception ex)
			{
				System.Diagnostics.Debug.WriteLine("プロフィールの読み込みエラー: " + ex.Message);
				ShowError("プロフィール情報の読み込みに失敗しました。");
			}
		}


		// セッション情報を削除してログアウト
		protected void btnLogout_Click(object sender, EventArgs e)
		{
			Session.Clear();
			Session.Abandon();

			Response.Redirect("Login.aspx");
		}

		// ログイン中の管理者アカウントと関連データを削除
		protected void btnDeleteAccount_Click(object sender, EventArgs e)
		{
			try
			{
				int adminID = Convert.ToInt32(Session["AdminID"]);

				using (SqlConnection con = new SqlConnection(connectionString))
				{
					con.Open();

					// 一連の削除処理をトランザクションとして実行
					using (SqlTransaction transaction = con.BeginTransaction())
					{
						try
						{
							// 管理者が作成した売上データを削除
							string deleteSalesQuery = "DELETE FROM Sales WHERE CreatedBy = @AdminID";
							using (SqlCommand cmd = new SqlCommand(deleteSalesQuery, con, transaction))
							{
								cmd.Parameters.AddWithValue("@AdminID", adminID);
								cmd.ExecuteNonQuery();
							}

							// 管理者が作成した予約データを削除
							string deleteBookingsQuery = "DELETE FROM Bookings WHERE CreatedBy = @AdminID";
							using (SqlCommand cmd = new SqlCommand(deleteBookingsQuery, con, transaction))
							{
								cmd.Parameters.AddWithValue("@AdminID", adminID);
								cmd.ExecuteNonQuery();
							}

							// 管理者アカウントを削除
							string deleteUserQuery = "DELETE FROM AdminUser WHERE AdminID = @AdminID";
							using (SqlCommand cmd = new SqlCommand(deleteUserQuery, con, transaction))
							{
								cmd.Parameters.AddWithValue("@AdminID", adminID);
								int rowsAffected = cmd.ExecuteNonQuery();

								if (rowsAffected > 0)
								{
									// すべての削除処理が成功した場合に確定
									transaction.Commit();

									// セッション情報を削除してログイン画面へ移動
									Session.Clear();
									Session.Abandon();

									Response.Redirect("Login.aspx?deleted=1");
								}
								else
								{
									transaction.Rollback();
									ShowError("アカウントの削除に失敗しました。もう一度お試しください。");
								}
							}
						}
						catch
						{
							// 処理中にエラーが発生した場合は変更を取り消す
							transaction.Rollback();
							throw;
						}
					}
				}
			}
			catch (Exception ex)
			{
				System.Diagnostics.Debug.WriteLine("アカウント削除エラー: " + ex.Message);
				ShowError("アカウントの削除中にエラーが発生しました。もう一度お試しください。");
			}
		}


		// 管理者の権限名を日本語表記に変換
		private string ConvertRoleToJapanese(string role)
		{
			switch (role?.ToLower())
			{
				case "administrator":
				case "admin":
					return "管理者";
				case "manager":
					return "マネージャー";
				case "receptionist":
					return "受付係";
				case "staff":
					return "スタッフ";
				default:
					return role;
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

