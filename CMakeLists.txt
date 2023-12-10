cmake_minimum_required(VERSION 3.13)

include(cmake/kconfig.cmake)


project(kconfig-test
    VERSION     1.0
    DESCRIPTION "kconfig test project"
    LANGUAGES   C
)


if(CONFIG_TEST_OPTION)
    message("Config test_option enabled")
else()
    message("Config test_option disabled")
endif()

if (CONFIG_TEST_STRING)
    message("Wonder what this say...: ${CONFIG_TEST_STRING}")
endif()



