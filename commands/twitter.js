/* jslint esversion: 11 */
const Discord = require('discord.js');
const dotenv = require('dotenv');
dotenv.config({path: 'storage/env/twitter.env'});

const {TwitterApi, ETwitterStreamEvent} = require('twitter-api-v2');
const token = process.env.TWITTER_TOKEN;
const webhook = new Discord.WebhookClient({
    id: process.env.TWITTER_DISCORD_WEBHOOK_ID,
    token: process.env.TWITTER_DISCORD_WEBHOOK_TOKEN
});

const Twitter = new TwitterApi(token);

const v1Client = Twitter.v1.readOnly;
const v2Client = Twitter.v2.readWrite;

module.exports = {
    name: 'twitter',
    cooldown: 5,
    description: 'Twitter lurking management',
    args: true,
    "options": [
        {
            "type": 2,
            "name": "control",
            "description": "control",
            "options": [
                {
                    "type": 1,
                    "name": "start",
                    "description": "start",
                    "options": []
                },
                {
                    "type": 1,
                    "name": "stop",
                    "description": "stop",
                    "options": []
                }
            ]
        },
        {
            "type": 2,
            "name": "accounts",
            "description": "accounts stuff",
            "options": [
                {
                    "type": 1,
                    "name": "add",
                    "description": "add",
                    "options": [
                        {
                            "type": 3,
                            "name": "rule",
                            "description": "example: `from:bahijd -is:reply -is:retweet`",
                            "required": true
                        }
                    ]
                },
                {
                    "type": 1,
                    "name": "list",
                    "description": "list",
                    "options": []
                },
                {
                    "type": 1,
                    "name": "delete",
                    "description": "delete",
                    "options": [
                        {
                            "type": 3,
                            "name": "rule",
                            "description": "`<ID> from list`",
                            "required": true
                        }
                    ]
                },
            ]
        },
        {
            "type": 1,
            "name": "vidlookup",
            "description": "vidlookup",
            "options": [
                {
                    "type": 3,
                    "name": "tweetid",
                    "description": "`<ID>`",
                    "required": true
                }
            ]
        },
    ],
    execute: async function (interaction) {

        let message = interaction.message;
        // let userId = interaction.user.id;
        // let username = interaction.user.username;
        // let avatarURL = interaction.user.avatarURL();

        const twitterEmbed = new Discord.MessageEmbed();
        twitterEmbed.setColor('#1c9cea');
        twitterEmbed.setTitle('Twitter');

        async function videoFetch(tweet_id) {
            let bitrate = 0;
            let video_url;
            if (tweet_id) {
                const vidtweet = await v1Client.singleTweet(tweet_id) ?? null;
                if (vidtweet) {
                    vidtweet.extended_entities.media[0].video_info.variants.forEach(variant => {
                        if (variant.content_type === 'video/mp4') {
                            if (variant.bitrate) {
                                if (variant.bitrate > bitrate) {
                                    bitrate = variant.bitrate;
                                    video_url = variant.url;
                                }
                            }
                        }
                    });
                }
                video_url = video_url.replace(/(.*)\?tag=\d+$/, '$1');
                return video_url;
            }
        }

        async function postTweet(data, includes) {

            const useWebhook = false;

            // console.log(data);
            let tweet = data;
            let author = includes.users[0];

            twitterEmbed.author = {
                name: `${author.name} (@${author.username})`,
                iconURL: author.profile_image_url,
                url: `https://twitter.com/${author.username}`
            };

            twitterEmbed.setDescription(tweet.text);
            if (includes.media) {
                let media = includes.media[0];
                // console.info(tweet);
                switch (media.type) {
                    case 'photo':
                        twitterEmbed.setImage(media.url + ":orig");
                        break;
                    case 'video':
                        // videoFetch(tweet.id);
                        twitterEmbed.setImage(media.preview_image_url);
                        break;
                    default:
                        break;
                }
            }

            // twitterEmbed.setTimestamp(tweet.tweet.created_at);
            let tweetDate = new Date(tweet.created_at);
            let tweetDateFormatted = `${tweetDate.toISOString().split('T')[0]} ${tweetDate.toISOString().split('T')[1].split('.')[0]} UTC`;

            // twitterEmbed.setFooter(`[${tweetDateFormatted}](https://twitter.com/${author.username}/${tweet.tweet.id})`);
            let moreMedia = '';
            if (includes.media) {
                if (includes.media.size > 1) {
                    moreMedia = ` - More media in tweet: ${includes.media.size - 1}`;
                }
            }
            twitterEmbed.setFooter(`${tweetDateFormatted}${moreMedia}`);

            let hasVideo = false;
            if (includes.media) {
                hasVideo = includes.media[0].type === 'video';
            }
            if (author.username === "bahijd") {
                if (hasVideo) {
                    return () => {
                        message.channel.send({
                            content:`<https://twitter.com/${author.username}/status/${tweet.id}> ` +
                                `Hey Sakuga Nerds, did you know bahijd tweeted this video?`,
                            embeds: [twitterEmbed]
                        }).catch(console.error);
                        // message.channel.send({
                        //     content: await videoFetch(tweet.id)
                        // }).catch(console.error);
                    };
                } else {
                    return message.channel.send({
                        content: `<https://twitter.com/${author.username}/status/${tweet.id}> ` +
                        `Hey Sakuga Nerds, did you know bahijd tweeted this?`,
                        embeds: [twitterEmbed]
                    }).catch(console.error);
                }
            }

            let sanitized_username = author.username.replace(/([*_`~\\])/g, '\\$1');
            if (useWebhook) {
                if (hasVideo) {
                    return () => {
                        webhook.send({
                            content: `${sanitized_username} tweeted a video: ` +
                                `https://twitter.com/${author.username}/status/${tweet.id}`,
                            threadId: process.env.TWITTER_THREAD_ID
                        }).catch(console.error);
                        // webhook.send({
                        //     content: await videoFetch(tweet.id)
                        // }).catch(console.error);
                    };
                } else {
                    return webhook.send({
                        content: `<https://twitter.com/${author.username}/status/${tweet.id}>`,
                        threadId: process.env.TWITTER_THREAD_ID,
                        embeds: [twitterEmbed]
                    }).catch(console.error);
                }
            } else {
                if (hasVideo) {
                    return () => {
                        message.channel.send(`${sanitized_username} tweeted a video: ` +
                            `<https://twitter.com/${author.username}/status/${tweet.id}>`, twitterEmbed).catch(console.error);
                    };
                    // message.channel.send({
                    //     content: await videoFetch(tweet.id)
                    // }).catch(console.error);
                } else {
                    return message.channel.send(`<https://twitter.com/${author.username}/status/${tweet.id}>`, twitterEmbed)
                        .catch(console.error);
                }
            }
        }

        async function streamConnect() {

            // Log every rule ID
            // const rules = await v2Client.streamRules();
            // console.log(rules.data.map(rule => rule.id));

            const stream = await v2Client.searchStream({
                "media.fields": ["media_key", "type", "url", "preview_image_url", "alt_text"],
                "user.fields": ["name", "created_at", "profile_image_url", "verified"],
                "tweet.fields": ["created_at", "attachments", "entities", "source"],
                expansions: ["author_id", "attachments.media_keys"]
            });

            // Emitted when Node.js {response} emits a 'error' event (contains its payload).
            stream.on(ETwitterStreamEvent.ConnectionError, err => {
                    console.error('Connection error!', err);
                },
            );

            // Emitted when Node.js {response} is closed by remote or using .close().
            stream.on(ETwitterStreamEvent.ConnectionClosed, () => {
                    console.error('Connection has been closed.');
                },
            );

            // Emitted when a Twitter payload (a tweet or not, given the endpoint).
            stream.on(ETwitterStreamEvent.Data, eventData => {
                    console.log('Twitter has sent something:', eventData);
                    console.info(eventData.data);
                    console.info(eventData.includes);
                    postTweet(eventData.data, eventData.includes);
                },
            );

            // Emitted when a Twitter sent a signal to maintain connection active
            stream.on(ETwitterStreamEvent.DataKeepAlive, () => {
                    console.info('Twitter has sent a keep-alive packet.');
                },
            );

            // Enable reconnect feature
            stream.autoReconnect = true;

            return stream;
        }

        async function getTweets() {
            try {
                await streamConnect();
            } catch (error) {
                console.log(error);
            }
        }

        function start() {
            interaction.reply({content: 'Now watching Twitter!!', ephemeral: true});
            getTweets();
        }

        function stop() {
            //FIXME: Write a way to actually stop tweeting instead of manually killing everything
            interaction.reply({content: 'Stopped watching Twitter!!', ephemeral: true});
            // let stop = true;
            // getTweets(stop);
        }

        async function accountControl(interaction) {
            const subcommand = interaction.options._subcommand;
            switch (subcommand) {
                case 'add':
                    let add_rule = interaction.options._hoistedOptions[0].value.toString();
                    const addedRules = await v2Client.updateStreamRules({
                        add: [
                            {value: add_rule}
                        ],
                    });

                    // { value: 'TypeScript', tag: 'ts' },
                    console.log(addedRules);
                    if (addedRules.meta.summary.created === 1) {
                        await interaction.reply({content: '✅', ephemeral: true});
                    } else {
                        await interaction.reply({content: '❌', ephemeral: true});
                    }
                    break;
                case 'list':
                    const fetchRules = await v2Client.streamRules();
                    let rules = '';
                    fetchRules.data.forEach(rule => {
                        rules += `${rule.id} - \`${rule.value}\`\n`;
                    });
                    let rulesList = new Discord.MessageEmbed();
                    rulesList.setTitle("Twitter list");
                    rulesList.setDescription(rules);
                    interaction.reply({embeds: [rulesList], ephemeral: true});
                    break;
                case 'delete':
                    let delete_rule = interaction.options._hoistedOptions[0].value;
                    console.log(delete_rule);
                    let delRuleAr = await v2Client.updateStreamRules({
                        delete: {
                            ids: [delete_rule],
                        }
                    });

                    if (delRuleAr.meta.summary.deleted > 0) {
                        interaction.reply({content: "✅", ephemeral: true});
                        console.log('✅');
                    } else {
                        interaction.reply({content: "❌", ephemeral: true});
                        console.log('❌');
                    }
                    break;
                default:
                    break;
            }
        }

        if (interaction.options._group === 'accounts') {
            console.log("Found accounts thing command");
            await accountControl(interaction);
        }
        if (interaction.options._group === 'control') {
            const subcommand = interaction.options._subcommand;
            switch (subcommand) {
                case "start":
                    start();
                    break;
                case "stop":
                    stop();
                    break;
                default:
                    await interaction.reply({
                        content: `No valid command specified: '${subcommand}'`,
                        ephemeral: true
                    }).then(() => interaction.deleteReply({timeout: 5000}));
            }
        }
        if (interaction.options._subcommand === 'vidlookup') {
            const tweet_id = interaction.options._hoistedOptions[0].value;

            await interaction.reply({
                content: await videoFetch(tweet_id),
                // threadId: process.env.TWITTER_THREAD_ID
            });
        }
    },
};