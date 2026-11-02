# KURERINFO

Локальный Hugo-сайт о работе курьером: лендинг, сценарный калькулятор дохода, городские страницы и WIKI.

## Запуск

Нужен Hugo. Сайт проверен на Hugo 0.169.0.

```bash
hugo server
```

Локальный адрес: `http://localhost:1313/`.

Финальная сборка:

```bash
hugo --gc --minify --panicOnWarning
```

Готовые статические файлы появятся в `public/`.

## Публикация на GitHub Pages

Репозиторий содержит workflow `.github/workflows/deploy.yml`. При каждом push в ветку `main` GitHub Actions устанавливает Hugo, собирает сайт и публикует каталог `public/` в GitHub Pages.

В настройках репозитория выберите `Settings → Pages → Source: GitHub Actions`, затем укажите custom domain `kurerinfo.ru`. DNS домена должен быть направлен на GitHub Pages отдельно.

## Настройки перед публикацией

- `baseURL` в `hugo.toml` — сейчас указан `https://kurerinfo.ru/`.
- `params.referral_url` — короткая ссылка регистрации `https://clck.ru/3WpciR`.
- `params.registration_redirect_url` — внутренняя промежуточная страница `/go/yandex-courier/`.
- `params.yandex_metrika_id` — поставьте идентификатор Метрики вместо `0`, если аналитика нужна.
- `static/admin/config.yml` → `backend.repo` — проверьте имя GitHub-репозитория перед использованием `/admin/`.

Изображения и видео, использованные в дизайне, сохранены локально в `static/media/`.

## Проверка ссылок

После сборки:

```bash
ruby scripts/audit_site.rb public
```

Проверка уникальности WIKI относительно материалов из `пример/kurergo`:

```bash
ruby scripts/audit_wiki_uniqueness.rb
```

Проверка коротких WIKI URL и отсутствия старых маршрутов из сайта-примера:

```bash
ruby scripts/audit_wiki_urls.rb
```

Сценарий `scripts/rewrite_wiki.rb` является редакционным генератором корпуса. Запускайте его с `--write` только если нужно заново пересобрать все статьи: команда перезаписывает их тела, description и FAQ, сохраняя URL и ключевые запросы.
