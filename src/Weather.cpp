#include "Weather.h"

Weather::Weather() : Weather(nullptr) {
}

Weather::Weather(QObject* parent) : QObject{parent} {
    QObject::connect(&networkManager_, &QNetworkAccessManager::finished, this, &Weather::requestComplete);
    QObject::connect(&timer_, &QTimer::timeout, this, &Weather::updateTemperature);
    timer_.start(UPDATE_DELAY);
}

void Weather::updateTemperature() {
    if (!isValid()) {
        return;
    }

    isValid_ = false;
    emit isValidChanged();

    auto query = QString("?lat=%1&lon=%2").arg(coordinate_.latitude()).arg(coordinate_.longitude());
    QNetworkRequest request(QUrl(URL + query));
    request.setRawHeader("User-Agent", USER_AGENT);
    networkManager_.get(request);
}

void Weather::requestComplete(QNetworkReply* reply) {
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "Network error: " << reply->error();
        return;
    }

    auto jsonDoc = QJsonDocument::fromJson(reply->readAll());
    if (!jsonDoc.isObject()) {
        qDebug() << "Unable to read the data\n";
        return;
    }

    auto object = jsonDoc.object();
    auto units = object["properties"].toObject()["meta"].toObject()["units"].toObject();
    auto timeseries = object["properties"].toObject()["timeseries"].toArray();

    if (units.isEmpty() || timeseries.isEmpty()) {
        qDebug() << "Empty data\n";
        return;
    }

    if(units["air_temperature"].toString() != "celsius") {
        qDebug() << "Unknown temperature unit\n";
        return;
    }

    auto weather = timeseries[0].toObject()["data"].toObject()["instant"].toObject()["details"].toObject();
    auto temperature = weather["air_temperature"];
    auto symbol = timeseries[0]
                    .toObject()["data"]
                    .toObject()["next_6_hours"]
                    .toObject()["summary"]
                    .toObject()["symbol_code"];

    if(temperature.isUndefined() || symbol.isUndefined()) {
        qDebug() << "Temperature could not be read\n";
        return;
    }

    temperature_ = temperature.toDouble();
    isValid_ = true;

    emit isValidChanged();
    emit temperatureChanged();

    timer_.start();
}

double Weather::temperature() const {
    return temperature_;
}

void Weather::setCoordinate(double latitude, double longitude) {
    coordinate_.setLatitude(latitude);
    coordinate_.setLongitude(longitude);
    isValid_ = coordinate_.isValid();
    updateTemperature();
}

bool Weather::isValid() const {
    return isValid_;
}
