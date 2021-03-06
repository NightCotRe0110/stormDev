# Copyright (C) 2008-2014 TrinityCore <http://www.trinitycore.org/>
#
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without
# modifications, as long as this notice is preserved.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# User has manually chosen to ignore the git-tests, so throw them a warning.
# This is done EACH compile so they can be alerted about the consequences.

if(NOT BUILDDIR)
  # Workaround for funny MSVC behaviour - this segment only run during compile
  set(NO_GIT ${WITHOUT_GIT})
  set(GIT_EXEC ${GIT_EXECUTABLE})
  set(BUILDDIR ${CMAKE_BINARY_DIR})
endif()

if(WITHOUT_GIT)
  set(rev_date "1970-01-01 00:00:01 +0000")
  set(rev_hash "unknown")
  set(rev_branch "Archived")
else()
  if(GIT_EXECUTABLE)
    # Create a revision-string that we can use
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" describe --dirty=+ --abbrev=12
      WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
      OUTPUT_VARIABLE rev_info
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )

    # And grab the commits timestamp
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" show -s --format=%ci
      WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
      OUTPUT_VARIABLE rev_date
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )

    # Also retrieve branch name
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" rev-parse --abbrev-ref HEAD
      WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
      OUTPUT_VARIABLE rev_branch
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
  endif()

  # Last minute check - ensure that we have a proper revision
  # If everything above fails (means the user has erased the git revision control directory or removed the origin/HEAD tag)
  if(NOT rev_info)
    # No valid ways available to find/set the revision/hash, so let's force some defaults
    message(STATUS "
    Could not find a proper repository signature (hash) - you may need to pull tags with git fetch -t
    Continuing anyway - note that the versionstring will be set to \"unknown 1970-01-01 00:00:00 (Archived)\"")
    set(rev_date "28.11.2017 21:07:21 +4.3.4")
    set(rev_hash "StormDev")
    set(rev_branch "Master")
  else()
    # Extract information required to build a proper versionstring
	string(REGEX REPLACE -[a-z0-9+]+ "" rev_ver ${rev_info})
    string(REGEX REPLACE ${rev_ver}-|[0-9]+-g "" rev_hash ${rev_info})
	string(REGEX REPLACE [a-z] "" rev_ver ${rev_ver})
	string(REGEX REPLACE [.*] ", " rev_ver ${rev_ver})
  endif()
endif()

# Create the actual revision.h file from the above params
  configure_file(
    "${CMAKE_SOURCE_DIR}/revision.h.in.cmake"
    "${BUILDDIR}/revision.h"
    @ONLY
  )
  set(rev_hash_cached "${rev_hash}" CACHE INTERNAL "Cached commit-hash")
  set(rev_branch_cached "${rev_branch}" CACHE INTERNAL "Cached branch name")

