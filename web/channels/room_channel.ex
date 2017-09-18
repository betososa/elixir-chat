defmodule Chat.RoomChannel do
  use Chat.Web, :channel
  alias Chat.Presence

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room"<> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast! socket, "new_msg", %{body: body}
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    Presence.track(socket, socket.assigns.user, %{
      online_at: :os.system_time(:milli_seconds)
      })
    push socket, "presence_state", Presence.list(socket)
    {:noreply, socket}
  end

end
