defmodule Carbon.AttachmentController do
  use Carbon.Web, :controller

  def show(conn, %{"id" => id}) do
    current_user = conn.assigns[:current_user]
    attachment = Repo.one(from a in Carbon.Attachment, where: a.id == ^id and (not a.private or a.user_id == ^current_user.id))

    conn
    |> put_resp_content_type(attachment.mimetype)
    |> put_resp_header("Content-Disposition", ~s[attachment; filename="#{ attachment.name }"])
    |> send_resp(200, Base.decode64!(attachment.base64_content))
  end
end