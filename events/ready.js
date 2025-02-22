// const PuzzlunInit = require("../modules/puzzlun/Init");
// const Birthday = require('../modules/Birthday');
// const BirthdayGuildModel = require("../models/BirthdayGuildModel");

const { REST, Routes } = require("discord.js");
const dotenv = require("dotenv").config();
const fs = require("fs");
const { errorLog } = require("../modules/Logger");
const { dateTimeNow } = require("../modules/helper/datetime");
const Init = require("../modules/Init");

// returns error message on catch
function errorHandler(tag, error) {
	let log = `[${tag}] ${dateTimeNow()} `;
	log += error;
	errorLog(log);
	console.log(log);
}

module.exports = {
	name: "ready",
	once: true,
	async execute(client) {
		try {
			const rest = new REST({ version: "10" }).setToken(dotenv.parsed.BOT_TOKEN);
			const commandFiles = fs.readdirSync("./commands").filter(file => file.endsWith(".js"));

			// load all commands
			for (const file of commandFiles) {
				const command = require(`../commands/${file}`);
				await client.commands.set(command.name, command);
			}

			// check & load commands with production environment
			if (dotenv.parsed.NODE_ENV === "production") {
				await rest.put(
					Routes.applicationCommands(client.application.id),
					{ body: client.commands },
				);
			}

			// init peacestats
			await Init.initPeaceStats(client);

			client.guilds.cache.each(async guild => {
				console.log(`Connected @${guild.id} - ${guild.name}`);
				// check & load commands with development environment
				if (dotenv.parsed.NODE_ENV === "development") {
					await (async () => {
						try {
							// console.log("Refreshing commands (/)");
							await rest.put(
								Routes.applicationGuildCommands(`${client.application.id}`, `${guild.id}`),
								{ body: client.commands.toJSON() },
							);

							// console.log("Commands reloaded (/)");
						}
						catch (error) {
							errorHandler("ON_READY_DEV_COMMAND_LOAD", error);
						}
					})();
				}

				await Init.initBirthdayModule(guild);
			});

			// add the activity
			const arrActivity = [
				"Sparkling, glittering, rock-paper-scissors! Cure Peace!",
				"Puzzlun Peace!",
			];

			const randIndex = Math.floor(Math.random() * Math.floor(arrActivity.length));
			client.user.setActivity(arrActivity[randIndex]);

			// randomize the status every 1 hour:
			setInterval(function intervalRandomStatus() {
				client.user.setActivity(arrActivity[randIndex]);
			}, 3600000);

			console.log("Cure Peace Ready!");
		}
		catch (error) {
			console.log(error);
			errorHandler("ON_READY", error);
		}
	},
};