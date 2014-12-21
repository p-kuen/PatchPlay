@echo off
set /p changes="Changes: "
"../../../bin/gmad.exe" create -out "D:\Daten\Workshop\PPlay.gma" -folder "D:\Daten\Server\Valve Server\steamapps\common\GarrysModDS\garrysmod\addons\PatchPlay"
"../../../bin/gmpublish" update -addon "D:\Daten\Workshop\PPlay.gma" -id "250792180" -changes "%changes%"
PAUSE