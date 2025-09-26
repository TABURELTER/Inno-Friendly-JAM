extends Node

const PORT: int = 42096
const DISCOVERY_PORT: int = 42097
const BROADCAST_INTERVAL := 1.0

enum Status { IDLE, WAIT, PLAY }
var status: Status = Status.IDLE

var peer: ENetMultiplayerPeer

# Разделяем сокеты: один для приёма (bind), другой для отправки (broadcast)
var udp_recv := PacketPeerUDP.new()
var udp_send := PacketPeerUDP.new()

var broadcast_timer := 0.0
var found_lobbies: Array = []


func _ready() -> void:
	# Клиент всегда слушает порт DISCOVERY_PORT (на всех интерфейсах IPv4)
	var err = udp_recv.bind(DISCOVERY_PORT, "0.0.0.0")
	if err != OK:
		push_error("Не удалось открыть UDP порт для поиска: %s" % err)
	else:
		print("UDP приёмник слушает DISCOVERY_PORT =", DISCOVERY_PORT)


func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

	# Настраиваем UDP-отправитель для широковещания
	udp_send.set_broadcast_enabled(true)
	print("Сервер запущен на порту", PORT, "статус WAIT")
	status = Status.WAIT


func start_client(ip: String) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer
	print("Клиент подключается к", ip, ":", PORT)
	status = Status.PLAY


func _process(delta: float) -> void:
	# Широковещательная рассылка от сервера в режиме WAIT
	if status == Status.WAIT:
		broadcast_timer += delta
		if broadcast_timer >= BROADCAST_INTERVAL:
			broadcast_timer = 0.0
			var msg = "LOBBY:MyGame:%d" % PORT

			# 1) Broadcast в LAN
			udp_send.set_dest_address("255.255.255.255", DISCOVERY_PORT)
			udp_send.put_packet(msg.to_utf8_buffer())
			print("Broadcast отправлен -> 255.255.255.255:", msg)

			# 2) Loopback для теста на одной машине
			udp_send.set_dest_address("127.0.0.1", DISCOVERY_PORT)
			udp_send.put_packet(msg.to_utf8_buffer())
			print("Loopback отправлен -> 127.0.0.1:", msg)

	# Приём пакетов на клиенте (и вообще всегда, если кто-то шлёт)
	while udp_recv.get_available_packet_count() > 0:
		var pkt = udp_recv.get_packet().get_string_from_utf8()
		var ip = udp_recv.get_packet_ip()
		print("Получен пакет:", pkt, "от", ip)

		if pkt.begins_with("LOBBY:"):
			var parts = pkt.split(":")
			if parts.size() >= 3:
				var name = parts[1]
				var port = int(parts[2])

				# Добавляем только новые источники по IP
				if not found_lobbies.any(func(l): return l.ip == ip):
					found_lobbies.append({"name": name, "ip": ip, "port": port})
					print("Найдено лобби:", name, ip, port)

	# Постоянный статус-лог (каждые ~секунду будет видно состояние)
	if status == Status.IDLE:
		print("Status: IDLE — ожидаем действий")
	elif status == Status.WAIT:
		print("Status: WAIT — сервер рассылает объявления")
	elif status == Status.PLAY:
		print("Status: PLAY — подключено, идёт игра")


func connect_to_lobby(lobby: Dictionary) -> void:
	if status != Status.WAIT:
		print("Подключение возможно только при статусе WAIT")
		return
	start_client(lobby["ip"])
