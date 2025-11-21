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