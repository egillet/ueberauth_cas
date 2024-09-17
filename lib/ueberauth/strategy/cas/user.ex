defmodule Ueberauth.Strategy.CAS.User do
  @moduledoc """
  Representation of a CAS user with their roles.
  """
  import SweetXml
  require Record
  require Jason

  def from_xml(body, opts) do
    xml = parse(body)
    %{}
    |> set_uid(xml)
    |> set_attributes(xml, opts)
    |> add_credentials(opts)
  end

  defp set_uid(user, xml) do
    Map.put user, :uid, (xpath(xml, ~x"//cas:user/text()") |> to_string())
  end

  defp add_credentials(user, opts) do
    upd_user = case Map.fetch(user, :name) do
      {:ok, _} -> user
      :error -> Map.put user, :name, user.uid
    end
    case Keyword.fetch(opts, :credential_keys) do
      {:ok, keys} when is_list(keys) ->
        cred = Enum.reduce(keys, %{}, fn k, acc ->
          Map.put acc, k, Map.get(user, k)
        end)
        Map.put upd_user, :credentials, cred
      _ ->
        upd_user
    end
  end

  defp set_attributes(user, xml, opts) do
    {upd_user, jfield } = case Keyword.fetch(opts, :json_attributes) do
      {:ok, field} ->
        json_attr = xpath(xml, ~x"//#{field}/text()")
        if is_nil(json_attr) do
          {user, field}
        else
          case Jason.decode( xpath(xml, ~x"//#{field}/text()") , keys: :atoms ) do
            {:ok, json} ->
              attr_user = Enum.reduce(json, user, fn {k, v}, acc ->
                Map.put(acc, k, v)
              end )
              {attr_user, field}
            {:error, _} ->
              {user, field}
          end
        end
      :error ->
          {user, nil}
    end
    upd_user
    |> add_xml_attributes(xml, jfield)
  end


  defp add_xml_attributes(user, xml, excluded_attr) do
    excluded = if is_nil(excluded_attr), do: nil, else: String.to_atom(excluded_attr)
    el_attr =  xpath(xml, ~x"//cas:attributes")
    Enum.filter(xmlElement(el_attr, :content), fn child ->
      Record.is_record(child, :xmlElement)
    end)
    |> Enum.reduce(user, fn raw_attr, acc ->
      attr = xmlElement(raw_attr)
      if Keyword.get(attr, :name) != excluded do
        {_ns, key } = Keyword.get attr, :nsinfo
        value = xpath(raw_attr, ~x"text()") |> to_string()
        Map.put acc, List.to_atom(key), value
      else
        acc
      end
    end)
  end
end
