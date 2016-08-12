defmodule Carbon.ProjectTagTest do
  use Carbon.ModelCase

  alias Carbon.ProjectTag

  @valid_attrs %{active: true, color: "some content", description: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ProjectTag.changeset(%ProjectTag{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ProjectTag.changeset(%ProjectTag{}, @invalid_attrs)
    refute changeset.valid?
  end
end