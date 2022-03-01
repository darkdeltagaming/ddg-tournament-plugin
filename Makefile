SPCOMP=./server/csgo/addons/sourcemod/scripting/spcomp
PLUGINS_DIR=./server/csgo/addons/sourcemod/plugins/
PLUGIN_NAME=ddg-tournament

final: build_smx move_smx
	@echo "Finished."

build_smx:
	@echo "Compiling plugin source file"
	${SPCOMP} -o ${PLUGIN_NAME}.smx plugin01.sp

move_smx:
	@echo "Moving compiled plugin to plugins folder"
	mv ${PLUGIN_NAME}.smx ${PLUGINS_DIR}
