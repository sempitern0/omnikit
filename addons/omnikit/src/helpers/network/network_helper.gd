class_name OmniKitNetworkHelper


const DefaultDNSPort: int = 53
const GoogleHost: String = "8.8.8.8"
const CloudFlareHost: String = "1.1.1.1"
const LocalHost: String = "127.0.0.1"
const DefaultBroadcastAddress: String = "255.255.255.255"
const DefaultPingHosts: Array[String] = [GoogleHost, CloudFlareHost]
const DefaultPingURLs: Array[String] = [
		"https://www.google.com/generate_204",
		"https://www.cloudflare.com/cdn-cgi/trace",
		"https://example.com"
]

## TODO - SEE A WAY TO IMPLEMENT THIS FUNCTION INSIDE A _PROCESS MORE READABLE
#static var internet_connection_status_socket: StreamPeerTCP = StreamPeerTCP.new()
#
#
#static func has_internet_connection(selected_hosts: Array[String] = DefaultPingHosts) -> bool:
	#if internet_connection_status_socket == null:
		#internet_connection_status_socket = StreamPeerTCP.new()
	#
	#internet_connection_status_socket.set_no_delay(true)
	#
	#var has_connection: bool = false
	#var pending_hosts_to_check: Array[String] = selected_hosts.duplicate()
	#
	#while pending_hosts_to_check.size() > 0 and not has_connection:
		#if internet_connection_status_socket.connect_to_host(pending_hosts_to_check.pop_front(), DefaultDNSPort) == OK:
			#internet_connection_status_socket.poll()
			#
			#if internet_connection_status_socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
				#has_connection = true
				#break
			#
			#internet_connection_status_socket.disconnect_from_host()
#
	#return has_connection

## Needs a node to add the HttpRequest in the SceneTree as this function is static
## Example: await OmniKitNetworkHelper.ping(self)
static func ping(node: Node, urls: Array[String] = DefaultPingURLs) -> bool:
	var http_request: HTTPRequest = HTTPRequest.new()
	## Used Array as GDScript pass them as reference on parameters, so it can be mutated inside the closure
	var internet_connection: Array[bool] = [false] 
	
	node.add_child(http_request)
	
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

	
static func validate_ipv4(ip: String) -> bool:
	var ipv4_regex: RegEx = RegEx.new()
	
	return ipv4_regex.compile(r"^(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)){3}$")


static func validate_ipv6(ip: String) -> bool:
	var ipv6_regex: RegEx = RegEx.new()
	
	return ipv6_regex.compile(r"(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))")
	
	
static func port_in_valid_range(port: int) -> bool:
	return OmniKitMathHelper.value_is_between(port, 1, pow(2, 16) - 1) ## 65536 - 1


static func random_port() -> bool:
	return randi_range(1, 65535)


static func get_local_ips() -> Array[String]:
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
	

static func get_local_ip(ip_type: IP.Type = IP.Type.TYPE_IPV4) -> String:
	var local_ips: Array[String] = get_local_ips()
	
	return LocalHost if local_ips.is_empty() else local_ips.front()


static func get_broadcast_address(local_ip: String, use_localhost: bool = false) -> String:
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
	

static func is_valid_url(url: String) -> bool:
	var regex = RegEx.new()
	var url_pattern = "/(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?\\/[a-zA-Z0-9]{2,}|((https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{1,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?)|(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}(\\.[a-zA-Z0-9]{2,})?/g"
	regex.compile(url_pattern)
	
	return regex.search(url) != null


static func open_external_link(url: String) -> void:
	if is_valid_url(url) and OS.has_method("shell_open"):
		if OS.get_name() == "Web":
			url = url.uri_encode()
			
		OS.shell_open(url)
		

static func clear_signal_connections(selected_signal: Signal):
	for connection: Dictionary in selected_signal.get_connections():
		selected_signal.disconnect(connection.callable)

## Generates a Cryptographically Secure Nonce (Number Used Once).
# It uses the Crypto module to generate by default 16 bytes (128 bits) of
# cryptographically secure random data. The value is then hex-encoded.
# **Primary Purpose:** To prevent replay attacks in network and
# authentication protocols by ensuring that every submitted message is unique.
static func generate_nonce(bytes: int = 16) -> String:
	return Crypto.new().generate_random_bytes(bytes).hex_encode()
