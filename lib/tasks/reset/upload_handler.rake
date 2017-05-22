task reset: 'reset:upload_handler'

namespace :reset do
  desc 'Check out an app for handling local file uploads'
  task upload_handler: %w(
    reset:upload_handler:header
    reset:upload_handler:checkout
    reset:upload_handler:sync
    reset:upload_handler:bundle
  )

  namespace :upload_handler do
    task :header do
      printf "\e[30;100m %-80s \e[0m\n", 'Resetting upload handler'
    end

    task checkout: './upload-handler'

    task :bundle do
      Bundler.with_clean_env do
        Dir.chdir('upload-handler') do
          sh 'bundle'
        end
      end
    end

    task :sync do
      Dir.chdir('upload-handler') do
        sh 'git',
          'pull',
          '--ff-only'
      end
    end

    directory './upload-handler' do
      sh 'git',
        'clone',
        'git@github.com:livinginthepast/upload-handler',
        'upload-handler'
    end
  end
end

