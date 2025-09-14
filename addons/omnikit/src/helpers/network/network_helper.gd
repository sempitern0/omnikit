class_name OmniKitNetworkHelper


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
	
	return "127.0.0.1" if local_ips.is_empty() else local_ips.front()


static func get_broadcast_address(local_ip: String, use_localhost: bool = false) -> String:
	if use_localhost:
		return "127.0.0.1"
	elif local_ip.begins_with("192.168."):
		return "192.168.1.255"
	elif local_ip.begins_with("10."):
		return "10.255.255.255"
	elif local_ip.begins_with("172."):
		return "172.20.255.255"
	else:
		return "127.0.0.1" if use_localhost else "255.255.255.255"
	

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
