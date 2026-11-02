#!/usr/bin/env ruby

require "date"
require "yaml"

root = File.expand_path("..", __dir__)
current_dir = File.join(root, "content", "wiki")
reference_dir = File.join(root, "пример", "kurergo", "content", "wiki")

def metadata(path)
  raw = File.read(path)
  match = raw.match(/\A---\s*\n(.*?)\n---\s*\n?/m)
  raise "Нет front matter: #{path}" unless match

  YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true) || {}
end

current_paths = Dir.glob(File.join(current_dir, "*.md")).reject { |path| File.basename(path) == "_index.md" }
reference_paths = Dir.glob(File.join(reference_dir, "*.md")).reject { |path| File.basename(path) == "_index.md" }
current_slugs = current_paths.map { |path| metadata(path).fetch("slug") }
reference_slugs = reference_paths.map { |path| metadata(path).fetch("slug") }

raise "Текущие slug не уникальны" unless current_slugs.uniq.length == current_slugs.length
raise "Не все URL отличаются от примера" if (current_slugs & reference_slugs).any?
raise "Есть длинный slug" if current_slugs.any? { |slug| slug.length > 24 }
raise "Есть неверный slug" unless current_slugs.all? { |slug| slug.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/) }

patterns = [
  File.join(root, "content", "**", "*.md"),
  File.join(root, "layouts", "**", "*"),
  File.join(root, "data", "**", "*"),
  File.join(root, "static", "*.txt"),
  File.join(root, "public", "**", "*.html"),
  File.join(root, "public", "sitemap.xml")
]
scan_paths = patterns.flat_map { |pattern| Dir.glob(pattern) }.select { |path| File.file?(path) }.uniq
old_routes = reference_slugs.flat_map { |slug| ["/wiki/#{slug}/", "/blog/#{slug}/"] }
leftovers = []

scan_paths.each do |path|
  source = File.read(path)
  old_routes.each do |route|
    leftovers << [path.delete_prefix("#{root}/"), route] if source.include?(route)
  end
end

raise "Остались старые маршруты:\n#{leftovers.first(20).map { |file, route| "#{file}: #{route}" }.join("\n")}" if leftovers.any?

average = current_slugs.sum(&:length).to_f / current_slugs.length
puts "WIKI URL проверено: #{current_slugs.length}"
puts "Совпадений URL с примером: 0"
puts "Старых /wiki/ и /blog/ маршрутов в сборке: 0"
puts "Средняя длина slug: #{average.round(1)}"
puts "Диапазон длины: #{current_slugs.map(&:length).min}–#{current_slugs.map(&:length).max}"
