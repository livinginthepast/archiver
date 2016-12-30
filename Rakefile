namespace :reset do
  namespace :db do
    desc 'Initialize an empty Postgres database'
    task :init do
      sh('initdb -D ./pg_data -E "UTF-8" --lc-collate="en_US.UTF-8" --lc-ctype="en_US.UTF-8" || :')
    end

    task :start do
      sh('postgres -D ./pg_data & sleep 5')
    end

    task :stop do
      sh('pkill -f postgres')
    end

    desc 'Create a postgres superuser'
    task :user do
      sh('createuser -s postgres || :')
    end
  end
end

task nginx: %w(nginx:checkout nginx:cert:install)

namespace :nginx do
  task checkout: './nginx'

  directory './nginx' do
    sh 'git clone git@github.com:livinginthepast/archiver_nginx nginx'
  end

  namespace :cert do
    CRT_FILE = "nginx/certs/local-dev.archiver.ssl.crt"
    REQUIRED_FILES = %W{
      #{CRT_FILE}
      nginx/sites-enabled/http.archiver.conf
      nginx/sites-enabled/https.archiver.conf
      nginx/sites-enabled/https.archiver.uploads.conf
      nginx/certs/.trusted
    }

    desc 'Generate and install wildcard SSL certs for local development'
    task install: REQUIRED_FILES

    file 'nginx/certs/.trusted' do
      puts 'Adding local developent SSL crt to keychain.'
      puts 'Please configure the keychain to always trust.'
      sh "open '/Applications/Utilities/Keychain Access.app' #{ENV['PWD']}/#{CRT_FILE}"
      touch 'nginx/certs/.trusted'
    end

    file 'nginx/sites-enabled/http.archiver.conf' do
      sh "ln -fs #{ENV['PWD']}/nginx/sites-available/http.archiver.dev nginx/sites-enabled/http.archiver.conf"
    end

    file 'nginx/sites-enabled/https.archiver.conf' do
      sh "ln -fs #{ENV['PWD']}/nginx/sites-available/https.archiver.dev nginx/sites-enabled/https.archiver.conf"
    end

    file 'nginx/sites-enabled/https.archiver.uploads.conf' do
      sh "ln -fs #{ENV['PWD']}/nginx/sites-available/https.archiver.uploads.dev nginx/sites-enabled/https.archiver.uploads.conf"
    end

    file CRT_FILE => '/tmp/archiver.openssl.cnf' do
      if File.exist?('nginx/certs/.trusted')
        puts 'Cert already created and trusted, skipping creation of new one'
      else
        sh %{
        openssl req \
          -new \
          -newkey rsa:2048 \
          -sha1 \
          -days 3650 \
          -nodes \
          -x509 \
          -keyout nginx/certs/local-dev.archiver.ssl.key \
          -out nginx/certs/local-dev.archiver.ssl.crt \
          -config /tmp/archiver.openssl.cnf
        }
      end
    end

    file '/tmp/archiver.openssl.cnf' do
      open('/tmp/archiver.openssl.cnf', 'w') do |f|
        f.write <<-EOF.gsub(/^\s+/, '')
            [req]
            distinguished_name = req_distinguished_name
            x509_extensions = v3_req
            prompt = no
            [req_distinguished_name]
            CN = *.archiver.dev
            [v3_req]
            keyUsage = keyEncipherment, dataEncipherment
            extendedKeyUsage = serverAuth
            subjectAltName = @alt_names
            [alt_names]
            DNS.1 = *.archiver.dev
            DNS.2 = archiver.dev
        EOF
      end
    end
  end
end

task upload_handler: %w(upload_handler:checkout)

namespace :upload_handler do
  task checkout: './upload-handler'

  directory './upload-handler' do
    sh 'git clone git@github.com:livinginthepast/upload-handler upload-handler'
  end
end

task web: %w(web:checkout)

namespace :web do
  task checkout: './web'

  directory './web' do
    sh 'git clone git@github.com:livinginthepast/archiver_web web'
  end
end

desc 'Run through all of the reset tasks'
task reset: %w(
  reset:db:init
  reset:db:start
  reset:db:user
  reset:db:stop

  nginx
  upload_handler
  web
)
