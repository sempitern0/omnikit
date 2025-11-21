extends Node

signal client_connected(id: int)
signal client_disconnected(id: int)
signal connected_to_server()
signal connection_failed_to_server()
signal server_disconnected()


const DefaultServerPort: int = 42069
const DefaultBroadcastPort: int = 42070
const DefaultBroadcastListenPort: int = 42071

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
	current_ip_address =  OmniKitNetworkHelper.get_local_ip()
	current_broadcast_address = OmniKitNetworkHelper.get_broadcast_address(OmniKitNetworkHelper.DefaultBroadcastAddress)


func _exit_tree() -> void:
	end()
	

func start_server(port: int =  DefaultServerPort, max_players: int = 32) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port, max_players)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(on_client_connected)
	multiplayer.peer_disconnected.connect(on_client_disconnected)


func start_client(ip: String = OmniKitNetworkHelper.LocalHost, port: int = DefaultServerPort) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
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
