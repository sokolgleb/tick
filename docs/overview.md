# Tick — Simple Time Tracker

## Что это?

Tick — кроссплатформенное приложение для трекинга времени и подсчёта повторений. Минималистичный интерфейс, иерархические активности, гибкая статистика. Работает на вебе, Android, iOS, macOS, Linux, Windows.

**GitHub:** https://github.com/sokolgleb/tick

## Зачем?

Простой персональный трекер без лишнего. Создаёшь активности (например "Чтение", "Спорт", "Код"), логируешь время или количество. Смотришь статистику за день, неделю, месяц, год. Данные синхронизируются между устройствами через облако.

## Стек

| Технология | Роль |
|---|---|
| **Flutter 3.38** | UI, кроссплатформенность |
| **Supabase** | Auth (анонимный, Google, email) + PostgreSQL БД |
| **Riverpod** | State management (провайдеры, реактивность) |
| **GoRouter** | Навигация (path-based URL strategy на вебе) |
| **SharedPreferences** | Локальный кэш настроек |

## Ключевые фичи

- **Иерархические активности** — активности могут содержать подактивности (дерево любой глубины). Статистика родителя включает все дочерние.
- **Два типа трекинга** — время (минуты) и количество (повторения). Одна запись может содержать оба значения.
- **Пресеты логирования** — быстрые кнопки: 5м, 10м, 15м, 30м, 1ч для времени; +1, +5, +10, +25 для счётчика. Или произвольное значение.
- **Статистика по периодам** — сегодня, вчера, неделя, месяц, год, всё время, произвольный диапазон.
- **Два режима отображения** — список или сетка (с опциональной цветовой заливкой).
- **Архивация** — мягкое удаление: активность скрывается, данные сохраняются.
- **Локализация** — 5 языков: English, Русский, Italiano, Turkce, Espanol + системный.
- **Темы** — светлая, тёмная, системная.
- **Анонимный режим** — приложение работает сразу, без регистрации. Данные привязаны к анонимной сессии.
- **Привязка аккаунта** — анонимный пользователь может привязать Google или email, сохранив свои данные.
- **Удаление аккаунта** — полное удаление данных + пользователя из auth.users.

---

## Архитектура

### Структура проекта

```
lib/
  core/           # Тема, константы, расширения, преференсы
  l10n/           # Локализация (ARB-файлы + сгенерированный код)
  models/         # Модели данных (Activity, TimeEntry, EntrySort, StatPeriod)
  providers/      # Riverpod-провайдеры (auth, activities, time_entries, preferences)
  repositories/   # Слой данных (Supabase-клиент)
  routing/        # GoRouter конфигурация
  screens/        # Экраны (Home, ActivityDetail, Auth, Settings)
  widgets/        # Переиспользуемые виджеты
  app.dart        # MaterialApp.router
  main.dart       # Точка входа

supabase/
  migrations/     # SQL-миграции (5 файлов)
```

### Экраны

| Роут | Экран | Назначение |
|---|---|---|
| `/` | HomeScreen | Список/сетка активностей, выбор периода, итоги |
| `/activity/:id` | ActivityDetailScreen | Детали активности, логирование, статистика, история, дочерние |
| `/auth` | AuthScreen | Вход (Google, email), регистрация, привязка аккаунта |
| `/settings` | SettingsScreen | Тема, язык, вид, аккаунт, выход, удаление |

### Слои

```
UI (Screens / Widgets)
  |
  v
State (Riverpod Providers)
  |
  v
Data (Repositories)
  |
  v
Backend (Supabase: Auth + PostgreSQL + RPC)
```

---

## База данных

### Таблицы

#### activities

| Поле | Тип | Описание |
|---|---|---|
| `id` | UUID, PK | |
| `user_id` | UUID, FK → auth.users | Владелец |
| `name` | text | Название |
| `color` | text | Hex-цвет (#FF5722) |
| `position` | int | Порядок сортировки |
| `archived` | bool | Мягкое удаление |
| `parent_id` | UUID, FK → activities | Родительская активность (NULL = корневая) |
| `created_at` | timestamptz | |
| `updated_at` | timestamptz | Автообновление через триггер |

#### time_entries

| Поле | Тип | Описание |
|---|---|---|
| `id` | UUID, PK | |
| `activity_id` | UUID, FK → activities | |
| `user_id` | UUID, FK → auth.users | |
| `value` | numeric | Время в минутах |
| `count_value` | numeric | Количество (повторения) |
| `date` | date | Дата записи |
| `note` | text | Заметка (опционально) |
| `created_at` | timestamptz | |

**Constraint:** `value > 0 OR count_value > 0` — хотя бы одно значение должно быть.

#### user_preferences

| Поле | Тип | Описание |
|---|---|---|
| `user_id` | UUID, UNIQUE | |
| `theme` | text | light / dark / system |
| `locale` | text | Код языка или system |
| `view_mode` | text | list / grid |

### RLS (Row-Level Security)

Все таблицы защищены RLS. Пользователь видит и изменяет только свои данные — фильтр `auth.uid() = user_id` на всех операциях (SELECT, INSERT, UPDATE, DELETE).

### RPC-функции

| Функция | Назначение |
|---|---|
| `get_activity_subtree_total(id, from, to)` | Рекурсивный подсчёт итогов по дереву (CTE) |
| `get_activity_children(parent_id)` | Прямые потомки активности |
| `delete_anonymous_data()` | Удаление данных анонимного пользователя |
| `merge_anonymous_to_account(target_id)` | Перенос данных анонима → постоянный аккаунт |
| `delete_user_account()` | Удаление аккаунта + всех данных (security definer) |

### Миграции

```
20240909000001_initial.sql          # Таблицы, RLS, RPC (delete_anonymous, merge)
20260909000002_redesign.sql         # parent_id, user_preferences, subtree RPC
20260909000003_entry_type.sql       # Tracking type
20260909000004_dual_values.sql      # value + count_value (dual tracking)
20260910000005_delete_account.sql   # delete_user_account() RPC
```

---

## Аутентификация

### Потоки

```
Первый запуск
  └→ signInAnonymously() → анонимная сессия → данные привязаны к временному UID

Привязка аккаунта (анонимный → постоянный)
  ├→ linkWithGoogle()  — OAuth (на вебе redirect, на мобильных нативный)
  ├→ linkWithEmail()   — updateUser(email, password)
  └→ Данные сохраняются под тем же UID

Вход в существующий аккаунт (есть конфликт с анонимными данными)
  ├→ Нет данных → signOut + signIn (данные анонима теряются)
  └→ Есть данные → диалог подтверждения → deleteAnonymousData + signOut + signIn

Выход
  └→ signOut() → signInAnonymously() → новая анонимная сессия

Удаление аккаунта
  └→ RPC delete_user_account() → signInAnonymously() → новая сессия
```

### Особенности веба

На вебе OAuth redirect-based — try/catch не работает через перезагрузку страницы. Поэтому:
- `linkIdentity` на вебе **не вызывается** — сразу `signInWithOAuth`
- `redirectTo` = `Uri.base.origin` (текущий порт dev-сервера)
- `usePathUrlStrategy()` — чтобы hash-фрагменты Supabase (`#access_token=...`) не ломали GoRouter

---

## State Management (Riverpod)

### Провайдеры

**Auth:**
- `authRepositoryProvider` → `AuthRepository` (синглтон)
- `authStateProvider` → `Stream<AuthState>` (реактивно слушает изменения сессии)
- `isAnonymousProvider` → `bool`

**Активности:**
- `activitiesProvider` → `AsyncNotifier<List<Activity>>` (корневые, неархивированные)
- `childActivitiesProvider(parentId)` → дочерние активности
- `activityProvider(id)` → одна активность
- `activityAncestorsProvider(id)` → цепочка предков (для breadcrumb)

**Записи и статистика:**
- `todayTotalsProvider` → итоги за сегодня по всем активностям
- `homeTotalsProvider` → итоги за выбранный период
- `homeSubtreeTotalsProvider(id)` → итоги поддерева
- `activityEntriesProvider({id, sort})` → записи одной активности
- `activitySubtreeStatsProvider({id, range})` → статистика по периодам

**Настройки:**
- `themeModeProvider`, `localeProvider`, `viewModeProvider`, `coloredGridProvider`
- Хранятся в SharedPreferences локально + синхронизируются с Supabase

### Механизм обновления

`timeEntriesVersionProvider` — глобальный счётчик. При логировании времени/счёта инкрементируется, что инвалидирует все зависимые провайдеры (итоги, статистика). Это позволяет обновлять данные без ручного refresh каждого провайдера.

---

## UI / Дизайн

### Тема

Минималистичная, монохромная. Два варианта:

| | Светлая | Тёмная |
|---|---|---|
| Фон | #FFFFFF | #0F0F0F |
| Surface | #FAFAFA | #1A1A1A |
| Текст | #111111 | #F0F0F0 |
| Вторичный | #888888 | #777777 |

Кнопки, диалоги, карточки — скругление 8px, без теней. AppBar без elevation.

### Виджеты

| Виджет | Назначение |
|---|---|
| `ActivityTile` | Элемент списка: цветная полоска, название, итог, кол-во дочерних |
| `ActivityGridTile` | Карточка в сетке (опционально с цветным фоном) |
| `AddActivityDialog` | Создание/редактирование: имя + палитра цветов |
| `LogTimeWidget` | Пресеты времени (5м, 10м, ...) + кастомное |
| `LogCountWidget` | Пресеты счёта (+1, +5, ...) + кастомное |
| `TimeEntryList` | Пагинированная история записей |
| `TimeStatsCard` | Карточка итогов за период |
| `DateRangeSelector` | Переключатель периодов + произвольный диапазон |
| `AnonymousConflictDialog` | Диалог конфликта при входе (потеря анонимных данных) |

### Форматирование

Расширения в `core/extensions.dart`:
- `120` → "2h 0m" / "2ч 0м" (локализовано)
- `45` → "45m" / "45м"
- `12.0` count → "12x"
- Комбо: "2h 15m + 12x"
- Даты: "Today", "Yesterday", "Jan 15" (локализовано)

---

## Локализация

5 языков + системный выбор:

| Код | Язык | Файл |
|---|---|---|
| en | English | `app_en.arb` (шаблон) |
| ru | Русский | `app_ru.arb` |
| es | Espanol | `app_es.arb` |
| it | Italiano | `app_it.arb` |
| tr | Turkce | `app_tr.arb` |

Генерация через `flutter gen-l10n` (настройка в `l10n.yaml`). Доступ: `S.of(context)!.keyName`.

---

## Запуск

### Требования

- Flutter 3.38+
- Supabase-проект с примёнёнными миграциями и включёнными Anonymous Sign-Ins
- Google OAuth credentials (для входа через Google)

### Локальная разработка

```bash
# Веб (порт 3000 — совпадает с redirect URL в Supabase)
flutter run -d chrome --web-port=3000 \
  --dart-define=GOOGLE_WEB_CLIENT_ID=<your-web-client-id>

# macOS
flutter run -d macos

# Android
flutter run -d <device-id> \
  --dart-define=GOOGLE_WEB_CLIENT_ID=<web-client-id> \
  --dart-define=GOOGLE_IOS_CLIENT_ID=<ios-client-id>
```

### Применение миграций

```bash
supabase db push
# или вручную: выполнить SQL-файлы из supabase/migrations/ по порядку
```

### Настройка Supabase

1. Создать проект на supabase.com
2. Применить все миграции из `supabase/migrations/`
3. **Auth > Settings** → включить Anonymous Sign-Ins
4. **Auth > Providers** → включить Google, указать Client ID и Secret
5. **Auth > URL Configuration** → добавить redirect URLs:
   - `http://localhost:3000` (веб, разработка)
   - `com.sokolgleb.tick://login-callback` (мобильные)
6. Обновить `supabaseUrl` и `supabaseAnonKey` в `lib/core/constants.dart`
