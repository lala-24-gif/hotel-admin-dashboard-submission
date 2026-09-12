using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace HotelManagement
{
    public partial class AddGuest : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["HotelDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is logged in
            if (Session["AdminID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    string firstName = txtFirstName.Text.Trim();
                    string lastName = txtLastName.Text.Trim();
                    string email = txtEmail.Text.Trim();
                    string phone = txtPhone.Text.Trim();
                    string address = txtAddress.Value.Trim();
                    string idNumber = txtIDNumber.Text.Trim();

                    DateTime? dateOfBirth = null;
                    if (!string.IsNullOrEmpty(txtDateOfBirth.Text))
                    {
                        dateOfBirth = Convert.ToDateTime(txtDateOfBirth.Text);
                    }

                    using (SqlConnection con = new SqlConnection(connectionString))
                    {
                        string query = @"INSERT INTO Guests (FirstName, LastName, Email, Phone, Address, IDNumber, DateOfBirth, CreatedDate) 
                                       VALUES (@FirstName, @LastName, @Email, @Phone, @Address, @IDNumber, @DateOfBirth, GETDATE())";

                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@FirstName", firstName);
                            cmd.Parameters.AddWithValue("@LastName", lastName);
                            cmd.Parameters.AddWithValue("@Email", string.IsNullOrEmpty(email) ? (object)DBNull.Value : email);
                            cmd.Parameters.AddWithValue("@Phone", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone);
                            cmd.Parameters.AddWithValue("@Address", string.IsNullOrEmpty(address) ? (object)DBNull.Value : address);
                            cmd.Parameters.AddWithValue("@IDNumber", string.IsNullOrEmpty(idNumber) ? (object)DBNull.Value : idNumber);
                            cmd.Parameters.AddWithValue("@DateOfBirth", dateOfBirth.HasValue ? (object)dateOfBirth.Value : DBNull.Value);

                            con.Open();
                            int rowsAffected = cmd.ExecuteNonQuery();

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

        protected void btnCancel_Click(object sender, EventArgs e)
        {
			Response.Redirect("~/Default.aspx");
		}

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
