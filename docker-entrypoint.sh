#!/usr/bin/env bash

set -x
set -e

# if host networking is enabled, bind everything to 0.0.0.0
if [[ "${HOST_MODE}" ]]; then

    # sed -i "s,command = /usr/bin/gunicorn -b127.0.0.1:8000 -w 4 graphite.wsgi:application,command = /usr/bin/gunicorn -b0.0.0.0:8000 -w 4 graphite.wsgi:application," /opt/grafana/conf/custom.ini

    sed -i 's@graphiteHost: "127.0.0.1"@graphiteHost: "0.0.0.0"@' /src/statsd/config.js
    # sed -i "s,USER = nobody"


    # /opt/graphite/webapp/graphite/local_settings.py

    # # Confiure StatsD
    # ADD     ./statsd/config.js /src/statsd/config.js

    # # Configure Whisper, Carbon and Graphite-Web
    # ADD     ./graphite/initial_data.json /opt/graphite/webapp/graphite/initial_data.json
    # ADD     ./graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
    # ADD     ./graphite/carbon.conf /opt/graphite/conf/carbon.conf
    # ADD     ./graphite/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
    # ADD     ./graphite/storage-aggregation.conf /opt/graphite/conf/storage-aggregation.conf
    # RUN     mkdir -p /opt/graphite/storage/whisper
    # RUN     touch /opt/graphite/storage/graphite.db /opt/graphite/storage/index
    # RUN     chown -R www-data /opt/graphite/storage
    # RUN     chmod 0775 /opt/graphite/storage /opt/graphite/storage/whisper
    # RUN     chmod 0664 /opt/graphite/storage/graphite.db
    # RUN     cp /src/graphite-web/webapp/manage.py /opt/graphite/webapp
    # RUN     cd /opt/graphite/webapp/ && python manage.py migrate --run-syncdb --noinput

fi
