```bash
mkdir devise

git clone https://github.com/YouraSilin/TurboSearch.git devise

cd devise
```
delete all folders and files except

docker-compose.yml

Dockerfile

entrypoint.sh

Gemfile

package.json

Procfile.dev
```bash
docker compose build

docker compose run --no-deps web rails new . --force --database=postgresql --css=bootstrap

sudo chown -R $USER:$USER .
```
replace this files

https://github.com/YouraSilin/TurboSearch/blob/master/config/database.yml

https://github.com/YouraSilin/TurboSearch/blob/master/Dockerfile

https://github.com/YouraSilin/TurboSearch/blob/master/Gemfile
```bash
cd app/assets/images/

wget https://raw.githubusercontent.com/YouraSilin/TurboSearch/refs/heads/master/app/assets/images/bars.svg

cd ~/devise

docker compose up

docker compose exec web rake db:create db:migrate

sudo chown -R $USER:$USER .

docker compose exec web rails generate devise:install

docker compose exec web rails generate devise User

docker compose exec web rails generate migration AddRoleToUsers role:string

docker compose exec web rails db:migrate

sudo chown -R $USER:$USER .
```
Here is a possible configuration for config/environments/development.rb:
```erb
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```
В файл app/views/layouts/application.html.erb добавьте:
```erb
    <ul class="navbar-nav ms-auto">
      <% if user_signed_in? %>
        <li class="nav-item">
          <span class="nav-link">Вы зашли как: <strong><%= current_user.email %></strong></span>
        </li>
        <li class="nav-item">
          <%= button_to "Выйти", destroy_user_session_path, method: :delete, class: "nav-link" %>
        </li>
      <% else %>
        <li class="nav-item">
          <%= link_to "Войти", new_user_session_path, class: "nav-link" %>
        </li>
        <li class="nav-item">
          <%= link_to "Регистрация", new_user_registration_path, class: "nav-link" %>
        </li>
      <% end %>
    </ul>
```
Модифицируйте модель User (app/models/user.rb), чтобы задать роли:
```erb
class User < ApplicationRecord

# Devise модули

devise :database_authenticatable, :registerable,

       :recoverable, :rememberable, :validatable

# Установим роли

enum role: { viewer: 'viewer', admin: 'admin' }

# Зададим роль по умолчанию

after_initialize do

  self.role ||= :viewer
  
end
  
end
```
Задайте дефолтную роль в консоли (для существующих пользователей).
```bash
docker compose exec web rails c

User.update_all(role: 'viewer')

exit
```
Создайте два контроллера — один для просмотра (режим просмотра) и другой для админки (режим редактирования).

Пример: создадим ресурс Posts.
```bash
docker compose exec web rails generate scaffold Post title:string content:text

docker compose exec web rails db:migrate

sudo chown -R $USER:$USER .

docker compose exec web bin/importmap pin jquery
```
В importmap.rb должно появиться
```erb
pin "jquery", preload: true # @3.7.1
```
В application.js нужно добавить
```erb
import $ from "jquery";

$(document).ready(function() {
  console.log("jQuery is ready!");
});
```
Ограничиваем доступ в контроллере:

Модифицируйте PostsController:
```erb
class PostsController < ApplicationController

  before_action :authenticate_user!
  
  before_action :authorize_admin, only: [:edit, :update, :destroy]

  # Только администратор может редактировать и удалять

  def edit
      @post = Post.find(params[:id])
  end
  
  private

  def authorize_admin
  
    redirect_to posts_path, alert: 'У вас нет прав для этого действия.' unless current_user&.admin?
  
  end

end
```
Добавьте проверку прав администратора в представления, где доступны действия редактирования и удаления:
```erb
<% if current_user&.admin? %>
  
  <%= link_to 'Редактировать', edit_post_path(@post) %>
  
  <%= button_to "Удалить эту запись", @post, method: :delete, data: { turbo_method: 'delete', turbo_confirm: "вы уверены?" } %>

<% end %>
```
В application.html.erb нужно добавить
``` erb
    <style>
      @keyframes fadeInFromNone {
        from {
          opacity: 0;
        }
        to {
          opacity: 1;
        }
      }
      .alert {
        visibility: hidden;
        padding: 15px 20px;
        margin: 15px;
        border: 1px solid #ccc;
        border-radius: 5px;
        position: fixed;
        bottom: 20px;
        left: 50%;
        transform: translateX(-50%);
        z-index: 9999;
        max-width: 90%;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      }
      .alert.success {
        background-color: #d4edda;
        color: #155724;
        border-color: #c3e6cb;
      }
      .alert.error {
        background-color: #f8d7da;
        color: #721c24;
        border-color: #f5c6cb;
      }
      .scroll-button {
        position: fixed;
        bottom: 20px;
        right: 20px;
        padding: 10px 15px;
        background-color: #007bff;
        border: none;
        border-radius: 5px;
        color: white;
        font-size: 14px;
        cursor: pointer;
        z-index: 1000;
      }
      .scroll-button:hover {
        background-color: #0056b3;
      }
      #spinner-overlay {
        visibility: hidden;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.1);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 1050;
        opacity: 0;
        transition: opacity 0.3s ease, visibility 0.3s ease;
    }
    #spinner-overlay.show {
        visibility: visible;
        opacity: 1;
    }
    .spinner {
      width: 150px;
      height: 150px; 
      opacity: 0.8;
    }
    </style>

    <% flash.each do |type, message| %>
      <% css_class = type == "notice" ? "success" : "error" %> <!-- Определение типа уведомления -->
      <div class="alert <%= css_class %>">
        <%= message %>
      </div>
    <% end %>

    <!-- Кнопка наверх -->
    <button id="scroll-to-top" class="scroll-button" style="display: none;">Наверх  </button>

    <%= render "shared/spinner" %>

    <!-- Первый вариант скрипта сообщений -->
    <script type="module">
      import $ from "jquery";

      $(document).ready(function() {
        // Показываем уведомление
        $(".alert").css("display", "block").css("opacity", "1").css("animation", "fadeInFromNone 1.2s");

        // Автоматическое скрытие через 2 секунды
        setTimeout(function() {
          $(".alert").fadeOut(1200);
        }, 2000);
      });
    </script>

    <!-- Второй вариант скрипта сообщений -->
    <script type="module">
        document.addEventListener("turbo:load", () => {
          // Показываем уведомления
          const alerts = document.querySelectorAll(".alert");
          alerts.forEach((alert) => {
            alert.style.visibility = "visible";
            alert.style.opacity = "1";
            alert.style.animation = "fadeInFromNone 1.2s";

            // Автоматическое скрытие через 2 секунды
            setTimeout(() => {
              alert.style.transition = "opacity 1.2s";
              alert.style.opacity = "0";

              // Удаляем элемент после того, как он полностью исчезнет
              setTimeout(() => {
                alert.style.visibility = "hidden";
              }, 1200);
            }, 2000);
          });
        });
      </script>

    <script type="module">
      document.addEventListener("turbo:load", () => {
        const scrollToTopButton = document.getElementById("scroll-to-top");

        if (!scrollToTopButton) return;

        // Функция для показа/скрытия кнопки при прокрутке
        const handleScroll = () => {
          if (window.scrollY > 200) { // Показываем кнопку, если прокрутили больше 200px
            scrollToTopButton.style.display = "block";
          } else {
            scrollToTopButton.style.display = "none";
          }
        };

        // Скролл-обработчик
        window.addEventListener("scroll", handleScroll);

        // Обработчик нажатия на кнопку
        scrollToTopButton.addEventListener("click", () => {
          window.scrollTo({
            top: 0,
            behavior: "smooth",
          });
        });
      });
    </script>
    
    <script>
      document.addEventListener("turbo:load", function () {
        const showSpinner = () => {
          const spinnerOverlay = document.getElementById("spinner-overlay");
            if (spinnerOverlay) {
              spinnerOverlay.style.visibility = "visible"; // Сначала делаем элемент видимым
              requestAnimationFrame(() => {
                spinnerOverlay.style.opacity = "1"; // Затем плавно показываем спиннер
                spinnerOverlay.style.animation = "fadeInFromNone 1.2s"
              });
              document.body.style.overflow = "hidden"; // Блокируем прокрутку
            }
        };

        const hideSpinner = () => {
          const spinnerOverlay = document.getElementById("spinner-overlay");
          if (spinnerOverlay) {
            spinnerOverlay.style.opacity = "0"; // Плавно убираем спиннер
            // Скрываем элемент после завершения анимации (например, через 300 мс)
            setTimeout(() => {
                spinnerOverlay.style.visibility = "hidden";
                document.body.style.overflow = ""; // Разблокируем прокрутку
            }, 300); // Время совпадает с длительностью transition
          }
        };

        const delayedHideSpinner = () => {
          setTimeout(hideSpinner, 1200); // Добавляем задержку в 1200 мс
        };

        // Показываем спиннер при отправке формы импорта
        document.querySelectorAll("form.import-form").forEach((form) => {
          form.addEventListener("submit", () => {
            showSpinner();

            // Прячем спиннер через событие 'submit-end' (например, если используется Turbo)
            document.addEventListener("turbo:submit-end", delayedHideSpinner, { once: true });
          });
        });

        // Показываем спиннер при клике на ссылки для скачивания файлов
        document.querySelectorAll("a.download-file").forEach((link) => {
          link.addEventListener("click", async (event) => {
          showSpinner();
          try {
            const url = event.target.href;
            const response = await fetch(url);
            const blob = await response.blob();
            const downloadUrl = window.URL.createObjectURL(blob);

            const tempLink = document.createElement("a");
            tempLink.href = downloadUrl;
            tempLink.download = link.getAttribute("data-filename") || "downloaded-file";
            document.body.appendChild(tempLink);
            tempLink.click();
            tempLink.remove();
            window.URL.revokeObjectURL(downloadUrl);
          } catch (error) {
            console.error("Ошибка при скачивании файла:", error);
          } finally {
            hideSpinner();
          }

          event.preventDefault(); // Предотвращение стандартного поведения
          });
        });

        // Показываем спиннер при клике на кнопку с class "delete-button"
        document.querySelectorAll(".delete-button").forEach((button) => {
          button.addEventListener("click", () => {
          showSpinner();

          // Прячем спиннер через событие 'turbo:submit-end'
          document.addEventListener("turbo:submit-end", delayedHideSpinner, { once: true });
        });
      });
    });
</script>
```
Добавление администратоа
```bash
docker compose exec web rails c

user = User.find_by(email: "email@example.com")

user.update(role: "admin")
