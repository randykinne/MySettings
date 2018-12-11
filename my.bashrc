#!/usr/bin/env bash

prompt_git() {
	local s='';
	local branchName='';

	# Check if the current directory is in a Git repository.
	if [ $(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}") == '0' ]; then

		# check if the current directory is in .git before running git checks
		if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then

			# Ensure the index is up to date.
			git update-index --really-refresh -q &>/dev/null;

			# Check for uncommitted changes in the index.
			if ! $(git diff --quiet --ignore-submodules --cached); then
				s+='+';
			fi;

			# Check for unstaged changes.
			if ! $(git diff-files --quiet --ignore-submodules --); then
				s+='!';
			fi;

			# Check for untracked files.
			if [ -n "$(git ls-files --others --exclude-standard)" ]; then
				s+='*';
			fi;

			# Check for stashed files.
			if $(git rev-parse --verify refs/stash &>/dev/null); then
				s+='$';
			fi;

		fi;

		# Get the short symbolic ref.
		# If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
		# Otherwise, just give up.
		branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
			git rev-parse --short HEAD 2> /dev/null || \
			echo '(unknown)')";

		[ -n "${s}" ] && s="${s}";

		echo -e "${1}${branchName}${2}${s}";
	else
		return;
	fi;
}

if tput setaf 1 &> /dev/null; then
	tput sgr0; # reset colors
	bold=$(tput bold);
	reset=$(tput sgr0);
	# Solarized colors, taken from http://git.io/solarized-colors.
	black=$(tput setaf 0);
	blue=$(tput setaf 33);
	cyan=$(tput setaf 37);
	green=$(tput setaf 64);
	orange=$(tput setaf 166);
	purple=$(tput setaf 125);
	red=$(tput setaf 124);
	violet=$(tput setaf 61);
	white=$(tput setaf 15);
	yellow=$(tput setaf 136);
	pink=$(tput setaf 161);
	light_pink=$(tput setaf 135);
	light_yellow=$(tput setaf 228);
	light_blue=$(tput setaf 81);
	light_green=$(tput setaf 118);
	magenta=$(tput setaf 199);
	gray=$(tput setaf 242);
else
	bold='';
	reset="\e[0m";
	black="\e[1;30m";
	blue="\e[1;34m";
	cyan="\e[1;36m";
	green="\e[1;32m";
	orange="\e[1;33m";
	purple="\e[1;35m";
	red="\e[1;31m";
	violet="\e[1;35m";
	white="\e[1;37m";
	yellow="\e[1;33m";

fi;
# pink=$(tput setaf 161);
# yellow=$(tput setaf 228);
# orange=$(tput setaf 166);
# green=$(tput setaf 83);
# white=$(tput setaf 15);
# bold=$(tput bold);
# reset=$(tput sgr0);

# Highlight the user name when logged in as root.
if [[ "${USER}" == "root" ]]; then
	userStyle="${light_blue}";
else
	userStyle="${orange}";
fi;

# Highlight the hostname when connected via SSH.
if [[ "${SSH_TTY}" ]]; then
	hostStyle="${bold}${pink}";
else
	hostStyle="${yellow}";
fi;

PS1="\[${bold}\]";
PS1+="\[${pink}\]\u"; #username
PS1+="\[${reset}\]";
PS1+="\[${white}\] at "; #at
PS1+="\[${bold}\]";
PS1+="\[${light_green}\]\h"; #host
PS1+="\[${reset}\]";
PS1+="\[${white}\] in ";
PS1+="\[${bold}\]";
PS1+="\[${light_blue}\]\w"; #working directory
PS1+="\[${reset}\]";
PS1+="\$(prompt_git \"\[${white}\] on \[${bold}\]\[${light_pink}\]\"\"\[${light_pink}\]\")"; # Git repository details
PS1+="\n";
PS1+="\[${white}\]\$ \[${reset}\]"; #'$' (and reset color)
export PS1;
