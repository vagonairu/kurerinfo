#!/usr/bin/env ruby

require "date"
require "digest"
require "set"
require "yaml"

root = File.expand_path("..", __dir__)
current_dir = File.join(root, "content", "wiki")
reference_dir = File.join(root, "пример", "kurergo", "content", "wiki")

def split_document(raw)
  match = raw.match(/\A---\s*\n(.*?)\n---\s*\n?/m)
  raise "Нет front matter" unless match

  [match[1], raw[match.end(0)..].to_s]
end

def metadata(front)
  YAML.safe_load(front, permitted_classes: [Date, Time], aliases: true) || {}
end

def normalized_words(text)
  text.downcase.gsub(%r{https?://\S+}, " ").scan(/[a-zа-яё0-9]+/)
end

def shingles(text, size = 10)
  words = normalized_words(text)
  return Set.new if words.length < size

  Set.new(words.each_cons(size).map { |items| items.join(" ") })
end

def jaccard(first, second)
  union = first | second
  return 0.0 if union.empty?

  (first & second).length.to_f / union.length
end

paths = Dir.glob(File.join(current_dir, "*.md")).reject { |path| File.basename(path) == "_index.md" }.sort
results = []
long_paragraphs = Hash.new { |hash, key| hash[key] = [] }

paths.each do |path|
  slug = File.basename(path)
  reference_path = File.join(reference_dir, slug)
  raise "Нет файла-примера для #{slug}" unless File.file?(reference_path)

  current_front, current_body = split_document(File.read(path))
  reference_front, reference_body = split_document(File.read(reference_path))
  current_meta = metadata(current_front)
  reference_meta = metadata(reference_front)

  current_body.split(/\n{2,}/).each do |paragraph|
    clean = paragraph.strip
    next if clean.length < 220
    next if clean.start_with?("#", "-", "|", ">") || clean.match?(/\A\d+[.)]\s/)

    signature = normalized_words(clean).join(" ")
    long_paragraphs[signature] << slug
  end

  results << {
    slug: slug,
    length: current_body.length,
    exact_body: Digest::SHA256.hexdigest(current_body) == Digest::SHA256.hexdigest(reference_body),
    description_equal: current_meta["description"].to_s == reference_meta["description"].to_s,
    faq_equal: current_meta["faq"].to_s == reference_meta["faq"].to_s,
    similarity: jaccard(shingles(current_body), shingles(reference_body))
  }
end

duplicate_paragraphs = long_paragraphs.select { |_paragraph, slugs| slugs.uniq.length > 1 }
minimum = results.min_by { |item| item[:length] }
maximum_similarity = results.max_by { |item| item[:similarity] }
exact_count = results.count { |item| item[:exact_body] }
same_descriptions = results.count { |item| item[:description_equal] }
same_faq = results.count { |item| item[:faq_equal] }

puts "Статей проверено: #{results.length}"
puts "Минимальный объём тела: #{minimum[:length]} знаков (#{minimum[:slug]})"
puts "Полностью совпадающих тел с примером: #{exact_count}"
puts "Совпадающих description с примером: #{same_descriptions}"
puts "Совпадающих FAQ с примером: #{same_faq}"
puts "Максимальное сходство 10-словных шинглов: #{(maximum_similarity[:similarity] * 100).round(2)}% (#{maximum_similarity[:slug]})"
puts "Повторяющихся длинных абзацев внутри WIKI: #{duplicate_paragraphs.length}"
if duplicate_paragraphs.any?
  duplicate_paragraphs.first(8).each do |paragraph, slugs|
    puts "  - #{slugs.uniq.length} статей: #{paragraph[0, 150]}…"
  end
end

failed = minimum[:length] < 16_000 || exact_count.positive? || same_descriptions.positive? || same_faq.positive? || maximum_similarity[:similarity] > 0.10 || duplicate_paragraphs.any?
exit(failed ? 1 : 0)
