defmodule Ueberauth.Strategy.CAS.API do
  @moduledoc """
  CAS server API implementation.
  """

  use Ueberauth.Strategy
  alias Ueberauth.Strategy.CAS

  @doc "Returns the URL to this CAS server's login page."
  def login_url do
    settings(:base_url) <> "/login"
  end

  @doc "Validate a CAS Service Ticket with the CAS server."
  def validate_ticket(ticket, conn) do
    HTTPoison.get(validate_url(), [], params: %{ticket: ticket, service: callback_url(conn)})
    |> handle_validate_ticket_response(Ueberauth.Strategy.Helpers.options(conn))
  end

  defp handle_validate_ticket_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, opts) do
    case String.match?(body, ~r/cas:authenticationFailure/) do
      true -> {:error, error_from_body(body)}
      _    -> 
        {_, default_opts} = Application.get_env(:ueberauth, Ueberauth)[:providers][:cas]
        merged_opts = if is_nil(opts) do
          default_opts
        else
          Keyword.merge(default_opts, opts)
        end
        {:ok, CAS.User.from_xml(body, merged_opts)}
    end
  end

  defp handle_validate_ticket_response({:error, %HTTPoison.Error{reason: reason}}, _opts) do
    {:error, reason}
  end

  defp error_from_body(body) do
    case Regex.named_captures(~r/code="(?<code>\w+)"/, body) do
      %{"code" => code} -> code
      _                 -> "UNKNOWN_ERROR"
    end
  end

  defp validate_url do
    # A different URL can be specified for service_validate.
    # This is useful for development in docker containers.
    base_url = case settings(:service_validate_base_url) do
      nil -> settings(:base_url)
      u -> u
    end
    base_url <> "/serviceValidate"
  end

  defp settings(key) do
    {_, settings} = Application.get_env(:ueberauth, Ueberauth)[:providers][:cas]
    settings[key]
  end
end
