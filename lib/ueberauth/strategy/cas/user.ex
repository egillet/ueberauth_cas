defmodule Ueberauth.Strategy.CAS.User do
  @moduledoc """
  Representation of a CAS user with their roles.
  """

  defstruct name: nil, email: nil, roles: nil

  alias Ueberauth.Strategy.CAS.User

  def from_xml(body) do
    %User{}
    |> set_name(body)
    |> set_email(body)
    |> set_roles(body)
  end

  defp set_name(user, body),   do: %User{user | name: email(body)}
  defp set_email(user, body),  do: %User{user | email: email(body)}
  defp set_roles(user, _body), do: %User{user | roles: ["developer", "admin"]}

  defp email(body) do
    case Floki.parse_document(body) do
      {:ok, document} -> email_from_floki_doc(document)
      {_, _} -> nil
    end
  end

  defp email_from_floki_doc(document) do
    Floki.find(document, "cas|user")
    |> List.first
    |> Tuple.to_list
    |> List.last
    |> List.first
    |> String.downcase  
  end
end
