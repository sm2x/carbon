defmodule Carbon.Workflow.FieldController do
  use Carbon.Web, :controller
  alias Carbon.Workflow.Field

  def delete(conn, %{"workflow_id" => workflow_id, "section_id" => section_id, "id" => field_id})do
    query = from f in Field, where: f.id == ^field_id
    case Repo.update_all(query, set: [active: false]) do
      {1, nil} ->
        conn
        |> put_flash(:archived_workflow_field, Repo.one!(query))
        |> redirect(to: workflow_section_path(conn, :edit, workflow_id, section_id))
      true ->
        conn
        |> put_flash(:info, "Failed to archive workflow field")
        |> render("show.html")
    end
  end
  def restore(conn, %{"workflow_id" => workflow_id, "section_id" => section_id, "id" => field_id}) do
    query = from f in Field, where: f.id == ^field_id
    case Repo.update_all(query, set: [active: true]) do
      {1, nil} ->
        conn
        |> redirect(to: workflow_section_path(conn, :edit, workflow_id, section_id))
      true ->
        conn
        |> put_flash(:info, "Failed to restore workflow field")
        |> redirect(to: workflow_section_path(conn, :edit, workflow_id, section_id))
    end

  end

  def edit(conn, %{"id"=> field_id}) do
    query = from f in Field, where: f.id == ^field_id
    field = Repo.one!(query)
    changeset = Field.changeset(field)
    conn
    |> assign(:changeset, changeset)
    |> assign(:field, field)
    |> render("edit.html")
  end


  def update(conn, %{"workflow_id" => workflow_id, "section_id" => section_id, "id" => field_id, "field" => field_params}) do
    field = Repo.get!(Field, field_id)
    changeset = Field.changeset(field, field_params)
    case Repo.update(changeset) do
      {:ok, _field} ->
        conn
        |> put_flash(:info, "Field updated successfully.")
        |> redirect(to: workflow_section_path(conn, :edit, workflow_id, section_id))
      {:error, changeset} ->
        conn
        |> assign(:field, field)
        |> assign(:changeset, changeset)
        |> render(conn, "edit.html")
    end
  end

  def new(conn, %{"workflow_id" => _workflow_id, "section_id" => _section_id}) do
    conn
    |> assign(:changeset, Field.changeset(%Field{}, %{}))
    |> render("new.html")
  end

  def next_presentation_order(nil), do: 1
  def next_presentation_order(anything), do: anything + 1

  def create(conn, %{"workflow_id" => workflow_id, "section_id" => section_id, "field" => field_params}) do
    query = from f in Field,
      select: max(f.presentation_order_index),
      where: f.section_id == ^section_id
    max_presentation_order_index = Repo.one(query)


    field = %Field{section_id: String.to_integer(section_id), presentation_order_index: next_presentation_order(max_presentation_order_index)}
    changeset = Field.changeset(field, field_params)
    case Repo.insert(changeset) do
      {:ok, _field} ->
        conn
        |> put_flash(:info, "Field created successfully")
        |> redirect(to: workflow_section_path(conn, :edit, workflow_id, section_id))
      {:error, changeset} ->
        conn
        |> put_flash(:info, "Failed to create new field")
        |> assign(:changeset, changeset)
        |> render("new.html")
    end

  end

end
