#!/bin/bash
set -e

# VARIABLES ###################################################

# set the mule repo url. To build locally, these variables needs to be set manually.

#MULE_RUNTIME_VERSION=$(cat /opt/VERSION)
MULE_RUNTIME_VERSION="4.1.2"
#MULE_EDITION=$(cat /opt/EDITION)
MULE_EDITION="ee"
AUTHORIZATION=$(cat /opt/AUTHORIZATION)
MULE_AGENT_UPDATE_VERSION=$(cat /opt/MULE_AGENT_UPDATE_VERSION)
MULE_AGENT_UPDATE_URL_SECOND=$(cat /opt/MULE_AGENT_UPDATE_URL_SECOND)
MULE_BUILD_ERROR=false
# END VARIABLES ###############################################

# runtime version not specified?
if [[ ${MULE_RUNTIME_VERSION} == '' ]]; then
	echo "MULE_RUNTIME_VERSION environment variable is missing";
	MULE_BUILD_ERROR=true
fi

if [[ ${MULE_EDITION} == '' ]]; then
	echo "MULE_EDITION environment variable is missing";
	MULE_BUILD_ERROR=true
fi

if [[ ${AUTHORIZATION} == '' ]]; then
	echo "AUTHORIZATION environment variable is missing";
	MULE_BUILD_ERROR=true
fi


if [[ ${AUTHORIZATION} == true ]]; then
	echo "Container stopped building!";
	exit;
fi

MULE_HOME=/opt/mule

echo "--${MULE_EDITION}-${CI_BUILD_REF_NAME}-${MULE_RUNTIME_VERSION}--"

if [[ ${MULE_EDITION} == 'ee' ]]; then

	MULE_RUNTIME_PACKAGE=mule-ee-distribution-standalone
	MULE_RUNTIME_UNPACKED_NAME=mule-enterprise-standalone-${MULE_RUNTIME_VERSION}
	MULE_RUNTIME=${MULE_RUNTIME_PACKAGE}-${MULE_RUNTIME_VERSION}
	MULE_PACKAGE_REPOSITORY_URL_MAIN=https://repository.mulesoft.org/nexus/content/repositories/releases-ee/com/mulesoft/muleesb/distributions/
	MULE_PACKAGE_REPOSITORY_URL_SEC=https://repository.mulesoft.org/nexus/content/repositories/releases-ee/com/mulesoft/mule/distributions/
	MULE_PACKAGE_EXT=zip
	MULE_EXTRACT_CMD=unzip
	# 3.x.x -> https://repository.mulesoft.org/nexus/content/repositories/releases-ee/com/mulesoft/muleesb/distributions/
	# MULE 4.0 -> https://repository.mulesoft.org/nexus/content/repositories/releases-ee/com/mulesoft/mule/distributions/
	# MULE_PACKAGE_REPOSITORY_URL=${MULE_PACKAGE_MASTER_REPO_URL}${MULE_RUNTIME_PACKAGE}/${MULE_RUNTIME_VERSION}/${MULE_RUNTIME_PACKAGE}-${MULE_RUNTIME_VERSION}.zip	
	
	if [ ! -f /opt/${MULE_RUNTIME_PACKAGE}-${MULE_RUNTIME_VERSION}.${MULE_PACKAGE_EXT} ]; then
		echo "Fetching Mule Runtime Enterprise Edition..."

		if curl --header "Authorization: Basic ${AUTHORIZATION}" --output /dev/null --silent --head --fail "${MULE_PACKAGE_REPOSITORY_URL_MAIN}${MULE_RUNTIME_PACKAGE}/${MULE_RUNTIME_VERSION}/"
		then
		    echo "Package exists..."
		    MULE_PACKAGE_REPOSITORY_URL=${MULE_PACKAGE_REPOSITORY_URL_MAIN}${MULE_RUNTIME_PACKAGE}/${MULE_RUNTIME_VERSION}/${MULE_RUNTIME_PACKAGE}-${MULE_RUNTIME_VERSION}.${MULE_PACKAGE_EXT}
		else
		    echo "Checking alternative source..."
		    MULE_PACKAGE_EXT=tar.gz
		    MULE_PACKAGE_REPOSITORY_URL=${MULE_PACKAGE_REPOSITORY_URL_SEC}${MULE_RUNTIME_PACKAGE}/${MULE_RUNTIME_VERSION}/${MULE_RUNTIME_PACKAGE}-${MULE_RUNTIME_VERSION}.${MULE_PACKAGE_EXT}

		fi	
			
		cd /opt && wget --header "Authorization: Basic ${AUTHORIZATION}" ${MULE_PACKAGE_REPOSITORY_URL}
		
		if [[ "${MULE_PACKAGE_EXT}" == "zip" ]]; then

			cd /opt && unzip ${MULE_RUNTIME}.zip ${MULE_RUNTIME_UNPACKED_NAME}/apps/* ${MULE_RUNTIME_UNPACKED_NAME}/domains/* ${MULE_RUNTIME_UNPACKED_NAME}/conf/* ${MULE_RUNTIME_UNPACKED_NAME}/logs/* && mv /opt/${MULE_RUNTIME_UNPACKED_NAME} /opt/mule-archive
			cd /opt && unzip ${MULE_RUNTIME}.zip && rm ${MULE_RUNTIME}.zip && mv /opt/${MULE_RUNTIME_UNPACKED_NAME} ${MULE_HOME} && mkdir ${MULE_HOME}/patches && rm -rf ${MULE_RUNTIME}.zip && rm -rf /opt/set-mule-repo.sh
		
		else
			cd /opt && tar zxvf ${MULE_RUNTIME}.tar.gz && echo "show contents of /opt/" && ls -al /opt/ && echo "show contents of ${MULE_RUNTIME_UNPACKED_NAME}" && ls -al /opt/${MULE_RUNTIME_UNPACKED_NAME} && mv /opt/${MULE_RUNTIME_UNPACKED_NAME} /opt/mule-archive
			cd /opt && tar zxvf ${MULE_RUNTIME}.tar.gz && rm ${MULE_RUNTIME}.tar.gz && mv /opt/${MULE_RUNTIME_UNPACKED_NAME} ${MULE_HOME} && mkdir ${MULE_HOME}/patches && rm -rf ${MULE_RUNTIME}.tar.gz && rm -rf /opt/set-mule-repo.sh
		fi

		chmod 755 /opt/mule-start.sh && mv /opt/mule-start.sh /opt/mule/bin/ 

		ls -al /opt/mule-archive/
		
	fi
		
else
	
	MULE_RUNTIME_PACKAGE_CE=mule-standalone
	MULE_RUNTIME_UNPACKED_NAME_CE=${MULE_RUNTIME_PACKAGE_CE}-${MULE_RUNTIME_VERSION}
	MULE_RUNTIME_CE=${MULE_RUNTIME_PACKAGE_CE}-${MULE_RUNTIME_VERSION}
	MULE_PACKAGE_REPOSITORY_URL=https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${MULE_RUNTIME_VERSION}/${MULE_RUNTIME_CE}.zip
	
	if [ ! -f /opt/${MULE_RUNTIME_CE}.zip ]; then
		echo "Fetching Mule Runtime Community Edition..."
		cd /opt && wget ${MULE_PACKAGE_REPOSITORY_URL}

		cd /opt && unzip ${MULE_RUNTIME_CE}.zip ${MULE_RUNTIME_CE}/apps/* ${MULE_RUNTIME_CE}/domains/* ${MULE_RUNTIME_CE}/conf/* ${MULE_RUNTIME_CE}/logs/* && mv /opt/${MULE_RUNTIME_CE} /opt/mule-archive

		cd /opt && unzip ${MULE_RUNTIME_CE}.zip && rm ${MULE_RUNTIME_CE}.zip && mv /opt/${MULE_RUNTIME_CE} ${MULE_HOME} && mkdir ${MULE_HOME}/patches && rm -rf ${MULE_RUNTIME_CE}.zip && rm -rf /opt/set-mule-repo.sh
		chmod 755 /opt/mule-start.sh && mv /opt/mule-start.sh /opt/mule/bin/

		echo "show contents of /opt/mule-archive/"
		ls -al /opt/mule-archive/
		ls -al /opt/mule-archive/apps/
		#ls -al /opt/mule-archive/apps/default/		
		
	fi	
fi



# update mule agent if specified
if [[ "${MULE_AGENT_UPDATE_VERSION}" != "" ]]; then



	if [[ $MULE_EDITION == *"ce"* ]]; then
		echo "Community Edition not support... Skipping Mule Agent update..."	
	else
		# if /tools/ dir exist, then proceed with the update of MULE ARM agent.
		if [ -d "${MULE_HOME}/tools/" ]; then

			if [[ $MULE_RUNTIME_VERSION == *"4."* ]]; then
				echo "Skipping Mule Agent update for Mule version ${MULE_RUNTIME_VERSION} ..."
			else

				echo "Updating Mule Agent to ${MULE_AGENT_UPDATE_VERSION}..."

				if curl --header --output /dev/null --silent --head --fail "${MULE_AGENT_UPDATE_URL}/${MULE_AGENT_UPDATE_VERSION}/"
				then
					echo "${MULE_AGENT_UPDATE_URL}/${MULE_AGENT_UPDATE_VERSION}/agent-setup-${MULE_AGENT_UPDATE_VERSION}.zip -O agent-setup-${MULE_AGENT_UPDATE_VERSION}.zip"
					cd ${MULE_HOME}/bin/ && wget ${MULE_AGENT_UPDATE_URL}/${MULE_AGENT_UPDATE_VERSION}/agent-setup-${MULE_AGENT_UPDATE_VERSION}.zip -O agent-setup-${MULE_AGENT_UPDATE_VERSION}.zip

				else
				    echo "Checking alternative source..."
				    echo "${MULE_AGENT_UPDATE_URL_SECOND}"
				    curl -L -o ${MULE_HOME}/bin/agent-setup-${MULE_AGENT_UPDATE_VERSION}.zip $MULE_AGENT_UPDATE_URL_SECOND
				fi	

				unzip -o agent-setup-${MULE_AGENT_UPDATE_VERSION}.zip
				rm -rf agent-setup-${MULE_AGENT_UPDATE_VERSION}.zip
				rm -rf ${MULE_HOME}/tools/agent-setup*.jar
				mv agent-setup-${MULE_AGENT_UPDATE_VERSION}*.jar ${MULE_HOME}/tools/
				echo "Updating Mule Agent to complete."


			fi
		else
			if [[ $MULE_RUNTIME_VERSION == *"3.6"* ]]; then
				echo "Mule ESB 3.6.x detected... storing to ${MULE_HOME}/bin/"
				cd ${MULE_HOME}/bin/ && wget ${MULE_AGENT_UPDATE_URL}/${MULE_AGENT_UPDATE_VERSION}/agent-setup-${MULE_AGENT_UPDATE_VERSION}.zip  -O agent-setup-${MULE_AGENT_UPDATE_VERSION}.zip
				unzip -o agent-setup-${MULE_AGENT_UPDATE_VERSION}.zip
				rm -rf agent-setup-${MULE_AGENT_UPDATE_VERSION}.zip
				echo "Updating Mule Agent to complete."

			else
				echo "Skipping Mule Agent update... ${MULE_HOME}/tools/ does not exist."	
			fi
			
		fi	
	fi
	
 else
	echo "Skipping Mule Agent update..."	
fi
# clean up
rm -rf /opt/AUTHORIZATION /opt/VERSION /opt/EDITION /opt/MMC_AGENT_VERSION /opt/MULE_AGENT_UPDATE_URL_SECOND

if [ ! -f /opt/set-mule-repo.sh ]; then
	rm -rf /opt/set-mule-repo.sh
fi


