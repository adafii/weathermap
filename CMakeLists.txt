cmake_minimum_required(VERSION 3.18)
project("Weathermap" LANGUAGES CXX)

find_package(Qt6 COMPONENTS Gui Quick Qml QuickControls2 REQUIRED)
qt_standard_project_setup(REQUIRES 6.5)

set(source_dir src)
set(main_target weathermap)
set(main_src ${source_dir}/main.cpp)

qt_add_executable(${main_target}
        ${main_src}
        )

qt_add_qml_module(${main_target}
        URI app
        NO_RESOURCE_TARGET_PATH
        QML_FILES
        "qml/main.qml"
        )


target_include_directories(${main_target} PRIVATE ${source_dir})

target_link_libraries(${main_target} PRIVATE
        Qt6::Gui
        Qt6::Quick
        Qt6::Qml
        Qt6::QuickControls2
        )

target_compile_features(${main_target} PRIVATE cxx_std_20)
target_compile_options(${main_target} PRIVATE $<$<CONFIG:Debug>:-Wall -Wextra -Wpedantic -fsanitize=address -fsanitize=undefined>)
target_compile_options(${main_target} PRIVATE $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>:-Wall -Wextra -Wpedantic -flto>)
target_link_options(${main_target} PRIVATE $<$<CONFIG:Debug>:-fsanitize=address -fsanitize=undefined>)
target_link_options(${main_target} PRIVATE $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>:-flto>)
