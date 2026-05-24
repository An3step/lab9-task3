cmake_minimum_required(VERSION 3.16)

project(Task_9_3 VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Quick и LinguistTools оставляем обязательными
find_package(Qt6 REQUIRED COMPONENTS Quick LinguistTools)
# Multimedia, Sql и Test делаем опциональными для WebAssembly
find_package(Qt6 COMPONENTS Multimedia Sql Test)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appTask_9_3
    main.cpp
    MediaPlayerBackend.cpp MediaPlayerBackend.h
)

qt_add_qml_module(appTask_9_3
    URI MediaApp
    QML_FILES
        Main.qml
        PlayerControls.qml
        TrackList.qml
        PlatformUI.qml
    RESOURCES
        "default_cover.png"
)

# Localization
set(TS_FILES
    "i18n/MediaApp_en_US.ts"
    "i18n/MediaApp_ru_RU.ts"
    "i18n/MediaApp_be_BY.ts"
)
qt_add_translations(appTask_9_3 TS_FILES ${TS_FILES})

# Линковка с проверкой наличия компонентов
target_link_libraries(appTask_9_3 PRIVATE Qt6::Quick)

if(TARGET Qt6::Multimedia)
    target_link_libraries(appTask_9_3 PRIVATE Qt6::Multimedia)
endif()

if(TARGET Qt6::Sql)
    target_link_libraries(appTask_9_3 PRIVATE Qt6::Sql)
endif()

# Тесты (собираем, только если есть модуль Test)
if(TARGET Qt6::Test)
    enable_testing()
    add_executable(test_backend tests/test_backend.cpp MediaPlayerBackend.cpp)
    target_link_libraries(test_backend PRIVATE Qt6::Test)
    if(TARGET Qt6::Sql)
        target_link_libraries(test_backend PRIVATE Qt6::Sql)
    endif()
    if(TARGET Qt6::Multimedia)
        target_link_libraries(test_backend PRIVATE Qt6::Multimedia)
    endif()

    if(EMSCRIPTEN)
        target_link_options(test_backend PRIVATE "--bind" "-sASYNCIFY")
    endif()

    add_test(NAME BackendTest COMMAND test_backend)
endif()

set_target_properties(appTask_9_3 PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

if(EMSCRIPTEN)
    # --bind подключает библиотеку Embind, необходимую для работы QtCore и QLocale
    # -sASYNCIFY позволяет Qt обрабатывать события внутри вложенных циклов и корректно завершаться
    target_link_options(appTask_9_3 PRIVATE
        "-sALLOW_MEMORY_GROWTH=1"
        "--bind"
        "-sASYNCIFY"
    )
endif()
