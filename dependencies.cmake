# This is an example dependency used by both targets of this example project.
# Try to find new enough spdlog via find_package first, and if not found, fetch it.
# Remember to add dependencies to GitHub CI workflow as well if needed: .github/workflows/ci.yml
find_package(spdlog 1.12.0 QUIET)
if(NOT spdlog_FOUND)
    message(STATUS "[x_PROJECT_NAME_x] System-installed spdlog not found or too old, using FetchContent")
    include(FetchContent)
    FetchContent_Declare(
        spdlog
        GIT_REPOSITORY https://github.com/gabime/spdlog.git
        GIT_TAG v1.17.0
    )
    set(FETCHCONTENT_UPDATES_DISCONNECTED_spdlog ON) # No need to check for updates remotely
    set(SPDLOG_INSTALL ON CACHE BOOL "" FORCE) # Make spdlog installable if used via FetchContent
    FetchContent_MakeAvailable(spdlog)
else()
    message(STATUS "[x_PROJECT_NAME_x] Using system-installed spdlog")
endif()
