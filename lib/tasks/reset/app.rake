task reset: 'reset:app'

namespace :reset do
  desc 'Check out the main app'
  task app: %w(
    reset:app:header
    reset:app:checkout
    reset:app:sync
    reset:app:bundle
  )

  namespace :app do
    REPO = 'livinginthepast/archiver_web'.freeze
    REPO_URL = format('git@github.com:%s', REPO).freeze
    CHECKOUT = 'web'.freeze

    task :header do
      printf "\e[30;100m %-80s \e[0m\n", 'Resetting app'
    end

    task checkout: CHECKOUT

    task :bundle do
      Bundler.with_clean_env do
        Dir.chdir(CHECKOUT) do
          sh 'bundle'
        end
      end
    end

    task :sync do
      Dir.chdir(CHECKOUT) do
        sh 'git',
          'pull',
          '--ff-only'
      end
    end

    directory CHECKOUT do
      sh 'git',
        'clone',
        REPO_URL,
        CHECKOUT
    end
  end
end


