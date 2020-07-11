defmodule Jsend do
  @moduledoc """
  Json helpers to send success or error reasons.

  Depends on Phoenix.
  """
  import Phoenix.Controller, only: [json: 2]
  import Plug.Conn, only: [put_status: 2]

  defguard is_status(status) when is_integer(status) or is_atom(status)

  def ok(conn, data),
    do: json(conn, wrap_ok(data))

  def ok(conn, status, data) when is_status(status) do
    conn
    |> put_status(status)
    |> json(wrap_ok(data))
  end

  def fail(conn, status \\ 400, data) when is_status(status) do
    conn
    |> put_status(status)
    |> json(wrap_failure(data))
  end

  def error(conn, error),
    do: error(conn, error, nil)

  def error(conn, status, error)
      when is_status(status),
      do: error(conn, status, error, nil)

  def error(conn, error, detail),
    do: error(conn, conn.status || 500, error, detail)

  def error(conn, status, error, detail) when is_status(status) do
    json = wrap_error(error, detail)

    conn
    |> Plug.Conn.put_status(status)
    |> Phoenix.Controller.json(json)
  end

  def wrap_ok(data),
    do: %{status: "ok", data: data}

  def wrap_failure(data),
    do: %{status: "fail", data: data}

  def wrap_error(error, detail) do
    case cast_to_error(error, detail) do
      {message, nil} ->
        %{status: "error", message: message}

      {message, data} ->
        %{status: "error", message: message, data: data}
    end
  end

  # Expected final clause with a binary message
  def cast_to_error(message, detail) when is_binary(message),
    do: {message, cast_detail(detail)}

  def cast_to_error({:error, error}, detail) when is_atom(error) or is_binary(error),
    do: cast_to_error(error, detail)

  def cast_to_error(atom, detail) when is_atom(atom),
    do: cast_to_error(Atom.to_string(atom), detail)

  def cast_to_error(other, _) do
    raise ArgumentError,
          "expected a string or an atom as the error message, got: #{inspect(other)}"
  end

  defp cast_detail({:error, term}),
    do: cast_detail(term)

  defp cast_detail(nil),
    do: nil

  if :prod == Mix.env() do
    defp cast_detail(term),
      do: term
  else
    defp cast_detail(term) do
      case Phoenix.json_library() do
        Jason ->
          case Jason.encode(term) do
            {:ok, json} -> Jason.Fragment.new(json)
            {:error, _} -> "invalid-json-data -- #{inspect(term)}"
          end

        # Other libraries may not have fragment feature so we will
        # just return the data as-is
        _other ->
          term
      end
    end
  end
end
