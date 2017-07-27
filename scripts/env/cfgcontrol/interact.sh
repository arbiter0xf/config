print_help_and_exit() {
	echo "Usage: cfgcontrol [OPTION] ACTION"
	echo "Share configuration files between multiple machines."
	echo ""
	echo "===== OPTIONS ====="
	echo "-d, --debug         print debug messages when running"
	echo "-h, --help          print this help text"
	echo ""
	echo "===== ACTIONS ====="
	echo "clean               Remove backups of local configuration files."
	echo "                    Backups are generated when using the ${bold}"
	echo "                    pull${normal} action."
	echo "push                Use files on local machine in replacing of"
	echo "                    files in projects configuration directory."
	echo "pull                Use files from projects configuration"
	echo "                    directory in replacing of files used on local"
	echo "                    machine. By default backups are made from"
	echo "                    files on local machine before replacing them."
	echo "sync                Update list of project & local configuration"
	echo "                    file pairs. Files found from scripts"
	echo "                    configuration directory which begin with"
	echo "                    dot \".\" are added to the list. Files of"
	echo "                    identical name are searched under users home"
	echo "                    directory."
	echo ""
	echo "===== FILES ====="
	echo "$config_list_file"
	echo "    List of project & local configuration. Used in ${bold}pull"
	echo "    ${normal} and ${bold}push${normal} actions to find out which"
	echo "    files are considered to be the local equivalents of files in"
	echo "    configuration directory of project."
	echo ""
	echo "===== DIRECTORIES ====="
	echo "$config_dir"
	echo "    Configuration directory of project. Contains the files"
	echo "    intended to be shared with other machines. Add copies of new"
	echo "    configuration files here."
 
	exit 0
}

get_yes_no() {
	local prompt=$1
	local answer=""

	while [ 1 ] ; do
		read -p "$prompt [y/n] " answer

		if [ "y" == "$answer" -o "n" == "$answer" ] ; then
			break
		fi
	done

	echo $answer
}
