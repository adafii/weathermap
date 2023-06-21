#include "Weather.h"

Weather::Weather() : Weather(nullptr) {
}

Weather::Weather(QObject* parent) : QObject{parent} {
    QObject::connect(&timer_, &QTimer::timeout, this, QOverload<>::of(&Weather::updateTemperature));
    timer_.start(1000);
}

void Weather::updateTemperature() {
    if (!coordinate_.isValid()) {
        return;
    }

    temperature_++;
    emit temperatureChanged();
}

double Weather::temperature() const {
    return temperature_;
}

void Weather::setCoordinate(double latitude, double longitude) {
    coordinate_.setLatitude(latitude);
    coordinate_.setLongitude(longitude);
    updateTemperature();
    timer_.start();
}
