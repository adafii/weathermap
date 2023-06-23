#pragma once

#include <QGeoCoordinate>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QString>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

const QString URL = "https://api.met.no/weatherapi/locationforecast/2.0/compact";
const QByteArray USER_AGENT = "weathermap/0.1 https://github.com/adafii/weathermap";
const auto UPDATE_DELAY = 60 * 60 * 1000;  // ms

class Weather : public QObject {
    Q_OBJECT
    Q_PROPERTY(double temperature READ temperature NOTIFY temperatureChanged)
    Q_PROPERTY(QString icon READ icon NOTIFY iconChanged)
    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)
    QML_ELEMENT

public:
    Weather();
    explicit Weather(QObject* parent);

    double temperature() const;
    QString icon() const;
    bool isValid() const;
    Q_INVOKABLE void setCoordinate(double latitude, double longitude);

signals:
    void temperatureChanged();
    void iconChanged();
    void isValidChanged();

private slots:
    void updateTemperature();
    void requestComplete(QNetworkReply* reply);

private:
    double temperature_{0};
    QString icon_{};
    bool isValid_{false};
    QGeoCoordinate coordinate_{};
    QNetworkAccessManager networkManager_{};
    QTimer timer_{};
};