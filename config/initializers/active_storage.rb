Rails.application.config.after_initialize do
  # Ensure storage directories exist with proper permissions
  storage_dirs = [
    Rails.root.join("storage"),
    Rails.root.join("storage", "cache"),
    Rails.root.join("tmp", "storage"),
    Rails.root.join("tmp", "storage", "cache")
  ]

  storage_dirs.each do |dir|
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    FileUtils.chmod(0755, dir)
  end

  Rails.logger.info "Active Storage directories initialized: #{storage_dirs.select { |d| Dir.exist?(d) }.map(&:to_s)}"
end
