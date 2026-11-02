#!/usr/bin/env ruby

require "date"
require "yaml"

ROOT = File.expand_path("..", __dir__)
WIKI_DIR = File.join(ROOT, "content", "wiki")

SLUGS = {
  "bankovskaya-karta-dlya-vyplat-kureru" => "karta-vyplat",
  "bezopasnost-kurera-na-doroge" => "bezopasnost",
  "bonusy-koeffitsienty-i-mnozhiteli-yandex-pro" => "bonusy-pro",
  "chaevye-kureru-v-dostavke-yandex-eda" => "chaevye",
  "chto-delat-esli-klient-ne-otkryvaet-dver-kureru" => "klient-molchit",
  "chto-delat-esli-samozanyatost-zablokirovali-kureru" => "blok-vyplat",
  "chto-delat-esli-u-kurera-ne-rabotaet-gps" => "gps",
  "chto-delat-kureru-esli-propal-internet" => "internet",
  "chto-delat-kureru-pri-dtp-na-smene" => "dtp",
  "chto-nuzhno-dlya-starta" => "start",
  "dostavka-iz-magazinov-i-aptek-kureru" => "magaziny",
  "dostavka-iz-restoranov-chto-nuzhno-znat-kureru" => "restorany",
  "elektrosamokat-dlya-kurera-kak-vybrat" => "elektrosamokat",
  "ezhednevnye-vyplaty" => "vyplaty",
  "faq-rabota-kurierom" => "faq",
  "fioletovye-zony-yandex-pro" => "zony-pro",
  "forma-i-termokorob-kurera-gde-vzyat" => "ekipirovka",
  "gde-arendovat-velosiped-ili-samokat-kureru" => "arenda",
  "gde-luchshe-rabotat-kurerom" => "vybor-servisa",
  "kak-dostavlyat-bolshe-i-menshe-ustavat" => "temp",
  "kak-migrantu-ustroitsya-kurerom-v-yandex-eda" => "migrant",
  "kak-najti-rabotu-bez-obrazovaniya" => "bez-diploma",
  "kak-opredelyat-vygodnye-zakazy-kureru" => "vygodnyj-zakaz",
  "kak-rabotat-kurerom-zimoj" => "zima",
  "kak-rabotayut-algoritmy-yandex-edy-dlya-kurerov" => "algoritmy",
  "kak-stat-kurierom-yandex-eda" => "start-eda",
  "kak-stat-samozanyatym-kurerom-i-ne-zaputatsya" => "samozanyatost",
  "kak-ustroen-reyting-kurera-i-kak-ego-ne-isportit" => "reiting",
  "kak-vybrat-termosumku-dlya-kurera" => "termosumka",
  "kak-vyvesti-dengi-kureru-yandex-eda-na-kartu" => "vyvod-deneg",
  "kis-art-dlya-kurerov-chto-eto" => "kis-art",
  "konflikt-s-sotrudnikami-restorana-kurer" => "konflikt",
  "kuda-ustroitsya-na-podrabotku" => "podrabotka",
  "letnyaya-podrabotka-dlya-studenta" => "leto-student",
  "luchshee-vremya-dlya-raboty-kurerom" => "vremya",
  "mozhno-li-rabotat-kurerom-bez-samozanyatosti" => "bez-npd",
  "mozhno-li-rabotat-v-neskolkih-servisah-kureru" => "multi-servis",
  "nalogovye-vychety-dlya-samozanyatyh-kurerov" => "vychet",
  "obsluzhivanie-avto-kurera-rashody" => "rashody-avto",
  "pauerbank-dlya-kurera-kak-vybrat" => "powerbank",
  "perehod-iz-yandex-edy-v-yandex-dostavku" => "eda-dostavka",
  "pervyj-rabochij-den-kurera" => "pervyj-den",
  "peshiy-velo-avto-kurier" => "formaty",
  "planovye-sloty-yandex-pro" => "sloty",
  "platnoe-ozhidanie-v-yandex-dostavke-dlya-kurera" => "ozhidanie",
  "plyusy-i-minusy-raboty-kurerom-gid" => "plyusy-minusy",
  "portret-moskovskogo-kurera-2026" => "moskva-portret",
  "povredil-zakaz-v-puti-chto-delat-kureru" => "povrezhdenie",
  "rabota-dlya-studenta-bez-opyta" => "student",
  "rabota-kurerom-ili-taksistom-chto-vybrat" => "kurier-taksi",
  "rabota-kurerom-na-polnyj-den" => "polnyj-den",
  "rabota-kurierom-yandex-registraciya" => "registraciya",
  "samozanyatyj-ili-parkovyj-kurer" => "park-ili-npd",
  "seo-01-skolko-zarabatyvaet-kurier-yandex-2026-regiony" => "dohod-regiony",
  "seo-02-kurier-yandex-edy-zarabotok-den-nedelya-mesyac" => "dohod-period",
  "seo-03-peshij-kurier-yandexa-realnyj-zarabotok" => "dohod-peshkom",
  "seo-04-skolko-platyat-kureram-yandexa-za-odin-zakaz" => "oplata-zakaza",
  "seo-05-dohod-kuriera-na-velosipede-yandex" => "dohod-velo",
  "seo-06-kak-uvelichit-zarabotok-kuriera-yandexa" => "rast-dohoda",
  "seo-07-skolko-zarabatyvaet-kurier-na-lichnom-avtomobile" => "dohod-avto",
  "seo-08-kak-stat-kurierom-yandexa-za-odin-den" => "start-za-den",
  "seo-09-poshagovaya-instrukciya-ustroitsya-kurierom-yandex" => "shagi",
  "seo-10-dokumenty-dlya-raboty-kurierom-yandexa" => "dokumenty",
  "seo-11-samozanyatyj-kurier-yandexa-plyusy-minusy" => "npd-plyusy",
  "seo-12-rabota-kurierom-yandex-eda-bez-opyta" => "bez-opyta",
  "seo-13-kak-bystro-projti-registraciyu-v-yandex-pro" => "pro-registraciya",
  "seo-14-stoit-li-ustraivatsya-kurierom-yandex-2026" => "stoit-li",
  "seo-15-so-skolki-let-mozhno-rabotat-kurierom-yandexa" => "vozrast",
  "seo-16-mozhno-li-stat-kurierom-yandexa-v-16-let" => "v-16-let",
  "seo-17-rabota-dlya-studentov-kurier-yandex-edy" => "student-eda",
  "seo-18-podrabotka-kurierom-posle-ucheby" => "posle-ucheby",
  "seo-19-rabota-kurierom-yandexa-chestnye-otzyvy" => "otzyvy",
  "seo-20-chto-govoryat-kuriery-o-rabote-v-yandexe" => "mneniya",
  "seo-21-pyat-glavnyh-plyusov-raboty-kurierom-yandexa" => "preimushestva",
  "seo-22-minusy-raboty-kurierom-yandexa" => "nedostatki",
  "seo-23-kak-stat-kurierom-yandex-edy-i-nachat-zarabatyvat" => "start-i-dohod",
  "seo-24-peshij-kurier-yandex-edy-instrukciya" => "peshij-start",
  "seo-25-skolko-zakazov-vypolnyaet-kurier-yandex-edy" => "zakazov-za-smenu",
  "seo-26-kurier-yandex-edy-ili-samokat-gde-vyshe-dohod" => "eda-ili-samokat",
  "seo-27-kak-vybrat-luchshij-rajon-yandex-edy" => "vybor-raiona",
  "seo-28-rabota-v-yandex-dostavke-skolko-zarabotat" => "dostavka-dohod",
  "seo-29-kurier-na-lichnom-avto-yandex-dostavka" => "lichnoe-avto",
  "seo-30-kurier-na-velosipede-ili-avtomobile" => "velo-ili-avto",
  "seo-31-kak-poluchat-bolshe-zakazov-yandex-dostavka" => "bolshe-zakazov",
  "seo-32-rabota-kurierom-yandexa-v-moskve" => "moskva",
  "seo-33-kurier-yandexa-v-sankt-peterburge" => "spb",
  "seo-34-rabota-kurierom-v-ekaterinburge" => "ekaterinburg",
  "seo-35-kurier-yandexa-v-novosibirske" => "novosibirsk",
  "seo-36-rabota-kurierom-v-kazani-otzyvy" => "kazan",
  "seo-37-skolko-zarabatyvaet-kurier-yandexa-v-krasnodare" => "krasnodar",
  "seo-38-rabota-kurierom-v-nizhnem-novgorode" => "nizhny",
  "seo-39-kurier-yandexa-v-samare-vakansii-2026" => "samara",
  "seo-40-rabota-kurierom-v-rostove-na-donu" => "rostov",
  "seo-41-kurier-yandexa-v-chelyabinske" => "chelyabinsk",
  "seo-42-rabota-kurierom-v-ufe" => "ufa",
  "seo-43-kurier-yandexa-v-omske" => "omsk",
  "seo-44-rabota-kurierom-v-permi" => "perm",
  "seo-45-kurier-yandexa-v-volgograde" => "volgograd",
  "seo-46-skolko-poluchaet-kurier-yandexa-v-krasnoyarske" => "krasnoyarsk",
  "seo-47-sem-prichin-stat-kurierom-yandexa" => "sem-prichin",
  "seo-48-kak-zarabotat-pervye-100000-kurierom-yandexa" => "cel-100k",
  "seo-49-rabota-kurierom-bez-opyta-gid-novichka" => "novichok",
  "seo-50-kurier-yandexa-2026-polnyj-obzor-professii" => "professiya",
  "skolko-nalogov-platit-samozanyatyj-kurer" => "nalog",
  "skolko-poluchaet-kurer-v-chas-den-mesyats" => "raschet-dohoda",
  "skolko-zarabatyvaet-kurier-yandex-2026" => "dohod-2026",
  "smartfon-dlya-raboty-kurerom" => "smartfon",
  "so-skolki-let-mozhno-rabotat-kurerom-gid" => "vozrast-kurera",
  "so-skolki-let-yandex-kurier-trebovaniya" => "trebovaniya",
  "stoit-li-byt-kurerom" => "reshenie",
  "strahovanie-dlya-kurerov" => "strahovka",
  "svobodniy-grafik-kuriera" => "svobodnyj-grafik",
  "tipy-zakazov-v-yandex-dostavke" => "tipy-zakazov",
  "velosiped-dlya-raboty-kurerom" => "velosiped",
  "vostrebovannye-professii-v-rossii-2026" => "professii",
  "yandex-bike-arenda-dlya-kurerov" => "bike",
  "yandex-dostavka-kurier-avto-velo" => "dostavka-format",
  "yandex-eda-ili-kuper-gde-luchshe-rabotat-kurerom" => "eda-ili-kuper",
  "yandex-eda-ili-yandex-dostavka-gde-luchshe-kureru" => "eda-ili-pro",
  "yandex-eda-kurier-polnyj-gid" => "gid-eda",
  "yandex-kurier-goroda-millionniki" => "millionniki",
  "yandex-kurier-otzyvy-plyusy-minusy" => "otzyvy-gid",
  "za-chto-shtrafuyut-kurerov-yandex-eda" => "ogranicheniya",
  "zakaz-otmenen-v-puti-chto-delat-kureru" => "otmena"
}.freeze

def split_document(raw)
  match = raw.match(/\A---\s*\n(.*?)\n---\s*\n?/m)
  raise "Нет front matter" unless match

  [match[1], raw[match.end(0)..].to_s]
end

paths = Dir.glob(File.join(WIKI_DIR, "*.md")).reject { |path| File.basename(path) == "_index.md" }.sort
current = paths.to_h do |path|
  front, = split_document(File.read(path))
  data = YAML.safe_load(front, permitted_classes: [Date, Time], aliases: true) || {}
  [data.fetch("slug"), path]
end

missing = current.keys - SLUGS.keys
extra = SLUGS.keys - current.keys
raise "Нет соответствий: #{missing.join(", ")}" if missing.any?
raise "Лишние соответствия: #{extra.join(", ")}" if extra.any?
raise "Новые URL не уникальны" unless SLUGS.values.uniq.length == SLUGS.length
raise "Неверный новый slug" unless SLUGS.values.all? { |slug| slug.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/) && slug.length <= 24 }
raise "Slug не изменён" if SLUGS.any? { |old_slug, new_slug| old_slug == new_slug }

current.each do |old_slug, path|
  front, body = split_document(File.read(path))
  data = YAML.safe_load(front, permitted_classes: [Date, Time], aliases: true) || {}
  data["slug"] = SLUGS.fetch(old_slug)
  data.delete("aliases")
  rendered_front = YAML.dump(data).sub(/\A---\s*\n/, "").sub(/\n\z/, "")
  File.write(path, "---\n#{rendered_front}\n---\n\n#{body.strip}\n")
end

index_path = File.join(WIKI_DIR, "_index.md")
front, body = split_document(File.read(index_path))
index_data = YAML.safe_load(front, permitted_classes: [Date, Time], aliases: true) || {}
index_data.delete("aliases")
rendered_index = YAML.dump(index_data).sub(/\A---\s*\n/, "").sub(/\n\z/, "")
File.write(index_path, "---\n#{rendered_index}\n---\n\n#{body.strip}\n")

patterns = [
  File.join(ROOT, "content", "**", "*.md"),
  File.join(ROOT, "layouts", "**", "*"),
  File.join(ROOT, "data", "**", "*"),
  File.join(ROOT, "static", "*.txt"),
  File.join(ROOT, "README.md")
]

text_paths = patterns.flat_map { |pattern| Dir.glob(pattern) }.select { |path| File.file?(path) }.uniq
text_paths.each do |path|
  source = File.read(path)
  updated = SLUGS.reduce(source) { |text, (old_slug, new_slug)| text.gsub(old_slug, new_slug) }
  File.write(path, updated) if updated != source
end

puts "Изменено WIKI URL: #{SLUGS.length}"
puts "Средняя длина slug: #{(SLUGS.values.sum(&:length).to_f / SLUGS.length).round(1)}"
puts "Самый длинный slug: #{SLUGS.values.max_by(&:length)}"
