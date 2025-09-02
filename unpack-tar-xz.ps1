$name = $args[0]
$dst = $args[1]
& "C:\Program Files\7-Zip\7z.exe" x "$name.tar.xz" "$name.tar"
& "C:\Program Files\7-Zip\7z.exe" x "$name.tar" "$name"
Rename-Item -Path "$name" -NewName "$dst"
