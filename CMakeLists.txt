cmake_minimum_required(VERSION 3.18)
project("Weathermap" LANGUAGES CXX)

find_package(Qt6 COMPONENTS Gui Quick Qml QuickControls2 Svg Positioning Network REQUIRED)
qt_standard_project_setup(REQUIRES 6.5)

set(source_dir src)
set(qml_dir qml)
set(images_dir images)

set(main_target weathermap)
set(main_src ${source_dir}/main.cpp)

qt_add_executable(${main_target}
        ${main_src}
        ${source_dir}/Weather.cpp
        )

qt_add_qml_module(${main_target}
        URI App
        NO_RESOURCE_TARGET_PATH
        QML_FILES
            "qml/main.qml"
            "qml/MapView.qml"
            "qml/Marker.qml"
        SOURCES
            ${source_dir}/Weather.cpp ${source_dir}/Weather.h
        )

qt_add_resources(${main_target} "app_images"
        PREFIX "/"
        FILES images/marker.svg
        )

target_include_directories(${main_target} PRIVATE ${source_dir})

target_link_libraries(${main_target} PRIVATE
        Qt6::Gui
        Qt6::Quick
        Qt6::Qml
        Qt6::QuickControls2
        Qt6::Svg
        Qt6::Positioning
        Qt6::Network
        )

target_compile_features(${main_target} PRIVATE cxx_std_20)
target_compile_options(${main_target} PRIVATE $<$<CONFIG:Debug>:-Wall -Wextra -Wpedantic -fsanitize=address -fsanitize=undefined>)
target_compile_options(${main_target} PRIVATE $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>:-Wall -Wextra -Wpedantic -flto>)
target_link_options(${main_target} PRIVATE $<$<CONFIG:Debug>:-fsanitize=address -fsanitize=undefined>)
target_link_options(${main_target} PRIVATE $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>:-flto>)
