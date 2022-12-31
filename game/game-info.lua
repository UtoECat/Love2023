-- Basic game-info structure.

return {
	-- id of your game. Characters can be ONLY alphabetic, numeric and '_'
	id = "love_new_year",
	name = "Love 2023",
	-- Path to icon of your game
	icon = "snowball.png",
	-- main info about your game
	version = "0.1",
	author = "UtoECat",
	license = "GNU GPL 3.0",
	-- debug mode enabled?
	debug = true,
	-- Extended info about your game
	source = "https://github.com/author/repository",
	website = "https://github.com/author/website",
	license_file = "license.txt",
	-- Optional field
	contributors = {
		{	name = "UtoECat",
			email = "utopia.egor.cat.allandall@gmail.com",
			contribution = "main developer, grpahical and sound designer" }
	}
}
