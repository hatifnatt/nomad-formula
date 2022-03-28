<!-- omit in toc -->
# nomad formula

Формула для установки и настройки HashiCorp Nomad.

* [Использование](#использование)
* [Доступные стейты](#доступные-стейты)
  * [nomad](#nomad)
  * [nomad.repo](#nomadrepo)
  * [nomad.repo.clean](#nomadrepoclean)
  * [nomad.install](#nomadinstall)
  * [nomad.binary.install](#nomadbinaryinstall)
  * [nomad.binary.clean](#nomadbinaryclean)
  * [nomad.package.install](#nomadpackageinstall)
  * [nomad.package.clean](#nomadpackageclean)
  * [nomad.config](#nomadconfig)
  * [nomad.config.tls](#nomadconfigtls)
  * [nomad.service](#nomadservice)
  * [nomad.service.install](#nomadserviceinstall)
  * [nomad.service.clean](#nomadserviceclean)
  * [nomad.shell_completion](#nomadshell_completion)
  * [nomad.shell_completion.clean](#nomadshell_completionclean)
  * [nomad.shell_completion.bash](#nomadshell_completionbash)
  * [nomad.shell_completion.bash.install](#nomadshell_completionbashinstall)
  * [nomad.shell_completion.bash.clean](#nomadshell_completionbashclean)

## Использование

* Создаем pillar с данными, см. `pillar.example` для качестве примера, привязываем его к хосту в pillar top.sls.
* Применяем стейт на целевой хост `salt 'nomad-01*' state.sls service.nomad saltenv=base pillarenv=base`.
* Прикрепить формулу к хосту в state top.sls, для выполнения оной при запуске `state.highstate`.

__ВНИМАНИЕ__  

С настройками по умолчанию запущенный nomad agent не будет работать, т.к. он будет запущен в режиме клиента, но адреса для подключения к серверу у него не будет. Таким образом, для запуска сервиса __обязательно__ нужно создать pillar с корректными данными.

## Доступные стейты

### nomad

Мета стейт, выполняет все необходимое для настройки сервиса на отдельном хосте.

### nomad.repo

Стейт для настройки официального репозитория HashiCorp <https://www.hashicorp.com/blog/announcing-the-hashicorp-linux-repository>

### nomad.repo.clean

Стейт для удаления репозитория, используйте с осторожностью, т.к. данный репозиторий используется для всех продуктов HashiCorp.

### nomad.install

Вызывает стейт для установки Nomad в зависимости от значения пиллара `use_upstream`:

* `binary` или `archive`: установка из архива `nomad.binary.install`
* `package` или `repo`: установка из пакетов `nomad.package.install`

### nomad.binary.install

Установка Nomad из архива

### nomad.binary.clean

Удаление Nomad установленного из архива

### nomad.package.install

Установка Nomad из пакетов

### nomad.package.clean

Удаление Nomad установленного из пакетов

### nomad.config

Создает конфигурационный файл. Создает самоподписныой сертификат, или устанавливает готовый сертификат. Запускает сервис.

### nomad.config.tls

Управление TLS сертификатами для Nomad, при `tls:self_signed: true` будут сгенерированы ключ и самоподписной сертификат и сохранены по путям указаннымм в `nomad.config.data.tls.key_file`, `nomad.config.data.tls.cert_file`. При `tls:self_signed: false` и наличии данных в `tls:key_file_source`, `tls:cert_file_source` существующие ключ и сертификат будут скопированы по путям указаннымм `nomad.config.data.tls.key_file`, `nomad.config.data.tls.cert_file`.

### nomad.service

Управляет состоянием сервиса nomad, в зависимости от значений пилларов `nomad.service.status`, `nomad.service.on_boot_state`.

### nomad.service.install

Устанавливает файл сервиса Nomad, на данный момент поддерживается только одна система инициализации - `systemd`.

### nomad.service.clean

Останавливает сервис, выключает запуск сервиса при старте ОС, удаляет юнит файл `systemd`.

### nomad.shell_completion

Вызывает стейты `nomad.shell_completion.*` на данный момент только `nomad.shell_completion.bash`.

### nomad.shell_completion.clean

Вызывает стейты `nomad.shell_completion.*.clean` на данный момент только `nomad.shell_completion.bash.clean`.

### nomad.shell_completion.bash

Вызывает стейт `nomad.shell_completion.bash.install`

### nomad.shell_completion.bash.install

Устанавливает автодополнение для bash

### nomad.shell_completion.bash.clean

Удаляет автодополнение для bash
