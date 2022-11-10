#****************************************************************************************
# Script für Erzeugung von FSBL und Applikation Projekte aus .xsa datei
# Zusammengestellt von Dmitry Eliseev auf Basis von Erklärungen hier: 
# https://ohwr.org/project/soc-course/wikis/Xilinx-Software-Command-Line-Tool-(XSCT)#creating-a-domain-for-FSBL
# Das root-Verzeichnis muss die folgenden Unterverzeichnisse und Dateien beinhalten:
# Achtung: das ist nicht das Project-Verzeichnis für VIVADO
#   gen-workspace.tcl <-- Diese Datei
#   output.bif <-- Die Boot_Image_Format Datei für bootgen
#   /src  <-- hier eure *.c Dateien (für Applikation)
#   /workspace <-- in diesem Verzeichnis wird das Workspace instantiiert und alle Sub-Projekte (fsbl, etc) erzeugt
#   /bootimage <-- wenn das Skript erfolgreich gelaufen ist, wird die vom bootgen erzeugte BOOT.bin Datei in diesem Ordner abgelegt
#
# Die wichtigen Schritte für erfolgreiche Script-Ausführung:
# 1. Unterverzeichnisse wie oben angegeben vorbereiten
# 2. Projekt Name (die Variabel "proj_name") unten ändern
# 3. Pfad zum root-Verzeichnis (root_dir) modifizieren 
# 4. Prüfen, dass das Blockdesign-Skript den Namen "bd.tcl" hat.  Ggf. umbenennen.
# 5. Chip-Modell angeben: set_property "part" "Dein Chip-Modell" 
# 6. (Optional): Die Entwicklungsplatine (falls vorhanden) entsprechend ändern: siehe set_property "board_part"
# 7. In dem aus Vivado exportierten bd-Script die Zuweisung der Variabel str_bd_folder auskommentieren
# 8. In der Vivado-console zu dem vorbereiteten root Verzeichnis 
#    übergehen und "source create.tcl" eintippen
#
# Updates:
# Rev 1.0 		05. November 2022 - Anfangsversion 
#****************************************************************************************

set hw_xsa "design_1_wrapper.xsa"
set platform "mvt-platform"
set fsbl_name "mvt_fsbl"
set app_name "mvt_test"
set src_path "./src"

setws ./workspace
platform create -name $platform -hw $hw_xsa
domain create -name fsbl_domain -os standalone -proc psu_cortexa53_0

bsp setlib xilffs
bsp setlib xilsecure
bsp setlib xilpm
bsp config zynqmp_fsbl_bsp true

platform generate

app create -name mvt_fsbl -template {Zynq MP FSBL} -platform mvt-platform -domain fsbl_domain #-sysproj mvt_fsbl_system 
#app config -name mvt_fsbl build-config release
#app config -name mvt_fsbl -add compiler-misc {-Os -flto -ffat-lto-objects}
app build -name $fsbl_name

app create -name $app_name -template {Empty Application} -platform $platform -domain fsbl_domain #-sysproj mvt_test_system 
importsources -name mvt_test -path $src_path
app build -name $app_name

