// SongFilters.as:  Storage for song filter information.

package
{

public class SongFilters {

public static var allFilters:Array;

public static var platformFilters:Array = [
"AMIGA",
"COMMODORE",
"KONAMI",
"NES",
"NOVELTY",
"SNES",
"SUPER",
"ULTRA"
];

public static var gameFilters:Array = [
"Banana Quest",
"Bucky O'Hare",
"Burger Joint",
"Burglar!",
"Dungeons",
"Edible Vomit",
"Elis House",
"Ezanya",
"Final Fantasy",
"Frost",
"Giana",
"Jacky T",
"Lebensraum",
"Lost Forest",
"Merbotia",
"Mercenary",
"Metal Gear",
"Monster Zoo",
"NARC",
"Ned the Knight",
"Secret of Evermore",
"Super Mario Bros. 3",
"Smash ZZT",
"Town",
"Winter"
];

public static var authorFilters:Array = [
"Alexis Janson",
"Allen Pilgrim",
"Al Payne",
"Bitbot",
"Brian L. Schmidt",
"Christopher Allen",
"Chris Huelsbeck",
"Claude Debussy",
"Danny Bloody Baranowsky",
"Doc Pomus",
"Draco",
"Ennio Morricone",
"GingerMuffins",
"Harry M. Woods",
"Herbie Hancock",
"Interactive Fantasies",
"Jeremy LaMar",
"Jeremy Soule",
"Johann Pachelbel",
"Jon Hey",
"Kev Carter",
"Koji Kondo",
"Lipid",
"MadTom",
"Marshall Parker",
"Matt Dabrowski",
"Michael Jackson",
"Monte Emerson",
"Mort Dixon",
"Mort Shuman",
"Mozart",
"Myth",
"N. Nakazato",
"Nobuo Uematsu",
"Peter, Paul and Mary",
"q2k2k",
"Queen",
"Richard M. Sherman",
"Rick Astley",
"Robert B. Sherman",
"Sonic 256",
"Tim Sweeney",
"T. Sumiyama",
"Todd Daggert",
"Viovis Acropolis",
"WiL",
"Wong Chung Bang",
"Yoko O.",
"Zenith Nadir"
];

// Initialize the "all filters" list.
public static function init():void {
	allFilters = new Array();
	var i:int;

	// Add platform filters.
	allFilters.push("[No Filter]");
	allFilters.push("");
	allFilters.push("-- Platforms --");
	for (i = 0; i < platformFilters.length; i++) {
		allFilters.push(platformFilters[i]);
	}

	// Add game filters.
	allFilters.push("");
	allFilters.push("-- Games --");
	for (i = 0; i < gameFilters.length; i++) {
		allFilters.push(gameFilters[i]);
	}

	// Add author filters.
	allFilters.push("");
	allFilters.push("-- Authors --");
	for (i = 0; i < authorFilters.length; i++) {
		allFilters.push(authorFilters[i]);
	}
}

};
};
