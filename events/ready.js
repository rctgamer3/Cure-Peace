// const GlobalFunctions = require('../modules/GlobalFunctions');
const fs = require('fs');
const {REST} = require('@discordjs/rest');
const {Routes} = require('discord-api-types/v9');

// const DBM_Guild_Data = require('../database/model/DBM_Guild_Data');
const CardModules = require('../modules/card/Card');
const GuildModule = require('../modules/card/Guild');
// const CardGuildModules = require('../modules/CardGuild');
// const WeatherModules = require('../modules/Weather');
const Birthday = require('../modules/Birthday');
const DBM_Birthday_Guild = require("../database/model/DBM_Birthday_Guild");
const {token} = require('../storage/config.json');

module.exports = {
    name: 'ready',
    once: true,
    async execute(client) {
        try {
            const rest = new REST({version: '9'}).setToken(token);

            //load all necessary card data
            await CardModules.init();

            // console.log('Ready!');
            // WeatherModules.updateTimerRemaining();

            const commandFiles = fs.readdirSync('./commands').filter(file => file.endsWith('.js'));

            for (const file of commandFiles) {
                const command = require(`../commands/${file}`);
                await client.commands.set(command.name, command);
            }

            await Promise.all(client.guilds.cache.map(async (guild) => {
                //init/one time load load all necessary guild data
                await GuildModule.init(guild.id);

                console.log(`connected to: ${guild.id} - ${guild.name}`);
                try {
                    // console.log('Started refreshing application (/) commands.');
                    await rest.put(
                        Routes.applicationGuildCommands(`${client.application.id}`, `${guild.id}`),
                        {body: client.commands.toJSON()},
                    );

                    // console.log('Successfully reloaded application (/) commands.');
                } catch (error) {
                    console.error(error);
                    // GlobalFunctions.errorLogger(error);
                }

                //get card spawn guild data
                // let cardGuildData = await CardGuildModules.getCardGuildData(guild.id);
                // //set card spawn interval
                // let channelSpawn = cardGuildData[DBM_Card_Guild.columns.id_channel_spawn];
                // if (channelSpawn != null && channelSpawn !== "") {
                //     //check if channel exists/not
                //     let cardSpawnChannelExists = guild.channels.cache.find(ch => ch.id === cardGuildData[DBM_Card_Guild.columns.id_channel_spawn]);
                //     if (cardSpawnChannelExists) {
                //
                //         await CardGuildModules.initCardSpawnInstance(guild.id, guild);
                //     }
                // }

                let birthdayGuildData = await Birthday.getGuildConfig(guild.id);
                let notif_channel = birthdayGuildData[DBM_Birthday_Guild.columns.id_notification_channel];
                let birthdays_enabled_for_guild = birthdayGuildData[DBM_Birthday_Guild.columns.enabled] === 1;
                if (notif_channel) {
                    let birthdayNotifChannelExists = guild.channels.cache.find(ch => ch.id === birthdayGuildData[DBM_Birthday_Guild.columns.id_notification_channel]);
                    if (birthdayNotifChannelExists && birthdays_enabled_for_guild) {
                        console.log(`birthday notif channel exists! ${birthdayNotifChannelExists} (${birthdayNotifChannelExists.name})`);
                        await Birthday.initBirthdayReportingInstance(guild.id, guild);
                    }
                } else if (birthdays_enabled_for_guild && notif_channel == null) {
                    console.warn(`Birthdays enabled for '${guild.name}' but no notification channel specified!`);
                }
            }));

            // console.log(GuildModule.dataUserLogin);

            //added the activity
            const arrActivity = [
                'Sparkling, glittering, rock-paper-scissors! Cure Peace!',
                'Puzzlun Cure!'
            ];

            let randIndex = Math.floor(Math.random() * Math.floor(arrActivity.length));
            client.user.setActivity(arrActivity[randIndex]);

            //randomize the status every 1 hour:
            setInterval(function intervalRandomStatus() {
                client.user.setActivity(arrActivity[randIndex]);
            }, 3600000);
            console.log('Cure Peace Ready!');
        } catch (error) {
            console.log(error);
            // GlobalFunctions.errorLogger(error);
        }
    },
};