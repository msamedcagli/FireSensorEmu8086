     .model small
.stack 100h
.data
    ; Giri� mesajlar�
    gaz_msg        db 13, 10, 'Gaz degerini girin (0-255 ppm): $'
    isi_msg        db 13, 10, 'Sicaklik degerini girin (0-255 C): $'
    ; E�ik de�erleri
    gaz_threshold  db 100       ; Gaz e�ik de�eri (ppm)
    isi_threshold  db 60        ; S�cakl�k e�ik de�eri (�C)
    ; Uyar� mesajlar�
    alarm_msg      db 13, 10, '[!] YANGIN RISKI: Hem gaz hem sicaklik yuksek!', 13, 10, '$'
    gaz_alarm_msg  db 13, 10, '[!] UYARI: Gaz seviyesi yuksek', 13, 10, '$'
    isi_alarm_msg  db 13, 10, '[!] UYARI: Sicaklik yuksek', 13, 10, '$'
    normal_msg     db 13, 10, '[+] Sistem normal calisiyor', 13, 10, '$'
    log_msg        db 13, 10, '--- Sistem logu ---', 13, 10, '$'
    ; De�erler
    gaz_value      db ?
    isi_value      db ?
.code
start:
    mov ax, @data
    mov ds, ax
    ; Sistem ba�lang�� logu
    mov dx, offset log_msg
    call print_string
    ; Gaz de�erini al
    mov dx, offset gaz_msg
    call print_string
    call get_number
    mov gaz_value, al
    ; S�cakl�k de�erini al
    mov dx, offset isi_msg
    call print_string
    call get_number
    mov isi_value, al
    ; Kontrolleri yap
    call check_thresholds
    ; Program� sonland�r
    mov ah, 4ch
    int 21h
; --------------------------------------
; E�ik de�erlerini kontrol et
check_thresholds:
    ; Gaz kontrol�
    mov al, gaz_value
    cmp al, gaz_threshold
    ja gaz_alarm
    ; S�cakl�k kontrol�
    mov al, isi_value
    cmp al, isi_threshold
    ja isi_alarm
    ; Her iki de�er de normal
    mov dx, offset normal_msg
    call print_string
    ret
gaz_alarm:
    mov al, isi_value
    cmp al, isi_threshold
    ja fire_alarm
    mov dx, offset gaz_alarm_msg
    call print_string
    ret
isi_alarm:
    mov dx, offset isi_alarm_msg
    call print_string
    ret
fire_alarm:
    mov dx, offset alarm_msg
    call print_string
    ; Ayr�ca her iki uyar�y� da g�ster
    call gaz_alarm
    call isi_alarm
    ret
; --------------------------------------
; Ekrana yaz� yaz (DX'de adres)
print_string:
    mov ah, 09h
    int 21h
    ret
; --------------------------------------
; Klavyeden 0-255 aras� say� al (AL'ye d�ner)
get_number:
    push bx
    push cx
    xor bx, bx   ; BH=0 (say�), BL=0 (basamak sayac�)
    
get_digit:
    mov ah, 01h   ; Karakter giri�i
    int 21h
    cmp al, 13    ; Enter tu�u
    je end_input
    ; ASCII rakam kontrol�
    cmp al, '0'
    jb get_digit
    cmp al, '9'
    ja get_digit
    ; Rakam� i�le
    sub al, '0'   ; ASCII'den say�ya �evir
    mov cl, al
    mov al, bh
    mov ch, 10
    mul ch        ; AL = AL * 10
    add al, cl    ; Yeni rakam� ekle
    mov bh, al
    inc bl
    cmp bl, 3     ; Maksimum 3 basamak
    jb get_digit
end_input:
    mov al, bh    ; Sonucu AL'ye al
    pop cx
    pop bx
    ret
end start
