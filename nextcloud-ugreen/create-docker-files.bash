#!/bin/bash

cd /volume1/nextcloud/ 2>/dev/null || { echo "Share nextcloud is missing. Please create it.."; exit 1; }

if [ ! -e .env ]; then
    if [ -z "$DOMAIN" ]; then echo "Please specify DOMAIN environment variable."; exit 1; fi
    {
        echo "NEXTCLOUD_RELEASE=32"
        echo "DOMAIN=$DOMAIN"

    } > .env
fi

for password_file in db_password.txt db_root_password.txt; do
    if [ ! -e $password_file ]; then
        dd if=/dev/random bs=12 count=1 2>&- | base64 > $password_file
    fi
done

if [ ! -e docker-compose.yaml ]; then
    curl -sSLo docker-compose.yaml 'https://github.com/majes-git/docker/raw/refs/heads/master/nextcloud-ugreen/docker-compose.yaml'
fi

file=lib.sh
if [ ! -e $file ]; then
    sed 's/ \{8\}//' > $file <<'EOF'
        run_as() {
            if [ "$(id -u)" = 0 ]; then
                su -p "$user" -s /bin/sh -c "$1"
            else
                sh -c "$1"
            fi
        }
EOF
fi

if [ ! -d post-installation ]; then
    mkdir post-installation
fi

file=post-installation/01-install-calendar.sh
if [ ! -e $file ]; then
    sed 's/ \{8\}//' > $file <<EOF
        #!/bin/sh
        . /docker-entrypoint-hooks.d/lib.sh
        run_as 'php /var/www/html/occ app:enable calendar'
EOF
    chmod +x $file
fi

file=post-installation/02-install-files-external.sh
if [ ! -e $file ]; then
    sed 's/ \{8\}//' > $file <<EOF
        #!/bin/sh
        . /docker-entrypoint-hooks.d/lib.sh
        run_as 'php /var/www/html/occ app:enable files_external'
EOF
    chmod +x $file
fi

file=post-installation/03-disable-firstrunwizard.sh
if [ ! -e $file ]; then
    sed 's/ \{8\}//' > $file <<EOF
        #!/bin/sh
        . /docker-entrypoint-hooks.d/lib.sh
        run_as 'php /var/www/html/occ app:disable firstrunwizard'
EOF
    chmod +x $file
fi

file=post-installation/11-change-skeleton.sh
if [ ! -e $file ]; then
    sed 's/ \{8\}//' > $file <<EOF
        #!/bin/sh
        . /docker-entrypoint-hooks.d/lib.sh
        run_as 'php /var/www/html/occ config:system:set skeletondirectory --value=""'
EOF
    chmod +x $file
fi

file=post-installation/12-change-language.sh
if [ ! -e $file ]; then
    sed 's/ \{8\}//' > $file <<EOF
        #!/bin/sh
        . /docker-entrypoint-hooks.d/lib.sh
        run_as 'php /var/www/html/occ config:system:set default_language --value="de"'
        run_as 'php /var/www/html/occ config:system:set default_locale --value="de_DE"'
EOF
    chmod +x $file
fi

# file=post-installation/21-create-users.sh
# if [ ! -e $file ]; then
#     sed 's/ \{8\}//' > $file <<EOF
#         #!/bin/sh
#         . /docker-entrypoint-hooks.d/lib.sh
#         export OC_PASS=128tRoutes.1
#         run_as 'php /var/www/html/occ user:add --display-name="Max Mustermann"  --password-from-env max'
# EOF
#     chmod +x $file
# fi

if [ ! -e docker-compose.override.yaml ]; then
    if [ -d /volume1/paperless-ngx/ ]; then
        cat > docker-compose.override.yaml <<EOF
services:
  app:
    volumes:
    - /volume1/paperless-ngx/volumes/media/documents/archive:/paperless-ngx:ro
EOF
        file=post-installation/02a-enable-paperless-ngx.sh
        if [ ! -e $file ]; then
            sed 's/ \{16\}//' > $file <<EOF
                #!/bin/sh
                . /docker-entrypoint-hooks.d/lib.sh
                run_as 'php /var/www/html/occ files_external:create paperless-ngx local null::null -c datadir=/paperless-ngx'
                run_as 'php /var/www/html/occ files:scan --all'
EOF
            chmod +x $file
        fi
    fi
fi
