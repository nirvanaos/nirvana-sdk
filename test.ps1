if ($args.count -ge 1) {
	$platform = $args[0]
} else {
	$platform = "x64"
}

ctest --preset=$platform-debug
ctest --preset=$platform-release
