     .model small
.stack 100h
.data
    ; Giriþ mesajlarý
    gaz_msg        db 13, 10, 'Gaz degerini girin (0-255 ppm): $'
    isi_msg        db 13, 10, 'Sicaklik degerini girin (0-255 C): $'
    ; Eþik deðerleri
    gaz_threshold  db 100       ; Gaz eþik deðeri (ppm)
    isi_threshold  db 60        ; Sýcaklýk eþik deðeri (°C)
    ; Uyarý mesajlarý
    alarm_msg      db 13, 10, '[!] YANGIN RISKI: Hem gaz hem sicaklik yuksek!', 13, 10, '$'
    gaz_alarm_msg  db 13, 10, '[!] UYARI: Gaz seviyesi yuksek', 13, 10, '$'
    isi_alarm_msg  db 13, 10, '[!] UYARI: Sicaklik yuksek', 13, 10, '$'
    normal_msg     db 13, 10, '[+] Sistem normal calisiyor', 13, 10, '$'
    log_msg        db 13, 10, '--- Sistem logu ---', 13, 10, '$'
    ; Deðerler
    gaz_value      db ?
    isi_value      db ?
.code
start:
    mov ax, @data
    mov ds, ax
    ; Sistem baþlangýç logu
    mov dx, offset log_msg
    call print_string
    ; Gaz deðerini al
    mov dx, offset gaz_msg
    call print_string
    call get_number
    mov gaz_value, al
    ; Sýcaklýk deðerini al
    mov dx, offset isi_msg
    call print_string
    call get_number
    mov isi_value, al
    ; Kontrolleri yap
    call check_thresholds
    ; Programý sonlandýr
    mov ah, 4ch
    int 21h
; --------------------------------------
; Eþik deðerlerini kontrol et
check_thresholds:
    ; Gaz kontrolü
    mov al, gaz_value
    cmp al, gaz_threshold
    ja gaz_alarm
    ; Sýcaklýk kontrolü
    mov al, isi_value
    cmp al, isi_threshold
    ja isi_alarm
    ; Her iki deðer de normal
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
    ; Ayrýca her iki uyarýyý da göster
    call gaz_alarm
    call isi_alarm
    ret
; --------------------------------------
; Ekrana yazý yaz (DX'de adres)
print_string:
    mov ah, 09h
    int 21h
    ret
; --------------------------------------
; Klavyeden 0-255 arasý sayý al (AL'ye döner)
get_number:
    push bx
    push cx
    xor bx, bx   ; BH=0 (sayý), BL=0 (basamak sayacý)
    
get_digit:
    mov ah, 01h   ; Karakter giriþi
    int 21h
    cmp al, 13    ; Enter tuþu
    je end_input
    ; ASCII rakam kontrolü
    cmp al, '0'
    jb get_digit
    cmp al, '9'
    ja get_digit
    ; Rakamý iþle
    sub al, '0'   ; ASCII'den sayýya çevir
    mov cl, al
    mov al, bh
    mov ch, 10
    mul ch        ; AL = AL * 10
    add al, cl    ; Yeni rakamý ekle
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
