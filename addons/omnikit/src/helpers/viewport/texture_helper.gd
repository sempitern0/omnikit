class_name OmniKitTextureHelper

static var ImageFormatSignatures: Dictionary[String, Array] = {
	"png": [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
	"jpg": [0xFF, 0xD8, 0xFF],
	"jpeg": [0xFF, 0xD8, 0xFF],
	"webp": [0x52, 0x49, 0x46, 0x46, null, null, null, null, 0x57, 0x45, 0x42, 0x50], ## Ignore byte size with null
	"bmp": [0x42, 0x4D],
	"tga": [0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
	"svg": [0x3C, 0x73, 0x76, 0x67], ## <svg bytes
	"svg_xml": [0x3C, 0x3F, 0x78, 0x6D, 0x6C], ## <?xml bytes
}

static func detect_image_format_from_bytes(data: PackedByteArray) -> String:
	if data.size() < 12:
		return ""
	
	for format: String in ImageFormatSignatures:
		var signature = ImageFormatSignatures[format]
		var is_match = true
		
		for index: int in signature.size():
			if signature[index] == null:  
				continue
				
			if index >= data.size() or data[index] != signature[index]:
				is_match = false
				break
		
		if is_match:
			
			if format.begins_with("svg"):
				return "svg"
				
			return format
	
	return ""
	
	
static func load_image_from_buffer(data: PackedByteArray) -> Image:
	var image: Image = Image.new()
	var format: String = detect_image_format_from_bytes(data)
	
	match format:
		"png":
			image.load_png_from_buffer(data)
		"jpg", "jpeg":
			image.load_jpg_from_buffer(data)
		"bmp":
			image.load_bmp_from_buffer(data)
		"webp":
			image.load_webp_from_buffer(data)
		"tga":
			image.load_tga_from_buffer(data)
		"svg":
			image.load_svg_from_buffer(data)
	
	return image


static func center_texture_rect_pivot(texture_rect: TextureRect) -> TextureRect:
	if texture_rect.texture:
		texture_rect.pivot_offset = (texture_rect.texture.get_size() / 2).ceil()
	else:
		push_warning("OmniKitTextureHelper::center_texture_rect_pivot -> The texture rect %s does not have a texture" % texture_rect.name)
	return texture_rect


static func get_texture_dimensions(texture: Texture2D) -> Rect2i:
	return texture.get_image().get_used_rect()
	
	
static func get_texture_rect_dimensions(texture_rect: TextureRect) -> Vector2:
	var texture: Texture2D = texture_rect.texture
	var used_rect: Rect2i = get_texture_dimensions(texture)
	var texture_dimensions: Vector2 = Vector2(used_rect.size) * texture_rect.scale

	return texture_dimensions


static func get_sprite_dimensions(sprite: Sprite2D) -> Vector2:
	var texture: Texture2D = sprite.texture
	var used_rect: Rect2i = get_texture_dimensions(texture)
	var sprite_dimensions: Vector2 = Vector2(used_rect.size) * sprite.scale

	return sprite_dimensions


static func get_png_rect_from_texture(texture: Texture2D) -> Rect2i:
	var image: Image = texture.get_image()
	
	assert(image != null and image is Image, "OmniKitTextureHelper::get_png_rect_from_texture -> The image from the texture is null, the texture it's invalid")
	
	var top_position: int = image.get_height()
	var bottom_position: int = 0
	
	var right_position: int = image.get_width()
	var left_position: int = 0
	
	for x in image.get_width():
		for y in image.get_height():
			var pixel_color: Color = image.get_pixel(x, y)
			
			if pixel_color.a:
				if top_position > y:
					top_position = y
					
				if bottom_position < y:
					bottom_position = y
				
				if right_position > x:
					right_position = x
					
				if left_position < x:
					left_position = x
	
	var position: Vector2i = Vector2i(left_position - right_position,  bottom_position - top_position)
	var size: Vector2i = Vector2i(right_position + roundi(position.x / 2.0),  top_position + roundi(position.y / 2.0))
	
	return Rect2i(position, size)


func get_colors_from_image(image: Image) -> PackedColorArray:
	var colors: OmniKitHashSet = OmniKitHashSet.new()
	
	for x in image.get_width():
		for y in image.get_height():
			var pixel_color: Color = image.get_pixel(x, y)
			colors.add(Color(pixel_color.to_html()))
	
	return PackedColorArray(colors.values)
	

func get_colors_from_texture(texture: Texture2D) -> PackedColorArray:
	return get_colors_from_image(texture.get_image())
