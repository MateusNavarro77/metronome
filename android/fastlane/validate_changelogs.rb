# frozen_string_literal: true

# Validates Play Store changelog files (`default.txt`) across all locales.
module ChangelogValidator
  MAX_LENGTH = 500

  def self.validate!(metadata_dir)
    unless File.directory?(metadata_dir)
      raise "Metadata directory does not exist: #{metadata_dir}"
    end

    locale_dirs = Dir.children(metadata_dir)
      .reject { |entry| entry.start_with?(".") }
      .map { |entry| File.join(metadata_dir, entry) }
      .select { |path| File.directory?(path) }
      .sort

    raise "No locale directories found in #{metadata_dir}" if locale_dirs.empty?

    errors = locale_dirs.map { |locale_dir| validate_locale(locale_dir) }.compact
    raise errors.join("\n") unless errors.empty?

    locale_dirs.map { |dir| File.basename(dir) }
  end

  def self.validate_locale(locale_dir)
    locale = File.basename(locale_dir)
    default_file = File.join(locale_dir, "changelogs", "default.txt")

    unless File.file?(default_file)
      return "Missing changelog file for locale '#{locale}': #{default_file}"
    end

    content = File.read(default_file, encoding: "UTF-8")
    if content.strip.empty?
      return "Changelog for locale '#{locale}' is empty: #{default_file}"
    end

    if content.length > MAX_LENGTH
      return "Changelog for locale '#{locale}' is #{content.length} chars (max #{MAX_LENGTH}): #{default_file}"
    end

    nil
  end
  private_class_method :validate_locale
end

if __FILE__ == $PROGRAM_NAME
  metadata_dir = ARGV[0] || File.expand_path("metadata/android", __dir__)
  begin
    locales = ChangelogValidator.validate!(metadata_dir)
    puts "Validated Play Store default.txt changelogs for locales: #{locales.join(', ')}"
  rescue StandardError => e
    warn "Changelog validation failed:\n#{e.message}"
    exit 1
  end
end
