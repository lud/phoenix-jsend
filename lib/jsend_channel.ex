defmodule Jsend.Channel do
  def ok(socket) do
    {:reply, :ok, socket}
  end

  def ok(socket, data) do
    {:reply, {:ok, data}, socket}
  end

  def error(socket, error, detail \\ nil) do
    error =
      case Jsend.cast_to_error(error, detail) do
        {message, nil} ->
          %{message: message}

        {message, data} ->
          %{message: message, data: data}
      end

    {:reply, {:error, error}, socket}
  end

  def guess(socket, :ok) do
    ok(socket)
  end

  def guess(socket, {:ok, data}) do
    ok(socket, data)
  end

  def guess(socket, {:error, _} = err) do
    error(socket, err)
  end
end
