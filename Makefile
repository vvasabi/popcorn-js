
PREFIX = .
BUILD_DIR = ${PREFIX}/build
DIST_DIR = ${PREFIX}/dist
PLUGINS_DIR = ${PREFIX}/plugins
PARSERS_DIR = ${PREFIX}/parsers
PLAYERS_DIR = ${PREFIX}/players

#Version
VERSION ?= $(error Specify a version for your release (e.g., VERSION=0.5))

RHINO ?= java -jar ${BUILD_DIR}/js.jar

CLOSURE_COMPILER = ${BUILD_DIR}/google-compiler-20100917.jar
compile = @@${MINJAR} $(1) \
	                    --compilation_level SIMPLE_OPTIMIZATIONS \
	                    --js_output_file $(2)

# minify
MINJAR ?= java -jar ${CLOSURE_COMPILER}

# source
POPCORN_SRC = ${PREFIX}/popcorn.js

# distribution files
POPCORN_DIST = ${DIST_DIR}/popcorn.js
POPCORN_MIN = ${DIST_DIR}/popcorn.min.js

# plugins
PLUGINS_DIST = ${DIST_DIR}/popcorn.plugins.js
PLUGINS_MIN = ${DIST_DIR}/popcorn.plugins.min.js

# plugins
PARSERS_DIST = ${DIST_DIR}/popcorn.parsers.js
PARSERS_MIN = ${DIST_DIR}/popcorn.parsers.min.js

# players
PLAYERS_DIST = ${DIST_DIR}/popcorn.players.js
PLAYERS_MIN = ${DIST_DIR}/popcorn.players.min.js

# Grab all popcorn.<plugin-name>.js files from plugins dir
PLUGINS_SRC := $(filter-out %unit.js, $(shell find ${PLUGINS_DIR} -name 'popcorn.*.js' -print))

# Grab all popcorn.<plugin-name>.js files from plugins dir
PARSERS_SRC := $(filter-out %unit.js, $(shell find ${PARSERS_DIR} -name 'popcorn.*.js' -print))

# Grab all popcorn.<player-name>.js files from players dir
PLAYERS_SRC := $(filter-out %unit.js, $(shell find ${PLAYERS_DIR} -name 'popcorn.*.js' -print))

# popcorn + plugins
POPCORN_COMPLETE_LIST := --js ${POPCORN_SRC} \
                         $(shell for js in ${PLUGINS_SRC} ; do echo --js $$js ; done) \
                         $(shell for js in ${PARSERS_SRC} ; do echo --js $$js ; done) \
                         $(shell for js in ${PLAYERS_SRC} ; do echo --js $$js ; done)
POPCORN_COMPLETE_DIST = ${DIST_DIR}/popcorn-complete.js
POPCORN_COMPLETE_MIN = ${DIST_DIR}/popcorn-complete.min.js

# For custom selection of parts to include.
PARTS ?= $(error Specify the files to include, e.g. PARTS="popcorn.js")
CUSTOM_DIST ?= ${DIST_DIR}/popcorn-custom.js
CUSTOM_MIN ?= ${DIST_DIR}/popcorn-custom.min.js

all: lint lint-plugins lint-parsers lint-players popcorn plugins parsers players complete min
	@@echo "Popcorn build complete."

${DIST_DIR}:
	@@mkdir -p ${DIST_DIR}

popcorn: ${POPCORN_DIST}

${POPCORN_DIST}: ${POPCORN_SRC} | ${DIST_DIR}
	@@echo "Building" ${POPCORN_DIST}
	@@cat ${POPCORN_SRC} | sed -e 's/@VERSION/${VERSION}/' > ${POPCORN_DIST}

min: ${POPCORN_MIN} ${PLUGINS_MIN} ${PARSERS_MIN} ${PLAYERS_MIN} ${POPCORN_COMPLETE_MIN}

${POPCORN_MIN}: ${POPCORN_DIST}
	@@echo "Building" ${POPCORN_MIN}
	$(call compile, --js ${POPCORN_DIST}, ${POPCORN_MIN})

${POPCORN_COMPLETE_MIN}: ${POPCORN_SRC} ${PLUGINS_SRC} ${PARSERS_SRC} ${DIST_DIR}
	@@echo "Building" ${POPCORN_COMPLETE_MIN}
	@@$(call compile, ${POPCORN_COMPLETE_LIST}, ${POPCORN_COMPLETE_MIN})

plugins: ${PLUGINS_DIST}

${PLUGINS_MIN}: ${PLUGINS_DIST}
	@@echo "Building" ${PLUGINS_MIN}
	$(call compile, $(shell for js in ${PLUGINS_SRC} ; do echo --js $$js ; done), ${PLUGINS_MIN})

${PLUGINS_DIST}: ${PLUGINS_SRC} ${DIST_DIR}
	@@echo "Building ${PLUGINS_DIST}"
	@@cat ${PLUGINS_SRC} > ${PLUGINS_DIST}

parsers: ${PARSERS_DIST}

${PARSERS_MIN}: ${PARSERS_DIST}
	@@echo "Building" ${PARSERS_MIN}
	$(call compile, $(shell for js in ${PARSERS_SRC} ; do echo --js $$js ; done), ${PARSERS_MIN})

${PARSERS_DIST}: ${PARSERS_SRC} ${DIST_DIR}
	@@echo "Building ${PARSERS_DIST}"
	@@cat ${PARSERS_SRC} > ${PARSERS_DIST}

players: ${PLAYERS_DIST}

${PLAYERS_MIN}: ${PLAYERS_DIST}
	@@echo "Building" ${PLAYERS_MIN}
	$(call compile, $(shell for js in ${PLAYERS_SRC} ; do echo --js $$js ; done), ${PLAYERS_MIN})

${PLAYERS_DIST}: ${PLAYERS_SRC} ${DIST_DIR}
	@@echo "Building ${PLAYERS_DIST}"
	@@cat ${PLAYERS_SRC} > ${PLAYERS_DIST}

complete: ${POPCORN_SRC} ${PARSERS_SRC} ${PLUGINS_SRC} ${PLAYERS_SRC} ${DIST_DIR}
	@@echo "Building popcorn + plugins + parsers + players"
	@@cat ${POPCORN_SRC} ${PLUGINS_SRC} ${PARSERS_SRC} ${PLAYERS_SRC} | sed -e 's/@VERSION/${VERSION}/' > ${POPCORN_COMPLETE_DIST}

lint:
	@@echo "Checking Popcorn against JSLint..."
	@@${RHINO} build/jslint-check.js popcorn.js

lint-plugins:
	@@echo "Checking all plugins against JSLint..."
	@@${RHINO} build/jslint-check.js ${PLUGINS_SRC}

lint-parsers:
	@@echo "Checking all parsers against JSLint..."
	@@${RHINO} build/jslint-check.js ${PARSERS_SRC}

lint-players:
	@@echo "Checking all players against JSLint..."
	@@${RHINO} build/jslint-check.js ${PLAYERS_SRC}

custom:
	@@echo "Building a custom-made Popcorn.js..."
	@@build/custom.sh "${VERSION}" "${PARTS}" "${CUSTOM_DIST}"
	$(call compile, --js ${CUSTOM_DIST}, ${CUSTOM_MIN})

clean:
	@@echo "Removing Distribution directory:" ${DIST_DIR}
	@@rm -rf ${DIST_DIR}

