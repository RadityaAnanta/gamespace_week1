extends CanvasLayer

func _ready():
	# Sembunyikan menu saat game baru dimulai
	hide() 

# Fungsi untuk mendeteksi tombol ESC (atau tombol back di HP)
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

# Logika untuk menghentikan waktu game
func toggle_pause():
	var is_paused = get_tree().paused
	get_tree().paused = !is_paused
	
	# Munculkan atau sembunyikan CanvasLayer ini
	visible = !is_paused


# Fungsi untuk tombol "Lanjut Main / Resume"
func _on_button_pressed() -> void:
	print("TOMbol LANJUT BERHASIL DIKLIK!") 
	toggle_pause() # <-- Panggil fungsi untuk melanjutkan game


# Fungsi untuk tombol "Keluar / Quit"
func _on_button_2_pressed() -> void:
	print("TOMBOL KELUAR BERHASIL DIKLIK!") 
	get_tree().quit() # <-- Perintah untuk keluar dari game
