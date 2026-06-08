@tool
extends MarginContainer
class_name TextureArrayCreatorDock

@export var select_files_btn : Button
@export var create_array_btn : Button
@export var save_btn : Button
@export var clear_btn : Button

@export var preview_array_holder : BoxContainer
@export var selected_filenames_holder : BoxContainer

@export var open_files_dialog : FileDialog
@export var save_dialog : FileDialog

var selected_imgs : Array[Image]
var created_texture_2d_array : Texture2DArray

func _ready() -> void:
	open_files_dialog.file_selected.connect(add_selected_img)
	save_dialog.file_selected.connect(save_texture_2d_array)
	
	select_files_btn.pressed.connect(prompt_select_files)
	create_array_btn.pressed.connect(create_texture_2d_array)
	save_btn.pressed.connect(prompt_save_file)
	clear_btn.pressed.connect(clear_all)

func clear_all():
	selected_imgs.clear()
	created_texture_2d_array = null
	
	for child in preview_array_holder.get_children():
		child.queue_free()
	
	for child in selected_filenames_holder.get_children():
		child.queue_free()

func prompt_select_files():
	open_files_dialog.show()

func prompt_save_file():
	save_dialog.show()

func add_selected_img(path : String):
	var loaded_resource_texture : Texture2D = load(path) as Texture2D
	if loaded_resource_texture == null:
		push_warning("Not a Texture2D. Skipping.")
		return
	
	selected_imgs.append(loaded_resource_texture.get_image())
	
	var filename_label : Label = Label.new()
	filename_label.text = path
	selected_filenames_holder.add_child(filename_label)

func create_texture_2d_array():
	var new_t2d_array = Texture2DArray.new()
	var err = new_t2d_array.create_from_images(selected_imgs)
	print(err)
	created_texture_2d_array = new_t2d_array
	var layers = created_texture_2d_array.get_layers()
	
	for child in preview_array_holder.get_children():
		child.queue_free()
	
	for layer in range(layers):
		var text_rect = TextureRect.new()
		text_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		text_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		text_rect.custom_minimum_size = Vector2(32.0,32.0)
		text_rect.texture = ImageTexture.create_from_image(created_texture_2d_array.get_layer_data(layer))
		print(text_rect.texture)
		preview_array_holder.add_child(text_rect)

func save_texture_2d_array(save_path):
	ResourceSaver.save(created_texture_2d_array, save_path, ResourceSaver.FLAG_COMPRESS)
