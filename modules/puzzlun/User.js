// const stripIndents = require('common-tags/lib/stripIndent');
const dedent = require("dedent-js");
const {MessageEmbed} = require('discord.js');
const DB = require('../../database/DatabaseCore');
const DBConn = require('../../storage/dbconn');
const DiscordStyles = require('../DiscordStyles');
const GlobalFunctions = require('../GlobalFunctions.js');
const capitalize = GlobalFunctions.capitalize;

const paginationEmbed = require('../DiscordPagination');

const Properties = require('./Properties');
const Color = Properties.color;
const Currency = Properties.currency;
const Emoji = Properties.emoji;

const {Badge} = require("./data/Badge");
const User = require("./data/User");
const UserGacha = require("./data/Gacha");
const Gachapon = require("./Gachapon");
const Card = require("./data/Card");
const {Shikishi, ShikishiInventory} = require("./data/Shikishi");
const CardInventory = require("./data/CardInventory");
const {Character} = require("./data/Character");
const {UserQuest, DailyCardQuest} = require("./data/Quest");
const {AvatarFormation, PrecureAvatar} = require("./data/Avatar");

// const CpackModule = require("./Cpack");
const {Series, SPack} = require("./data/Series");

const Embed = require("./Embed");

class Validation extends require("./Validation") {
    
}

class Listener extends require("./data/Listener") {

    async status(){//print user status menu
        var username = this.interaction.options.getString("username");
                
        var userSearchResult = await Validation.User.isAvailable(this.discordUser, username, this.interaction);
        if(!userSearchResult) return; else this.discordUser = userSearchResult;

        var userId = this.discordUser.id;
        //init embed
        var arrPages = []; //prepare paging embed
    
        var user = new User(await User.getData(userId));
        var userLevel = user.getAverageColorLevel();//average color level
        var userQuest = new UserQuest(await UserQuest.getData(userId));
        var userGacha = new UserGacha(await UserGacha.getData(userId));
    
        //init the object
        var objCardInventory = {
            pink:{},
            blue:{},
            yellow:{},
            purple:{},
            red:{},
            green:{},
            white:{}
        };

        var query = `select cd.${Card.columns.pack}, count(inv.${CardInventory.columns.id_user}) as total, 
        cd.${Card.columns.color}, cd.${Card.columns.series} 
        from ${Card.tablename} cd 
        left join ${CardInventory.tablename} inv 
        on cd.${Card.columns.id_card}=inv.${CardInventory.columns.id_card} and 
        inv.${CardInventory.columns.id_user}=? 
        group by cd.${Card.columns.pack}`;
        
        var queryGold = `select cd.${Card.columns.pack}, count(inv.${CardInventory.columns.id_user}) as total_gold, cd.${Card.columns.color}, cd.${Card.columns.series} 
        from ${Card.tablename} cd
        left join ${CardInventory.tablename} inv 
        on cd.${Card.columns.id_card}=inv.${CardInventory.columns.id_card} and 
        inv.${CardInventory.columns.id_user}=? and inv.${CardInventory.columns.is_gold}=1 
        group by cd.${Card.columns.pack}`;

        var cardDataInventory = await DBConn.conn.query(query, [userId]);
        var cardDataInventoryGold = await DBConn.conn.query(queryGold, [userId]);

        for(var i=0;i<cardDataInventory.length;i++){
            var cardInventory = new CardInventory(cardDataInventory[i], cardDataInventory[i]);
            var color = cardInventory.color;
            var pack = cardInventory.pack;
            var pack = cardInventory.pack;
            var packTotal = cardInventory.packTotal;
            cardInventory.addKeyVal("total_gold", cardDataInventoryGold[i].total_gold);

            //set for completion emoji
            cardInventory.addKeyVal("emoji_completion", "");
            if(cardInventory.total>=cardInventory.packTotal){
                cardInventory.getKeyVal("total_gold")>packTotal ?
                cardInventory.addKeyVal("emoji_completion", "☑️") : cardInventory.addKeyVal("emoji_completion", "✅");
            }
            objCardInventory[color][pack] = cardInventory;
        }
    
        //prepare the embed
        //avatar
        var setColor = user.set_color;
        var setSeries = user.set_series;

        var seriesData = new Series(setSeries);
        if(!user.hasLogin()){
            var txtDailyCardQuest = `not checked in yet ❌`;
        } else if(userQuest.DailyCardQuest.getTotal()>1) {
            var txtDailyCardQuest = `${userQuest.DailyCardQuest.getTotal()}/${DailyCardQuest.max}`;
        } else {
            var txtDailyCardQuest = ` completed ✅`;
        }
    
        //prepare the embed
        var txtMainStatus = dedent(`${seriesData.emoji.mascot} **Location:** ${seriesData.location.name} @${seriesData.name}
        ${User.peacePoint.emoji} **${User.peacePoint.name}:** ${user.peace_point}/${User.limit.peacePoint}
        ${Emoji.mofuheart} **Daily card quest:** ${txtDailyCardQuest}

        __**Currency:**__
        ${Currency.mofucoin.emoji} **Mofucoin:** ${user.Currency.mofucoin}/${User.Currency.limit.mofucoin} 
        ${Currency.jewel.emoji} **Jewel:** ${user.Currency.jewel}/${User.Currency.limit.jewel}

        __**Gachapon:**__
        **${capitalize(Gachapon.Daily.name)}:** ${userGacha.hasDailyGacha()? `✅`:`❌`}
        **${capitalize(Gachapon.TropicalCatch.name)}**: ${userGacha.hasTropicalCatchGacha()? `✅`:`❌`}`);

        var author = Embed.builderUser.author(this.discordUser, `${this.discordUser.username} (Lvl. ${userLevel})`);
        var objEmbed = Embed.builder(txtMainStatus, author, {
            title:`${Emoji.mofuheart} Main Status:`,
            color:Embed.color[setColor],
            image:null,
            thumbnail:seriesData.icon,
            fields: [
                {name: dedent(`${Color.pink.emoji} __${capitalize(Color.pink.value)} Lvl. ${user.Color.getLevel(Color.pink.value)}__
                ${user.Color.canLevelUp("pink") ? "🆙":""} ${user.Color.getPoint("pink")} Pts`),
                value: ``, inline:true},

                {name: dedent(`${Color.blue.emoji} __${capitalize(Color.blue.value)} Lvl. ${user.Color.getLevel(Color.blue.value)}__
                ${user.Color.canLevelUp("blue") ? "🆙":""} ${user.Color.getPoint("blue")} Pts`),
                value: ``, inline:true},
                
                {name: dedent(`${Color.yellow.emoji} __${capitalize(Color.yellow.value)} Lvl. ${user.Color.getLevel(Color.yellow.value)}__
                ${user.Color.canLevelUp("yellow") ? "🆙":""} ${user.Color.getPoint("yellow")} Pts`),
                value: ``, inline:true},

                {name: dedent(`${Color.purple.emoji} __${capitalize(Color.purple.value)} Lvl. ${user.Color.getLevel(Color.purple.value)}__
                ${user.Color.canLevelUp("purple") ? "🆙":""} ${user.Color.getPoint("purple")} Pts`),
                value: ``, inline:true},

                {name: dedent(`${Color.red.emoji} __${capitalize(Color.red.value)} Lvl. ${user.Color.getLevel(Color.red.value)}__
                ${user.Color.canLevelUp("red") ? "🆙":""} ${user.Color.getPoint("red")} Pts`),
                value: ``, inline:true},

                {name: dedent(`${Color.green.emoji} __${capitalize(Color.green.value)} Lvl. ${user.Color.getLevel(Color.green.value)}__
                ${user.Color.canLevelUp("green") ? "🆙":""} ${user.Color.getPoint("green")} Pts`),
                value: ``, inline:true},

                {name: dedent(`${Color.white.emoji} __${capitalize(Color.white.value)} Lvl. ${user.Color.getLevel(Color.white.value)}__
                ${user.Color.canLevelUp("white") ? "🆙":""} ${user.Color.getPoint("white")} Pts`),
                value: ``, inline:true},
            ],
            footer:{
                text:`Page 1 / 5 | Daily checked in: ${user.hasLogin() ? `✅`:`❌`} `
            }
        });
    
        var idxColor = 0;
        for(var color in objCardInventory){
            for(var pack in objCardInventory[color]){
                var obj = objCardInventory[color][pack];
                var cardInventory = new CardInventory(obj,obj);
                
                objEmbed.fields[idxColor].value += 
                `${cardInventory.getKeyVal("emoji_completion")} ${GlobalFunctions.capitalize(cardInventory.pack)}: ${cardInventory.total}/${cardInventory.getPackTotal()}\n`;
            }
            idxColor++;
        }
    
        arrPages[0] = new MessageEmbed(objEmbed); //add embed to pages
    
        //======page 2 : series, color effect======
        objEmbed.title = `${Emoji.mofuheart} Main Status`;
        objEmbed.description = ``;
        var arrColor = Object.keys(Color);
        var txtColorEffect = ``;
        for(var key in arrColor){
            let color = arrColor[key];
            txtColorEffect+=`${User.Color.getEmoji(color)} **Lvl ${user.Color.getLevel(color)}**: +${user.Color.getCardCaptureBonus(color)}%\n`;
        }

        //reset fields embed:
        objEmbed.fields = [
            {
                name:`Card capture bonus effect:`,
                value:txtColorEffect
            }
        ];

        objEmbed.footer = null;

        for(var key in SPack){
            let series = new Series(key);
            if(series.value==user.set_series){
                objEmbed.description+=`**${series.emoji.mascot} ${user.Series.getPoint(series.value)}/${User.Series.limit.point} ${series.getCurrencyName()} (${series.name})**\n`;
             }else {
                objEmbed.description+=`${series.emoji.mascot} ${user.Series.getPoint(series.value)}/${User.Series.limit.point} ${series.getCurrencyName()} (${series.name})\n`;
            }
        }
        
        arrPages[1] = new MessageEmbed(objEmbed); //add embed to pages
    
        //======page 3: duplicate card======
        objEmbed.title = `Status - Duplicate Card:`;
        objEmbed.description = ``;
        objEmbed.fields = [
            { name: `${Color.pink.emoji_card} __Pink:__`, value: ``, inline: true}, 
            { name: `${Color.blue.emoji_card} __Blue:__`, value: ``, inline: true},
            { name: `${Color.yellow.emoji_card} __Yellow:__`, value: ``, inline: true}, 
            { name: `${Color.purple.emoji_card} __Purple:__`, value: ``, inline: true },
            { name: `${Color.red.emoji_card} __Red:__`, value: ``, inline: true }, 
            { name: `${Color.green.emoji_card} __Green:__`, value: ``, inline: true },
            { name: `${Color.white.emoji_card} __White:__`, value: ``, inline: true }
        ];

        var queryDuplicate = `select cd.${Card.columns.pack}, sum(inv.${CardInventory.columns.stock}) as total, 
        cd. ${Card.columns.color}
        from ${Card.tablename} cd
        left join ${CardInventory.tablename} inv
        on cd.${Card.columns.id_card}=inv.${CardInventory.columns.id_card} and
        inv.${CardInventory.columns.id_user}=? and
        inv.${CardInventory.columns.stock}>=1
        where inv.${CardInventory.columns.stock}>=1 
        group by cd.${Card.columns.pack}`;
    
        var cardDataInventory = await DBConn.conn.query(queryDuplicate, [this.discordUser.id]);
        //reassign total into duplicate total
        for(var i=0;i<cardDataInventory.length;i++){
            var pack = cardDataInventory[i][Card.columns.pack];
            var color = cardDataInventory[i][Card.columns.color];
            var objData = objCardInventory[color][pack];

            var cardInventory = new CardInventory(objData,objData);
            cardInventory.addKeyVal("total",cardDataInventory[i].total);
            objCardInventory[color][pack] = cardInventory; //reassign object
        }

        //print embed of normal card duplicate
        var idxColor = 0;
        for(var color in objCardInventory){
            for(var pack in objCardInventory[color]){
                var obj = objCardInventory[color][pack];
                var cardInventory = new CardInventory(obj,obj);
                
                objEmbed.fields[idxColor].value += 
                `${cardInventory.getKeyVal("emoji_completion")} ${GlobalFunctions.capitalize(cardInventory.pack)}: ${cardInventory.getKeyVal("total")}/${CardInventory.limit.card*3}\n`;
            }
            idxColor++;
        }
    
        arrPages[2] = new MessageEmbed(objEmbed); //add embed to pages
    
        //======page 4: gold card======
        objEmbed.title = `Status - Gold Card:`;
        objEmbed.fields = [
            { name: `${Color.pink.emoji_card} __Pink:__`, value: ``, inline: true}, 
            { name: `${Color.blue.emoji_card} __Blue:__`, value: ``, inline: true},
            { name: `${Color.yellow.emoji_card} __Yellow:__`, value: ``, inline: true}, 
            { name: `${Color.purple.emoji_card} __Purple:__`, value: ``, inline: true },
            { name: `${Color.red.emoji_card} __Red:__`, value: ``, inline: true }, 
            { name: `${Color.green.emoji_card} __Green:__`, value: ``, inline: true },
            { name: `${Color.white.emoji_card} __White:__`, value: ``, inline: true }
        ];
    
        //print embed of normal card duplicate
        var idxColor = 0;
        for(var color in objCardInventory){
            for(var pack in objCardInventory[color]){
                var obj = objCardInventory[color][pack];
                var cardInventory = new CardInventory(obj, obj);
                
                objEmbed.fields[idxColor].value += 
                `${cardInventory.getKeyVal("emoji_completion")} ${GlobalFunctions.capitalize(cardInventory.pack)}: ${cardInventory.getKeyVal("total_gold")}/${cardInventory.packTotal}\n`;
            }
            idxColor++;
        }
    
        arrPages[3] = new MessageEmbed(objEmbed); //add embed to pages

        //======page 5: avatar======
        var avatarFormation = new AvatarFormation(await AvatarFormation.getData(userId));

        var arrFields = [
            {name:`**${capitalize(AvatarFormation.formation.main.name)}:**`, value:`:x: ${capitalize(AvatarFormation.formation.main.name)} precure avatar has not set yet.`},
            // {name:`**${capitalize(AvatarFormation.formation.support1.name)}:**`, value:`:x: ${capitalize(AvatarFormation.formation.support1.name)} precure avatar has not set yet.`},
            // {name:`**${capitalize(AvatarFormation.formation.support2.name)}:**`, value:`:x: ${capitalize(AvatarFormation.formation.support2.name)} precure avatar has not set yet.`},
        ];

        var idx = 0;
        for(var key in AvatarFormation.formation){
            var formation = AvatarFormation.formation[key];

            if(avatarFormation[formation.columns]!=null){
                var avatar = new PrecureAvatar(key, 
                    await CardInventory.getDataByIdUser(userId, avatarFormation[formation.columns]),
                    await Card.getCardData(avatarFormation[formation.columns]));
                var rarity = avatar.cardInventory.rarity;
                arrFields[idx].name = `${avatar.cardInventory.getRarityEmoji()} ${rarity} ${avatar.properties.name} Lvl. ${avatar.parameter.level} (**${capitalize(avatar.formation.name)}**)`;
                arrFields[idx].value =  `${CardInventory.emoji.hp}**Hp:** ${avatar.parameter.maxHp} ${CardInventory.emoji.atk} **Atk:** ${avatar.parameter.atk} ${CardInventory.emoji.sp}**Sp:** ${avatar.parameter.maxSp}`;

                if(formation.value=="main"){
                    var embedColor = avatar.cardInventory.color;
                    var embedThumbnail = avatar.properties.icon;
                }
            }

            idx++;
        }

        arrPages[4] = new MessageEmbed(
            Embed.builder(``,
            this.discordUser,
            {
                color: avatarFormation.id_main!=null? embedColor:setColor,
                title: `Precure Avatar:`,
                thumbnail: avatarFormation.id_main!=null? embedThumbnail:``,
                fields: arrFields
            })
        ); //add embed to pages

        paginationEmbed(this.interaction,arrPages,DiscordStyles.Button.pagingButtonList, username==null?true:false);
    }

    async levelUpColor(){//level up color
        var colorSelection = this.interaction.options.getString("selection");
        var user = new User(await User.getData(this.userId));
        var costPoint = user.Color.getNextLevelPoint(colorSelection);
        var nextLevel = user.Color[colorSelection].level+1;

        if(!user.Color.canLevelUp(colorSelection)){//validation: not enough color points
            return this.interaction.reply(
                Embed.errorMini(`${User.Color.getEmoji(colorSelection)} ${costPoint} ${colorSelection} points are required to level up into ${nextLevel}`, this.discordUser, true, {
                    title:`❌ Not enough ${colorSelection} points`
                })
            );
        }
        
        user.Color[colorSelection].point-=costPoint;
        user.Color[colorSelection].level+=1;
        await user.update();

        var costPoint = user.Color.getNextLevelPoint(colorSelection);//reassign level point

        var colorEmoji = User.Color.getEmoji(colorSelection);
        return this.interaction.reply({
            embeds:[
                Embed.builder(`Your ${colorEmoji} **${colorSelection}** color is now level **${user.Color[colorSelection].level}**!`, this.discordUser, {
                    color: colorSelection,
                    title: `🆙 ${capitalize(colorSelection)} color leveled up!`,
                    thumbnail: Properties.imgSet.mofu.ok,
                    fields:[
                        {
                            name:`Base ${colorSelection} capture bonus:`,
                            value:`${Color[colorSelection].emoji_card} +${user.Color.getCardCaptureBonus(colorSelection)}% chance`,
                        },
                        {
                            name:`Next level with:`,
                            value:`${colorEmoji} ${costPoint} ${colorSelection} points`,
                        }
                    ]
                })
            ]}
        );
    }

    async setAvatar(){
        var cardId = this.interaction.options.getString("card-id");//get card id
        var formation = this.interaction.options.getString("formation")!==null? 
            this.interaction.options.getString("formation"): AvatarFormation.formation.main.value;
        var isPrivate =  this.interaction.options.getBoolean("visible-public")!==null? 
            this.interaction.options.getBoolean("visible-public"): false;

        var user = new User(await User.getData(this.userId));
        
        //validation: if card exists
        var cardInventoryData = await CardInventory.getJoinUserData(this.userId, cardId);
        if(cardInventoryData==null) return this.interaction.reply(Validation.Card.embedNotFound(this.discordUser));
        
        //validation: if user have card
        if(cardInventoryData.cardInventoryData==null) return this.interaction.reply(Validation.Card.embedNotHave(this.discordUser));

        var card = new CardInventory(cardInventoryData.cardInventoryData, cardInventoryData.cardData);
        var series = card.Series;
        var rarity = card.rarity;
        var character = card.Character;
        //validation color & series points
        var cost = {
            color:AvatarFormation.setCost.color(rarity),
            series:AvatarFormation.setCost.series(rarity)
        }

        var avatarFormation = new AvatarFormation(await AvatarFormation.getData(this.userId));
        if(!avatarFormation.isMainAvailable()&&formation!=AvatarFormation.formation.main.value){
            return this.interaction.reply(
                Embed.errorMini(`Cannot assign into this formation when **${AvatarFormation.formation.main.name}** formation is not assigned yet.`,
                this.discordUser, true,{
                    title:`❌ Main formation need to be assigned`
                })
            );
        }

        //validation: check for same avatar on any formation
        for(var key in AvatarFormation.formation){
            var formationList = AvatarFormation.formation[key];
            var formName = formationList.name;

            if(avatarFormation.getCardByFormation(key)==card.id_card){
                return this.interaction.reply(
                    Embed.errorMini(`This precure already assigned in **${formName}** formation`,this.discordUser, true,{
                        title:`❌ This card already assigned`
                    })
                );
            }

        }

        //check if formation is empty/not
        if(!avatarFormation.isAvailable(formation)){
            //validation color & series points
            if(user.getColorPoint(card.color)<cost.color||
            user.getSeriesPoint(card.series)<cost.series){
                return this.interaction.reply(
                    Embed.errorMini(`You need more color & series points to assign: **${card.getRarityEmoji()}${rarity} ${card.id_card} - ${card.getName(15)}** as precure avatar.`,this.discordUser, true,{
                        title:`❌ Not enough color/series points`,
                        fields:[
                            {
                                name:`${card.getRarityEmoji()}${rarity} points requirement:`,
                                value:dedent(`${card.getColorEmoji()} ${cost.color} ${card.color} points
                                ${series.currency.emoji} ${cost.series} ${card.Series.getCurrencyName()}`)
                            }
                        ],
                        footer:Embed.builderUser.footer(this.discordUser.username, Embed.builderUser.getAvatarUrl(this.discordUser))
                    })
                );
            }

            //update user color & series points:
            user.Color[card.color].point-=cost.color;
            user.Series[card.series]-=cost.series;
            await user.update();
        }

        //update the precure avatar:
        avatarFormation.setCardFormation(cardId, formation);
        await avatarFormation.update();

        var precureAvatar = new PrecureAvatar(formation, cardInventoryData.cardInventoryData, cardInventoryData.cardData);
        return this.interaction.reply({embeds:[
            Embed.builder(dedent(`*"${precureAvatar.properties.transform_quotes2}"*
        
            ${Emoji.mofuheart} <@${this.userId}> has assign **${precureAvatar.properties.name}** as **${precureAvatar.formation.name}** precure avatar!
            
            **${card.getRarityEmoji()}${card.rarity} - Level:** ${card.level}/${card.getMaxLevel()}
            ─────────────────
            ${CardInventory.emoji.hp} **Hp:** ${card.maxHp} | ${CardInventory.emoji.atk} **Atk:** ${card.atk} | ${CardInventory.emoji.sp} **Sp:** ${card.maxSp}        
            💖 **Special:** ${character.specialAttack} Lv.${card.level_special}
            
            __**Passive Skill:**__`),
                Embed.builderUser.authorCustom(`⭐${rarity} ${precureAvatar.character.alter_ego}`, precureAvatar.character.icon),{
                    color: precureAvatar.character.color,
                    thumbnail: precureAvatar.cardInventory.getImgDisplay(),
                    title: precureAvatar.properties.transform_quotes1,
                    image: precureAvatar.properties.img_transformation
                }
            )
        ], ephemeral: isPrivate});
    }

    async setColor(){
        var selection = this.interaction.options.getString("change");
        var user = new User(await User.getData(this.userId));
        var setCost = 100;
        var userColor = Color[user.set_color];
        var color = Color[selection];
        
        if(user.set_color==selection){
            //validation: same color
            return this.interaction.reply(
                Embed.errorMini(`You've already assigned in ${userColor.emoji} **${userColor.value}** color`, this.discordUser, true, {
                    title:`❌ Same color`
                })
            );
        } else if(user.Color[user.set_color].point<=setCost){
            //validation: color point
            return this.interaction.reply(
                Embed.errorMini(`**${userColor.emoji} ${setCost} ${userColor.value} points** are required to change your color assignment into: **${color.emoji} ${color.value}**`,this.discordUser, true,{
                    title:`❌ Not enough ${userColor.value} points`
                })
            );
        }

        user.Color.modifPoint(user.set_color, -setCost);
        user.set_color = selection;
        await user.update();

        return this.interaction.reply({embeds:[
            Embed.builder(`${Properties.emoji.mofuheart} Your color has been changed into: **${color.emoji} ${color.value}**`, this.discordUser, {
                color:user.set_color,
                title:`Color changed!`,
                thumbnail:Properties.imgSet.mofu.ok
            })
        ]});
    }

    async setSeries(){
        var selection = this.interaction.options.getString("location");
        var user = new User(await User.getData(this.userId));
        var setCost = 100;
        var userSeries = new Series(user.set_series);
        var series = new Series(selection);
        if(user.set_series==selection){
            return this.interaction.reply(
                Embed.errorMini(`You've already assigned in **${userSeries.emoji.mascot} ${userSeries.location.name} @${userSeries.name}**`, this.discordUser, true, {
                    title:`❌ Same Location`
                })
            );
        } else if(user.Series[user.set_series]<setCost){
            //validation: series point
            return this.interaction.reply(
                Embed.errorMini(`You need **${userSeries.emoji.mascot} ${setCost} ${userSeries.currency.name}** to teleport into: **${series.location.name} @${series.name}**`,this.discordUser, true,{
                    title:`❌ Not enough series points`
                })
            );
        }

        user.Series.modifPoint(userSeries.value, -setCost);
        user.set_series = series.value;
        await user.update();

        return this.interaction.reply({embeds:[
            Embed.builder(`${Properties.emoji.mofuheart} You have successfully teleported into: **${series.location.name} @${series.name}**`, this.discordUser, {
                color:user.set_color,
                title:`${series.emoji.mascot} Welcome to: ${series.location.name}!`,
                thumbnail:series.location.icon,
                footer:Embed.builderUser.footer(`${await User.getUserTotalByLocation(selection)} other user are available in this location`)
            })
        ]});
    }

    async unsetAvatar(){
        var formation = this.interaction.options.getString("formation");
        var user = new User(await User.getData(this.userId));
        var avatarFormation = new AvatarFormation(await AvatarFormation.getData(this.userId));
        //validation if all:
        if(formation=="all"){
            var arrFormation = Object.keys(AvatarFormation.formation);
            var found = false;
            for(var key in arrFormation){
                var formation = arrFormation[key];
                if(avatarFormation.isAvailable(formation)){
                    found = true;
                    
                }
            }
            // for(var key in arrFormation){
            //     var val = arrFormation[key];
            //     if(avatarFormation.getCardFormation(formation))
            // }
            
        }
        
    }

    async viewBadge(){
        var username = this.interaction.options.getString("username");
                
        var userSearchResult = await Validation.User.isAvailable(this.discordUser, username, this.interaction);
        if(!userSearchResult) return; else this.discordUser = userSearchResult;

        var userId = this.discordUser.id;

        var badge = new Badge(await Badge.getUserData(userId));
        
        return this.interaction.reply({embeds:[
            Embed.builder(dedent(`**About:**
            `), 
            this.discordUser, {
                color:badge.color,
                thumbnail:`https://cdn.discordapp.com/attachments/795299749745131560/959698873444618330/01_maxheart.png`,
                fields:[
                    {
                        name:`Favorite series:`,
                        value:`${badge.Series.getMascotEmoji()} ${badge.Series.name}`
                    },
                    {
                        name:`Favorite character:`,
                        value:`${badge.Character.name}`
                    }
                ],
                image:badge.img_cover
            })
        ]});
    }

    async editBadge(){
        var badge = new Badge(await Badge.getUserData(this.userId));

        var newNickname = this.interaction.options.getString("nickname");
        var newAbout = this.interaction.options.getString("about");
        var newShikishiId = this.interaction.options.getString("set-shikishi-cover");

        var newFavSeries = this.interaction.options.getString("favorite-series")!==null?
            badge.setFavoriteSeries(this.interaction.options.getString("favorite-series")):null;

        var newFavCharacter = this.interaction.options.getString("favorite-character");

        var newColor = this.interaction.options.getString("color")!==null? 
            badge.color = this.interaction.options.getString("color"):null;

        if(newNickname==null&&newFavSeries==null&&newColor==null&&
            newFavCharacter==null&&newAbout==null&&newShikishiId==null){//validation: no given parameter 
            return this.interaction.reply(
                Embed.errorMini(`Please enter the badge section that you want to edit`, this.discordUser, true, {
                    title:`❌ Missing parameter`
                })
            );
        }

        if(newNickname!==null){//validation: nickname
            if(newNickname.length>20){
                return this.interaction.reply(
                    Embed.errorMini(`Please re-enter with shorter nickname`, this.discordUser, true, {
                        title:`❌ Invalid nickname`
                    })
                );
            } else {
                badge.nickname = newNickname;
            }
        }

        if(newAbout!==null){//validation: about
            if(newAbout.length>60){
                return this.interaction.reply(
                    Embed.errorMini(`Please re-enter with shorter about`, this.discordUser, true, {
                        title:`❌ Invalid about`
                    })
                );
            } else {
                badge.about = newAbout;
            }
        }

        if(newShikishiId!==null){//validation: shikishi
            var shikishiDataInventory = await ShikishiInventory.getShikishiInventoryDataById(this.userId, newShikishiId);
            if(shikishiDataInventory==null) {
                return this.interaction.reply(
                    Embed.errorMini(`I cannot find that shikishi id.`,this.discordUser, true, {
                        title:`❌ Shikishi not found`
                    })
                );
            } else if(shikishiDataInventory.shikishiInventoryData==null) { //validation: if user have shikishi
                return this.interaction.reply(
                    Embed.errorMini(`You don't have this shikishi yet.`,this.discordUser, true, {
                        title:`❌ Shikishi not owned`
                    })
                );
            } else {
                var shikishi = new ShikishiInventory(shikishiDataInventory.shikishiInventoryData, shikishiDataInventory.shikishiData);
                badge.img_cover = shikishi.img_url;
            }
        }

        if(newFavCharacter!==null){//validation: cheracter
            if(!Validation.Pack.isAvailable(newFavCharacter)){
                return this.interaction.reply(Validation.Pack.embedNotFound(this.discordUser));
            } else {
                badge.setFavoriteCharacter(newFavCharacter);
            }  
        }

        await this.interaction.reply(Embed.successMini(`Your precure badge has successfully updated`, this.discordUser, true, {
            title:`✅ Precure badge updated`
        }));

        await badge.update();
    }

    async removeBadgeSection(){
        var badge = new Badge(await Badge.getUserData(this.userId));

        var choice = this.interaction.options.getString("section");
        switch(choice){
            case "nickname":{
                badge.nickname=null;
                break;
            }
            case "about":{
                badge.about=null;
                break;
            }
            case "shikishi-cover":{
                badge.img_cover=null;
                break;
            }
        }

        await this.interaction.reply(Embed.successMini(`Your precure badge has successfully updated`, this.discordUser, true, {
            title:`✅ Precure badge updated`
        }));

        await badge.update();
    }

}

module.exports = Listener