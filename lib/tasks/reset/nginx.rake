task reset: 'reset:nginx'

namespace :reset do
  desc 'Check out and configure local nginx'
  task nginx: %w(
    reset:nginx:header
    reset:nginx:checkout
    reset:nginx:sync
    reset:nginx:cert:install
  )

  namespace :nginx do
    task :header do
      printf "\e[30;100m %-80s \e[0m\n", 'Resetting nginx'
    end

    task checkout: %w(
      ./nginx
      nginx/sites-enabled
    )

    directory './nginx' do
      sh 'git',
        'clone',
        'git@github.com:livinginthepast/archiver_nginx',
        'nginx'
    end

    directory 'nginx/sites-enabled' do
      sh 'mkdir',
        '-p',
        'nginx/sites-enabled'
    end

    task :sync do
      Dir.chdir('nginx') do
        sh 'git',
          'pull',
          '--ff-only'
      end
    end

    namespace :cert do
      DOMAIN = 'archiver.dev'
      CRT_FILE = "nginx/certs/local-dev.archiver.ssl.crt"
      KEY_FILE = "nginx/certs/local-dev.archiver.ssl.key"
      SSL_CONFIG = "/tmp/archiver.openssl.cnf"
      REQUIRED_FILES = %W{
        #{CRT_FILE}
        nginx/sites-enabled/http.archiver.conf
        nginx/sites-enabled/https.archiver.conf
        nginx/sites-enabled/https.archiver.uploads.conf
        nginx/certs/.trusted
      }

      task install: REQUIRED_FILES

      file 'nginx/certs/.trusted' do
        puts "\e[1;34mAdding local developent SSL crt to keychain.\e[0m"
        puts "\e[1;34mPlease configure the keychain to always trust.\e[0m"
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

      file CRT_FILE => SSL_CONFIG do
        if File.exist?('nginx/certs/.trusted')
          puts "\e[32mCert already created and trusted, skipping creation of new one\e[0m"
        else
          sh %{
            openssl req \
              -new \
              -newkey rsa:2048 \
              -sha1 \
              -days 3650 \
              -nodes \
              -x509 \
              -keyout #{KEY_FILE} \
              -out #{CRT_FILE} \
              -config #{SSL_CONFIG}
          }
        end
      end

      file SSL_CONFIG do
        open(SSL_CONFIG, 'w') do |f|
          f.write <<-EOF.gsub(/^\s+/, '')
            [req]
            distinguished_name = req_distinguished_name
            x509_extensions = v3_req
            prompt = no
            [req_distinguished_name]
            CN = *.#{DOMAIN}
            [v3_req]
            keyUsage = keyEncipherment, dataEncipherment
            extendedKeyUsage = serverAuth
            subjectAltName = @alt_names
            [alt_names]
            DNS.1 = *.#{DOMAIN}
            DNS.2 = #{DOMAIN}
          EOF
        end
      end
    end
  end
end


