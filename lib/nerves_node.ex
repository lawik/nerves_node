defmodule NervesNode do
  use GenServer
  use Toolshed

  @arbitrary_wait 2000
  @interval 10_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  @impl GenServer
  def init(opts) do
    {"", 0} = System.cmd("epmd", ["-daemon"])
    {:ok, pid} =
      case Node.start(:"nerves@#{hostname()}.local") do
        {:ok, pid} -> {:ok, pid}
        {:error, {:already_started, pid}} -> {:ok, pid}
      end
    Node.set_cookie(opts[:cookie])
    state = %{node_pid: pid, opts: opts}
    Process.send_after(self(), :check, @interval)
    {:ok, state}
  end

  @impl GenServer
  def handle_info(:check, state) do
    query_for_nodes() |> connect_nodes()
    Process.send_after(self(), :check, @interval)
    {:noreply, state}
  end

  @epmd_definition '_epmd._tcp.local'
  def query_for_nodes do
    q = build_query(@epmd_definition)

    MdnsLite.Responder.multicast_all(q)
    :timer.sleep(@arbitrary_wait)
    %{additional: records} = MdnsLite.Responder.query_all_caches(q)

    hostnames = records
    |> Enum.reduce([], fn r, acc ->
      case r do
        {:dns_rr, _service, :srv, :in, _, _, {_, _, _, hostname}, _, _, _} -> [hostname | acc]
        _ -> acc
      end
    end)
    |> Enum.filter(fn hostname ->
      :pong == Node.ping(name(hostname))
    end)
  end

  def connect_nodes(hostnames) do
    Enum.each(hostnames, fn hostname ->
      Node.connect(name(hostname))
    end)
    Node.list()
  end

  defp name(hostname) do
    :"nerves@#{hostname}"
  end

  defp build_query(service_definition) do
    {:dns_query, service_definition, :ptr, :in, false}
  end
end
