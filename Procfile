dnsmasq:   /usr/local/opt/dnsmasq/sbin/dnsmasq --no-daemon -C ./etc/dnsmasq/dnsmasq.conf --port 8053 -q
memcached: memcached -l 127.0.0.1 -p 11211
nginx:     nginx -g "daemon off;" -c /Users/sax/workspace/art_management/nginx/nginx.conf -p /Users/sax/workspace/art_management/nginx
postgres:  postgres -D /Users/sax/workspace/art_management/pg_data
rabbitmq:  rabbitmq-server
redis:     redis-server redis/redis.conf
upload-handler: subcontract --chdir upload-handler 'bundle exec rackup -p 4000 config.ru'
