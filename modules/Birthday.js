const cron = require("node-cron");
const DB = require("./Database");
const DBM_Birthday = require("../models/BirthdayModel");
const DBM_Birthday_Guild = require("../models/BirthdayGuildModel");

const DBM_BirthdayGuildInst = new DBM_Birthday_Guild();
const DBM_BirthdayInst = new DBM_Birthday();

/**
 * Gets config
 * @param id_guild - Guild ID
 * @returns {Promise<boolean>}
 */
async function isGuildEnabled(id_guild) {
	const guild_config = await getGuildConfig(id_guild, false);
	return guild_config.enabled === 1;
}
/**
 * Gets config
 * @param id_guild - Guild ID
 * @param insertNew - Whether to insert the current guild if it isn't in the DB yet
 * @returns {Promise<*>}
 */
async function getGuildConfig(id_guild, insertNew = true) {

	const parameterWhere = new Map();
	parameterWhere.set("id_guild", id_guild);

	let data = await DB.select(DBM_BirthdayGuildInst.tableName, parameterWhere);

	// insert
	if (insertNew) {
		if (data == null) {

			const parameter = new Map();
			parameter.set(DBM_BirthdayGuildInst.fields.id_guild, id_guild);
			parameter.set(DBM_BirthdayGuildInst.fields.id_notification_channel, null);
			parameter.set(DBM_BirthdayGuildInst.fields.notification_hour, "09:00:00");
			parameter.set(DBM_BirthdayGuildInst.fields.enabled, 0);

			await DB.insert(DBM_BirthdayGuildInst.tableName, parameter);
			data = await DB.selectAll(DBM_BirthdayGuildInst.tableName, parameterWhere);

			return await data;
		}
		else {
			return data;
		}
	}
	return data;
}

/**
 * Gets all birthdays in the database for this guild
 * @param guild
 * @returns {Promise<*>}
 */
async function getListOfBDsForThisServer(guild) {

	const parameterWhere = new Map();
	parameterWhere.set(DBM_BirthdayGuildInst.fields.id_guild, guild);
	// override to be DAC
	// parameterWhere.set(DBM_BirthdayGuildInst.fields.id_guild, '314512031313035264');
	parameterWhere.set(DBM_BirthdayGuildInst.fields.enabled, 1);

	const columns = [
		DBM_BirthdayInst.fields.id_user,
		DBM_BirthdayInst.fields.birthday,
		`MONTH(${DBM_BirthdayInst.fields.birthday}) AS 'month'`,
		`DAY(${DBM_BirthdayInst.fields.birthday}) AS 'day'`,
		DBM_BirthdayInst.fields.label,
		DBM_BirthdayInst.fields.notes,
	];
	const parameterOrderBy = new Map();
	parameterOrderBy.set("month", "ASC");
	parameterOrderBy.set("day", "ASC");
	return await DB.selectColumnsIn(DBM_BirthdayInst.tableName, columns, parameterWhere, parameterOrderBy, null);

//     const query = `SELECT ${DBM_BirthdayInst.fields.id_user},
//                           ${DBM_BirthdayInst.fields.birthday},
//                           MONTH(${DBM_BirthdayInst.fields.birthday}) as 'month',
//                           DAY(${DBM_BirthdayInst.fields.birthday})   AS 'day',
//                           label,
//                           notes
//                    FROM birthday
//                    WHERE ${DBM_BirthdayInst.fields.id_guild} = '314512031313035264'
//                      AND ${DBM_BirthdayInst.fields.enabled} = '1'
// #                    WHERE ${DBM_BirthdayInst.fields.id_guild} = '${guild}' AND ${DBM_BirthdayInst.fields.enabled} = '1'
//                    ORDER BY month, day`;
//     let foo = await DBConn.conn.query(query);
//     return await foo;
}

/**
 * Generates the reminder message in the defined notification channel
 * @param birthday - Birthday object
 * @type {(birthday: object) => string}
 * @returns {Promise<string>}
 */
async function generateNotification(birthday) {
	let output = `It's <@${birthday.id_user}>'s birthday today.`;
	if (birthday.notes) {
		output += ` Notes about them: \`${birthday.notes}\``;
	}
	return output;
}

/**
 *
 * @param birthdays
 * @param client - Discord client object
 * @param assignedChannel - channel ID where to send reminders to
 * @param hour - GMT hour when to send reminders
 * @param minute - At what minute should the daily ping be sent
 * @returns {Promise<ScheduledTask>}
 */
async function schedulerSetup(birthdays, client, assignedChannel, hour = 9, minute = 0) {
	hour = hour != null ? hour : 9;
	minute = minute != null ? minute : 0;
	const second = 0;

	return new cron.schedule(`${second} ${minute} ${hour} * * *`, async () => {

		const today = new Date();

		for (const birthdayObject of birthdays) {
			if (birthdayObject instanceof Object) {
				const birthday = birthdayObject;

				// console.log(`${60 - (birthday.month + birthday.day)} (${birthday.month} ${birthday.day})`);
				if (birthday.month === (today.getUTCMonth() + 1) && birthday.day === today.getUTCDate()) {
					// if(60 - (birthday.month + (birthday.day * 3)) === today.getMinutes()) {
					// if (birthday.day + birthday.month === today.getMinutes().toString()) {
					console.log("BIRTHDAY!");
					const message = await generateNotification(birthday);

					const channel = await client.channels.cache.get(assignedChannel);

					channel.send({
						content: message,
						allowedMentions: {
							"users": [],
						},
					});
					console.log(message);
				}
			}
		}
	}, {
		scheduled: false,
		// Use Etc/UTC if that's easier
		timezone: "Europe/London",
	});
}

/**
 * Checks if there's a birthday in the DB for this user in this guild
 * @param id_guild
 * @param id_user
 * @returns {Promise<*>}
 */
async function doesBirthdayExist(id_guild, id_user) {

	const parameterWhere = new Map();
	parameterWhere.set(DBM_BirthdayInst.fields.id_guild, id_guild);
	parameterWhere.set(DBM_BirthdayInst.fields.id_user, id_user);

	return await DB.select(DBM_BirthdayInst.tableName, parameterWhere);
}

/**
 * Re-enables pinging again for this guild.
 * @param guild
 * @param {string|null} setChannel
 * @param {number|null|undefined} [setHour]
 * @param {boolean|undefined} [setEnabled]
 * @returns {Promise<any>}
 */
// async function setGuildConfig(guild, setChannel, setHour, setEnabled) {
//
// 	const parameterSet = new Map();
// 	if (setChannel) {parameterSet.set(DBM_BirthdayGuildInst.fields.id_notification_channel, setChannel);}
// 	if (setHour !== undefined && setHour != null) {
//
// 		// time.setHours(setHour);
// 		const newHour = (setHour.toString().length === 1) ? `0${setHour}` : setHour;
// 		parameterSet.set(DBM_BirthdayGuildInst.fields.notification_hour, `${newHour}:00:00`);
// 	}
//
// 	if (setEnabled !== undefined) {
//
// 		parameterSet.set(DBM_BirthdayGuildInst.fields.enabled, setEnabled === true ? 1 : 0);
// 	}
//
// 	const parameterWhere = new Map();
// 	parameterWhere.set(DBM_BirthdayGuildInst.fields.id_guild, guild);
//
// 	return await DB.update(DBM_BirthdayInst.tableName, parameterSet, parameterWhere);
// }

/**
 * Adds birthday of the user for this guild to the DB
 * @param id_guild
 * @param id_user
 * @param birthday
 * @param label
 * @param notes
 * @returns {Promise<string>}
 */
async function addBirthday(id_guild, id_user, birthday, label, notes) {

	const haveBirthday = await doesBirthdayExist(id_guild, id_user);
	if (haveBirthday != null) {
		return "BIRTHDAY_EXISTS";
	}

	const parameters = new Map();
	parameters.set(DBM_BirthdayInst.fields.id_guild, id_guild);
	parameters.set(DBM_BirthdayInst.fields.id_user, id_user);
	parameters.set(DBM_BirthdayInst.fields.birthday, birthday);
	parameters.set(DBM_BirthdayInst.fields.label, label);
	// parameters.set(DBM_BirthdayInst.fields.notes, DBConn.conn.escape(notes));
	// needs new escaping
	parameters.set(DBM_BirthdayInst.fields.notes, notes);

	const add_insert = await DB.insert(DBM_BirthdayInst.tableName, parameters);
	return add_insert ? "BIRTHDAY_ADDED" : "BIRTHDAY_ERROR";
}

async function initBirthdayReportingInstance(guildId, guild) {
	const birthdayGuildData = await getGuildConfig(guildId, true);


	if (birthdayGuildData[DBM_BirthdayGuildInst.fields.id_notification_channel] != null) {
		const assignedChannelId = birthdayGuildData[DBM_BirthdayGuildInst.fields.id_notification_channel];
		// todo: replace with notification_time column name later
		const time = birthdayGuildData[DBM_BirthdayGuildInst.fields.notification_hour];

		const enabled = parseInt(birthdayGuildData[DBM_BirthdayGuildInst.fields.enabled]) === 1;

		// fallback check
		const valid_time = /(\d{2}):(\d{2}):(\d{2})$/.test(time);
		if (valid_time) {
			const arr = time.split(":");
			const hour = parseInt(arr[0]);
			const minute = parseInt(arr[1]);
			// let sec = parseInt(arr[2]);

			const birthdays = await getListOfBDsForThisServer(guildId);

			if (birthdays.length > 0) {
				const schedule = await schedulerSetup(birthdays, guild, assignedChannelId, hour, minute);

				if (enabled) {
					schedule.start();
				}
			}
			else {
				console.error("Invalid format for notification time specified");
			}
		}
	}
}

/**
 * Removes the user's birthday from the DB, after checking if there is one at all
 * @param id_guild
 * @param id_user
 * @returns {Promise<string>}
 */
async function removeBirthday(id_guild, id_user) {
	const hasValidBirthday = await doesBirthdayExist(id_guild, id_user);

	if (hasValidBirthday !== null) {
		const parameterWhere = new Map();
		parameterWhere.set(DBM_BirthdayInst.fields.id_guild, id_guild);
		parameterWhere.set(DBM_BirthdayInst.fields.id_user, id_user);
		const deleted = await DB.del(DBM_BirthdayInst.tableName, parameterWhere);

		return deleted ? "BIRTHDAY_DELETED" : "BIRTHDAY_ERROR";
	}
	else {
		return "NO_BIRTHDAY";
	}
}

module.exports = {
	getGuildConfig,
	initBirthdayReportingInstance,
	addBirthday,
	isGuildEnabled,
	removeBirthday,
	getListOfBDsForThisServer,
	// setGuildConfig,
};