const fs = require("fs");
const peacestats = JSON.parse(fs.readFileSync("storage/peacestats.json", "utf8"));
const PeaceStatsModel = require("../models/PeaceStatsModel");
const DBM_Birthday_Guild = require("../models/BirthdayGuildModel");
const { getGuildConfig, initBirthdayReportingInstance } = require("./Birthday");
const { PermissionFlagsBits } = require("discord-api-types/v10");

// check if peacestats data exists
async function initPeaceStats(client) {
	const clientId = client.application.id;

	// init peacestats json
	if (!peacestats[clientId]) {
		peacestats[clientId] = {
			name: "Cure Peace",
			win: 0,
			draw: 0,
			loss: 0,
			points: 0,
		};

		fs.writeFile("storage/peacestats.json", JSON.stringify(peacestats), (err) => {
			if (err) console.error(err);
		});
	}

	// check if peace stats exists
	let peaceStats = new PeaceStatsModel();
	const paramWhere = new Map();
	paramWhere.set(peaceStats.fields.id_user, clientId);
	await peaceStats.find(paramWhere);

	if (!peaceStats.hasData()) {
		const paramInsert = new Map();
		paramInsert.set(peaceStats.fields.id_user, clientId);
		paramInsert.set(peaceStats.fields.name, "Cure Peace");
		peaceStats = new PeaceStatsModel();
		await peaceStats.insert(paramInsert);
	}
}


/**
 * Birthday cronjob loading functionality
 * @param guild
 * @returns {Promise<void>}
 */
async function initBirthdayModule(guild) {
	const DBM_BirthdayGuildInst = new DBM_Birthday_Guild();
	await getGuildConfig(guild.id, false)
		.then(async (birthdayGuildData) => {
			const guild_data_notif_channel = birthdayGuildData[DBM_BirthdayGuildInst.fields.id_notification_channel];
			const birthdays_enabled_for_guild = birthdayGuildData[DBM_BirthdayGuildInst.fields.enabled] === 1;
			if (guild_data_notif_channel !== null) {
				const birthdayNotifChannel = guild.channels.cache.find(ch => ch.id === birthdayGuildData[DBM_BirthdayGuildInst.fields.id_notification_channel]);
				if (!birthdayNotifChannel.permissionsFor(guild.members.me).has(PermissionFlagsBits.SendMessages)) {
					console.error(`Notification channel ${birthdayNotifChannel.name} is specified, but we don't have access to send messages there!!`);
				}
				if (birthdayNotifChannel && birthdays_enabled_for_guild) {
					// console.log(`birthday notif channel exists! ${birthdayNotifChannelExists} (${birthdayNotifChannelExists.name})`);
					console.log(`Loaded birthday module for guild ${guild.id}`);
					await initBirthdayReportingInstance(guild.id, guild);
				}
			}
			else if (birthdays_enabled_for_guild) {
				console.warn(`Birthdays enabled for '${guild.name}' but no notification channel specified! Skipping.`);
			}
		})

		.catch((e) => {
			console.log(e);
		});
}
module.exports = { initPeaceStats, initBirthdayModule };