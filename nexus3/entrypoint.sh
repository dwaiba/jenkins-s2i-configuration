#!/bin/sh -e

#[ -d "${NEXUS_DATA}" ] || mkdir -p "${NEXUS_DATA}"
#[ $(stat -c '%U' "${NEXUS_DATA}") != 'neuxs' ] && chown -R nexus3 "${NEXUS_DATA}"

# clear tmp and cache for upgrade
#rm -fr "${NEXUS_DATA}"/tmp/ "${NEXUS_DATA}"/cache/
#exec su -s /bin/sh -c '/opt/sonatype/nexus3/bin/nexus run' nexus3 || \

[ $# -eq 0 ] && \
 exec  /bin/sh -c '/opt/sonatype/nexus3/bin/nexus run' nexus3 || \
 exec "$@"
