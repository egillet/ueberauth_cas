# Überauth CAS Strategy

Central Authentication Service strategy for Überauth.
Forked from [marceldegraaf/ueberauth_cas](https://github.com/marceldegraaf/ueberauth_cas).

## Installation

Add `ueberauth` and `ueberauth_cas` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
      {:ueberauth_cas, git: "https://github.com/kljensen/ueberauth_cas.git", tag: "v0.1"},
      {:ueberauth, "~> 0.6"},
  ]
end
```

Ensure `ueberauth_cas` is started before your application:

```elixir
def application do
  [applications: [:ueberauth_cas]]
end
```

Configure the CAS integration in `config/config.exs`:

```elixir
config :ueberauth, Ueberauth,
  providers: [cas: {Ueberauth.Strategy.CAS, [
    base_url: "http://cas.example.com",
    callback: "http://your-app.example.com/auth/cas/callback",
  ]}]
```

In `AuthController` use the CAS strategy in your `login/4` function:

```elixir
def login(conn, _params, _current_user, _claims) do
  conn
  |> Ueberauth.Strategy.CAS.handle_request!
end
```
