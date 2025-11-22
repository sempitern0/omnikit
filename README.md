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
	- [CollisionHelper 💥](#collisionhelper-)
	- [ColorHelper 🎨](#colorhelper-)
		- [ColorPalette](#colorpalette)
		- [ColorGradient](#colorgradient)
		- [Generate and compare colors](#generate-and-compare-colors)
	- [Name generator 🏷️](#name-generator-️)
		- [Custom repositories](#custom-repositories)
		- [Generate random names](#generate-random-names)
	- [Files 🗃️](#files-️)
		- [OmniKitFileHelper](#omnikitfilehelper)
		- [CSV Reader](#csv-reader)
		- [JSON Reader](#json-reader)
	- [Geometry 🔳](#geometry-)
	- [Hardware detector 💻](#hardware-detector-)
		- [Accessible variables](#accessible-variables-1)
		- [Device/OS detection](#deviceos-detection)
		- [Project settings](#project-settings)
	- [Hardware requirements 💾](#hardware-requirements-)
		- [GPU quality](#gpu-quality)
		- [Graphic quality presets](#graphic-quality-presets)
			- [Auto-discover](#auto-discover)
		- [Apply graphics](#apply-graphics)
	- [Input 🎮](#input-)
	- [MotionInput ↔️](#motioninput-️)
		- [How to use](#how-to-use)
		- [Default Input map](#default-input-map)
		- [Inputs](#inputs)
	- [Localization 🌍](#localization-)
		- [Get a language](#get-a-language)
		- [Available languages](#available-languages)
	- [Math 🧮](#math-)
		- [Constants](#constants-1)
		- [Methods](#methods-1)
	- [BitStream 💠](#bitstream-)
	- [UUID 🔑](#uuid-)
	- [VelocityHelper 👟](#velocityhelper-)
	- [Nodes ⭕](#nodes-)
		- [Node Positioner](#node-positioner)
		- [Node Traversal](#node-traversal)
		- [Node Remover](#node-remover)

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

## CollisionHelper 💥
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

## ColorHelper 🎨
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

## Files 🗃️

### OmniKitFileHelper
Generic methods to work with files inside Godot

```swift
// Validate a file path to see if it is valid and can be worked with.
static func filepath_is_valid(path: String) -> bool

// Validate a directory path to see if it is valid and can be worked with.
static func dirpath_is_valid(path: String) -> bool

// Validate a directory path where the godot executable folder is.
static func directory_exist_on_executable_path(directory_path: String) -> bool

// Get all the files recursively on the path provided, a RegEx can be passed to filter the files to retrieve.
static func get_files_recursive(path: String, regex: RegEx = null) -> Array

// Copy content of a folder recursively into another overwrite existing files on the process
static func copy_directory_recursive(from_dir: String, to_dir: String) -> Error

// Remove all the files recursively on the path provided, a RegEx can be passed to filter what files to delete.
static func remove_files_recursive(path: String, regex: RegEx = null) -> Error

// This is actually a shortcut to retrieve all the .pck files on a folder, it simply uses get_files_recursive with a RegEx behind the scenes.
static func get_pck_files(path: String) -> Array

static func get_resource_files(path: String)

static func get_scene_files(path: String) -> Array

static func get_script_files(path: String) -> Array

static func get_shader_files(path: String) -> Array

// Given the UID, return the path to the linked file
static func uid_to_file(uid: String) -> String
```

### CSV Reader
This `OmniKitCSVReader` provides methods to work with `csv` files mainly parsing or retrieving metadata.

`static read(path: String, as_dictionary: bool = true): Variant`

This function loads a CSV/TSV file from the specified path and returns the parsed data, when as_dictionary is false the first array will be the columns. Although the function name only includes `.csv` it also supports `.tsv` files that separate by tabs instead of commas

- **path (String):** The absolute path to the CSV/TSV file.
- **as_dictionary (bool, optional):** Defaults to true. When set to true, the function attempts to convert the parsed data into an array of dictionaries, using the first line of the CSV as column headers. If false, the function returns an array of arrays, where each inner array represents a row of data where the first row are the column headers.

Returns:
- **Variant:** The parsed CSV data can be either an array of dictionaries *(if as_dictionary is true)* or an array of arrays.
**ERR_PARSE_ERROR (int):** This error code is returned if there are issues opening the file, parsing the CSV data, or encountering data inconsistencies.

For this example was used the `currency.csv` that you can find in this website [https://wsform.com/knowledgebase/sample-csv-files/](https://wsform.com/knowledgebase/sample-csv-files/)

```swift
for line in OmniKitCSVReader.read("res://currency.csv", false):
	print_rich("ARRAY LINE ", line)

// Output of
[
	ARRAY LINE ["Code", "Symbol", "Name"] // Headers
	ARRAY LINE ["AED", "د.إ", "United Arab Emirates d"]
	ARRAY LINE ["AFN", "؋", "Afghan afghani"]
	ARRAY LINE ["ALL", "L", "Albanian lek"]
	ARRAY LINE ["AMD", "AMD", "Armenian dram"]
	ARRAY LINE ["ANG", "ƒ", "Netherlands Antillean gu"]
	ARRAY LINE ["AOA", "Kz", "Angolan kwanza"]
	ARRAY LINE ["ARS", "$", "Argentine peso"]
	ARRAY LINE ["AUD", "$", "Australian dollar"]
	ARRAY LINE ["AWG", "Afl.", "Aruban florin"]
	ARRAY LINE ["AZN", "AZN", "Azerbaijani manat"]
	ARRAY LINE ["BAM", "KM", "Bosnia and Herzegovina "]
	// ....
]

for line in OmniKitCSVReader.read("res://currency.csv"):
	print_rich("DICT LINE ", line)

// Output of
[
	DICT LINE { "Code": "AED", "Symbol": "د.إ", "Name": "United Arab Emirates d" }
	DICT LINE { "Code": "AFN", "Symbol": "؋", "Name": "Afghan afghani" }
	DICT LINE { "Code": "ALL", "Symbol": "L", "Name": "Albanian lek" }
	DICT LINE { "Code": "AMD", "Symbol": "AMD", "Name": "Armenian dram" }
	DICT LINE { "Code": "ANG", "Symbol": "ƒ", "Name": "Netherlands Antillean gu" }
	DICT LINE { "Code": "AOA", "Symbol": "Kz", "Name": "Angolan kwanza" }
	DICT LINE { "Code": "ARS", "Symbol": "$", "Name": "Argentine peso" }
	DICT LINE { "Code": "AUD", "Symbol": "$", "Name": "Australian dollar" }
	DICT LINE { "Code": "AWG", "Symbol": "Afl.", "Name": "Aruban florin" }
	DICT LINE { "Code": "AZN", "Symbol": "AZN", "Name": "Azerbaijani manat" }
	DICT LINE { "Code": "BAM", "Symbol": "KM", "Name": "Bosnia and Herzegovina " }
]
```

### JSON Reader
This `OmniKitJSONHelper` provides a static utility function to safely load and parse JSON data from a file path, supporting both standard and encrypted files.


The static function `parse()` attempts to open a file, read its content, and parse it as a JSON object (*either a Dictionary or an Array)*. It includes robust error checking for file access and JSON parsing.

**Returns:**

- **Variant:** The parsed JSON data *(as a Godot Dictionary or Array)* if successful.
- **{}:** An empty Dictionary if any error occurs during file opening, JSON parsing, or if the file extension is incorrect. Errors are printed using `push_error`.

```swift
static func parse(path: String, encrypted_key: String = "") -> Variant

//...

var result = OmniKitJSONHelper.parse("res://currency.json")
```

## Geometry 🔳
Functions to obtain information on sizes, measurements or to draw specific shapes

```swift
// Shorcuts to create a MeshInstance3D with a specific mesh shape
func create_plane_mesh(size: Vector2 = Vector2.ONE) -> MeshInstance3D

func create_quad_mesh(size: Vector2 = Vector2.ONE) -> MeshInstance3D

func create_prism_mesh(size: Vector3 = Vector3.ONE, left_to_right: float = 0.5) -> MeshInstance3D

func create_cilinder_mesh(height: float = 2.0, top_radius: float = 0.5, bottom_radius: float = 0.5) -> MeshInstance3D

func create_sphere_mesh(height: float = 2.0, radius: float = 0.5, is_hemisphere: bool = false) -> MeshInstance3D

func create_capsule_mesh(height: float = 2.0, radius: float = 0.5) -> MeshInstance3D


// Get a random position as `Vector3` on any mesh shape surface
func get_random_mesh_surface_position(target: MeshInstance3D) -> Vector3

// Get a random position as `Vector2` from the inside of a circle with the given `radius`
func random_inside_unit_circle(position: Vector2, radius: float = 1.0) -> Vector

// Get a random position as `Vector2` from a circunference
func random_on_unit_circle(position: Vector2) -> Vector2

// Get a random point as Vector2 in the provided Rect2
func random_point_in_rect(rect: Rect2) -> Vector2

// Get a random point as Vector2 in annulus _(a donut shape)_ with provided center and radius provided
func random_point_in_annulus(center, radius_small, radius_large) -> Vector2

// Get the bounding box as `Rect2` from the polygon points provided
func polygon_bounding_box(polygon: PackedVector2Array) -> Rect2

func is_valid_polygon(points: PackedVector2Array) -> bool

func calculate_polygon_area(polygon: PackedVector2Array) -> float

func fracture_polygons_triangles(polygon: PackedVector2Array) -> Array

// https://stackoverflow.com/questions/1073336/circle-line-segment-collision-detection-algorithm
func segment_circle_intersects(start, end, center, radius) -> Array

// Returns intersection point(s) of a segment from 'a' to 'b' with a given rect, in order of increasing distance from 'a'
func segment_rect_intersects(a, b, rect) -> Array

// https://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Rectangle_difference
func rect_difference(r1: Rect2, r2: Rect2) -> Array

func volume_of_sphere(radius: float) -> float

func volume_of_hollow_sphere(outer_radius: float, inner_radius: float) -> float

func area_of_circle(radius: float) -> float

func area_of_triangle(base: float, perpendicular_height: float) -> float
```

## Hardware detector 💻
The `OmniKitHardwareDetector` is a static helper class that retrieves comprehensive information about the current execution environment, including operating system details, hardware specifications, and project settings.

### Accessible variables
```swift
static var engine_version: String 
static var device: String
static var platform: String
static var distribution_name: String
static var video_adapter_name: String
static var processor_name: String
static var processor_count: int
static var usable_threads: int 
static var computer_screen_size
```

### Device/OS detection
Useful methods to detect the device on which the game is running and the operating system

```swift
static func is_steam_deck() -> bool

static func is_mobile() -> bool

static func is_android() -> bool

static func is_ios() -> bool

static func is_windows() -> bool

static func is_linux() -> bool

static func is_mac() -> bool

static func is_desktop() -> bool

static func is_web() -> bool
```

### Project settings
Useful methods to detect Godot project settings related to renderer.

```swift
// Returns the rendering method that this Godot project is using (Forward+, Compatibility or Mobile)
static func renderer() -> String

static func renderer_is_forward() -> bool

static func render_is_compatibility() -> bool

static func renderer_is_mobile() -> bool

static func is_multithreading_enabled() -> bool

static func is_exported_release() -> bool

static func has_fsr() -> bool
```

## Hardware requirements 💾
> [!NOTE]
> This class was inspired by the [official graphic settings demo](https://github.com/godotengine/godot-demo-projects/blob/master/3d/graphics_settings)

The `OmniKitHardwareRequirements` class provides a mechanism to automatically detect the appropriate graphics quality preset based on the user's GPU and apply those settings dynamically to `WorldEnvironment` and `DirectionalLight3D` nodes.The quality tiers and settings configurations are based on established practices and the official Godot Demo Projects repository for Godot 4.


The `GraphicQualityDisplay` inner class serves as a data container to map a specific Godot Project Setting or Viewport property to a desired value.

```swift
class GraphicQualityDisplay:
	var project_setting: String
	var property_name: StringName
	var value: Variant

// Example
GraphicQualityDisplay.new("rendering/anti_aliasing/quality/msaa_3d", &"AntiAliasing 3D", Viewport.MSAA_DISABLED),
```

The `QualityPreset` is just an enum that can be used as information

```swift
enum QualityPreset {
	Low,
	Medium,
	High,
	Ultra
}
```

### GPU quality
An accurate list of current GPUs in the market to detect the user machine capabilities

`static var gpu_quality: Dictionary[QualityPreset, String]`


### Graphic quality presets
A set of premade `GraphicQualityClass` that contains multiple options ready to set in your game based on the `QualityPreset`

`static var graphics_quality_presets: Dictionary[QualityPreset, Array]`

#### Auto-discover
An auto-detection function that returns a `QualityPreset`based on the machine your game is currently running

```swift
static func auto_discover_graphics_quality() -> QualityPreset

//...

OmniKitHardwareRequirements.auto_discover_graphics_quality() // QualityPreset.High
```

### Apply graphics

```swift
static func apply_graphics_on_directional_light(directional_light: DirectionalLight3D, quality_preset: QualityPreset = QualityPreset.Medium) -> void:

static func apply_graphics_on_environment(world_environment: WorldEnvironment, quality_preset: QualityPreset = QualityPreset.Medium) -> void
```

## Input 🎮

This section introduces the `OmniKitInputHelper`, a collection of helpful functions for handling common input-related tasks in your game. It acts as a shortcut to avoid repetitive code for frequently used input checks.


```swift
static func is_mouse_left_click(event: InputEvent) -> bool

static func is_mouse_right_click(event: InputEvent) -> bool

static func is_mouse_left_button_pressed(event: InputEvent) -> bool

static func is_mouse_right_button_pressed(event: InputEvent) -> bool

static func is_mouse_left_released(event: InputEvent)

static func is_mouse_middle_released(event: InputEvent)

static func is_mouse_right_released(event: InputEvent)

static func is_mouse_button(event: InputEvent) -> bool


static func is_mouse_wheel(event: InputEvent) -> bool

static func is_mouse_wheel_up(event: InputEvent) -> bool

static func is_mouse_wheel_down(event: InputEvent) -> bool

static func is_mouse_wheel_right(event: InputEvent) -> bool

static func is_mouse_wheel_left(event: InputEvent) -> bool

static func is_mouse_wheel_up_or_down(event: InputEvent) -> bool

static func is_mouse_wheel_right_or_left(event: InputEvent) -> bool

// In certain cases (e.g input remapping) you want to translate the double clicks to single to ignore them.
static func double_click_to_single(event: InputEvent) -> InputEvent

// Get the relative motion regardless of viewport resolution and scale. This is useful when getting mouse motion to move
// the camera in a First Person Controller for example
static func mouse_relative_motion(event: InputEvent, scene_tree: SceneTree) -> Vector2

static func is_mouse_visible() -> bool

static func is_mouse_visible_or_confined() -> bool

static func is_mouse_captured() -> bool

static func is_mouse_confined() -> bool

static func show_mouse_cursor() -> void

static func show_mouse_cursor_confined() -> void

static func capture_mouse() -> void

static func hide_mouse_cursor() -> void

static func hide_mouse_cursor_confined() -> void
	

static func any_key_modifier_is_pressed() -> bool

static func shift_modifier_pressed() -> bool

static func ctrl_modifier_pressed() -> bool

static func alt_modifier_pressed() -> bool

static func is_controller_button(event: InputEvent) -> bool
	
static func is_controller_axis(event: InputEvent) -> bool
	
static func is_gamepad_input(event: InputEvent) -> bool

// Determines if a numeric key (including numpad keys) was pressed in the InputEvent.
static func numeric_key_pressed(event: InputEvent) -> bool

// Translates a raw InputEventKey into a human-readable string representation. 
// This is useful for displaying what key was pressed, including modifiers like "ctrl" or "shift" and physical key names.
static func readable_key(key: InputEvent) -> String


static func action_just_pressed_and_exists(action: String) -> bool

static func action_pressed_and_exists(action: String, event: InputEvent = null) -> bool

static func action_just_released_and_exists(action: String) -> bool

static func action_released_and_exists(event: InputEvent, action: String) -> bool

static func is_any_action_just_pressed(actions: Array = [])

static func is_any_action_pressed(actions: Array, event: InputEvent = null)

static func is_any_action_released(actions: Array, event: InputEvent)

static func release_input_actions(actions: Array[StringName] = [])

static func get_all_inputs_for_action(action: String) -> Array[InputEvent]
	
static func get_keyboard_inputs_for_action(action: String) -> Array[InputEvent]

// Output example: InputEventKey: keycode=4194309 (Enter), mods=none, physical=false, pressed=false, echo=false
static func get_keyboard_input_for_action(action: String) -> InputEvent

static func get_joypad_inputs_for_action(action: String) -> Array[InputEvent]

static func get_joypad_input_for_action(action: String) -> InputEvent
```

## MotionInput ↔️
The `OmniKitMotionInput` simplifies handling and transforming player input directions in your Godot games. It provides various properties and functions to access and manipulate input based on your needs.


### How to use
In order to update the inputs, the method `update` needs to be called manually, in this example we will be calling it on the `_process` for better input precision.

```swift
class_name Player extends CharacterBody3D
//...

var motion_input: OmniKitMotionInput = OmniKitMotionInput.new()
// Optionally can provide a Node3D to calculate the world_coordinate_space_direction using the provided node Basis
var motion_input: OmniKitMotionInput = OmniKitMotionInput.new(self)


func _ready() -> void:
	// Remap an input map action with chained action setters
	motion_input.change_move_forward_action(&"forward").change_move_back_action(&"back")


func _process(delta: float) -> void:
	// Detect new inputs and save previous ones
	motion_input.update()
//...
```

### Default Input map
This class provides a default input map actions to detect the inputs but can be changed for the ones that you use in your project with the action setters.

```swift
var move_right_action: StringName = &"move_right"
var move_left_action: StringName = &"move_left"
var move_forward_action: StringName = &"move_forward"
var move_back_action: StringName = &"move_back"

// Right joystick support
var up_motion_action: StringName = &"up_motion"
var down_motion_action: StringName = &"down_motion"
var left_motion_action: StringName = &"left_motion"
var right_motion_action: StringName = &"right_motion"
```

```swift
// Action setters
func change_move_right_action(new_action: StringName) -> OmniKitMotionInput

func change_move_left_action(new_action: StringName) -> OmniKitMotionInput

func change_move_forward_action(new_action: StringName) -> OmniKitMotionInput

func change_move_back_action(new_action: StringName) -> OmniKitMotionInput


func change_motion_right_action(new_action: StringName) -> OmniKitMotionInput

func change_motion_left_action(new_action: StringName) -> OmniKitMotionInput

func change_motion_up_action(new_action: StringName) -> OmniKitMotionInput

func change_motion_down_action(new_action: StringName) -> OmniKitMotionInput:
```

### Inputs

```swift
var input_direction: Vector2
var input_direction_deadzone_square_shape: Vector2
var input_direction_horizontal_axis: float
var input_direction_vertical_axis: float
var input_axis_as_vector: Vector2

// Right joystick support
var input_right_motion_horizontal_axis: float
var input_right_motion_vertical_axis: float
var input_right_motion_axis_as_vector: Vector2
var input_right_motion_as_vector: Vector2

var input_direction_horizontal_axis_applied_deadzone: float
var input_direction_vertical_axis_applied_deadzone: float
var input_joy_direction_left: Vector2
var input_joy_direction_right: Vector2
var world_coordinate_space_direction: Vector3

// Previous frame input
var previous_input_direction: Vector2
var previous_input_direction_deadzone_square_shape: Vector2
var previous_input_direction_horizontal_axis: float
var previous_input_direction_vertical_axis: float
var previous_input_axis_as_vector: Vector2

// Right joystick support
var previous_input_right_motion_horizontal_axis: float
var previous_input_right_motion_vertical_axis: float
var previous_input_right_motion_as_vector: Vector2
var previous_input_right_motion_axis_as_vector: Vector2

var previous_input_direction_horizontal_axis_applied_deadzone: float
var previous_input_direction_vertical_axis_applied_deadzone: float
var previous_input_joy_direction_left: Vector2
var previous_input_joy_direction_right: Vector2
var previous_world_coordinate_space_direction: Vector3
```

## Localization 🌍
The `OmniKitLocalization` class allows access to the information of each language to make more easy the translation management.

```swift

class Language:
	var code:  String
	var iso_code: String
	var native_name: String
	var english_name: String
```
### Get a language

**Through the available_languages dictionary using the Language enum as key:**

```swift
static var available_languages: Dictionary[Languages, Language] = {
	Languages.English: Language.new("en", "en_US", "English", "English"),
	Languages.French: Language.new("fr", "fr_FR", "Français", "French"),
	Languages.Czech: Language.new("cs", "cs_CZ", "Czech", "Czech"),

	//...
}

OmniKitLocalization.available_languages[OmniKitLocalization.Languages.English]
OmniKitLocalization.available_languages[OmniKitLocalization.Languages.French]
```

**Through the shorcut methods using the lowercase language name:**

```swift
OmniKitLocalization.english()
OmniKitLocalization.french()
OmniKitLocalization.italian()
//...
```

### Available languages
```swift
static var available_languages: Dictionary[Languages, Language] = {
	// Common languages
	Languages.English: Language.new("en", "en_US", "English", "English"),
	Languages.French: Language.new("fr", "fr_FR", "Français", "French"),
	Languages.Czech: Language.new("cs", "cs_CZ", "Czech", "Czech"),
	Languages.Danish: Language.new("da", "da_DK", "Dansk", "Danish"),
	Languages.Dutch: Language.new("nl", "nl_NL", "Nederlands", "Dutch"),
	Languages.German: Language.new("de", "de_DE", "Deutsch", "German"),
	Languages.Greek: Language.new("el", "el_GR", "Ελληνικά", "Greek"),
	Languages.Spanish: Language.new("es", "es_ES", "Español", "Spanish"),
	Languages.Indonesian: Language.new("id", "id_ID", "Indonesian", "Indonesian"),
	Languages.Italian: Language.new("it", "it_IT", "Italiano", "Italian"),
	Languages.Latvian: Language.new("lv", "lv_LV", "Latvian", "Latvian"),
	Languages.Polish: Language.new("pl", "pl_PL", "Polski", "Polish"),
	Languages.PortugueseBrazilian: Language.new("pt_BR", "pt_BR", "Português Brasileiro", "Brazilian Portuguese"),
	Languages.Portuguese: Language.new("pt", "pt_PT", "Português", "Portuguese"),
	Languages.Russian: Language.new("ru", "ru_RU", "Русский", "Russian"),
	Languages.ChineseSimplified: Language.new("zh_CN", "zh_CN", "简体中文", "Chinese Simplified"),
	Languages.ChineseTraditional: Language.new("zh_TW", "zh_TW", "繁體中文", "Chinese Traditional"),
	Languages.NorwegianBokmal: Language.new("nb", "nb_NO", "Norsk Bokmål", "Norwegian Bokmål"),
	Languages.Hungarian: Language.new("hu", "hu_HU", "Magyar", "Hungarian"),
	Languages.Romanian: Language.new("ro", "ro_RO", "Română", "Romanian"),
	Languages.Korean: Language.new("ko", "ko_KR", "한국어", "Korean"),
	Languages.Turkish: Language.new("tr", "tr_TR", "Türkçe", "Turkish"),
	Languages.Japanese: Language.new("ja", "ja_JP", "日本語", "Japanese"),
	Languages.Ukrainian: Language.new("uk", "uk_UA", "Українська", "Ukrainian"),
	Languages.Bulgarian: Language.new("bg", "bg_BG", "Български", "Bulgarian"),
	Languages.Finnish: Language.new("fi", "fi_FI", "Suomi", "Finnish"),
	Languages.Swedish: Language.new("sv", "sv_SE", "Svenska", "Swedish"),
	Languages.Hindi: Language.new("hi", "hi_IN", "हिंदी", "Hindi"),
	Languages.Arabic: Language.new("ar", "ar_EG", "العربية", "Arabic"),
	
	// -------- Not so common languages --------
	
	Languages.Esperanto: Language.new("eo", "eo_UY", "Esperanto", "Esperanto"),
	Languages.Vietnamese: Language.new("vi", "vi_VN", "Tiếng Việt", "Vietnamese"),
	Languages.Persian: Language.new("fa", "fa_IR", "فارسی", "Persian"),
	Languages.Thai: Language.new("th", "th_TH", "ภาษาไทย", "Thai"),
	Languages.Malayalam: Language.new("ml", "ml_IN", "മലയാളം", "Malayalam"),
	Languages.Telugu: Language.new("te", "te_IN", "తెలుగు", "Telugu"),
	Languages.Tamil: Language.new("ta", "ta_IN", "தமிழ்", "Tamil"),
	Languages.Marathi: Language.new("mr", "mr_IN", "मराठी", "Marathi"),
	Languages.Gujarati: Language.new("gu", "gu_IN", "ગુજરાતી", "Gujarati"),
	Languages.Kannada: Language.new("kn", "kn_IN", "ಕನ್ನಡ", "Kannada"),
	Languages.Bengali: Language.new("bn", "bn_BD", "বাংলা", "Bengali"),
	Languages.Punjabi: Language.new("pa", "pa_IN", "ਪੰਜਾਬੀ", "Punjabi"),
	Languages.Urdu: Language.new("ur", "ur_PK", "اردو", "Urdu"),
	Languages.Odia: Language.new("or", "or_IN", "ଓଡ଼ିଆ", "Odia"),
	Languages.Assamese: Language.new("as", "as_IN", "অসমীয়া", "Assamese"),
	Languages.Malay: Language.new("ms", "ms_MY", "Bahasa Melayu", "Malay"),
	Languages.Tagalog: Language.new("tl", "tl_PH", "Tagalog", "Tagalog"),
	Languages.Filipino: Language.new("fil", "fil_PH", "Filipino", "Filipino"),
	Languages.Serbian: Language.new("sr", "sr_RS", "Српски", "Serbian"),
	Languages.Croatian: Language.new("hr", "hr_HR", "Hrvatski", "Croatian"),
	Languages.Bosnian: Language.new("bs", "bs_BA", "Bosanski", "Bosnian"),
	Languages.Slovenian: Language.new("sl", "sl_SI", "Slovenščina", "Slovenian"),
	Languages.Albanian: Language.new("sq", "sq_AL", "Shqip", "Albanian"),
	Languages.Macedonian: Language.new("mk", "mk_MK", "Македонски", "Macedonian"),
	Languages.Montenegrin: Language.new("mn", "mn_ME", "Црногорски", "Montenegrin"),
	Languages.Georgian: Language.new("ka", "ka_GE", "ქართული", "Georgian"),
	Languages.Armenian: Language.new("hy", "hy_AM", "Հայերեն", "Armenian"),
	Languages.Kazakh: Language.new("kk", "kk_KZ", "Қазақша", "Kazakh"),
	Languages.Uzbek: Language.new("uz", "uz_UZ", "Oʻzbekcha", "Uzbek"),
	Languages.Kyrgyz: Language.new("ky", "ky_KG", "Кыргызча", "Kyrgyz"),
	Languages.Turkmen: Language.new("tk", "tk_TM", "Türkmençe", "Turkmen"),
	Languages.Azerbaijani: Language.new("az", "az_AZ", "Azərbaycanca", "Azerbaijani"),
	Languages.Belarusian: Language.new("be", "be_BY", "Беларуская", "Belarusian"),
	Languages.Moldovan: Language.new("mo", "mo_MD", "Moldovenească", "Moldovan"),
	Languages.Lithuanian: Language.new("lt", "lt_LT", "Lietuvių", "Lithuanian"),
	Languages.Estonian: Language.new("et", "et_EE", "Eesti keel", "Estonian"),
	Languages.Swahili: Language.new("sw", "sw_TZ", "Kiswahili", "Swahili"),
	Languages.Yoruba: Language.new("yo", "yo_NG", "Yorùbá", "Yoruba"),
	Languages.Igbo: Language.new("ig", "ig_NG", "Igbo", "Igbo"),
	Languages.Zulu: Language.new("zu", "zu_ZA", "IsiZulu", "Zulu"),
	Languages.Xhosa: Language.new("xh", "xh_ZA", "IsiXhosa", "Xhosa"),
	Languages.Afrikaans: Language.new("af", "af_ZA", "Afrikaans", "Afrikaans"),
	Languages.Amharic: Language.new("am", "am_ET", "አማርኛ", "Amharic"),
	Languages.Tigrinya: Language.new("ti", "ti_ER", "ትግርኛ", "Tigrinya"),
	Languages.Oromo: Language.new("om", "om_ET", "Afaan Oromoo", "Oromo"),
	Languages.Somali: Language.new("so", "so_SO", "Soomaali", "Somali"),
	Languages.Hausa: Language.new("ha", "ha_NG", "Hausa", "Hausa"),
	Languages.Fulfulde: Language.new("ff", "ff_CM", "Fulfulde", "Fulfulde"),
	Languages.Kanuri: Language.new("kr", "kr_NG", "Kanuri", "Kanuri"),
	Languages.Mandinka: Language.new("mnk", "mnk_GM", "Mandinka", "Mandinka"),
	Languages.Wolof: Language.new("wo", "wo_SN", "Wolof", "Wolof"),
	Languages.Serer: Language.new("sr", "sr_SN", "Serer", "Serer"),
	Languages.Shona: Language.new("sh", "sh_ZW", "Shona", "Shona"),
	Languages.Ndebele: Language.new("nd", "nd_ZW", "Ndebele", "Ndebele"),
	Languages.Sesotho: Language.new("st", "st_ZA", "Sesotho", "Sesotho"),
	Languages.Setswana: Language.new("tn", "tn_ZA", "Setswana", "Setswana"),
	Languages.Sepedi: Language.new("nso", "nso_ZA", "Sepedi", "Sepedi"),
	Languages.Tswana: Language.new("ts", "ts_ZA", "Tswana", "Tswana"),
	Languages.Venda: Language.new("ve", "ve_ZA", "Venda", "Venda"),
	Languages.Tsonga: Language.new("ts", "ts_ZA", "Tsonga", "Tsonga"),
	Languages.Lingala: Language.new("ln", "ln_CD", "Lingala", "Lingala"),
	Languages.Kikongo: Language.new("kg", "kg_CD", "Kikongo", "Kikongo"),
	Languages.Kongo: Language.new("kon", "kon_CD", "Kongo", "Kongo"),
	Languages.Mbundu: Language.new("umb", "umb_AO", "Umbundu", "Mbundu"),
	Languages.Kimbundu: Language.new("kmb", "kmb_AO", "Kimbundu", "Kimbundu"),
	Languages.Tumbuka: Language.new("tum", "tum_MW", "Tumbuka", "Tumbuka"),
	Languages.Chichewa: Language.new("ny", "ny_MW", "Chichewa", "Chichewa"),
	Languages.Bemba: Language.new("bem", "bem_ZM", "Bemba", "Bemba"),
	Languages.Nyanja: Language.new("nyn", "nyn_MW", "Nyanja", "Nyanja"),
	Languages.Herero: Language.new("hz", "hz_NA", "Otjiherero", "Herero"),
	Languages.Nama: Language.new("na", "na_NA", "Nama", "Nama"),
	Languages.Damara: Language.new("da", "da_NA", "Damara", "Damara")
} 
```

## Math 🧮

The `OmniKitMathHelper` class provide methods to work more easily with mathematical operations and oriented to videogames.

### Constants

```swift
const CommonEpsilon = 0.000001  // 1.0e-6
const PreciseEpsilon = 0.00000001  // 1.0e-8

const E: float = 2.71828182845904523536028747135266249775724709369995
const δ: float = 4.6692016091 // FEIGENBAUM CONSTANT, period-doubling bifurcation. This bifurcation describes the behavior of a system that exhibits a doubling of its periodic cycle when a certain parameter is gradually changed
const FeigenbaumAlpha: float = 2.5029078750  // FEIGENBAUM ALPHA, another bifurcation constant
const AperyConstant: float = 1.2020569031  // APERY'S CONSTANT, related to zeta function
const GoldenRatio: float = 1.6180339887  // GOLDEN RATIO, (1 + sqrt(5)) / 2
const GoldenRatioConjugate: float = 0.618033988749895 // Reciprocal of the golden ratio. In other words, it's 1/ϕ.
const EulerMascheroniConstant: float = 0.5772156649  // EULER-MASCHERONI CONSTANT, gamma minus harmonic series
const KhinchinsConstant: float = 2.6854520010  // KHINCHIN'S CONSTANT, optimal embedding dimension
const GaussKuzminWirsingConstant: float = 0.3036630028  // GAUSS-KUZMIN-WIRSING CONSTANT, sphere packing
const BernstensConstant: float = 0.2801694990  // BERNSTEIN'S CONSTANT, derivative of Dirichlet eta function
const HafnerSarnakMcCurleyConstant: float = 0.3532363718  // HAFNER-SARNAK-MCCURLEY CONSTANT, number theory
const MeisselMertensConstant: float = 0.2614972128  // MEISSEL-MERTENS CONSTANT, prime number distribution
const GlaisherKinkelinConstant: float = 1.2824271291  // GLAISHER-KINKELIN CONSTANT, zeta function
const Omega: float = 0.5671432904  // OMEGA CONSTANT, alternating harmonic series
const GolombDickmanConstant: float = 0.6243299885  // GOLOMB-DICKMAN CONSTANT, prime number distribution
const CahensConstant: float = 0.6434105462  // CAHEN'S CONSTANT, Diophantine approximation
const TwinPrime: float = 0.6601618158  // TWIN PRIME CONSTANT, probability of twin prime
const LaplaceLimit: float = 0.6627434193  // LAPLACE LIMIT, cosmic microwave background radiation
const LandauRamanujanConstant: float = 0.7642236535  // LANDAU-RAMANUJAN CONSTANT, constant in quantum field theory
const CatalansConstant: float = 0.9159655941  // CATALAN'S CONSTANT, sum of reciprocals of squares
const ViswanathsConstant: float = 1.13198824  // VISWANATH'S CONSTANT, number theory
const ConwaysConstant: float = 1.3035772690  // CONWAY'S CONSTANT, sphere packing
const MillsConstant: float = 1.3063778838  // MILLS' CONSTANT, normal number
const PlasticConstant: float = 1.3247179572  // PLASTIC CONSTANT, golden raio analogue
const RamanujanSoldnerConstant: float = 1.4513692348  // RAMANUJAN-SOLDNE CONSTANT, elliptic integrals
const BackhouseConstant: float = 1.4560749485  // BACKHOUSE'S CONSTANT, gamma function
const PortersConstant: float = 1.4670780794  // PORTER'S CONSTANT, geometry
const LiebsSquareIceConstant: float = 1.5396007178  // LIEB'S SQUARE ICE CONSTANT, statistical mechanics
const ErdosBorweinConstant: float = 1.6066951524  // ERDOS-BORWEIN CONSTANT, normal number
const NivensConstant: float = 1.7052111401  // NIVENS' CONSTANT, number theory
const UniversalParabolicConstant: float = 2.2955871493  // UNIVERSAL PARABOLIC CONSTANT, reflection coefficient
const SierpinskisConstant: float = 2.5849817595  // SIERPINSKI'S CONSTANT, Sierpinski triangle fractal
const FransenRobinsonConstant: float = 2.807770 // FRANSEN ROBINSON'S CONSTANT, It represents the area between the graph of the reciprocal Gamma function, 1/Γ(x), and the positive x-axis

const MetersPerSecondToMilePerHourFactor: float = 2.23694
const MetersPerSecondToKilometersPerHourFactor: float = 3.6

const HexCharacters: String = "0123456789ABCDEF"
```

### Methods
```swift
// The cbrt functions compute the real cube root of x.
// https://stackoverflow.com/questions/8493005/c-finding-cube-root-of-a-negative-number-with-pow-function
static func cbrt(x: float) -> float:
	return signf(x) * absf(x) ** (1.0 / 3.0)
	
// "x": This is the input value between 0 and 1 that you want to apply the bias to.
// It could represent a probability, a random number between 0 and 1, or any other value in that range.
// "bias": This is the bias factor, also between 0 and 1. It controls how much the function pushes the x value away from 0.5 (the center).
// Example:
// By adjusting the bias value, you can control how much the dice is skewed towards higher numbers.
// A bias of 0.5 would result in a fair die roll. A bias closer to 1 would make it more likely to roll higher numbers.
func bias(x : float, _bias : float) -> float

// The sigmoid function, in its most common form, produces an "S"-shaped curve. It takes any real-valued number as input and outputs a value between 0 and 1.
// The scaling_factor parameter is a modification that allows you to adjust the steepness and midpoint of the curve, giving you more control over its behavior.
func sigmoid(x: float, scaling_factor: float = 0.0) -> float

// Dease calculates a smooth, accelerating transition value over time
// Sharpness should be a value between 0 and 1
// -------
// Fading Effects: Gradually fade in or out game objects, images, or the entire screen.
// Easing Movement: Create smooth acceleration and deceleration for moving objects, such as characters or camera movements.
// Progress Bars: Simulate the filling of progress bars with a smooth, accelerating effect.
// Sound Volume Control: Gradually increase or decrease the volume of sound effects or music.
// Visual Effects: Create smooth transitions for visual effects like particle systems or screen shakes.
func dease(delta: float, sharpness: float = 0.5) -> float:

func average(numbers: Array = []) -> float

func spread(scale: float = 1.0) -> float

func get_percentage(max_value: int, value: int) -> int

func chance(probability_chance: float = 0.5, less_than: bool = true) -> bool


// https://en.wikipedia.org/wiki/Factorial
// This function calculates the factorial of a given non-negative integer number. The factorial of a number n (denoted as n!) is the product of all positive integers less than or equal to n
func factorial(number)
func factorial(5) // Returns 120 (5 * 4 * 3 * 2 * 1 = 120)

// This function generates an array containing the factorials of all non-negative integers from 0 up to and including the given number
func factorials_from(number) -> Array[float]:
func factorials_from(5) // Returns [1, 1, 2, 6, 24, 120]

// Only for radians
// If the target angle is in degrees just transform it with deg_to_rad(target_angle)
func quantize_angle_to_90(target_angle: float) -> float:

// Only for radians
func angle_is_between(angle: float, start_angle: float, end_angle: float) -> bool

// This function assumes that the cardinal direction is in radians unit.
// https://en.wikipedia.org/wiki/Cardinal_direction
func angle_from_cardinal_direction(cardinal_direction: float) -> float

func limit_horizontal_angle(direction: Vector2, limit_angle: float) -> Vector2

// Quaternions are a mathematical representation commonly used in 3D graphics to represent rotations.
// Axis-angle representation specifies a rotation by an axis vector and the angle of rotation around that axis
// Useful for Animation or Inverse Kinematics, Gimbal lock (when rotations get stuck or limited), Data storage or Transmission
func quaternion_to_axis_angle(quaternion : Quaternion) -> Quaternion

//Transform from integer to roman or from roman to integer easily with this functions.
func integer_to_roman_number(number: int) -> String
integer_to_roman_number(1994) // "MCMXCIV"

func roman_number_to_integer(roman_number: String) -> int
roman_number_to_integer( "MCMXCIV") // 1994

func hexadecimal_to_decimal(hex: String) -> int:
hexadecimal_to_decimal("FF") // 255

func decimal_to_hexadecimal(decimal: int) -> String
decimal_to_hexadecimal(255) // "FF

value_is_between(number: int, min_value: int, max_value: int, inclusive: = true) -> bool

/**
if value_is_between(10, 5, 15) // True, Inclusive range (default)
	 // do stuff..

if value_is_between(15, 5, 15, false):  //False, not Inclusive range
	 // do stuff..
*/

func decimal_value_is_between(number: float, min_value: float, max_value: float, inclusive: = true, precision: float = 0.00001) -> bool


//Formats a number (integer or float) with comma separators for thousands. This improves readability for large numbers.
// If the absolute value of the number is less than 1000, it is simply converted to a string and returned without any modification
func add_thousand_separator(number, separator: String = ",") -> String:

add_thousand_separator(1000) // 1,000
add_thousand_separator(1000000) // 1,000,000
add_thousand_separator(9999448828) // 1,289,128,918,921
add_thousand_separator(1289128918921, ".") // 9.999.448.828

func big_round(num: int) -> int:

func random_byte() -> int

func logbi(x: int, base: int = 10) -> int

func logb(x: float, base: float = 10.0) -> float

func generate_random_seed(seed_range: int = 10) -> String
```

## BitStream 💠

The `OmniKitBitStream` class offers a powerful tool for working with data in a bit-oriented manner. It allows you to efficiently pack and unpack integer values and strings into a compact format, saving memory and potentially improving performance compared to traditional string storage.

The BitStream can be used in a lot of places, here we provide a super minimal example but if you understand the concept you can easily transmit a lot of data via network using bitstreams instead of plain text


```swift

var bits: Array
var current_bit = 0


//Packs an integer value (value) within a specified range (range_max) into the bit stream, converting it into individual bits.
func push(value: int, range_max: int)

 //Appends a single bit _(True or False)_ to the bit stream.
func push_bit(bit: bool)

// Reads and unpacks an integer value within a specified range (range_max) from the bit stream, interpreting the next num_bits as the value.
func pull(range_max:int)

//Convert the bit stream to and from a Godot string format for basic data exchange.
func to_godot_string(), from_godot_string(string: String)

//Prints a human-readable representation of the bit stream as a sequence of 0s and 1s for debugging.
func pprint():

//Convert the bit stream to and from a packed byte array for more advanced manipulation.
func to_byte_array() -> PackedByteArray
func from_byte_array(byte_array: PackedByteArray) -> Bitstream

//  Convert the bit stream to and from UTF-8 encoded text, allowing storage in a file or transmission over a network.
func to_utf8() -> String
func from_utf8(utf8_string: String) -> Bitstream

// Convert the bit stream to and from an ASCII string representation.
func to_ascii_string() -> String
func from_ascii_string(string: String) -> Bitstream

//  Reads a string of 0s and 1s and interprets it as a bit stream, initializing the internal data.
func from_string(string: String)
```


**Here's the Godot script code example using the OmniKitBitStream class for the multiplayer communication scenario:**

`Server-side`

```swift
extends Node

var clients = {}  // Dictionary to store BitStream instances for connected clients

func _on_player_connected(player_id):
	clients[player_id] = BitStream.new()

func _on_player_disconnected(player_id):
	clients.erase(player_id)

func _on_player_position_changed(player_id, position):
	var bitstream = clients[player_id]
	bitstream.push(position.x, 1024)
	bitstream.push(position.y, 512)
	// Send data to client (replace with your network communication method)
	var data = bitstream.to_byte_array()
	// ... send data to player_id ...

func _on_player_health_changed(player_id, health):
	var bitstream = clients[player_id]
	bitstream.push(health, 256)
	// Send data to client (replace with your network communication method)
	var data = bitstream.to_byte_array()
	// ... send data to player_id ..
```

`Client-Side`
```swift
extends Node

var server_bitstream = BitStream.new() // BitStream for receiving data from server

func _on_server_data_received(data):
	server_bitstream.from_byte_array(data)
	var player_x = server_bitstream.pull(1024)
	var player_y = server_bitstream.pull(512)
	var player_health = server_bitstream.pull(256)
	// Update player position and health based on received data
	// ... update
```

## UUID 🔑
The `OmniKitUUID` class in Godot provides a convenient way to generate and manage Universally Unique Identifiers *(UUIDs)*. These identifiers are strings of characters that are highly likely to be unique, making them useful for various purposes in your game development.

To generate a new `UUID` just use `OmniKitUUID.v4()` or if you want to provide a custom `RandomNumberGenerator` for deterministic results use `OmniKitUUID.v4_rng(RandomNumberGenerator.new())`

- **Unique Identification:** Generates random UUIDs that are statistically improbable to clash with existing ones.
- **Multiple Generation Options:** Offers two methods for creating UUIDs

**Benefits for Users:**

- ***Simplified Unique IDs:*** Assigning unique IDs to objects, resources, or network connections becomes easier.
- ***Reduced Errors:*** Less chance of conflicts arising from duplicate IDs.
- ***Flexibility:*** Choose between the standard generation method or provide a custom random number generator for specific needs.
- ***Easy Integration:*** Convert the UUID to a string for display or transmit it as a byte array for internal processing.

```swift
// Generates a version 4 UUID according to the standard format.
static func v4() -> String

// Allows you to provide a custom random number generator for more control over the generation process.
static func v4_rng(rng: RandomNumberGenerator) -> String

// Easily convert the generated UUID to a human-readable string format
func as_string()

//  Access the raw byte data of the UUID as an array
func as_array()

//  Check if two UUIDs are identical
func is_equal(other)
```

## VelocityHelper 👟

The `OmniKitVelocityHelper` class helps to work with units of measurement related to velocity.

The `velocity` vector can be passed as `float`, `Vector2`, `Vector2i`, `Vector3`, `Vector3i`

```swift
class_name OmniKitVelocityHelper

enum SpeedUnit {
	KilometersPerHour,
	MilesPerHour,
}

// It can receive a Vector2 & Vector3 as velocity and it will return the speed on the unit selected (Km or Miles)
static func current_speed_on(speed_unit: SpeedUnit, velocity: Variant) -> float:

// Alternatively, you can use the corresponding function for the desired velocity unit
static func current_speed_on_miles_per_hour(velocity: Variant) -> float:

static func current_speed_on_kilometers_per_hour(velocity: Variant) -> float:
```

## Nodes ⭕

This node helpers are static classes in Godot that acts as your toolbox for simplifying common node operations. It provides convenient methods to handle tasks you'd typically perform using native methods like `direction_to` and `distance_to`. However, offers a more user-friendly approach: instead of working directly with vectors, you can interact with nodes themselves.

Think of it as syntactic sugar – it sweetens the code by allowing you to reference nodes directly, making your code more readable and easier to maintain.


### Node Positioner
The `OmniKitNodePositioner` class helps to simplify operations related to position and distance between nodes.

```swift
static func mouse_grid_snap(node: Node2D, size: int, use_local_position: bool = false) -> Vector2

static func mouse_grid_snap_by_texture(sprite: Sprite2D, use_local_position: bool = false) -> Vector2


static func local_direction_to_v2(a: Node2D, b: Node2D) -> Vector2
static func local_direction_to_v3(a: Node3D, b: Node3D) -> Vector3

static func global_direction_to_v2(a: Node2D, b: Node2D) -> Vector2
static func global_direction_to_v3(a: Node3D, b: Node3D) -> Vector3

static func local_distance_to_v2(a: Node2D, b: Node2D) -> float
static func local_distance_to_v3(a: Node3D, b: Node3D) -> float

static func global_distance_to_v2(a: Node2D, b: Node2D) -> float
static func global_distance_to_v3(a: Node2D, b: Node2D) -> float

static func node_viewport_center_position(node: CanvasItem) -> Vector2

static func a_is_facing_b(a: Node3D, b: Node3D) -> bool

// Use on _process or _physic_process
static func rotate_toward_v2(from: Node2D, to: Node2D, lerp_weight: float = 0.5) -> void

// Use on _process or _physic_process
static func rotate_toward_v3(from: Node3D, to: Node3D, lerp_weight: float = 0.5) -> void:

//// This is mean to be used on physic_process to rotate smoothly replicating the look_at function
static func rotate_toward_direction_v3(node: Node3D, direction: Vector3, smooth_lerp_speed: float = 6.0) -> void

// Rotate towards the current mouse position without colliding a raycast in the world
static func rotate_toward_mouse_v3(node: Node3D) -> void

static func align_nodes_v2(from: Node2D, to: Node2D, align_position: bool = true, align_rotation: bool = true) -> void

static func align_nodes_v3(from: Node3D, to: Node3D, align_position: bool = true, align_rotation: bool = true) -> void


// These functions help you locate nodes within a specific distance range relative to a given point. The nodes in the array needs to inherit from Node2D or Node3D as they have global_position vectors in the world although these functions internally apply the necessary filters to only work with valid nodes.

// All this distance functions return a dictionary with two keys:
// -------
// - target: The nearest/farthest node found within the distance range (or null if none is found).
// - distance: The distance between the from point and the found node (or null if none is found).
// -------
static func get_nearest_node_by_distance_v2(from: Vector2, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Dictionary

static func get_farthest_node_by_distance_v2(from: Vector2, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Dictionary

static func get_nearest_nodes_sorted_by_distance_v2(from: Vector2, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Array


static func get_nearest_node_by_distance_v3(from: Vector3, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Dictionary

static func get_farthest_node_by_distance_v3(from: Vector3, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Dictionary

static func get_nearest_nodes_sorted_by_distance_v3(from: Vector3, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Array
```

### Node Traversal
The `OmniKitNodeTraversal` class helps to simplify operations related to traverse the `SceneTree`.

```swift
// Useful when you need to add a node in the scene tree in your @tool scripts.
// It checks for you if the Engine.is_editor_hint()
static func set_owner_to_edited_scene_root(node: Node) -> void

// Create a PackedScene from the selected node, perfect if you want to use Resource as saves
static func create_scene_from(root_node: Node) -> PackedScene:

static func get_all_children(from_node: Node) -> Array:
static func get_all_ancestors(from_node: Node) -> Array:

//Only works for native nodes that Godot provides like Area2D, Camera2D, etc.
//Example NodePositioner.find_nodes_of_type(self, Sprite2D.new())
static func find_nodes_of_type(node: Node, type_to_find: Node) -> Array
static func first_node_of_type(node: Node, type_to_find: Node) -> Array

// Only works for native custom class not for GDScriptNativeClass
// Example NodePositioner.find_nodes_of_custom_class(self, MachineState)
static func find_nodes_of_custom_class(node: Node, class_to_find: Variant) -> Array:
static func first_node_of_custom_class(node: Node, class_to_find: GDScript):


// Get the tree depth from a node so you can know how deep is on the current scene.
static func get_tree_depth(node: Node) -> int

static func get_absolute_z_index(node: Node2D) -> int

// This function simplifies your life by grabbing the first child node from a parent node, just like picking the firsts item from a list.
static func get_first_child(node: Node):

// This function simplifies your life by grabbing the last child node from a parent node, just like picking the last item from a list.
static func get_last_child(node: Node)

static func first_child_node_in_group(node: Node, group: String)

static func hide_nodes(nodes: Array[Node] = []) -> void
static func show_nodes(nodes: Array[Node] = []) -> void

static func add_all_childrens_to_group(node: Node, group: String, filter: Array[Node] = []) -> void
static func remove_all_childrens_from_group(node: Node, group: String, filter: Array[Node] = []) -> void:

static func add_meta_to_all_children(node: Node, meta: String, value: Variant, filter: Array[Node] = []) -> void
static func remove_meta_from_all_children(node: Node, meta: String) -> void
```

### Node Remover

The `OmniKitNodeRemover` class helps to simplify operations related to node removal

```swift
// Detects if a node is valid and is not queued for deletion
static func is_node_valid(node: Node) -> bool:

// A safe function to remove only valid nodes
func remove(node: Node) -> void

// This functions help you declutter your scene by removing all child nodes from a parent node. They handle the cleanup process efficiently, so you don't have to write repetitive code.
// --- Exceptions are passed as [Area3D.new().get_class) ---
func remove_and_queue_free_children(node: Node) -> void

func queue_free_children(node: Node) -> void

func free_children(node: Node, except: Array = []) -> void:

```