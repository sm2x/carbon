defmodule Carbon.AccountController do
  use Carbon.Web, :controller

  alias Carbon.Account

  def index(conn, params) do
    query = from a in Account,
      where: a.active == true,
      order_by: a.name,
      limit: ^min(Map.get(params, "limit", 25), 25),
      offset: ^Map.get(params, "offset", 0)
    render(conn, "index.html", accounts: Repo.all(query))
  end

  def new(conn, _params) do
    changeset = Account.changeset(%Account{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"account" => account_params}) do
    changeset = Account.changeset(%Account{}, account_params)

    case Repo.insert(changeset) do
      {:ok, _account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: account_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    query = from a in Account,
      where: a.id == ^id,
      join: s in assoc(a, :status),
      left_join: ba in assoc(a, :billing_address),
      left_join: sa in assoc(a, :shipping_address),
      left_join: e in assoc(a, :events),
      left_join: r in assoc(e, :reminders),
      left_join: et in assoc(e, :tags),
      left_join: d in assoc(a, :deals),
      left_join: dt in assoc(d, :tags),
      left_join: c in assoc(a, :contacts),
      left_join: ct in assoc(c, :tags),
      left_join: t in assoc(a, :tags),
      preload: [
        status: s,
        billing_address: ba,
        shipping_address: sa,
        events: {e, reminders: r, tags: et},
        deals: {d, tags: dt},
        contacts: {c, tags: ct},
        tags: t
      ]
    account = Repo.one(query)
    render(conn, "show.html", account: account)
  end

  def edit(conn, %{"id" => id}) do
    account = Repo.get!(Account, id)
    changeset = Account.changeset(account)
    render(conn, "edit.html", account: account, changeset: changeset)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Repo.get!(Account, id)
    changeset = Account.changeset(account, account_params)

    case Repo.update(changeset) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: account_path(conn, :show, account))
      {:error, changeset} ->
        render(conn, "edit.html", account: account, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Repo.get!(Account, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(account)

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: account_path(conn, :index))
  end
end
