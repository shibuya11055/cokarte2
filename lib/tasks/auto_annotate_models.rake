# frozen_string_literal: true

# Auto-annotate models with schema information in development.
# Requires the 'annotate' gem.
if defined?(Rails) && Rails.env.development?
  begin
    # Ruby 3.2+ removed File.exists?. Older annotate versions still call it.
    # Provide a compatibility alias before loading the gem.
    unless File.respond_to?(:exists?)
      def File.exists?(path) = File.exist?(path)
    end

    require 'annotate'

    # Configure annotate defaults (models only)
    task :set_annotation_options do
      Annotate.set_defaults(
        'routes' => 'false',
        'models' => 'true',
        'position_in_class' => 'before',
        'position_in_test' => 'before',
        'position_in_fixture' => 'before',
        'position_in_factory' => 'before',
        'position_in_serializer' => 'before',
        'show_foreign_keys' => 'true',
        'show_indexes' => 'true',
        'simple_indexes' => 'false',
        'model_dir' => 'app/models',
        'schema_file' => 'db/schema.rb',
        'exclude_tests' => 'true',
        'exclude_fixtures' => 'true',
        'exclude_factories' => 'true',
        'exclude_serializers' => 'true',
        'exclude_controllers' => 'true',
        'exclude_helpers' => 'true',
        'exclude_scaffolds' => 'true',
        'exclude_decorators' => 'true',
        'exclude_views' => 'true',
        'exclude_mailers' => 'true',
        'exclude_jobs' => 'true',
        'wrapper_open' => nil,
        'wrapper_close' => nil
      )
    end

    Annotate.load_tasks

    # Ensure our options are applied before annotate tasks run
    Rake::Task['annotate_models'].enhance(['set_annotation_options']) if Rake::Task.task_defined?('annotate_models')

    # Auto-run after migrations in development
    if Rake::Task.task_defined?('db:migrate') && Rake::Task.task_defined?('annotate_models')
      Rake::Task['db:migrate'].enhance do
        Rake::Task['annotate_models'].invoke
      end
    end
  rescue LoadError
    # annotate gem not available; skip
  end
end
