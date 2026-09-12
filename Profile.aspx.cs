using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace HotelManagement
{
    public partial class Profile : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
          

            if (Session["AdminID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadUserProfile();
            }
        }


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
                                lblFullName.Text = reader["FullName"].ToString();
                                lblUsername.Text = reader["Username"].ToString();
                                lblEmail.Text = reader["Email"].ToString();

                               
                                string role = reader["Role"].ToString();
                                lblRole.Text = ConvertRoleToJapanese(role);

                                DateTime createdDate = Convert.ToDateTime(reader["CreatedDate"]);
                                lblCreatedDate.Text = createdDate.ToString("yyyy年MM月dd日");

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

      
        protected void btnLogout_Click(object sender, EventArgs e)
        {
           
            Session.Clear();
            Session.Abandon();

          
            Response.Redirect("Login.aspx");
        }

        protected void btnDeleteAccount_Click(object sender, EventArgs e)
        {
            try
            {
                int adminID = Convert.ToInt32(Session["AdminID"]);

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                  
                    using (SqlTransaction transaction = con.BeginTransaction())
                    {
                        try
                        {
                          
                            string deleteSalesQuery = "DELETE FROM Sales WHERE CreatedBy = @AdminID";
                            using (SqlCommand cmd = new SqlCommand(deleteSalesQuery, con, transaction))
                            {
                                cmd.Parameters.AddWithValue("@AdminID", adminID);
                                cmd.ExecuteNonQuery();
                            }

                          
                            string deleteBookingsQuery = "DELETE FROM Bookings WHERE CreatedBy = @AdminID";
                            using (SqlCommand cmd = new SqlCommand(deleteBookingsQuery, con, transaction))
                            {
                                cmd.Parameters.AddWithValue("@AdminID", adminID);
                                cmd.ExecuteNonQuery();
                            }

                        
                            string deleteUserQuery = "DELETE FROM AdminUser WHERE AdminID = @AdminID";
                            using (SqlCommand cmd = new SqlCommand(deleteUserQuery, con, transaction))
                            {
                                cmd.Parameters.AddWithValue("@AdminID", adminID);
                                int rowsAffected = cmd.ExecuteNonQuery();

                                if (rowsAffected > 0)
                                {
                                   
                                    transaction.Commit();

                                  
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