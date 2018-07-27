#!/bin/bash
set -e

printf "\r\nNOTICE : Initializing Mule ESB Runtime container...\r\n"

# if override default is set to true, it will not load the default resources
if [[ "${MULE_ENV_OVERRIDE_DEFAULT}" == "0" ]]; then
	
	# if mule-archive exists, then reload the default domain, app, and config
	if [ -d "${MULE_HOME}-archive" ]; then
	
		rm -rf ${MULE_HOME}/apps/default
		mkdir ${MULE_HOME}/apps/default

		
		
		if [ -d "${MULE_HOME}-archive/apps/default/mule" ]; then

			printf "\r\nNOTICE : Copying default mule app..."
			mkdir ${MULE_HOME}/apps/default/mule
			cp ${MULE_HOME}-archive/apps/default/mule/*.* ${MULE_HOME}/apps/default/mule/
		else
			#cp ${MULE_HOME}-archive/apps/default/*.* ${MULE_HOME}/apps/default/
			# do nothing
			# force remove default app if it exists
			rm -rf ${MULE_HOME}/apps/default/
			printf "\r\nNOTICE : No default mule app found..."
		fi

		if [ -d "${MULE_HOME}/domains/default" ]; then 
			printf "\r\nNOTICE : default domain found... skipping..."
		else

			printf "\r\nNOTICE : No default domain found..."

			if [ -d "${MULE_HOME}-archive/domains/default" ]; then
				printf "\r\nNOTICE : Configuring default domain..."
				mkdir ${MULE_HOME}/domains/default
			fi

			printf "done.\r\n"
		fi

		printf "\r\nNOTICE : Copying default configurations..."
		cp ${MULE_HOME}-archive/conf/* ${MULE_HOME}/conf/
		printf "done.\r\n"
		
		if [ -f "${MULE_HOME}-archive/conf/license.lic" ]; then
		
			# just remove the existing muleLicenseKey.lic
			rm -rf conf/muleLicenseKey.lic
			
		elif [ -f "${MULE_HOME}-archive/conf/mule-ee-license.lic" ]; then
		
			# just remove the existing muleLicenseKey.lic
			rm -rf conf/muleLicenseKey.lic
		else 
			if [ -f "${MULE_HOME}-archive/conf/.lic-mule" ]; then
				cp ${MULE_HOME}-archive/conf/.lic-mule ${MULE_HOME}/conf
			fi
		fi
				
		cp ${MULE_HOME}-archive/logs/* ${MULE_HOME}/logs
		
		# remove the template
		rm -rf ${MULE_HOME}-archive
		cp /opt/mmc_setup ${MULE_HOME}/bin/
		rm -rf cp /opt/mmc_setup
		chmod +x ${MULE_HOME}/bin/mmc_setup
		
		# create a link to mmc_setup
		ln -s /opt/mule/bin/mmc_setup /usr/local/bin/mmc_setup
		

	fi
fi

# Configure Mule Enterprise License if edition is set to enterprise

if [ -f ${MULE_HOME}/conf/wrapper-license.conf ]; then
	printf "\r\nNOTICE : Looking for enterprise license...\r\n"
	# if mule-ee-license.lic exists, it will install it.
	if [ -f ${MULE_HOME}/conf/mule-ee-license.lic ]; then
	
		rm -rf conf/muleLicenseKey.lic && \
		bin/mule -installLicense conf/mule-ee-license.lic && \
		printf "\r\nNOTICE : Enterprise license found and installed (mule-ee-license.lic)...\r\n"	
		
	elif [ -f ${MULE_HOME}/conf/license.lic ]; then
	
		rm -rf conf/muleLicenseKey.lic && \
		bin/mule -installLicense conf/license.lic && \
		printf "\r\nNOTICE : Enterprise license found and installed (license.lic)...\r\n"	

	else
		if [ ! -f ${MULE_HOME}/conf/muleLicenseKey.lic ]; then
			printf "\r\nWARNING : license not found, Mule enterprise will run in trial mode.\r\n"
		else
		
			printf "\r\nNOTICE : Verifying enterprise license...\r\n" && rm -rf ${MULE_HOME}/conf/.lic-mule && ${MULE_HOME}/bin/mule -verifyLicense && printf "done.\r\n"
		fi
		
	fi
	printf "\r\nNOTICE : Starting up Mule ESB Enterprise Edition...\r\n"
else
	printf "\r\nNOTICE : Starting up Mule ESB Community Edition...\r\n"
	
fi

# if patches directory exist and its not empty, then copy the contents of it to ${MULE_HOME}/lib/user, every time mule container starts

if [ -d "${MULE_HOME}/patches" ]; then
	if [ "$(ls -A ${MULE_HOME}/patches)" ]; then
		cp ${MULE_HOME}/patches/*.* ${MULE_HOME}/lib/user/
	fi
fi

if [ -d "${MULE_HOME}/tools/" ]; then

	if [ ! -f "${MULE_HOME}/conf/mule-agent.jks" ]; then

		if [[ "${MULE_ARM_TOKEN}" != "" ]]; then	

			if [[ "${MULE_ARM_NAME}" == "" ]]; then
				# generate MULE_ESB_NAME to use
				if [[ "${MULE_ESB_NAME}" == "" ]]; then
					MULE_ESB_NAME=MULE-ESB-$(date +%s000)-${MULE_RUNTIME}
				fi
			else
				# set MULE_ESB_NAME to use
				MULE_ESB_NAME=${MULE_ARM_NAME}
			fi

			echo "NOTICE: Configuring Mule Agent to Anypoint Management Center, registered as ${MULE_ESB_NAME}..."
			${MULE_HOME}/bin/amc_setup -H ${MULE_ARM_TOKEN} ${MULE_ESB_NAME}
		fi		
	else
		echo "NOTICE: Mule Agent running and was registered as ${MULE_ESB_NAME}..."
	fi
else
	echo "WARNING: No sufficient data for configuring Mule Agent... skipping ARM registration."
fi

# start Mule ESB Runtime
${MULE_HOME}/bin/mule $MULE_STARTUP_ENV_CONFIG -M-Dmule.config.path=$MULE_HOME/conf/$APP_CONFIG_PATH -M-Dmule.env=$MULE_ENV -M-Dmule.mmc.bind.port=$MULE_MMC_AGENT_PORT