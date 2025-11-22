<div align="center">
	<img src="icon.svg" alt="Logo" width="160" height="160">

<h3 align="center">OmniKit</h3>

  <p align="center">
   General utilities that does not belongs to a particular place and are sed as static classes that can be accessed at any time even if they are not in the scene tree.
	<br />
	·
	<a href="https://github.com/sempitern0/omnikit/issues/new?assignees=sempitern0&labels=%F0%9F%90%9B+bug&projects=&template=bug_report.md&title=">Report Bug</a>
	·
	<a href="https://github.com/sempitern0/omnikit/issues/new?assignees=sempitern0&labels=%E2%AD%90+feature&projects=&template=feature_request.md&title=">Request Features</a>

  </p>
</div>

<br>
<br>

- [Installation 📦](#installation-)
- [Autoloads](#autoloads)
	- [OmnikitWindowManager 🖥️](#omnikitwindowmanager-️)
		- [Available signals](#available-signals)
		- [Automatically centered window position](#automatically-centered-window-position)
		- [Improved quit game](#improved-quit-game)
		- [Resolution](#resolution)
		- [Screen related](#screen-related)
		- [Screenshot](#screenshot)
		- [Parallax](#parallax)
	- [OmniKiGamepadControllerManager 🎮](#omnikigamepadcontrollermanager-)
		- [Controller connected \& disconnected](#controller-connected--disconnected)
		- [Gamepad names and buttons](#gamepad-names-and-buttons)
		- [Current controller information](#current-controller-information)
		- [Methods](#methods)
	- [OmniKitNetworkHandler 🌐](#omnikitnetworkhandler-)
		- [Signals](#signals)
		- [Constants](#constants)
		- [Accessible variables](#accessible-variables)
		- [Information and detection methods](#information-and-detection-methods)
		- [Ping](#ping)
		- [Multiplayer (ENet)](#multiplayer-enet)
		- [Local Network Discovery (UDP Broadcast)](#local-network-discovery-udp-broadcast)
			- [Start Broadcast on the Server](#start-broadcast-on-the-server)
			- [Start Broadcast listener on the Client](#start-broadcast-listener-on-the-client)
			- [Set the broadcast emission data](#set-the-broadcast-emission-data)
			- [End broadcast](#end-broadcast)
- [OmniKitLogger](#omnikitlogger)
- [Helpers ✨](#helpers-)
	- [OmniKitCollisionHelper 💥](#omnikitcollisionhelper-)
	- [OmniKitColorHelper 🎨](#omnikitcolorhelper-)
		- [ColorPalette](#colorpalette)
		- [ColorGradient](#colorgradient)
		- [Generate and compare colors](#generate-and-compare-colors)
	- [Name generator 🏷️](#name-generator-️)
		- [Custom repositories](#custom-repositories)
		- [Generate random names](#generate-random-names)

# Installation 📦

1. Install from the asset library inside your project or [Download Latest Release](https://github.com/sempitern0/omnikit/releases/latest)
2. Unpack the `addons/omnikit` folder into your `/addons` folder within the Godot project
3. Enable this addon within the Godot settings: `Project > Project Settings > Plugins`

To better understand what branch to choose from for which Godot version, please refer to this table:
|Godot Version|omnikit Branch|omnikit Version|
|---|---|--|
|[![GodotEngine](https://img.shields.io/badge/Godot_4.5.x_stable-blue?logo=godotengine&logoColor=white)](https://godotengine.org/)|`main`|`1.x`|

# Autoloads

## OmnikitWindowManager 🖥️

The `OmnikitWindowManager` is a globally accessible Autoload that simplifies common tasks related to screen resolution, window centering, mobile safe areas, and provides utilities for capturing screenshots and adapting parallax backgrounds.

### Available signals

```swift
signal size_changed // A shortcut for the to get_tree().root.size_changed signal
signal screenshot_taken(image: Image) // When a screenshot is taken within this autoload provided methods
```

### Automatically centered window position
By default, this node already connects to the `size_changed` signal and automatically centers the screen when the resolution is changed. Additionally, the `size_changed` signal is exposed to prevent the need to access the root node for this purpose.

```swift
signal size_changed
//...

func _enter_tree() -> void:
	get_tree().root.size_changed.connect(on_size_changed)
//...

//This callback center the screen when the display resolution is changed in-game
func on_size_changed() -> void:
	center_window_position()
	size_changed.emit()

```

### Improved quit game
Gracefully exiting a game is often more complex than a simple call to `get_tree().quit()`, as it requires considering aspects like the execution platform and application state.

> [!IMPORTANT]  
> *To work as expected, make sure in your Godot project, the setting `application/config/auto_accept_quit` is false*.

The `OmniKitWindowManager` provides an improved method `quit_game()`, for robust, cross-platform application closure:

- **Cross-Platform Guardrail**: If the game is running on Web or iOS, where scripted termination is generally restricted, it displays an alert with customizable instructions. The translation constants `QUIT_GAME_INSTRUCTIONS` and `QUIT_GAME` are available for localized translation.
- **Pause Management**: It allows you to optionally unpause the SceneTree (unpause_before_quit: true) immediately before quitting, ensuring any final logic runs correctly.
- **Notification Propagation**: It propagates the NOTIFICATION_WM_CLOSE_REQUEST across the entire scene tree. This allows your individual scripts to define custom shutdown behavior (e.g., saving data, cleanup) by handling this notification.

- - -
The function just does:

```swift
// To work as expected, make sure application/config/auto_accept_quit is false
func quit_game(exit_code: int = 0, unpause_before_quit: bool = false) -> void:
	// Note: On Web platform and iOS this method doesn't work. 
	// On iOS instead, as recommended by the https://developer.apple.com/library/archive/qa/qa1561/_index.html.
	// The user is expected to close apps via the Home button

	if OmniKitHardwareDetector.is_ios() or OmniKitHardwareDetector.is_web():
		OS.alert(tr("QUIT_GAME_INSTRUCTIONS"), tr("QUIT_GAME"))
	else:
		var tree: SceneTree = get_tree()
		
		if unpause_before_quit:
			tree.paused = false
			
		tree.root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().call_deferred("quit", exit_code)
```

- - -


### Resolution
This module provides predefined lists of resolutions grouped by common aspect ratios. These are useful for populating resolution options in your game's settings menu.

> [!IMPORTANT]  
> *All resolution getter methods accept an optional argument: `use_computer_screen_limit: bool = false`. If set to true, the list will be filtered to only include resolutions that are smaller than or equal to the primary monitor's size. This prevents users from selecting resolutions they cannot physically display.*


```swift
func get_mobile_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]

func get_4_3_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]

func get_16_9_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]

func get_16_10_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]

func get_21_9_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]

func get_integer_scaling_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]
```

### Screen related
These functions offer essential abstractions for retrieving dimensions, ratios, and centers of the `Viewport` and the physical monitor.

```swift
// This function is called any time the size_changed signal is emitted but can be manually triggered.
func center_window_position(viewport: Viewport = get_viewport()) -> void

// Calculates the Viewport center position transformed into the 2D world space of a given CanvasItem.	
// For example to position a 2D effect (like a screen flash) or a debug overlay relative to the world camera.
func screen_center_2d(canvas: CanvasItem) -> Vector2

// Current screen center of the viewport in the world forward or backward always parallel to the ground
func screen_center() -> Vector2

// Returns the visible size of the current Viewport.
func screen_size() -> Vector2

// Calculates the aspect ratio of the current Viewport (Width / Height). 
// For example to detect if the game is running on Ultrawide (e.g., ratio > 2.0) to adjust level design or camera limits.
func screen_ratio() -> float:

// Returns the absolute center position of the primary physical monitor or screen.
func monitor_screen_center() -> Vector2i

// Returns the mouse position relative to the screen center, normalized to a range of [-1.0, 1.0].
// Example: Creating directional input from the mouse (e.g., aiming a twin-stick shooter) that is independent of screen resolution.
func screen_relative_mouse_position(viewport: Viewport = get_viewport()) -> Vector2

// This function is used to obtain the area of the screen where it is safe to place interactive content, 
// such as user interface (UI) controls, so that they are not hidden or inaccessible due to physical or software elements of the device.
func get_mobile_safe_area(viewport: Viewport = get_viewport()) -> Rect2
```

### Screenshot
Methods for capturing and saving the current viewport. All the methods emit the `screenshot_taken` signal

> [!TIP]
> The `screenshot()` function should be called after awaiting `RenderingServer.frame_post_draw` to ensure the captured frame is fully rendered. The other screenshot methods already takes this into account so it's not needed.

```swift
// Captures the viewport's texture as a Godot Image object.
func screenshot(viewport: Viewport) -> Image

// Captures and saves the image as a PNG file (timestamped) in the user data directory. Logs the save path to the console.
func screenshot_to_folder(viewport: Viewport = get_viewport(), folder: String = "%s/screenshots" % OS.get_user_data_dir()) -> Error

// Captures the image and assigns it to a new ImageTexture on the provided TextureRect node.
func screenshot_to_texture_rect(viewport: Viewport = get_viewport(), texture_rect: TextureRect = TextureRect.new()) -> TextureRect:
```

### Parallax
Helpers to automatically scale and mirror `ParallaxBackground` and `Parallax2D` layers to fit the viewport dimensions.

```swift
func adapt_parallax_to_horizontal_viewport(parallax: Parallax2D, viewport: Rect2 = get_window().get_visible_rect()) -> void

func adapt_parallax_to_vertical_viewport(parallax: Parallax2D, viewport: Rect2 = get_window().get_visible_rect()) -> void:	

// This functions supports the deprecated ParallaxBackground
func adapt_parallax_background_to_horizontal_viewport(parallax_background: ParallaxBackground, viewport: Rect2 = get_window().get_visible_rect()) -> void
		
func adapt_parallax_background_to_vertical_viewport(parallax_background: ParallaxBackground, viewport: Rect2 = get_window().get_visible_rect()) -> void
```

## OmniKiGamepadControllerManager 🎮

The `OmniKiGamepadControllerManager` allows you to manipulate and obtain information from connected game controllers. Most of the methods Tare for obtaining information from the gamepad.

This autoloads mainly helps you to detect gamepads connected to your game. **It does not contains actions remapping** so it's only for detection. This manager automatically detects when a joy it's connected & disconnected and update the current controller name.

> [!TIP]
> More information about gamepad names on [https://github.com/mdqinc/SDL_GameControllerDB](https://github.com/mdqinc/SDL_GameControllerDB)

### Controller connected & disconnected
This signals are emitted when a new or existing controller is connected & disconnected

```swift
signal controller_connected(device_id, controller_name: String)
signal controller_disconnected(device_id, previous_controller_name: String, controller_name: String)
```

### Gamepad names and buttons

```swift
const DeviceGeneric: StringName = &"generic"
const DeviceKeyboard: StringName = &"keyboard"
const DeviceXboxController: StringName = &"xbox"
const DeviceSwitchController: StringName = &"switch"
const DeviceSwitchJoyconLeftController: StringName = &"switch_left_joycon"
const DeviceSwitchJoyconRightController: StringName = &"switch_right_joycon"
const DevicePlaystationController: StringName = &"playstation"
const DeviceLunaController: StringName = &"luna"
const DeviceSteamDeckController: StringName = &"steam"

const XboxButtonLabels: Array[String] = ["A", "B", "X", "Y", "Back", "Home", "Menu", "Left Stick", "Right Stick", "Left Shoulder", "Right Shoulder", "Up", "Down", "Left", "Right", "Share"]
const SwitchButtonLabels: Array[String] = ["B", "A", "Y", "X", "-", "", "+", "Left Stick", "Right Stick", "Left Shoulder", "Right Shoulder", "Up", "Down", "Left", "Right", "Capture"]
const PlaystationButtonLabels: Array[String] = ["Cross", "Circle", "Square", "Triangle", "Select", "PS", "Options", "L3", "R3", "L1", "R1", "Up", "Down", "Left", "Right", "Microphone"]
const SteamdeckButtonLabels: Array[String] = ["A", "B", "X", "Y", "View", "", "Options", "Left Stick Press", "Right Stick Press", "Left Shoulder", "Right Shoulder", "Up", "Down", "Left", "Right"]

const DefaultVibrationStrength: float = 0.5
const DefaultVibrationDuration: float = 0.65
```

### Current controller information

```swift
var current_controller_guid
var current_controller_device := DeviceKeyboard
var current_controller_name: String = "Keyboard"
var current_device_id: int = 0
var connected: bool = false
```

### Methods

```swift
func has_joypad() -> bool

// Array of device ids
func joypads() -> Array[int]


func start_controller_vibration(weak_strength = default_vibration_strength, strong_strength = default_vibration_strength, duration = default_vibration_duration)

func stop_controller_vibration()

// Controller detectors
func current_controller_is_steam_deck() -> bool:

func current_controller_is_generic() -> bool

func current_controller_is_luna() -> bool

func current_controller_is_keyboard() -> bool

func current_controller_is_playstation() -> bool

func current_controller_is_xbox() -> bool

func current_controller_is_switch() -> bool

func current_controller_is_switch_joycon() -> bool

func current_controller_is_switch_joycon_right() -> bool

func current_controller_is_switch_joycon_left() -> bool
```

## OmniKitNetworkHandler 🌐
The `OmniKitNetworkHandler` is a comprehensive utility designed to simplify network, connectivity, and multiplayer operations in Godot. It provides essential tools for starting servers/clients using Godot's ENetMultiplayerPeer, handling local network discovery via UDP broadcasting, and performing external connectivity checks.

### Signals
```swift
signal client_connected(id: int)
signal client_disconnected(id: int)
signal connected_to_server()
signal connection_failed_to_server()
signal server_disconnected()
```

### Constants
```swift
const DefaultServerPort: int = 42069
const DefaultBroadcastPort: int = 42070
const DefaultBroadcastListenPort: int = 42071
const DefaultBroadcastAddress: String = "255.255.255.255"
const DefaultDNSPort: int = 53

const GoogleHost: String = "8.8.8.8"
const CloudFlareHost: String = "1.1.1.1"
const LocalHost: String = "127.0.0.1"
const DefaultPingHosts: Array[String] = [GoogleHost, CloudFlareHost]
const DefaultPingURLs: Array[String] = [
		"https://www.google.com/generate_204",
		"https://www.cloudflare.com/cdn-cgi/trace",
		"https://example.com"
]
```

### Accessible variables
```swift
var broadcaster: PacketPeerUDP
var broadcast_listener: PacketPeerUDP
var broadcast_timer: Timer
var broadcast_emission_interval: int = 1
var current_broadcast_emission: PackedByteArray

var peer: ENetMultiplayerPeer

// Useful to debug multiple instances in the same machine as using the local IP
// only works when testing different devices on the same LAN.
var use_localhost: bool = true

var current_ip_address: String // Initialized on enter_tree()
var current_broadcast_address: String // Initialized on enter_tree()
```

### Information and detection methods
Even if you don't use it for network management in your project, there are useful methods for obtaining network & hardware information.


```swift
func validate_ipv4(ip: String) -> bool

func validate_ipv6(ip: String) -> bool

func is_valid_url(url: String) -> bool

// Safely opens an external URL using the host operating system's shell. Includes a special check for the Web platform.
func open_external_link(url: String) -> void

func port_in_valid_range(port: int) -> bool

func random_port() -> bool

// Returns a sorted array of local private IP addresses (e.g., 192.168.x.x, $10.x.x.x). Sorts 192.168.x.x addresses first.
func get_local_ips() -> Array[String]

// Returns the most likely private IP address to be used for networking (the first in the sorted list from get_local_ips()). Defaults to 127.0.0.1 if no local IP is found.
func get_local_ip(ip_type: IP.Type = IP.Type.TYPE_IPV4) -> String:

// Determines the correct broadcast IP for the network segment (e.g., 192.168.1.255) based on the provided local_ip.
func get_broadcast_address(local_ip: String, use_localhost: bool = false) -> String:


// Generates a Cryptographically Secure Nonce (Number Used Once).
// It uses the Crypto module to generate by default 16 bytes (128 bits) of
// cryptographically secure random data. The value is then hex-encoded.
// **Primary Purpose:** To prevent replay attacks in network and
// authentication protocols by ensuring that every submitted message is unique.
func generate_nonce(bytes: int = 16) -> String
```

### Ping
Attempts to check for external internet connectivity by sending non-blocking `HTTPRequests` to a list of URLs *(defaults to known public endpoints like Google and Cloudflare)*. It returns true if any request returns a successful status code *(200 or 204)*.

> [!IMPORTANT]
> This method uses await for its internal HTTP requests, meaning it should be called from an async function or with await in mind.

`func ping(urls: Array[String] = DefaultPingURLs) -> bool`


### Multiplayer (ENet)
This set of methods manages the setup and teardown of the Godot MultiplayerAPI using the reliable ENet protocol.

```swift

// Initializes the ENetMultiplayerPeer as a server on the specified port, setting it as the active multiplayer.multiplayer_peer. 
// It automatically connects the server's lifecycle signals to the exposed OmniKitLocalNetworkHandler.
func start_server(port: int = DefaultServerPort, max_players: int = 32) -> void

// Initializes the ENetMultiplayerPeer as a client and attempts to connect to the specified IP address and port.
// It connects all relevant client lifecycle signals exposed OmniKitLocalNetworkHandler.
func start_client(ip: String = LocalHost, port: int = DefaultServerPort) -> void

// Cleans up all networking components: stops broadcasting, closes the broadcast listener, and sets multiplayer.multiplayer_peer = null, effectively closing the active connection or server.
func end() -> void:
```

### Local Network Discovery (UDP Broadcast)
This module utilizes UDP broadcasting to allow clients on the same local network (LAN) to discover active game servers without requiring the server's exact IP address.

#### Start Broadcast on the Server
Initializes the server-side broadcaster `PacketPeerUDP`. This starts a repeating `Timer` that sends the content of `current_broadcast_emission` every broadcast_emission_interval seconds to the local network's broadcast address.

The broadcast address is automatically determined based on the server's local IP address *(e.g., 192.168.1.255)*.

```swift
func start_broadcast(broadcast_port: int = DefaultBroadcastPort, dest_port: int = DefaultBroadcastListenPort, bind_address: String = "0.0.0.0") -> void
```

#### Start Broadcast listener on the Client
Initializes the client-side listener `PacketPeerUDP`. Once started, the client must poll the returned `PacketPeerUDP` object to check for and decode incoming server broadcasts.

```swift
func start_broadcast_listener(listen_port: int = DefaultBroadcastListenPort, bind_address: String = "0.0.0.0") -> PacketPeerUDP


// An example to decode packets received you can create the next logic inside the script where you started the listener
// It's possible that you could emit other type of information different from ascii
if OmniKitNetworkHandler.broadcast_listener and OmniKitNetworkHandler.broadcast_listener.get_available_packet_count() > 0:
	var server_bytes_data: Dictionary = JSON.parse_string(OmniKitNetworkHandler.broadcast_listener.get_packet().get_string_from_ascii())
```

#### Set the broadcast emission data
Sets the packet data that the server will repeatedly broadcast. This data should contain information about the server *(e.g., game name, player count, server IP, port)*, usually encoded as a JSON string and converted to a `PackedByteArray`.

`func set_current_broadcast_emission(packet: PackedByteArray) -> void`


#### End broadcast

```swift
func end_broadcast() -> void

func end_broadcast_listener() -> void
```


# OmniKitLogger
> [!NOTE]
> *This is an improved version of [https://forum.godotengine.org/t/how-to-use-the-new-logger-class-in-godot-4-5/127006](https://forum.godotengine.org/t/how-to-use-the-new-logger-class-in-godot-4-5/127006)*


This custom Logger extends Godot's built-in `Logger` class, providing an enhanced, asynchronous, and file-backed logging system. This OmnikitLogger requires zero setup from the user. The log files are saved by the default in `OS.get_user_data_dir() + "/logs"`

```swift
// Tracking player progression, state changes, or routine successful actions.
OmniKitLogger.info(message: String) 

//Notifying of non-critical issues (e.g., missing resource files, deprecated calls) that don't halt execution.
OmniKitLogger.warn(message: String)

// Logging application errors, failed API calls, or issues that prevent intended functionality. Includes a script backtrace.
OmniKitLogger.error(message: String)

// Logging failures that may lead to instability or immediate crashes. Includes a script backtrace.
OmniKitLogger.critical(message: String)
```

# Helpers ✨
The helpers are static classes with a multitude of methods to help simplify the work. They are globally available and they don't need to be loaded in the scene tree.

## OmniKitCollisionHelper 💥
Functions related to collisions.


```swift
func layer_to_value(layer: int) -> int

func value_to_layer(value: int) -> int

// Examples

OmniKitCollisionHelper.layer_to_value(3) // Returns 8
OmniKitCollisionHelper.value_to_layer(8) // Returns 3

OmniKitCollisionHelper.layer_to_value(11) // Returns 1024
OmniKitCollisionHelper.value_to_layer(1024) // Returns 11
```

## OmniKitColorHelper 🎨
Provides an easy way to work with colors. Create gradients and palettes through resources, generate random colors, compare them, etc.

### ColorPalette
There are multiple premade color palettes ready to use you can check them on `"res://addons/omnikit/src/helpers/color/palettes"`. 
```swift
class_name OmniKitColorPalette extends Resource

@export var id: StringName
@export var name: StringName
@export var colors: PackedColorArray = []
```


### ColorGradient
There are multiple premade color gradients ready to use you can check them on `"res://addons/omnikit/src/helpers/color/gradients"`. 
```swift
class_name OmniKitColorGradient extends Resource

@export var id: StringName
@export var name: StringName
@export var gradient: GradientTexture1D
```

```swift
const ColorPalettesPath: String = "res://addons/omnikit/src/helpers/color/palettes"
const GradientsPath: String = "res://addons/omnikit/src/helpers/color/gradients"

// By default it uses the path provided in this class as constants to find recursively the palette & gradient with the selected id
func get_palette(id: StringName) -> ColorPalette

func get_gradient(id: StringName) -> ColorGradient
```

### Generate and compare colors
```swift
// Based on the method, it will call the generate_random_hsv_colors or generate_random_rgb_colors method

enum ColorGenerationMethod {
	RandomRGB,
	GoldenRatioHSV
}

func generate_random_colors(method: ColorGenerationMethod, number_of_colors: int = 12, saturation: float = 0.5, value: float = 0.95) -> PackedColorArray

// Using ideas from https://martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically/
func generate_random_hsv_colors(number_of_colors: int = 12, saturation: float = 0.5, value: float = 0.95) -> PackedColorArray

// Using ideas from https://www.iquilezles.org/www/articles/palettes/palettes.htm
func generate_random_rgb_colors(number_of_colors: int = 12, darkened_value: float = 0.2) -> PackedColorArray

// ---------------------

// Compare colors with a tolerance
func colors_are_similar(color_a: Color, color_b: Color, tolerance: float = 100.0) -> bool

// Translates a Vector3 or Vector4 to a valid Color. Returns Color.WHITE by default
func color_from_vector(vec) -> Color:
```

## Name generator 🏷️
The `OmniKitNameGenerator` is designed to generate names by utilizing various repositories that allow for multiple combinations. This addon includes a few pre-made repositories for generating fantasy and real life type names that can be found on `res://addons/omnikit/content/names/repositories`.

### Custom repositories
To create a custom name repository, simply fill the parameters with your desired names. By default, it uses the `OmniKitShuffleBag` data structure to randomize names without immediate repetition. This feature can be disabled by setting the `use_shuffle_bag` variable to `false`.

```swift
class_name OmniKitNameRepository extends Resource

enum Category {
	Male,
	Female,
	NoGender,
}


@export var id: StringName
@export var use_shuffle_bag: bool = true
@export var region: StringName = &"en"
@export var gender: Category = Category.NoGender
@export var names: Array[String] = []
@export var surnames: Array[String] = []
```

> [!NOTE]
> ***Multilingual support:*** The region variable *(e.g., set to &"en" for English, &"es" for Spanish, etc.)* is highly useful when managing multiple languages. It allows you to easily identify and select the correct name repository *(e.g., male_human_**en**.tres vs. male_human_**es**.tres)* to ensure names are generated using the appropriate cultural context and language.

### Generate random names
To begin generating names, initialize an `OmniKitNameGenerator` instance with the desired name repository. You can have multiple generators instantiated simultaneously, each using a different repository. 

```swift
// Available functions
func generate(include_surname: bool = true) -> String

func generate_name() -> String

func generate_surname() -> String
	
func change_repository(new_repository: OmniKitNameRepository) -> OmniKitNameGenerator


// Example usage:

// Instantiate a new generator with a specific repository
var generator = OmniKitNameGenerator.new(load("res://addons/omnikit/content/names/repositories/real_life/male_human_en.tres"))

print(generator.generate())      // Output: "John Doe" (Example)
print(generator.generate_name()) // Output: "John" (Example)
print(generator.generate_surname()) // Output: "Doe" (Example)

// Change the repository on existing generator
generator.change_repository(new_repository)
```
