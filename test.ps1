if ($args.count -ge 1) {
	$platform = $args[0]
} else {
	$platform = "x64"
}
if ($args.count -ge 2) {
	$config = $args[1]
} else {
	$config = "Debug"
}

$build_dir = "$PWD\build\$platform\nirvana\$config"

ctest --test-dir "$build_dir"
