const properties = {
    value:"smile",
	name:"Smile",
    icon:"https://cdn.discordapp.com/attachments/793415946738860072/845617680399728690/latest.png",
    logo:"https://cdn.discordapp.com/attachments/793415946738860072/959708445014110208/07_smile.png",
    emoji:{
        mascot:"<:m7_candy:936237023747014726>",
    },
    currency:{
        name:"decor points",
        emoji:"<:m7_candy:936237023747014726>"
    },
    theme:"fairy tales",
    location:{
        name:"Nanairogaoka",
        icon:"https://static.wikia.nocookie.net/prettycure/images/7/74/Nanairoga1.jpg",
    }
}

const teams = {
	icon:"https://cdn.discordapp.com/attachments/793415946738860072/845617680399728690/latest.png",
    special:{
        name:"Royal Rainbow Burst",
        icon:"https://cdn.discordapp.com/attachments/793415946738860072/824151822146207764/image0.png",
    }
}

class Spawner {
    jankenponData = {
        rock:{
            value:"rock",
            icon:"🪨",
            img:"https://i.imgur.com/xvAk8aA.png",
            choiceResults:{//player results
                paper:true,
                scissors:false
            }
        }, 
        paper:{
            value:"paper",
            icon:"📜",
            img:"https://imgur.com/uQtSfqD.png",
            choiceResults:{//player results
                scissors:true,
                rock:false
            }
        },
        scissors:{
            value:"scissors",
            icon:"✂️",
            img:"https://imgur.com/vgqsHN5.png",
            choiceResults:{//player results
                rock:true,
                paper:false
            }
        }
    }
}

module.exports = {
    properties, teams, Spawner
}