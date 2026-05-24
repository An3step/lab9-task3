#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTranslator>
#include <QLocale>
#include <QDebug>
#include "MediaPlayerBackend.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Локализация
    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "MediaApp_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }

    MediaPlayerBackend backend;
    QQmlApplicationEngine engine;

    // Регистрация бэкенда
    engine.rootContext()->setContextProperty("backend", &backend);

    // Стандартный путь QRC в Qt 6: qrc:/qt/qml/[URI]/[Файл]
    const QUrl url(u"qrc:/qt/qml/MediaApp/Main.qml"_qs);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, [url]() {
            qCritical() << "Критическая ошибка: не удалось загрузить" << url;
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
