const properties = {
    value:"max_heart",
	name:"Max Heart",
    icon:"https://cdn.discordapp.com/attachments/793415946738860072/845617394872614942/latest.png",
    emoji:{
        mascot:"<:m1_mepple:936237021293322290>",
    },
    currency:{
        name:"heartiel points",
        emoji:"<:m1_mepple:936237021293322290>"
    },
    theme:"yin & yang",
    location:{
        name:"Wakaba City",
        icon:"",
    },
}

const teams = {
	icon:"https://cdn.discordapp.com/attachments/793415946738860072/845617394872614942/latest.png",
    special:{
        name:"Extreme Luminario",
        icon:"https://cdn.discordapp.com/attachments/793415946738860072/824146151757578240/image0.png",
    }
}

const monsters = require("../enpack/monsters/Zakenna");

module.exports = {
    properties, teams, monsters
}