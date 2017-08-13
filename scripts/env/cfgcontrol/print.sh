print_help_and_exit() {
	cat <<EOF

Usage: cfgcontrol [OPTION] ACTION

Copy configuration files to/from dedicated configuration directory.

===== OPTIONS =====
-d, --debug	print debug messages when running
-h, --help	print this help text

===== ACTIONS =====
clean		Remove backups of local configuration files. Backups are
		generated when using the ${bold} pull${normal} action.
push		Use files on local machine in replacing of files in projects
		configuration directory.
pull		Use files from projects configuration directory in replacing
		of files used on local machine. By default backups are made
		from files on local machine before replacing them.
sync		Update list of project & local configuration file pairs. Files
		found from scripts configuration directory which begin with
		dot "." are added to the list. Files of identical name are
		searched under users home directory.

===== FILES =====
$config_list_file
	List of project & local configuration. Used in ${bold}pull ${normal}
	and ${bold}push${normal} actions to find out which files are
	considered to be the local equivalents of files in configuration
	directory of project.

===== DIRECTORIES =====
$config_dir
	Configuration directory of project. Contains the files intended to be
	shared with other machines. Add copies of new configuration files
	here.
EOF

	exit 0
}

tell_about_backing_local_configs() {
	cat <<EOF
Backups of local configs have been written to $cfgcontrol_dir/backup

Running ${bold}cfgcontrol clean${normal} will remove all backups from
$cfgcontrol_dir/backup
EOF
}

common_paths_not_found_print() {

# Needed files are not sourced at this point of execution. Thus i.e. bold
# variable can't be used.

	cat <<EOF

[ ERROR ] Include file common_paths.sh not found.

Running configure script of useful-files should generate this file. cfgcontrol
is expected to be ran by using file found from bin/ directory of useful-files.
EOF
}
