#!/usr/bin/env ruby

require "pathname"
require "uri"

root = Pathname.new(ARGV.fetch(0, "public")).expand_path
html_files = Dir.glob(root.join("**/*.html")).map { |path| Pathname.new(path) }
broken = []
seo_issues = []
checked = 0

html_files.each do |html|
  source = html.read
  markup = source.gsub(/<script\b[^>]*>.*?<\/script>/im, "<script></script>")
  relative = html.relative_path_from(root).to_s

  markup.scan(/(?:href|src)\s*=\s*(?:"([^"]+)"|'([^']+)'|([^\s>]+))/i).each do |matches|
    raw = matches.compact.first
    next if raw.empty? || raw.start_with?("#", "//")
    next if raw.match?(/\A(?:https?:|mailto:|tel:|data:|javascript:)/i)

    clean = URI::DEFAULT_PARSER.unescape(raw.split(/[?#]/, 2).first.to_s)
    next if clean.empty?

    target = if clean.start_with?("/")
      root.join(clean.delete_prefix("/"))
    else
      html.dirname.join(clean).cleanpath
    end

    checked += 1
    candidates = [target]
    candidates << target.join("index.html") if target.extname.empty? || target.directory?
    candidates << Pathname.new("#{target}.html") if target.extname.empty?
    next if candidates.any?(&:file?)

    broken << [relative, raw]
  end

  next if relative == "admin/index.html"
  next if source.match?(/http-equiv=["']?refresh/i)
  next if relative == "go/yandex-courier/index.html"

  seo_issues << [relative, "нет title"] unless source.match?(/<title>.+?<\/title>/im)
  seo_issues << [relative, "нет meta description"] unless source.match?(/<meta\b[^>]*name=["']?description["']?[^>]*content=/i)
  seo_issues << [relative, "нет canonical"] unless source.match?(/<link\b[^>]*rel=["']?canonical["']?[^>]*href=/i)
  seo_issues << [relative, "нет H1"] unless source.match?(/<h1\b/i)
  seo_issues << [relative, "нет CTA на промежуточную страницу"] unless source.include?("/go/yandex-courier/")
  seo_issues << [relative, "короткая ссылка встречается вне промежуточной страницы"] if source.include?("clck.ru/3WpciR")

  markup.scan(/<img\b[^>]*>/i).each do |image|
    seo_issues << [relative, "у изображения нет alt"] unless image.match?(/\balt(?:\s|=|>)/i)
  end
end

if broken.empty? && seo_issues.empty?
  puts "OK: #{html_files.length} HTML-файлов, #{checked} локальных ссылок и ресурсов, SEO-поля и CTA проверены"
  exit 0
end

broken.uniq.each { |file, url| warn "BROKEN #{file}: #{url}" }
seo_issues.uniq.each { |file, issue| warn "SEO #{file}: #{issue}" }
warn "Найдено битых ссылок: #{broken.uniq.length}; SEO/CTA-проблем: #{seo_issues.uniq.length}"
exit 1
