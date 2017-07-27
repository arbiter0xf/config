assert_str() {
	local under_test=$1
	local wanted=$2
	local err_text=$3

	if [ "$under_test" != "$wanted" ] ; then
		exit_with_error "$err_text"
	fi
}

assert_dir() {
	local dir=$1
	local err_text=$2

	if [ ! -d "$dir" ] ; then
		exit_with_error "$err_text"
	fi
}

assert_file() {
	local file=$1
	local err_text=$2

	if [ ! -f "$file" ] ; then
		exit_with_error "$err_text"
	fi
}

exit_with_error() {
	local err_text=$1

	echo -e "[ ERROR ] $err_text"
	echo "Stopping..."
	exit 1
}
