Run these commands to rebuild zzt_guis.txt from composite files:

cd guis
type zzt_guis_Orig.txt comma_debugmenu.txt debugmenu.ZZTGUI comma_forest.txt lost_forest.ZZTGUI comma_proving.txt proving_grounds.ZZTGUI comma_monster.txt monster_zoo.ZZTGUI comma_custom.txt custom_szt.ZZTGUI comma_zzt.txt zzt.ZZTGUI comma_classiczzt.txt classiczzt.ZZTGUI comma_classicszt.txt classicszt.ZZTGUI comma_superz.txt superz.ZZTGUI comma_superz_intro.txt superz_intro.ZZTGUI comma_options.txt options.ZZTGUI comma_console.txt console.ZZTGUI cb_cr.txt > zzt_guis.txt

There are two main reasons to use this command as opposed to simply copying
and pasting ZZTGUI files into the JSON dictionary:

1) These GUIs are likely to be edited and touched up numerous times during
   development, making manual transfer annoying.
2) These GUIs tend to have lots of extended ASCII character markup, which
   complicates the manual copying process.
