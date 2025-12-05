extends Node

signal client_connected(id: int)
signal client_disconnected(id: int)
signal connected_to_server()
signal connection_failed_to_server()
signal server_disconnected()

signal create_server_error(error: Error)
signal join_client_error(error: Error)

const DefaultServerPort: int = 42069
const DefaultBroadcastPort: int = 42070
const DefaultBroadcastListenPort: int = 42071
const DefaultBroadcastAddress: String = "255.255.255.255"
const DefaultDNSPort: int = 53
const MinPort = 1024 # Avoid privileged & reserved ports (0-1023)
const MaxPort: int = pow(2, 16) - 1 ## 65535
const DefaultMaxServerPlayers: int = 32

const GoogleHost: String = "8.8.8.8"
const CloudFlareHost: String = "1.1.1.1"
const LocalHost: String = "127.0.0.1"
const DefaultPingHosts: Array[String] = [GoogleHost, CloudFlareHost]
const DefaultPingURLs: Array[String] = [
		"https://www.google.com/generate_204",
		"https://www.cloudflare.com/cdn-cgi/trace",
		"https://example.com"
]



enum NetworkType {
	## Game within the same local area network (LAN)
	LocalAreaNetwork,
	## Game over the Internet (using relays/servers).
	Global
}

var broadcaster: PacketPeerUDP
var broadcast_listener: PacketPeerUDP
var broadcast_timer: Timer
var broadcast_emission_interval: int = 1
var current_broadcast_emission: PackedByteArray

var peer: ENetMultiplayerPeer
## Useful to debug multiple instances in the same machine as using the local ip
## only works when testing different devices on the same LAN.
var use_localhost: bool = true

var current_ip_address: String
var current_broadcast_address: String


func _enter_tree() -> void:
	current_ip_address =  get_local_ip()
	current_broadcast_address = get_broadcast_address(DefaultBroadcastAddress)


func _exit_tree() -> void:
	end()


func ping(urls: Array[String] = DefaultPingURLs) -> bool:
	var http_request: HTTPRequest = HTTPRequest.new()
	## Used Array as GDScript pass them as reference on parameters, so it can be mutated inside the closure
	var internet_connection: Array[bool] = [false] 
	
	add_child(http_request)
	
	for url: String in urls.filter(func(ping_url: String): return is_valid_url(ping_url)):
		if internet_connection[0]:
			break
			
		var result: Error = http_request.request(url)
		
		http_request.request_completed.connect(
			func(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray):
				internet_connection[0] = (result == Error.OK and response_code in [200, 204])
				,CONNECT_ONE_SHOT)
				
		await http_request.request_completed
	
	http_request.queue_free()
	
	return internet_connection[0]


func start_server(port: int =  DefaultServerPort, max_players: int = DefaultMaxServerPlayers) -> void:
	peer = ENetMultiplayerPeer.new()
	var server_error: Error = peer.create_server(port, max_players)
	
	if server_error != OK:
		push_error("OmniKitNetworkHandler->start_server: An error [%d | %s] happened trying to create server, aborting..." % [server_error, error_string(server_error)])
		create_server_error.emit(server_error)
		return
		
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(on_client_connected)
	multiplayer.peer_disconnected.connect(on_client_disconnected)


func start_client(ip: String = LocalHost, port: int = DefaultServerPort) -> void:
	peer = ENetMultiplayerPeer.new()
	var client_error: Error = peer.create_client(ip, port)
	
	if client_error != OK:
		push_error("OmniKitNetworkHandler->start_server: An error [%d | %s] happened trying to create server, aborting..." % [client_error, error_string(client_error)])
		join_client_error.emit(client_error)
		return
		
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(on_client_connected)
	multiplayer.peer_disconnected.connect(on_client_disconnected)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed_to_server)
	multiplayer.server_disconnected.connect(on_server_disconnected)


func start_broadcast(broadcast_port: int = DefaultBroadcastPort, dest_port: int = DefaultBroadcastListenPort, bind_address: String = "0.0.0.0") -> void:
	_create_broadcast_timer()

	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(current_broadcast_address, dest_port)
	var binded_port_error: Error =  broadcaster.bind(broadcast_port, bind_address)
	
	if binded_port_error == OK:
		print("OmniKitLocalNetworkHandler: Broadcast port %d binded with success " % broadcast_port)
	else:
		push_error("OmniKitLocalNetworkHandler: An error %s happened when binding port on broadcast %d" % [error_string(binded_port_error), broadcast_port])
		
	broadcast_timer.start(broadcast_emission_interval)

## To decode packets received you can do:
## 	if broadcast_listener and broadcast_listener.get_available_packet_count() > 0:
##		var server_bytes_data: Dictionary = JSON.parse_string(broadcast_listener.get_packet().get_string_from_ascii())

func start_broadcast_listener(listen_port: int = DefaultBroadcastListenPort, bind_address: String = "0.0.0.0") -> PacketPeerUDP:
	if broadcast_listener:
		broadcast_listener.close()
	else:
		broadcast_listener = PacketPeerUDP.new()
		
	var binded_port_error: Error =  broadcast_listener.bind(listen_port, bind_address)
	
	if binded_port_error == OK:
		print("OmniKitLocalNetworkHandler: Listener broadcast port %d binded with success " % listen_port)
	else:
		push_error("OmniKitLocalNetworkHandler: An error %s happened when binding port on broadcast listener %d" % [error_string(binded_port_error), listen_port])
		
	return broadcast_listener

	
func set_current_broadcast_emission(packet: PackedByteArray) -> void:
	if packet.size() > 0:
		current_broadcast_emission = packet


func end() -> void:
	end_broadcast()
	end_broadcast_listener()
	multiplayer.multiplayer_peer = null


func end_broadcast() -> void:
	if is_instance_valid(broadcast_timer):
		broadcast_timer.stop()
	
	if broadcaster:
		broadcaster.close()


func end_broadcast_listener() -> void:
	if broadcast_listener:
		broadcast_listener.close()
	

func _create_broadcast_timer() -> void:
	if not is_instance_valid(broadcast_timer):
		broadcast_timer = Timer.new()
		broadcast_timer.name = "OmniKitLocalNetworkHandlerBroadcastTimer"
		broadcast_timer.process_callback = Timer.TIMER_PROCESS_IDLE
		broadcast_timer.autostart = false
		broadcast_timer.one_shot = false
		add_child(broadcast_timer)
		broadcast_timer.timeout.connect(on_broadcast_timer_timeout)


func validate_ipv4(ip: String) -> bool:
	var ipv4_regex: RegEx = RegEx.new()
	var compiled: Error = ipv4_regex.compile(r"^(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)){3}$")
	
	return compiled == OK and ipv4_regex.search(ip) != null


func validate_ipv6(ip: String) -> bool:
	var ipv6_regex: RegEx = RegEx.new()
	var compiled: Error = ipv6_regex.compile(r"(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))")
	
	return compiled == OK and ipv6_regex.search(ip) != null
	
	
func port_in_valid_range(port: int) -> bool:
	return OmniKitMathHelper.value_is_between(port, MinPort, MaxPort)


func random_port(include_reserved_ports: bool = false) -> bool:
	return randi_range(1 if include_reserved_ports else MinPort, MaxPort)


func get_local_ips() -> Array[String]:
	var addreses: PackedStringArray = IP.get_local_addresses()
	var valid_addreses: Array[String] = []

	for ip_address: String in addreses:
		if ip_address.begins_with("192.168.") \
				or ip_address.begins_with("10.") \
				or ip_address.begins_with("172."):
				
					valid_addreses.append(ip_address)
	## When sorted, 192.168 ips are first in the valid addresses
	valid_addreses.sort_custom(func(_a, b): return not b.begins_with("192.168"))
	
	return valid_addreses
	

func get_local_ip(ip_type: IP.Type = IP.Type.TYPE_IPV4) -> String:
	var local_ips: Array[String] = get_local_ips()
	
	return LocalHost if local_ips.is_empty() else local_ips.front()


func get_broadcast_address(local_ip: String, use_localhost: bool = false) -> String:
	if use_localhost:
		return LocalHost
	elif local_ip.begins_with("192.168."):
		return "192.168.1.255"
	elif local_ip.begins_with("10."):
		return "10.255.255.255"
	elif local_ip.begins_with("172."):
		return "172.20.255.255"
	else:
		return LocalHost if use_localhost else DefaultBroadcastAddress
	

func is_valid_url(url: String) -> bool:
	var regex = RegEx.new()
	var url_pattern = "/(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?\\/[a-zA-Z0-9]{2,}|((https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{1,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?)|(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}(\\.[a-zA-Z0-9]{2,})?/g"
	var compiled: Error = regex.compile(url_pattern)
	
	return compiled == OK and regex.search(url) != null


func open_external_link(url: String) -> void:
	if is_valid_url(url) and OS.has_method("shell_open"):
		if OS.get_name() == "Web":
			url = url.uri_encode()
			
		OS.shell_open(url)
		

func clear_signal_connections(selected_signal: Signal):
	for connection: Dictionary in selected_signal.get_connections():
		selected_signal.disconnect(connection.callable)

## Generates a Cryptographically Secure Nonce (Number Used Once).
# It uses the Crypto module to generate by default 16 bytes (128 bits) of
# cryptographically secure random data. The value is then hex-encoded.
# **Primary Purpose:** To prevent replay attacks in network and
# authentication protocols by ensuring that every submitted message is unique.
func generate_nonce(bytes: int = 16) -> String:
	return Crypto.new().generate_random_bytes(bytes).hex_encode()


#region Signal callbacks
func on_broadcast_timer_timeout() -> void:
	if current_broadcast_emission and current_broadcast_emission.size() > 0 and broadcaster:
		broadcaster.put_packet(current_broadcast_emission)

func on_client_connected(id: int) -> void:
	client_connected.emit(id)

func on_client_disconnected(id: int) -> void:
	client_disconnected.emit(id)

func on_connected_to_server() -> void:
	connected_to_server.emit()

func on_connection_failed_to_server() -> void:
	connection_failed_to_server.emit()

func on_server_disconnected() -> void:
	server_disconnected.emit()
	
#endregion
