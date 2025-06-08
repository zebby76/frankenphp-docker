#!/usr/bin/env bash
# shellcheck disable=SC1090

if [ -d /opt/bin/container-entrypoint.d/entrypoint.d ]; then

	for FILE in $(find /opt/bin/container-entrypoint.d/entrypoint.d -iname \*.sh | sort); do
		source ${FILE}
	done

fi

true
