# Metrostroi Clock Arrive V2.0 (RU)

![Metrostroi Clock Arrive](http://mss.community/images/addons/metrostroi_clock_arrive_v20.jpg)

**Модель:** Jarrius

**Оригинальные скрипты:** Alexell: https://alexell.ru/

**Оригинальный аддон в Steam Workshop:** https://steamcommunity.com/sharedfiles/filedetails/?id=1975028372

**Что нового:**
* Теперь каждый монитор - самостоятельная энтити и выполняет все вычисления независимо от других
* Оптимизирована передача данных от сервера игрокам
* Добвален режим ожидания с надписью "Подключение установлено"

**Описание:**

Мониторы для станций, отображающие линию, направление и время до прибытия состава.

**Как спавнить и сохранять:**

* **Primary (ЛКМ):** Заспавнить монитор / обновить настройки (если наводились на существующий монитор)
* **Secondary (ПКМ):** Удалить монитор
* **Reload (R):** Копировать настройки монитора

При спавне монитора, необходимо указывать в меню спавнера ID станции, номер пути, линию и ее цвет, а также направление (обычно это название следующей станции, но можно указывать и конечную, это на ваш вкус). Обратите внимание, что ID станции и номер пути должны **строго соответствовать данным с платформы на станции**. Вы можете включить галочку Метростроя "Отладочная информация сигнализации", чтобы видеть метки платформы и с них брать значения для часов.

После спавна всех мониторов на карте, необходимо **сохранить** их соответствующей кнопкой меню спавнера. Данные по ним будут сохранены в `data/clocks_arrive.txt` вашего сервера и мониторы будут автоматически спавниться при загрузке карты.

**Будьте внимательны:** нажатие кнопки "Загрузить часы" удалит все заспавненные мониторы на карте, прежде чем загрузить их из файла.

**Исправляем поворот новой модели монитора:**

Если у вас есть сохраненные до обновления аддона мониторы, то скорее всего теперь они повернуты неправильно. Для того чтобы атоматически исправить все мониторы на карте, в спавнере предусмотена кнопка "Исправить старые углы/позиции".

**P.S.** Для того чтобы быстро прописать линию и цвет на все мониторы, используйте кнопку **R** чтобы копировать настройки монитора, затем измените линию и цвет и обновите настройки монитора по **ЛКМ**.

Не забывайте сохранять мониторы после внесения любых изменений!


# Metrostroi Clock Arrive V2.0 (EN)

**Models:** Jarrius

**Scripts:** Alexell

**Original addon on Steam Workshop:** https://steamcommunity.com/sharedfiles/filedetails/?id=1975028372

**Changelog:**
* Each monitor is a standalone entity and calculates everything itself independently of others
* Optimized data transmission between server and clients
* Added start screen for monitors whith M and text "Подключение установлено"

**Description:**

Monitors that show line, destination, and the approximate time of the next train arival.

**How to spawn and save:**

* **Primary (LMB):** Spawn a new monitor / update monitor (if aimed on an existing monitor)
* **Secondary (RMB):** Remove a monitor (if aimed on an existing monitor)
* **Reload (R):** Copy monitor properties to spawner menu

Before spawning a monitor you need to define station ID, station path, number and color of line and destination (usually next station or ending station). You can enable debug mode in Metrostroi to check station platform marks that show station ID and station path. Mind that station ID and station path **must be valid and refer to a station you spawn a monitor**.

After all monitor are spawned (or after each monitor spawn) you need to click **save** button in spawned menu. All monitors' data will be saved to `data/clocks_arrive.txt` on your server. Monitors themselves will be automatically spawned on map start.

**Notice**: pressing **load clocks** button will cause deletion of all existing monitors on map and respawn of all clocks saved in `data/clocks_arrive.txt` file.

**Fix angles of new monitors:**

If you have some old monitors, that use old model, then you will face a problem with wrong spawn angles. Use the "fix old positions/angles" to fix that.

**P.S.** Don't forget to save all changes that you've made before disconnecting, restarting server or changing map!

