task reset: 'reset:db'

namespace :reset do
  desc 'Initialize a PostgreSQL data directory'
  task db: %w(
    reset:db:header
    ./pgdata
    reset:db:start
    reset:db:user
    reset:db:stop
  )

  namespace :db do
    task :header do
      printf "\e[30;100m %-80s \e[0m\n", 'Resetting database'
    end

    directory './pgdata' do
      sh('initdb -D ./pg_data -E "UTF-8" --lc-collate="en_US.UTF-8" --lc-ctype="en_US.UTF-8" || :')
    end

    task :start do
      sh('postgres -D ./pg_data & sleep 5')
    end

    task :stop do
      sh('pkill -f postgres')
    end

    task :user do
      sh('createuser -s postgres || :')
    end
  end
end


