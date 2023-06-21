#pragma once

#include <QGeoCoordinate>
#include <QObject>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

class Weather : public QObject {
    Q_OBJECT
    Q_PROPERTY(double temperature READ temperature NOTIFY temperatureChanged)
    QML_ELEMENT

public:
    Weather();
    explicit Weather(QObject* parent);

    double temperature() const;
    Q_INVOKABLE void setCoordinate(double latitude, double longitude);

signals:
    void temperatureChanged();

private slots:
    void updateTemperature();

private:
    double temperature_{0};
    QGeoCoordinate coordinate_{};
    QTimer timer_{};
};