# Überauth CAS Strategy


Central Authentication Service strategy for Überauth.
Forked from [marceldegraaf/ueberauth_cas](https://github.com/marceldegraaf/ueberauth_cas).

Forked from [kljensen/ueberauth_cas](https://github.com/kljensen/ueberauth_cas) in order to add some flexibility to the User definition:
  • the cas:serviceResponse is parsed in order to build the User map: the <cas:user> is converted in the :uid of the User (and then the uid of the Uberaut.Auth); all the <cas:attributes> are converted in field of the User map.
  • in some case one can use a json inside the <cas:attributes> to defined the User fields. In order to be able to use this approach an option json_attributes: is available to indicate which attribute contains the json (eg. "cas:data")
  • another option is avaliable:  :credential_keys, which is a list of atoms used to build the 'other' field of the Ueberauth.Auth.Credentials map --- the fields are extracted from the User map



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
