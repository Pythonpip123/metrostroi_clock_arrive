# Metrostroi Clock Arrive V2.1 (RU)

![Metrostroi Clock Arrive](http://mss.community/images/addons/metrostroi_clock_arrive_v21.jpg)

**Модель:** Jarrius

**Оригинальные скрипты:** Alexell: https://alexell.ru/

**Оригинальный аддон в Steam Workshop:** https://steamcommunity.com/sharedfiles/filedetails/?id=1975028372

**Новая версия в Steam Workshop:** https://steamcommunity.com/sharedfiles/filedetails/?id=2579263629

**Что нового:**
* Теперь каждый монитор - самостоятельная единица и выполняет все просчёты независимо от других
* Оптимизирована передача данных от сервера игрокам
* Добавлен режим ожидания с логотипом М и надписью "Подключение установлено"
* Добавлен параметр Дистанция, который определяет дальность просчёта (в метрах) для каждого монитора
* Добавлена локализация (RU + EN)

**Описание:**

Мониторы для станций, отображающие линию, направление и время прибытия ближайшего поезда.

**Как спавнить и сохранять:**

* **Primary (ЛКМ):** Заспавнить монитор / обновить настройки (если наводились на существующий монитор)
* **Secondary (ПКМ):** Удалить монитор
* **Reload (R):** Копировать настройки монитора

При спавне монитора, необходимо указывать в меню спавнера ID станции, номер пути, линию и её цвет, а также направление (обычно это название следующей станции, но можно указывать и конечную). Обратите внимание, что ID станции и номер пути должны **строго соответствовать данным с платформы на станции**. Вы можете включить галочку Метростроя "Отладочная информация сигнализации", чтобы видеть метки платформы, и взять с них данные для часов.

После спавна всех мониторов на карте, необходимо **сохранить** их соответствующей кнопкой меню спавнера. Данные будут сохранены в `data/clocks_arrive.txt` вашего сервера и мониторы будут автоматически спавниться при загрузке карты.

**Будьте внимательны:** нажатие кнопки "Загрузить часы" удалит все заспавненные мониторы на карте, прежде чем загрузить их из файла.

**Исправляем данные в файле сохранения:**

Если у вас есть мониторы, созданные до выхода версии 2.1, то на сервере будет ошибка спавна часов. Чтобы исправить данные в файле clocks_arrive.txt, воспользуйтесь кнопкой "Исправить старые данные".

**P.S.** Не забывайте сохранять мониторы после внесения любых изменений !


# Metrostroi Clock Arrive V2.1 (EN)

**Models:** Jarrius

**Scripts:** Alexell

**Original addon on Steam Workshop:** https://steamcommunity.com/sharedfiles/filedetails/?id=1975028372

**V2.1 addon в Steam Workshop:** https://steamcommunity.com/sharedfiles/filedetails/?id=2579263629

**Changelog:**
* Each monitor is a standalone entity and calculates everything itself independently of others
* Optimized data transmission between server and clients
* Added standby screen for monitors whith M and text "Подключение установлено"
* Added new parameter Distance, that defines the distance of calculation (in meters) for each clocks
* Added localization (RU + EN)

**Description:**

Monitors that show line, destination, and the approximate time of the next train arrival.

**How to spawn and save:**

* **Primary (LMB):** Spawn a new monitor / update monitor (if aimed on an existing monitor)
* **Secondary (RMB):** Remove a monitor (if aimed on an existing monitor)
* **Reload (R):** Copy monitor properties to spawner menu

Before spawning a monitor you need to define station ID, station path, number and color of line and destination (usually next station or ending station). You can enable debug mode in Metrostroi to check station platform marks that show station ID and station path. Mind that station ID and station path **must be valid and refer to a station you spawn a monitor**.

After all monitor are spawned (or after each monitor spawn) you need to click **save** button in spawned menu. All monitors' data will be saved to `data/clocks_arrive.txt` on your server. Monitors themselves will be automatically spawned on map start.

**Notice**: pressing **load** button will cause deletion of all existing monitors on map and respawn of all monitors saved in `data/clocks_arrive.txt` file.

**Fix old savedata:**
If you have some old monitors, spawned and saved before version 2.1 release, you will have spawn errors on serverside. Use fix button to update clock savedata and reload all clocks afterwards.

**P.S.** Don't forget to save all changes that you've made before disconnecting, restarting server or changing map!

