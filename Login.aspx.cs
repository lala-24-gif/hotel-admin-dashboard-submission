using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace HotelManagement
{
    public partial class Login : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check if already logged in
                if (Session["AdminID"] != null)
                {
                    Response.Redirect("Default.aspx");
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                string username = txtUsername.Text.Trim();
                string password = txtPassword.Text;

                if (AuthenticateUser(username, password))
                {
                    // Successful login
                    Response.Redirect("Default.aspx");
                }
                else
                {
                    // Failed login
                    ShowError("ユーザー名またはパスワードが間違っています。再度入力してください。");
                }
            }
        }

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
                                // Store user information in session
                                Session["AdminID"] = reader["AdminID"];
                                Session["AdminName"] = reader["FullName"];
                                Session["AdminUsername"] = reader["Username"];
                                Session["AdminEmail"] = reader["Email"];
                                Session["AdminRole"] = reader["Role"];

                                // Update last login
                                UpdateLastLogin(Convert.ToInt32(reader["AdminID"]));

                                return true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Login error: " + ex.Message);
            }

            return false;
        }

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
                System.Diagnostics.Debug.WriteLine("Update last login error: " + ex.Message);
            }
        }

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